package com.orion.pojo.dto;

import lombok.Data;

@Data
public class UserBehavior {
    private Integer userId;
    private Integer itemId;
    private Integer count;
    
    // getters/setters省略
}