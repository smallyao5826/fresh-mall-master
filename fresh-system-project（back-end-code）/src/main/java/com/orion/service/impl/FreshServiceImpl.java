package com.orion.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.orion.mapper.FreshMapper;
import com.orion.pojo.Fresh;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.service.FreshService;
import com.orion.utils.ThreadLocalUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * @author Orion
 * @description 针对表【fresh(生鲜商品表)】的数据库操作Service实现
 * @createDate 2024-10-29 01:58:27
 */
@Service
public class FreshServiceImpl extends ServiceImpl<FreshMapper, Fresh>
        implements FreshService {

    @Autowired
    private FreshMapper freshMapper;

    @Override
    public Result addFresh(Fresh fresh) {
        fresh.setId(null);

        fresh.setCreateTime(LocalDateTime.now());
        fresh.setUpdateTime(LocalDateTime.now());
        fresh.setSumRepertory(fresh.getRepertory());

        int rows = freshMapper.insert(fresh);
        return rows > 0 ? Result.success() : Result.error("添加失败");
    }

    @Override
    public Result<PageBean<Fresh>> getFresh(Integer pageNumber, Integer pageSize,
                                            String freshName, Integer categoryId,
                                            Integer recommend) {
        // 参数合理化处理
        pageNumber = Optional.ofNullable(pageNumber).orElse(1);
        pageSize = Optional.ofNullable(pageSize).orElse(10);

        // 分页查询
        PageHelper.startPage(pageNumber, pageSize);
        List<Fresh> list = freshMapper.selectByCondition(freshName, categoryId, recommend);
        PageInfo<Fresh> pageInfo = new PageInfo<>(list);

        return Result.success(new PageBean<>(pageInfo));
    }

    @Override
    public Result updateFresh(Fresh fresh) {
        // 添加版本控制检查
        Fresh original = freshMapper.selectById(fresh.getId());
        if (original == null) {
            return Result.error("商品不存在");
        }

        // 库存变更计算
        Integer stockChange = fresh.getRepertory() - original.getRepertory();
        if (stockChange > 0) {
            fresh.setSumRepertory(original.getSumRepertory() + stockChange);
        }

        // 保留必须字段
        fresh.setVersion(original.getVersion())
                .setCreateTime(original.getCreateTime())
                .setUpdateTime(LocalDateTime.now());

        // 处理促销价空值
        if (fresh.getPromotionPrice() == null) {
            fresh.setPromotionPrice(BigDecimal.ZERO); // 或保持null根据业务需求
        }

        int rows = freshMapper.updateById(fresh);
        return rows > 0 ? Result.success() : Result.error("修改失败");
    }

    @Override
    public Result<List> getSaleCount() {
        List<Map> freshlist = freshMapper.selectSaleRank();
        return Result.success(freshlist);
    }

    @Override
    public Result<List<Fresh>> queryRecommend() {
        List<Fresh> freshList = freshMapper.selectByCount();
        if (freshList.isEmpty())
            return Result.error("查询失败!");
        return Result.success(freshList);
    }

    @Override
    public Map<String, Integer> getFreshById(String freshId) {
        Map<String, Integer> map = freshMapper.selectByone(freshId);
        return map;
    }
}




