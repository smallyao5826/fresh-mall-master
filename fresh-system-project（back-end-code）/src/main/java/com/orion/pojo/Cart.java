package com.orion.pojo;

import com.baomidou.mybatisplus.annotation.Version;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * @TableName cart
 */
@Data
public class Cart implements Serializable {
    @JsonIgnore
    private Integer userId;

    @JsonIgnore
    private Integer  freshId;

    private Integer count;


    //多表连接：对一
    private Fresh fresh;

    @JsonIgnore
    @Version
    private Integer version;

    private static final long serialVersionUID = 1L;
}