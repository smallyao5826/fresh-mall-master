package com.orion.controller;

import com.orion.pojo.Cart;
import com.orion.pojo.helper.Result;
import com.orion.service.CartService;
import com.orion.utils.ThreadLocalUtil;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/*
 * @Description TODO 购物车管理
 * @Date 2024/10/8  10:31
 * @Author Orion
 **/
@RestController  //放入ioc容器、直接返回数据给前端不走视图解析器
@CrossOrigin(originPatterns = {"http://*:5173"}, maxAge = 3600L)  //前后端分离允许指定源的浏览器访问，并且浏览器预检请求1个小时向此处发一次
@Validated  //使Handler方法参数效验前的注解生效
@RequestMapping("cart")
public class CartController {

    @Autowired
    private CartService cartService;

    /**
     * 添加商品到购物车
     * 方法1、首先根据用户ID和生鲜ID去数据库中查询该用户是否已经把生鲜添加到数据库中了，若已添加则返回错误提示信息，否则直接新增购物车记录。
     * 方法2、对重复插入购物车数据进行异常捕获处理、返回重复插入数据导致主键冲突异常信息给前端。
     *
     * @param id
     * @param purchaseCount
     * @return
     */
    @PostMapping
    public Result addCartOfFresh(@NotNull Integer id, @NotNull Integer purchaseCount) {
        Cart cart = new Cart();
        cart.setCount(purchaseCount);
        cart.setFreshId(id);
        cart.setUserId(ThreadLocalUtil.getUserId());
        return cartService.save(cart) ? Result.success() : Result.error("加入购物车失败");
    }

    /**
     * @return com.orion.pojo.helper.Result<java.util.List < com.orion.pojo.Cart>>
     * @Description TODO 获取用户购物车生鲜
     * @Date 2024/11/29 0:07
     * @Author Orion
     **/
    @GetMapping
    public Result<List<Cart>> getUserFreshOfCart() {
        return cartService.getUserCart();
    }

    /**
     * @param fid
     * @return com.orion.pojo.helper.Result
     * @Description TODO 删除购物车中某些生鲜
     * @Date 2024/11/29 3:51
     * @Author Orion
     **/
    @DeleteMapping("{freshId}")
    public Result deleteCart(@PathVariable("freshId") @NotEmpty String fid) {
        return cartService.deleteByUidandFreshId(fid);
    }
}
