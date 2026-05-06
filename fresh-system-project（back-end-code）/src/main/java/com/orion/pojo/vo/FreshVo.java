package com.orion.pojo.vo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class FreshVo {
    private Integer id;
    private String freshName;
    private BigDecimal prices;
    private Integer categoryId;
    private Boolean isRecommend;
    private String specification;
}