package com.orion.service.impl;

import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.orion.pojo.Address;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.service.AddressService;
import com.orion.mapper.AddressMapper;
import com.orion.utils.ThreadLocalUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * @author Orion
 * @description 针对表【address(收货地址表)】的数据库操作Service实现
 * @createDate 2024-11-07 01:40:02
 */
@Service
public class AddressServiceImpl extends ServiceImpl<AddressMapper, Address>
        implements AddressService {

    @Autowired
    private AddressMapper addressMapper;

    // 新增地址（含默认地址处理）
    @Transactional
    public Result addAddress(Address address) {
        Integer userId = ThreadLocalUtil.getUserId();
        address.setUserId(Integer.valueOf(userId));

        // 处理默认地址
        if (Boolean.TRUE.equals(address.getIsDefault())) {
            addressMapper.clearDefaultAddress(userId);
        }

        return this.save(address) ?
                Result.success(address) :
                Result.error("添加失败");
    }

    // 更新地址
    @Transactional
    public Result updateAddress(Address address) {
        Integer userId = ThreadLocalUtil.getUserId();
        Address existAddr = this.getById(address.getId());

        // 验证地址归属
        if (!existAddr.getUserId().equals(userId)) {
            return Result.error("非法操作");
        }

        // 处理默认地址
        if (Boolean.TRUE.equals(address.getIsDefault())) {
            addressMapper.clearDefaultAddress(userId);
        }

        return this.updateById(address) ?
                Result.success(address) :
                Result.error("更新失败");
    }

    // 删除地址（逻辑删除）
    public Result deleteAddress(String id) {
        return this.update(new LambdaUpdateWrapper<Address>()
                .set(Address::getIsDeleted, true)
                .eq(Address::getId, id)
                .eq(Address::getUserId, ThreadLocalUtil.getUserId())) ?
                Result.success() :
                Result.error("删除失败");
    }


}




