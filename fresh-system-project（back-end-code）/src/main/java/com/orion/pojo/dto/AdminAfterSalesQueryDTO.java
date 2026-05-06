// com.orion.pojo.dto.AdminAfterSalesQueryDTO.java
package com.orion.pojo.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AdminAfterSalesQueryDTO {
    private Integer page = 1;
    private Integer pageSize = 10;
    private String orderNumber;    // 订单号筛选
    private String serviceType;    // 服务类型筛选
    private String status;         // 状态筛选
    private String userId;         // 用户ID筛选
    private LocalDateTime startTime; // 申请时间范围
    private LocalDateTime endTime;
}