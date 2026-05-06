package com.orion.pojo.helper;

import com.github.pagehelper.PageInfo;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

//分页返回结果对象
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PageBean<T> {
    private long pageNumber;  // 当前页
    private long pageSize;    // 每页条数
    private Long total;          // 总记录数
    private List<T> items;      // 数据列表

    public PageBean(PageInfo<T> pageInfo) {
        this.pageNumber = pageInfo.getPageNum();
        this.pageSize = pageInfo.getPageSize();
        this.total = pageInfo.getTotal();
        this.items = pageInfo.getList();
    }
}
