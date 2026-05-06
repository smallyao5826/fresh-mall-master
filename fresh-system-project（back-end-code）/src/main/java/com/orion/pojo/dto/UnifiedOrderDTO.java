package com.orion.pojo.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class UnifiedOrderDTO {
    @NotNull(message = "收货地址不能为空")
    private Integer addressID;
    
    @NotNull(message = "总金额不能为空")
    private BigDecimal sumMoney;
    
    @NotEmpty(message = "商品列表不能为空")
    private List<CartItemDTO> freshList;
    
    @NotNull(message = "订单类型标识不能为空")
    private Boolean isCartOrder;

    @NotNull(message = "支付方式不能为空")
    private String paymentMethod; // 支付方式

    @Size(max = 255, message = "备注不能超过255字符")
    private String remark; // 订单备注
}