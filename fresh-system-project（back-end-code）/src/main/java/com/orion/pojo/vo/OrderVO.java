package com.orion.pojo.vo;

import lombok.Data;
import lombok.experimental.Accessors;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Accessors(chain = true)
public class OrderVO {
    private String orderNumber;
    private String status;
    private BigDecimal sumPrices;
    private List<OrderDetailVO> details;
    private AddressVO address;
    private LocalDateTime createTime;
    private BigDecimal shippingFee;     // 新增
    private String paymentMethod;        // 新增
    private LocalDateTime paymentTime;   // 新增
    private String remark;
}