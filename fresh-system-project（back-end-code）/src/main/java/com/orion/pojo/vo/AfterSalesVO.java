package com.orion.pojo.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AfterSalesVO {
    private Integer id;
    private String orderNumber;  // 新增订单号字段
    private Integer userId;
    private String serviceType;
    private String applyReason;
    private String status;
    private String processResult;
    private String processComment;
    private LocalDateTime applyTime;
    private LocalDateTime processTime;
}