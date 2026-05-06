package com.orion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.orion.pojo.Cart;
import com.orion.pojo.helper.Result;
import com.orion.service.CartService;
import com.orion.mapper.CartMapper;
import com.orion.utils.ThreadLocalUtil;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * @author Orion
 * @description 针对表【cart(用户与生鲜产生的购物车关系表)】的数据库操作Service实现
 * @createDate 2024-11-28 02:08:56
 */
@Transactional(readOnly = true)  //业务方法都开启事务
@Service
public class CartServiceImpl extends ServiceImpl<CartMapper, Cart>
        implements CartService {

    //自动注入mapper接口JDK代理对象（注入优先级：1、根据注解name属性名  2、根据属性字段 3、根据属性字段所属类型）
    @Resource(name = "cartMapper")
    private CartMapper cartMapper;

    @Override
    public Result<List<Cart>> getUserCart() {
        List<Cart> cartList = cartMapper.getUserCart(ThreadLocalUtil.getUserId());
        return Result.success(cartList);
    }


    @Transactional(readOnly = false) //生效：就近原则
    @Override
    public Result deleteByUidandFreshId(String fid) {
        LambdaQueryWrapper<Cart> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Cart::getUserId, ThreadLocalUtil.getUserId())
                .eq(Cart::getFreshId, fid);
        int delete = cartMapper.delete(wrapper);
        if (delete < 1) {
            return Result.error("删除失败");
        }
        return Result.success();
    }
}




