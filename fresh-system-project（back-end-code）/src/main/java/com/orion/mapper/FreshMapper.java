package com.orion.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.orion.pojo.Fresh;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.Map;

/**
 * @author Orion
 * @description 针对表【fresh(生鲜商品表)】的数据库操作Mapper
 * @createDate 2024-10-29 01:58:27
 * @Entity com.orion.pojo.Fresh
 */
public interface FreshMapper extends BaseMapper<Fresh> {

    /**
     * 分页按条件查询生鲜
     *
     * @param freshPage
     * @param freshName
     * @param categoryId
     * @param recommend
     */
    IPage<Fresh> queryAll(IPage<Fresh> freshPage, String freshName, String categoryId, Integer recommend);

    /**
     * 根据生鲜id查询生鲜的信息
     *
     * @param id
     * @return
     */
    @Select("select repertory,sum_repertory,version from fresh_system.fresh where id=#{id}")
    Fresh queryById(String id);

    /**
     * 生鲜分类销量统计
     *
     * @return
     */
    List<Map> selectFreshesSaleCount();

    /**
     * 获取生鲜销售排行榜
     *
     * @return
     */
    List<Map> selectSaleRank();

    /**
     * 获取推荐生鲜详情信息
     *
     * @param
     * @return
     */
    List<Fresh> selectByCount();

    /**
     * 获取生鲜部分信息
     *
     * @param freshId
     * @return
     */
    @Select("select repertory, version from fresh_system.fresh where is_deleted = false and id=#{freshId}")
    Map selectByone(String freshId);

    int decreaseStock(@Param("freshId") String freshId,
                      @Param("count") Integer count);

    List<Fresh> selectByCondition(String freshName, Integer categoryId, Integer recommend);

    List<Fresh> selectByRecommend();

    List<String> selectCategoriesByIds(List<Integer> cartItemIds);

    @Select("SELECT * FROM fresh WHERE is_deleted = 0 AND repertory > 0")
    List<Fresh> selectValidItems();

    @Update("UPDATE fresh SET recommend_cache = NULL")
    void clearRecommendCache();

    @Select("SELECT * FROM fresh WHERE is_deleted = 0")
    List<Fresh> selectAll();


    @Select("SELECT id FROM fresh WHERE is_deleted = 0")
    @ResultType(Integer.class)
    List<Integer> selectAllIds();
}




