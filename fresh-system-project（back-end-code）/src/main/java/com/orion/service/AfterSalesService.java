package com.orion.service;

import com.orion.pojo.AfterSales;
import com.orion.pojo.dto.AdminAfterSalesQueryDTO;
import com.orion.pojo.dto.AfterSalesApplyDTO;
import com.orion.pojo.dto.AfterSalesProcessDTO;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.pojo.vo.AfterSalesVO;

public interface AfterSalesService {
    Result<String> submitApply(AfterSalesApplyDTO applyDTO);

    Result<PageBean<AfterSalesVO>> getAfterSalesList(AdminAfterSalesQueryDTO queryDTO);

    Result<String> processAfterSales(AfterSalesProcessDTO processDTO);
}