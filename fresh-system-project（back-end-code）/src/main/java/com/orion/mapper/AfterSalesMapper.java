package com.orion.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orion.pojo.AfterSales;
import com.orion.pojo.dto.AdminAfterSalesQueryDTO;
import com.orion.pojo.vo.AfterSalesVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface AfterSalesMapper extends BaseMapper<AfterSales> {
    List<AfterSalesVO> selectAfterSalesWithOrder(AdminAfterSalesQueryDTO queryDTO);
}