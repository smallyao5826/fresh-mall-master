package com.orion.pojo;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.experimental.Accessors;
import net.minidev.json.annotate.JsonIgnore;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * @TableName order
 * 订单结算表
 */
@Data
@Accessors(chain = true)
@TableName(value = "`order`")
public class Order implements Serializable {

    @TableId(value = "order_id")
    private Integer orderId;
    private String orderNumber;
    private String status;
    private BigDecimal sumPrices;
    private Integer userId;
    private Integer addressId;
    private LocalDateTime createTime;

    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    private Boolean isDeleted;
    private Integer version;

    @TableField(exist = false)
    private List<OrderDetail> details;

    private BigDecimal shippingFee; // 运费
    private String paymentMethod;   // 支付方式
    private LocalDateTime paymentTime; // 付款时间
    private String remark;           // 订单备注

}