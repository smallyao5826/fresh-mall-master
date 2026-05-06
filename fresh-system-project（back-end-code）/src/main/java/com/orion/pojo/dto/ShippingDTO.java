package com.orion.pojo.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ShippingDTO {
    @NotBlank(message = "订单号不能为空")
    private String orderNumber;
    
    @NotBlank(message = "物流公司不能为空")
    private String company;
    
    @NotBlank(message = "物流类型不能为空")
    private String type;
    
    @NotBlank(message = "物流单号不能为空")
    private String trackingNumber;
}