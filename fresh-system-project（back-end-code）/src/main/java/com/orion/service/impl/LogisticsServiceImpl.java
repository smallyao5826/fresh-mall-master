package com.orion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.orion.mapper.LogisticsHistoryMapper;
import com.orion.mapper.LogisticsMapper;
import com.orion.pojo.Logistics;
import com.orion.pojo.LogisticsHistory;
import com.orion.pojo.helper.Result;
import com.orion.pojo.vo.LogisticsVO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LogisticsServiceImpl {
    private final LogisticsMapper logisticsMapper;
    private final LogisticsHistoryMapper logisticsHistoryMapper;

    public Result<LogisticsVO> getLogisticsInfo(String orderNumber) {
        // 1. 获取物流主信息
        Logistics logistics = logisticsMapper.selectOne(
                new LambdaQueryWrapper<Logistics>()
                        .eq(Logistics::getOrderNumber, orderNumber)
        );
        if (logistics == null) {
            return Result.error("物流信息不存在");
        }

        // 2. 查询历史记录
        List<LogisticsHistory> histories = logisticsHistoryMapper.selectList(
                new LambdaQueryWrapper<LogisticsHistory>()
                        .eq(LogisticsHistory::getLogisticsId, logistics.getId())
                        .orderByAsc(LogisticsHistory::getEventTime)
        );

        // 3. 转换VO格式
        return Result.success(new LogisticsVO()
                .setOrderNumber(logistics.getOrderNumber())
                .setCompany(logistics.getCompany())
                .setType(logistics.getType())
                .setTrackingNumber(logistics.getTrackingNumber())
                .setCurrentStatus(logistics.getStatus())
                .setHistories(histories.stream().map(h ->
                        new LogisticsVO.HistoryItem(
                                h.getStatus(),
                                h.getEventTime().toString(),
                                h.getTemperature()
                        )).collect(Collectors.toList())
                )
        );
    }

}