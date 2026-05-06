package com.orion.controller;

import com.orion.pojo.helper.Result;
import com.orion.pojo.vo.LogisticsVO;
import com.orion.service.impl.LogisticsServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/logistics")
@RequiredArgsConstructor
public class LogisticsController {
    private final LogisticsServiceImpl logisticsService;

    @GetMapping("/{orderNumber}")
    public Result<LogisticsVO> getLogistics(@PathVariable String orderNumber) {
        return logisticsService.getLogisticsInfo(orderNumber);
    }
}