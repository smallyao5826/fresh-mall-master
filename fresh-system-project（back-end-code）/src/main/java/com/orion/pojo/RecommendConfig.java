package com.orion.pojo;

import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class RecommendConfig {
    @TableField("param_name")  // 明确指定数据库字段
    private String paramName;

    @TableField("param_value")
    private Double paramValue;
    private String description;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    

}