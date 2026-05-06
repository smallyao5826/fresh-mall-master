package com.orion.controller;

import com.orion.pojo.helper.Result;
import com.orion.service.impl.RecommendConfigService;
import org.junit.jupiter.api.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/recommend")
@CrossOrigin(originPatterns = {"http://*:5173"}, maxAge = 3600L)
public class RecommendConfigController {

    @Autowired
    private RecommendConfigService configService;

    @GetMapping("/config")
    public Result<Map<String,Double>> getConfig() {
        return Result.success(configService.getConfigParams());
    }

    @PostMapping("/config")
    public Result<String> updateConfig(
            @RequestBody Map<String, Double> paramMap) { // 改为接收Double类型

        configService.updateConfig(paramMap);
        return Result.success("配置更新成功");
    }
}