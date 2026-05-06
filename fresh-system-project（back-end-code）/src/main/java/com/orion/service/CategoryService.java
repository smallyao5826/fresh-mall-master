package com.orion.service;

import com.orion.pojo.Category;
import com.baomidou.mybatisplus.extension.service.IService;
import com.orion.pojo.helper.Result;

import java.util.List;
import java.util.Map;

/**
 * @author 每一天都是开始
 * @description 针对表【category(生鲜分类表)】的数据库操作Service
 * @createDate 2024-10-23 00:02:28
 */
public interface CategoryService extends IService<Category> {

    /**
     * 添加生鲜分类
     *
     * @param typeName
     * @return
     */
    Result addType(String typeName);

    /**
     * 查询所有生鲜分类
     * 1、将查询到的结果集使用list>map的集合来封装查询到的数据
     *
     * @return
     */
    Result<List<Map<String, Object>>> queryCategories(String search);

    /**
     * 生鲜分类销量统计
     * 1、返回数据是一个集合中封装value, name形式的Map
     *
     * @return
     */
    Result<List<Map>> getFreshTypeSales();
}
