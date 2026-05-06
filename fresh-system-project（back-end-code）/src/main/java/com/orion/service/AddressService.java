package com.orion.service;

import com.orion.pojo.Address;
import com.baomidou.mybatisplus.extension.service.IService;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import org.springframework.transaction.annotation.Transactional;

/**
 * @author Orion
 * @description 针对表【address(收货地址表)】的数据库操作Service
 * @createDate 2024-11-07 01:40:02
 */
public interface AddressService extends IService<Address> {


    Result addAddress(Address address);

    Result updateAddress(Address address);

    Result deleteAddress(String id);
}
