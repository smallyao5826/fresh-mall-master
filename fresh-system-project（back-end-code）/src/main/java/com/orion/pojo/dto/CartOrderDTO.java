package com.orion.pojo.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class CartOrderDTO {
    @NotNull(message = "收货地址不能为空")
    private Integer addressID;
    
    @NotNull(message = "总金额不能为空")
    private BigDecimal sumMoney;
    
    @NotEmpty(message = "商品列表不能为空")
    private List<CartItemDTO> freshList;
}