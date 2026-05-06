package com.orion.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orion.pojo.Logistics;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

public interface LogisticsMapper extends BaseMapper<Logistics> {
    @Select("SELECT * FROM logistics WHERE order_number = #{orderNumber}")
    Logistics selectByOrderNumber(String orderNumber);
}