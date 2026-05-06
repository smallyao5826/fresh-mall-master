package com.orion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.orion.mapper.*;
import com.orion.pojo.*;
import com.orion.pojo.dto.CartItemDTO;
import com.orion.pojo.dto.ShippingDTO;
import com.orion.pojo.dto.UnifiedOrderDTO;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.pojo.vo.OrderVO;
import com.orion.service.OrderService;
import com.orion.utils.ThreadLocalUtil;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class OrderServiceImpl extends ServiceImpl<OrderMapper, Order>
        implements OrderService {

    @Autowired
    private OrderMapper orderMapper;
    @Autowired
    private OrderDetailMapper orderDetailMapper;
    @Autowired
    private FreshMapper freshMapper;
    @Autowired
    private AddressMapper addressMapper;
    @Autowired
    private CartMapper cartMapper;
    @Autowired
    private LogisticsMapper logisticsMapper;
    @Autowired
    private LogisticsHistoryMapper logisticsHistoryMapper;
    @Autowired
    private AlipayService alipayService;

    @Transactional(rollbackFor = Exception.class)
    @Override
    public Result<String> createOrder(UnifiedOrderDTO orderDTO) {
        Map<String, Object> claims = ThreadLocalUtil.get();
        Integer userId = (Integer) claims.get("id");

        // 1.地址校验
        Address address = addressMapper.selectById(orderDTO.getAddressID());
        if (address == null || !address.getUserId().equals(userId)) {
            return Result.error("地址校验失败");
        }

        // 2.获取商品最新价格并校验库存
        List<CartItemDTO> validItems = validateItems(orderDTO.getFreshList());
        if (validItems.isEmpty()) {
            return Result.error("商品信息不合法");
        }

        // 3.计算商品总金额
        BigDecimal itemTotal = calculateItemTotal(validItems);

        // 4.计算运费（独立验证逻辑）
        BigDecimal shippingFee = calculateShippingFee(validItems);

        // 5.总金额校验（商品金额 + 运费）
        BigDecimal backendTotal = itemTotal.add(shippingFee)
                .setScale(2, RoundingMode.HALF_EVEN);
        BigDecimal frontendTotal = orderDTO.getSumMoney()
                .setScale(2, RoundingMode.HALF_EVEN);

        if (backendTotal.compareTo(frontendTotal) != 0) {
            return Result.error("金额校验失败");
        }

        // 6.创建订单
        Order order = buildOrder(orderDTO, userId, itemTotal, shippingFee);
        orderMapper.insert(order);

        /*// 7.创建明细
        createOrderDetails(order.getOrderId(), validItems);

        // 8.清理购物车
        if (orderDTO.getIsCartOrder()) {
            clearCartItems(userId, validItems);
        }
        return Result.success(order.getOrderNumber());
        */

        // 7.生成支付信息
        try {
            String paymentForm = alipayService.createPayment(
                    order.getOrderNumber(),
                    order.getSumPrices()
            );

            // 8.创建明细
            createOrderDetails(order.getOrderId(), validItems);

            // 9.清理购物车
            if (orderDTO.getIsCartOrder()) {
                clearCartItems(userId, validItems);
            }

            return Result.success(paymentForm); // 返回支付表单

        } catch (Exception e) {
            log.error("支付请求生成失败", e);
            throw new RuntimeException("支付系统繁忙");
        }


    }

    //--- 核心校验方法 ---
    private List<CartItemDTO> validateItems(List<CartItemDTO> items) {
        return items.stream()
                .filter(item -> {
                    Fresh fresh = freshMapper.selectById(item.getFreshId());
                    if (fresh == null || fresh.getIsDeleted()) return false;
                    if (item.getPurchaseCount() > fresh.getRepertory()) return false;
                    return true;
                })
                .collect(Collectors.toList());
    }

    private BigDecimal calculateItemTotal(List<CartItemDTO> items) {
        return items.stream()
                .map(item -> {
                    Fresh fresh = freshMapper.selectById(item.getFreshId());
                    BigDecimal price = Optional.ofNullable(fresh.getPromotionPrice())
                            .orElse(fresh.getPrices());
                    return price.multiply(BigDecimal.valueOf(item.getPurchaseCount()));
                })
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .setScale(2, RoundingMode.HALF_EVEN);
    }

    private BigDecimal calculateShippingFee(List<CartItemDTO> items) {
        boolean hasColdChain = items.stream()
                .map(item -> freshMapper.selectById(item.getFreshId()))
                .anyMatch(fresh -> fresh.getCategoryId() <= 5);

        // 运费策略：基础运费12元，冷链附加8元
        return hasColdChain ?
                new BigDecimal("20.00") :   // 12 + 8
                new BigDecimal("12.00");
    }

    //--- 订单构建方法 ---
    private Order buildOrder(UnifiedOrderDTO dto, Integer userId,
                             BigDecimal itemTotal, BigDecimal shippingFee) {
        return new Order()
                .setOrderNumber(generateOrderNo())
                .setUserId(userId)
                .setAddressId(dto.getAddressID())
                .setShippingFee(shippingFee)     // 运费（含冷链）
                .setSumPrices(itemTotal.add(shippingFee)) // 总金额
                .setPaymentMethod(dto.getPaymentMethod())
                .setRemark(dto.getRemark())
                .setStatus("待发货")
                .setCreateTime(LocalDateTime.now());
    }


    private BigDecimal processInventoryCheck(List<CartItemDTO> items) {
        BigDecimal total = BigDecimal.ZERO;
        for (CartItemDTO item : items) {
            Fresh fresh = freshMapper.selectById(item.getFreshId());
            BigDecimal price = Optional.ofNullable(fresh.getPromotionPrice())
                    .orElse(fresh.getPrices());
            // 统一保留2位小数，使用银行家舍入法
            price = price.setScale(2, RoundingMode.HALF_EVEN); // 关键修改点
            total = total.add(price.multiply(BigDecimal.valueOf(item.getPurchaseCount())));
        }
        return total.setScale(2, RoundingMode.HALF_EVEN); // 最终结果也保留2位小数
    }

    private Order generateOrder(UnifiedOrderDTO dto, Integer userId, BigDecimal amount, BigDecimal shippingFee) {
        return new Order()
                .setOrderNumber(generateOrderNo())
                .setUserId(userId)
                .setAddressId(dto.getAddressID())
                .setSumPrices(amount)
                .setShippingFee(shippingFee)
                .setPaymentMethod(dto.getPaymentMethod())
                .setRemark(dto.getRemark())
                .setStatus("待发货")
                .setCreateTime(LocalDateTime.now());
    }

    private void createOrderDetails(Integer orderId, List<CartItemDTO> items) {
        items.forEach(item -> {
            OrderDetail detail = new OrderDetail()
                    .setOrderId(orderId)
                    .setFreshId(item.getFreshId())
                    .setCount(item.getPurchaseCount())
                    .setCreateTime(LocalDateTime.now());
            orderDetailMapper.insert(detail);
        });
    }

    private void clearCartItems(Integer userId, List<CartItemDTO> items) {
        List<Integer> freshIds = items.stream()
                .map(CartItemDTO::getFreshId)
                .collect(Collectors.toList());

        LambdaQueryWrapper<Cart> query = new LambdaQueryWrapper<Cart>()
                .eq(Cart::getUserId, userId)
                .in(Cart::getFreshId, freshIds);
        cartMapper.delete(query);
    }

    private String generateOrderNo() {
        return new SimpleDateFormat("yyyyMMddHHmmss")
                .format(new Date()) +
                String.format("%06d", new Random().nextInt(999999));
    }
    @Override
    public Result<PageBean<OrderVO>> getUserOrders(Integer userId, Integer pageNumber, Integer pageSize, String search) {
        Page<OrderVO> page = new Page<>(pageNumber, pageSize);
        List<OrderVO> orderVOS = orderMapper.selectOrderVOs(page, userId, search);

        // MyBatis自动完成嵌套映射，无需手动处理
        return Result.success(new PageBean<>(
                page.getCurrent(),
                page.getSize(),
                page.getTotal(),
                orderVOS != null ? orderVOS : Collections.emptyList()
        ));
    }


    @Override
    public Result<PageBean<OrderVO>> getAll(Integer pageNumber, Integer pageSize, String search, String status) {
        // 计算偏移量
        Long offset = (long) (pageNumber - 1) * pageSize;

        // 查询总数
        Long total = orderMapper.queryOrdersCount(search, status);

        // 查询分页数据
        List<OrderVO> orderVOS = orderMapper.queryOrders(offset, (long)pageSize, search, status);

        return Result.success(new PageBean<>(
                pageNumber,
                pageSize,
                total,
                orderVOS
        ));
    }

    @Override
    public Result<OrderVO> getOrderDetail(String orderNumber, Integer userId) {
        // 1. 查询订单基本信息
        Order order = lambdaQuery()
                .eq(Order::getOrderNumber, orderNumber)
                .eq(Order::getIsDeleted, false)
                .one();

        // 2. 权限校验
        if (order == null || !order.getUserId().equals(userId)) {
            return Result.error("订单不存在或没有查看权限");
        }

        // 3. 查询完整订单VO数据
        OrderVO orderVO = orderMapper.selectOrderDetailByNumber(orderNumber,userId);

        if (orderVO == null) {
            return Result.error("订单详情获取失败");
        }

        return Result.success(orderVO);
    }

    @Transactional
    @Override
    public Result shipOrder(ShippingDTO shippingDTO) {
        // 1. 获取完整订单信息
        Order order = orderMapper.selectByOrderNumber(shippingDTO.getOrderNumber());


        // 2. 创建物流主记录
        Logistics logistics = new Logistics()
                .setOrderNumber(shippingDTO.getOrderNumber())
                .setCompany(shippingDTO.getCompany())
                .setType(shippingDTO.getType())
                .setTrackingNumber(shippingDTO.getTrackingNumber())
                .setStatus("已发货")
                .setCreateTime(LocalDateTime.now());
        logisticsMapper.insert(logistics);

        // 3. 创建初始物流历史（冷链记录温度）
        LogisticsHistory history = new LogisticsHistory()
                .setLogisticsId(logistics.getId())
                .setStatus("已发货")
                .setEventTime(LocalDateTime.now());
        if ("cold".equals(shippingDTO.getType())) {
            history.setTemperature(new BigDecimal("4.5")); // 模拟冷链初始温度
        }
        logisticsHistoryMapper.insert(history);

        // 4. 更新订单状态
        order.setStatus("待收货");
        order.setUpdateTime(LocalDateTime.now());
        orderMapper.updateById(order);

        // 5. 启动物流状态模拟
      /*  startLogisticsSimulation(logistics);*/

        return Result.success("发货成功");
    }

    @Override
    @Transactional
    public void updateOrderStatus(String orderNumber, String status) {
        LambdaUpdateWrapper<Order> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Order::getOrderNumber, orderNumber)
                .set(Order::getStatus, status)
                .set(Order::getUpdateTime, LocalDateTime.now());

        if ("已支付".equals(status)) {
            wrapper.set(Order::getPaymentTime, LocalDateTime.now());
        }

        orderMapper.update(null, wrapper);
    }


    @Transactional
    @Override
    public Result<String> deleteOrder(String userId, String orderNumber) {
        Order order = lambdaQuery()
                .eq(Order::getOrderNumber, orderNumber)
                .eq(Order::getUserId, userId)
                .one();

        if (order == null) {
            return Result.error("订单不存在或权限不足");
        }

        if (!"已完成".equals(order.getStatus())) {
            return Result.error("仅允许删除已完成订单");
        }

        boolean success = lambdaUpdate()
                .set(Order::getIsDeleted, true)
                .eq(Order::getOrderId, order.getOrderId())
                .update();

        return success ? Result.success("删除成功") : Result.error("删除失败");
    }
}



