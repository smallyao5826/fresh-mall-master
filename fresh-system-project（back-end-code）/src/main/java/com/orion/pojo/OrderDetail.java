package com.orion.pojo;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.Version;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.experimental.Accessors;
import net.minidev.json.annotate.JsonIgnore;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * @TableName order_detail
 * 订单详情表
 */
@Data
@Accessors(chain = true)
@TableName("order_detail")
public class OrderDetail implements Serializable {

    @TableId
    private Integer id;
    private Integer orderId;
    private Integer freshId;
    private Integer count;
    private LocalDateTime createTime;
    private Boolean isDeleted;
    private Integer version;
}