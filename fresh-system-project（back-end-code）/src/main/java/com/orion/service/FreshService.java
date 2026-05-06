package com.orion.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.orion.pojo.Fresh;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;

import java.util.List;
import java.util.Map;

/**
 * @author Orion
 * @description 针对表【fresh(生鲜商品表)】的数据库操作Service
 * @createDate 2024-10-29 01:58:27
 */
public interface FreshService extends IService<Fresh> {

    /**
     * 添加生鲜商品的接口
     *
     * @return
     */
    Result addFresh(Fresh fresh);

    /**
     * 分页查询生鲜接口
     * ①自定义动态sql
     *
     * @param pageNumber
     * @param pageSize
     * @param freshName
     * @param categoryId
     * @param recommend
     * @return
     */
    Result<PageBean<Fresh>> getFresh(Integer pageNumber, Integer pageSize, String freshName, Integer categoryId, Integer recommend);

    /**
     * 更新生鲜接口
     * 1、根据前端的生鲜ID从数据库中查询出当前用户修改的生鲜库存数量
     * 2、如果数据库存大于大于前端库存，则直接将用户的库存修改数据库存
     * 3、若数据库存小于前端库存，则将用户库存减去数据库存的结果增添到该生鲜的库存总量上去。
     *
     * @param fresh
     * @return
     */
    Result updateFresh(Fresh fresh);

    /**
     * 获取生鲜销量排行榜数据
     *
     * @return
     */
    Result<List> getSaleCount();

    /**
     * 查询指定记录数的生鲜信息
     *
     * @param
     * @return
     */
    Result<List<Fresh>> queryRecommend();

    /**
     * 根据id查询生鲜版本号、当前库存
     *
     * @param freshId
     * @return
     */
    Map<String, Integer> getFreshById(String freshId);
}
