package com.orion.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.orion.pojo.Order;
import com.orion.pojo.vo.OrderVO;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * @author Orion
 * @description 针对表【order(订单表)】的数据库操作Mapper
 * @createDate 2024-11-02 20:22:27
 * @Entity com.orion.pojo.Order
 */
public interface OrderMapper extends BaseMapper<Order> {


    List<OrderVO> queryOrders(
            @Param("offset") Long offset,
            @Param("pageSize") Long pageSize,
            @Param("search") String search, @Param("status") String status
    );


    List<OrderVO> selectOrderVOs(@Param("page") Page<OrderVO> page,
                                 @Param("userId") Integer userId,
                                 @Param("search") String search);


    Long queryOrdersCount(@Param("search") String search, @Param("status") String status);

    OrderVO selectOrderDetailByNumber(@Param("orderNumber") String orderNumber,  @Param("userId") Integer userId);

    Order selectByOrderNumber(String orderNumber);

}




