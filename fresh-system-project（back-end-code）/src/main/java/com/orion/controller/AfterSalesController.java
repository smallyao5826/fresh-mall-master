package com.orion.controller;

import com.orion.pojo.AfterSales;
import com.orion.pojo.dto.AdminAfterSalesQueryDTO;
import com.orion.pojo.dto.AfterSalesApplyDTO;
import com.orion.pojo.dto.AfterSalesProcessDTO;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.pojo.vo.AfterSalesVO;
import com.orion.service.AfterSalesService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@CrossOrigin(originPatterns = {"http://*:5173"}, maxAge = 3600L)
@RequestMapping("/afterSales")
public class AfterSalesController {

    private final AfterSalesService afterSalesService;

    public AfterSalesController(AfterSalesService afterSalesService) {
        this.afterSalesService = afterSalesService;
    }

    @PostMapping("/apply")
    public Result<String> applyAfterSales(@RequestBody AfterSalesApplyDTO applyDTO) {
        return afterSalesService.submitApply(applyDTO);
    }

    @GetMapping("/admin/list")
    public Result<PageBean<AfterSalesVO>> getAfterSalesList(AdminAfterSalesQueryDTO queryDTO) {
        return afterSalesService.getAfterSalesList(queryDTO);
    }

    @PostMapping("/admin/process")
    public Result<String> processAfterSales(@RequestBody @Valid AfterSalesProcessDTO processDTO) {
        return afterSalesService.processAfterSales(processDTO);
    }


}