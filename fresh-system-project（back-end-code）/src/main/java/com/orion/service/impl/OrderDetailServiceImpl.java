package com.orion.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.orion.pojo.OrderDetail;
import com.orion.service.OrderDetailService;
import com.orion.mapper.OrderDetailMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * @author Orion
 * @description 针对表【order_detail(订单与生鲜生成的订单详情表)】的数据库操作Service实现
 * @createDate 2024-11-02 20:22:27
 */
@Service
public class OrderDetailServiceImpl extends ServiceImpl<OrderDetailMapper, OrderDetail>
        implements OrderDetailService {

    @Autowired
    private OrderDetailMapper orderDetailMapper;



}




