package com.orion.pojo.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.Accessors;

import java.math.BigDecimal;
import java.util.List;

@Data
@Accessors(chain = true)
public class LogisticsVO {
    private String orderNumber;
    private String company;
    private String type;
    private String trackingNumber;
    private String currentStatus;
    private List<HistoryItem> histories;
    
    @Data
    @AllArgsConstructor
    public static class HistoryItem {
        private String status;
        private String eventTime;
        private BigDecimal temperature;
    }
}