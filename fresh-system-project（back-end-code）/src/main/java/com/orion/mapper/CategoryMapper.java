package com.orion.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orion.pojo.Category;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;
import java.util.Map;

/**
 * @author 每一天都是开始
 * @description 针对表【category(生鲜分类表)】的数据库操作Mapper
 * @createDate 2024-10-23 00:02:28
 * @Entity com.orion.pojo.Category
 */

public interface CategoryMapper extends BaseMapper<Category> {
    /**
     * 获取所有未删除分类记录
     *
     * @param search
     * @return
     */
    List<Map<String, Object>> getAll(String search);

    /**
     * 查询某条分类记录是否已存在
     *
     * @param typeName
     * @return
     */
    @Select("select * from category where category_name =#{typeName}")
    Category selectCategory(String typeName);

    /**
     * 修改已被逻辑删除的字段为未被修改状态
     *
     * @param id
     */
    @Update("update category set is_deleted = 0, user_id = #{userId},create_time=now(),update_time=now() where id=#{id}")
    Integer updateCategory(Integer id, Integer userId);

    /**
     * 彻底删除一条分类记录
     *
     * @param userId
     */
    @Delete("delete from category where user_id=#{userId} and category_name=#{categoryName}")
    Integer removeFull(Integer userId, String categoryName);
}




