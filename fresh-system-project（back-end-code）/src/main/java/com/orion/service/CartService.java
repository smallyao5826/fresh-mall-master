package com.orion.service;

import com.orion.pojo.Cart;
import com.baomidou.mybatisplus.extension.service.IService;
import com.orion.pojo.helper.Result;

import java.util.List;

/**
 * @author Orion
 * @description 针对表【cart(用户与生鲜产生的购物车关系表)】的数据库操作Service
 * @createDate 2024-11-28 02:08:56
 */
public interface CartService extends IService<Cart> {

    /**
     * @return com.orion.pojo.helper.Result<java.util.List < com.orion.pojo.Cart>>
     * @Description TODO 获取用户购物车生鲜
     * 1、根据ThreadLocal中存储的用户ID获取购物车表中所有用户添加的生鲜
     * 2、使用1对1多表连接生鲜表获取生鲜的具体数据
     * 3、返回List数据给前端
     * @Date 2024/11/29 0:09
     * @Author Orion
     **/
    Result<List<Cart>> getUserCart();

    /**
     * @param fid
     * @return com.orion.pojo.helper.Result
     * @Description TODO 根据uid和fid删除cart表中生鲜记录
     * @Date 2024/11/29 3:52
     * @Author Orion
     **/
    Result deleteByUidandFreshId(String fid);
}
