package com.orion.pojo.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AfterSalesApplyDTO {
    @NotBlank(message = "订单号不能为空")
    private String orderNumber;
    
    @NotBlank(message = "售后类型不能为空")
    private String serviceType;
    
    @NotBlank(message = "申请原因不能为空")
    private String applyReason;
}