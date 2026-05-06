package com.orion.service;

import com.orion.pojo.Order;
import com.baomidou.mybatisplus.extension.service.IService;
import com.orion.pojo.dto.ShippingDTO;
import com.orion.pojo.dto.UnifiedOrderDTO;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.pojo.vo.OrderVO;

/**
 * @author Orion
 * @description 针对表【order(订单表)】的数据库操作Service
 * @createDate 2024-11-02 20:22:27
 */
public interface OrderService extends IService<Order> {



    Result<PageBean<OrderVO>> getUserOrders(Integer userId, Integer pageNumber, Integer pageSize, String search);

    Result<String> deleteOrder(String userId, String orderNumber);


    Result<String> createOrder(UnifiedOrderDTO orderDTO);

    Result<PageBean<OrderVO>> getAll(Integer pageNumber, Integer pageSize, String search, String status);

    Result<OrderVO> getOrderDetail(String orderNumber, Integer userId);

    Result shipOrder(ShippingDTO shippingDTO);

    void updateOrderStatus(String orderNumber, String status);
}
