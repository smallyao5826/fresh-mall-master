package com.orion.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.orion.mapper.CategoryMapper;
import com.orion.mapper.FreshMapper;
import com.orion.pojo.Category;
import com.orion.pojo.helper.Result;
import com.orion.service.CategoryService;
import com.orion.utils.ThreadLocalUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * @author 每一天都是开始
 * @description 针对表【category(生鲜分类表)】的数据库操作Service实现
 * @createDate 2024-10-23 00:02:28
 */
@Service
public class CategoryServiceImpl extends ServiceImpl<CategoryMapper, Category>
        implements CategoryService {

    @Autowired
    private CategoryMapper categoryMapper;

    @Autowired
    private FreshMapper freshMapper;

    @Override
    public Result addType(String typeName) {
        Category category1 = categoryMapper.selectCategory(typeName);
        if (category1 != null && !category1.getIsDeleted()) {
            return Result.error("抱歉! 此生鲜分类名称已被占用。");
        } else if (category1 != null) {
            Integer userId = ThreadLocalUtil.getUserId();
            Integer i = categoryMapper.updateCategory(category1.getId(), userId);
            if (i < 1)
                return Result.error("添加分类失败!");
            return Result.success();
        }
        Category category = new Category();
        category.setUserId(ThreadLocalUtil.getUserId());
        category.setCategoryName(typeName);
        category.setCreateTime(LocalDateTime.now());
        category.setUpdateTime(LocalDateTime.now());
        int rows = categoryMapper.insert(category);
        if (rows > 0) {
            return Result.success();
        }
        return Result.error("添加生鲜分类失败!");
    }

    @Override
    public Result<List<Map<String, Object>>> queryCategories(String search) {
        List<Map<String, Object>> all = categoryMapper.getAll(search);
        return Result.success(all);
    }

    @Override
    public Result<List<Map>> getFreshTypeSales() {
        List<Map> saleCountList = freshMapper.selectFreshesSaleCount();
        if (saleCountList.stream().count() == 0) {
            return Result.error("查询失败");
        }
        return Result.success(saleCountList);
    }

}




