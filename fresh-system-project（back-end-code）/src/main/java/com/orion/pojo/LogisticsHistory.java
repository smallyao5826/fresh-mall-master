package com.orion.pojo;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.experimental.Accessors;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("logistics_history")
@Accessors(chain = true)
public class LogisticsHistory {
    @TableId(type = IdType.AUTO)
    private Integer id;
    private Integer logisticsId;
    private String status;
    private BigDecimal temperature;
    private LocalDateTime eventTime;

}