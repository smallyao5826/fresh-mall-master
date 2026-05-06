package com.orion.mapper;

import com.orion.pojo.Cart;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orion.pojo.dto.UserBehavior;
import org.apache.ibatis.annotations.Result;
import org.apache.ibatis.annotations.Results;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * @author Orion
 * @description 针对表【cart(用户与生鲜产生的购物车关系表)】的数据库操作Mapper
 * @createDate 2024-11-28 02:08:56
 * @Entity com.orion.pojo.Cart
 */
public interface CartMapper extends BaseMapper<Cart> {

    /***
     * @Description TODO 获取用户购物车所有生鲜
     * @param userId
     * @return java.util.List<com.orion.pojo.Cart>
     * @Date 2024/11/29 0:27
     * @Author Orion
     **/
    List<Cart> getUserCart(Integer userId);

    List<Integer> selectUserCartItemIds(Integer userId);


    @Select("SELECT user_id, fresh_id FROM cart")
    @Results({
            @Result(property = "userId", column = "user_id"),
            @Result(property = "itemId", column = "fresh_id")
    })
    List<UserBehavior> selectAllUserItems();
}




