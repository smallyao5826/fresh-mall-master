package com.orion.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.orion.pojo.Fresh;
import com.orion.pojo.Order;
import com.orion.pojo.User;
import com.orion.pojo.dto.CartOrderDTO;
import com.orion.pojo.dto.ShippingDTO;
import com.orion.pojo.dto.UnifiedOrderDTO;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.pojo.vo.OrderVO;
import com.orion.service.FreshService;
import com.orion.service.OrderDetailService;
import com.orion.service.OrderService;
import com.orion.service.UserService;
import com.orion.utils.ThreadLocalUtil;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;
import java.util.Map;

/*
 * @Description TODO 订单管理
 * @Date 2024/10/20 10:35
 * @Author Orion
 **/
@RestController //将此类对象放入ioc容器、直接返回数据给前端不走视图解析器
@RequestMapping("order")
@CrossOrigin(originPatterns = {"http://*:5173"}, maxAge = 3600L)  //允许端口号为5173的源浏览器器访问
@Validated //使handler方法参数前的效验注解生效
public class OrderController {
    @Autowired
    private OrderService orderService;

    @Autowired
    private OrderDetailService orderDetailService;

    // 创建订单
    @PostMapping("/create")
    public Result<String> createOrder(
            @RequestBody @Valid UnifiedOrderDTO orderDTO
    ) {
        return orderService.createOrder(orderDTO);
    }


    // 获取用户订单分页列表
    @GetMapping("/userOrders")
    public Result<PageBean<OrderVO>> getUserOrders(
            @RequestParam(defaultValue = "1") Integer pageNumber,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String search) {

        Map<String, Object> claims = ThreadLocalUtil.get();
        Integer userId = (Integer) claims.get("id");

        return orderService.getUserOrders(userId, pageNumber, pageSize, search);
    }

    @GetMapping("/detail/{orderNumber}")
    public Result<OrderVO> getOrderDetail(@PathVariable String orderNumber) {
        Map<String, Object> claims = ThreadLocalUtil.get();
        Integer userId = (Integer) claims.get("id");
        return orderService.getOrderDetail(orderNumber, userId);
    }

    // 删除订单
    @DeleteMapping
    public Result<String> deleteOrder(@RequestParam String orderNumber) {
        Map<String, Object> claims = ThreadLocalUtil.get();
        String userId = (String) claims.get("id");

        return orderService.deleteOrder(userId, orderNumber);
    }

    // 订单管理查询
    @GetMapping("getOrders")
    public Result<PageBean<OrderVO>> getOrders(@RequestParam Integer pageNumber, @RequestParam Integer pageSize, @RequestParam(required = false) String search,@RequestParam(required = false) String status) {
        return orderService.getAll(pageNumber, pageSize, search, status);
    }

    @PostMapping("/ship")
    public Result shipOrder(@RequestBody ShippingDTO shippingDTO) {
        return orderService.shipOrder(shippingDTO);
    }



}
