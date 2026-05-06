package com.orion.pojo.dto;

import lombok.Data;


@Data
public class AfterSalesProcessDTO {

    private Integer id;                // 对应AfterSales.id
    private String processResult;      // 对应AfterSales.processResult
    private String processComment;     // 对应AfterSales.processComment
}