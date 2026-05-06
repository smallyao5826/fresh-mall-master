package com.orion.pojo;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@TableName("logistics")
@Accessors(chain = true)
public class Logistics {
    @TableId(type = IdType.AUTO)
    private Integer id;
    private String orderNumber;
    private String company;
    private String type;
    private String trackingNumber;
    private String status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;


}