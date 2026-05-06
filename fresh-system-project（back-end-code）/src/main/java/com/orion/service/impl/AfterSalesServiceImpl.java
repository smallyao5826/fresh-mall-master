package com.orion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.orion.mapper.AfterSalesMapper;
import com.orion.mapper.OrderMapper;
import com.orion.pojo.AfterSales;
import com.orion.pojo.Order;
import com.orion.pojo.dto.AdminAfterSalesQueryDTO;
import com.orion.pojo.dto.AfterSalesApplyDTO;
import com.orion.pojo.dto.AfterSalesProcessDTO;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.pojo.vo.AfterSalesVO;
import com.orion.service.AfterSalesService;
import com.orion.utils.ThreadLocalUtil;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class AfterSalesServiceImpl implements AfterSalesService {

    private final AfterSalesMapper afterSalesMapper;
    private final OrderMapper orderMapper;

    public AfterSalesServiceImpl(AfterSalesMapper afterSalesMapper, OrderMapper orderMapper) {
        this.afterSalesMapper = afterSalesMapper;
        this.orderMapper = orderMapper;
    }

    @Override
    @Transactional
    public Result<String> submitApply(AfterSalesApplyDTO applyDTO) {
        // 1. 获取当前用户ID
        Map<String, Object> claims = ThreadLocalUtil.get();
        Integer userId = (Integer) claims.get("id");

        // 2. 查询订单信息
        Order order = orderMapper.selectOne(new LambdaQueryWrapper<Order>()
                .eq(Order::getOrderNumber, applyDTO.getOrderNumber()));
        if (order == null) {
            return Result.error("订单不存在");
        }

        // 3. 校验订单所属
        if (!order.getUserId().equals(userId)) {
            return Result.error("无权操作此订单");
        }

        // 4. 校验订单状态（示例：仅允许已完成订单申请售后）
        if (!"已完成".equals(order.getStatus())) {
            return Result.error("当前订单状态不允许申请售后");
        }

        // 5. 创建售后记录
        AfterSales afterSales = new AfterSales();
        BeanUtils.copyProperties(applyDTO, afterSales);
        afterSales.setOrderId(order.getOrderId());
        afterSales.setUserId(userId);
        afterSales.setStatus("待处理");
        afterSales.setApplyTime(LocalDateTime.now());

        int insert = afterSalesMapper.insert(afterSales);
        return insert > 0 ? 
            Result.success("申请提交成功") : 
            Result.error("申请提交失败");
    }

    @Override
    @Transactional(readOnly = true)
    public Result<PageBean<AfterSalesVO>> getAfterSalesList(AdminAfterSalesQueryDTO queryDTO) {
        try {
            PageHelper.startPage(queryDTO.getPage(), queryDTO.getPageSize());

            // 使用自定义查询
            List<AfterSalesVO> list = afterSalesMapper.selectAfterSalesWithOrder(queryDTO);
            PageInfo<AfterSalesVO> pageInfo = new PageInfo<>(list);

            return Result.success(new PageBean<>(pageInfo));
        } catch (NumberFormatException e) {
            return Result.error("用户ID格式错误");
        } catch (Exception e) {
            return Result.error("查询失败");
        }
    }


    @Override
    @Transactional
    public Result<String> processAfterSales(AfterSalesProcessDTO processDTO) {
        // 1. 查询售后记录
        AfterSales afterSales = afterSalesMapper.selectById(processDTO.getId());
        if (afterSales == null) {
            return Result.error("售后记录不存在");
        }

        // 2. 校验状态
        if (!"待处理".equals(afterSales.getStatus())) {
            return Result.error("该申请已处理，不可重复操作");
        }

        // 3. 构建更新实体（严格使用实体类字段）
        AfterSales updateEntity = new AfterSales();
        updateEntity.setId(processDTO.getId());
        updateEntity.setStatus("已处理");
        updateEntity.setProcessResult("通过".equals(processDTO.getProcessResult()) ? "已通过" : "已拒绝");  // 对应实体类processResult字段
        updateEntity.setProcessComment(processDTO.getProcessComment()); // 对应实体类processComment字段
        updateEntity.setProcessTime(LocalDateTime.now());  // 对应实体类processTime字段

        // 4. 执行更新
        int update = afterSalesMapper.updateById(updateEntity);
        if (update < 1) {
            throw new RuntimeException("更新售后记录失败");
        }

        // 5. 关联订单处理（可选）
        Order order = orderMapper.selectById(afterSales.getOrderId());
        if (order != null) {
            order.setStatus("已通过".equals(updateEntity.getStatus()) ? "售后处理中" : order.getStatus());
            orderMapper.updateById(order);
        }

        return Result.success("处理成功");
    }
}