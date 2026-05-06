package com.orion.controller;

import com.orion.pojo.Fresh;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.service.FreshService;
import com.orion.service.impl.Recommender;
import jakarta.validation.constraints.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

/*
 * @Description TODO 生鲜管理
 * @Date 2024/10/12  10:33
 * @Author Orion
 **/
@RestController
@RequestMapping("fresh")
@CrossOrigin(originPatterns = {"http://*:5173"}, maxAge = 3600L)  //解决前后端分离跨域问题
@Validated  //使handler方法形参前的效验注解生效
public class FreshController {
    @Autowired
    private FreshService freshService;

    @Autowired
    private Recommender recommender;

    /**
     * 新增生鲜接口
     */
    @PostMapping("saveFreshes")
    public Result saveFreshes(@RequestBody @Validated Fresh fresh) {
        if (fresh.getPromotionPrice() != null) {
            // 促销价必须小于原价
            if (fresh.getPromotionPrice().compareTo(fresh.getPrices()) >= 0) {
                return Result.error("折扣价格必须小于原价!");
            }

            // 促销价不能为负数（可选）
            if (fresh.getPromotionPrice().compareTo(BigDecimal.ZERO) < 0) {
                return Result.error("折扣价格不能为负数!");
            }
        }
        return freshService.addFresh(fresh);
    }

    /**
     * 分页查询生鲜接口
     *
     * @param pageNumber
     * @param pageSize
     * @param freshName
     * @param categoryId
     * @param recommend
     * @return
     */
    @GetMapping("/getFreshes") // 添加完整路径
    public Result<PageBean<Fresh>> getFreshes(@RequestParam @NotNull Integer pageNumber,
                                              @RequestParam @NotNull Integer pageSize,
                                              @RequestParam(required = false) String freshName,
                                              @RequestParam(required = false) Integer categoryId,
                                              @RequestParam(required = false) Integer recommend) {
        return freshService.getFresh(pageNumber, pageSize, freshName, categoryId, recommend);
    }

    /**
     * 更新生鲜接口
     *
     * @param fresh
     * @return
     */
    @PutMapping("updateFresh")
    public Result updateFresh(@RequestBody @Validated Fresh fresh) {
        // 添加促销价非空检查
        if (fresh.getPromotionPrice() != null) {
            if (fresh.getPromotionPrice().compareTo(fresh.getPrices()) >= 0) {
                return Result.error("折扣价格必须小于原价!");
            }

            // 可选：促销价不能为负数
            if (fresh.getPromotionPrice().compareTo(BigDecimal.ZERO) < 0) {
                return Result.error("折扣价格不能为负数!");
            }
        }

        return freshService.updateFresh(fresh);
    }

    /**
     * 删除生鲜接口
     *
     * @param id
     * @return
     */
    @DeleteMapping("deleteFresh")
    public Result deleteFresh(@RequestParam Integer id) {
        boolean result = freshService.removeById(id);
        return result ? Result.success() : Result.error("删除失败");
    }


    /**
     * 获取生鲜销量排行榜数据
     *
     * @return
     */
    @GetMapping("saleGrade")
    public Result<List> getFreshGrade() {
        return freshService.getSaleCount();
    }

    /**
     * 查询指定记录数的推荐生鲜信息
     *
     * @param
     * @return
     */
    /*@GetMapping("recommendAll")
    public Result<List<Fresh>> getRecommendAll() {
        return freshService.queryRecommend();
    }*/

    @GetMapping("recommendAll")
    public Result<List<Fresh>> getRecommend(
            @RequestParam(required = false) Integer userId) {

        List<Fresh> recommendations = recommender.recommend(userId);
        return Result.success(recommendations);
    }
}
