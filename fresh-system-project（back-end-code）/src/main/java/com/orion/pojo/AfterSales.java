package com.orion.pojo;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("after_sales")
public class AfterSales {
    @TableId(type = IdType.AUTO)
    private Integer id;
    private Integer orderId;
    private Integer userId;
    private String serviceType;
    private String applyReason;
    private String status;
    private String processResult;
    private String processComment;
    private LocalDateTime applyTime;
    private LocalDateTime processTime;
}