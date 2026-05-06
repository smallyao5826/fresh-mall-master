package com.orion.pojo.vo;

import lombok.Data;
import lombok.experimental.Accessors;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Accessors(chain = true)
public class OrderDetailVO {
    private Integer freshId;
    private String freshName;
    private String pictureAddress;
    private Integer count;
    private BigDecimal price;  // 实际成交价
    private BigDecimal originalPrice;
    private BigDecimal shippingFee;     // 新增
    private String paymentMethod;        // 新增
    private LocalDateTime paymentTime;   // 新增
    private String remark;
}