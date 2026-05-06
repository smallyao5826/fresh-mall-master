package com.orion.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.orion.mapper.CategoryMapper;
import com.orion.pojo.Category;
import com.orion.pojo.helper.Result;
import com.orion.service.CategoryService;
import com.orion.utils.ThreadLocalUtil;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/*
 * @Description TODO 生鲜分类管理
 * @Date 2024/10/8  10:31
 * @Author Orion
 **/
@RestController
@RequestMapping("category")
@Validated
@CrossOrigin(originPatterns = {"http://*:5173"}, maxAge = 3600L)
public class CategoryController {
    @Autowired
    private CategoryService category;

    @Autowired
    private CategoryMapper categoryMapper;

    /**
     * 定义查询生鲜分类接口
     */
    @GetMapping("all")
    public Result<List<Map<String, Object>>> queryAll(String search) {
        return category.queryCategories(search);
    }

    /**
     * 添加生鲜分类接口
     *
     * @param typeName
     * @return
     */
    @PostMapping("add")
    public Result addCategory(@NotEmpty String typeName) {
        return category.addType(typeName);
    }

    /**
     * 编辑分类接口
     *
     * @param id
     * @param typeName
     * @return
     */
    @PatchMapping("edit")
    public Result editCategory(@NotEmpty String id, @NotEmpty String typeName) {
        Category category2 = categoryMapper.selectCategory(typeName);
        if (category2 != null && !category2.getIsDeleted()) {
            return Result.error("分类名称已存在!");
        } else if (category2 != null) {
            Integer i = categoryMapper.removeFull(category2.getUserId(), category2.getCategoryName());
            if (i < 1) {
                return Result.error("编辑分类失败!");
            }
        }
        Category category1 = new Category();
        category1.setCategoryName(typeName);
        category1.setUpdateTime(LocalDateTime.now());
        LambdaQueryWrapper<Category> wrapper = new LambdaQueryWrapper<>();
        wrapper.allEq(Map.of(Category::getId, id, Category::getUserId, ThreadLocalUtil.getUserId()));
        boolean update = category.update(category1, wrapper);
        if (!update) {
            return Result.error("编辑失败!");
        }
        return Result.success();
    }


    /**
     * 删除生鲜分类接口
     */
    @DeleteMapping("delete")
    public Result delete(@NotNull String id) {
        if (!category.removeById(id)) {
            return Result.error("删除失败!");
        }
        return Result.success();
    }

    /**
     * 生鲜分类销量
     *
     * @return
     */
    @GetMapping("freshCategorySale")
    public Result<List<Map>> getFreshSale() {
        return category.getFreshTypeSales();
    }

}
