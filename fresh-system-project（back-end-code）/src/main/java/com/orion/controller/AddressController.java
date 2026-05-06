package com.orion.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.orion.pojo.Address;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.service.AddressService;
import com.orion.utils.ThreadLocalUtil;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

/*
 * @Description TODO 收货地址管理
 * @Date 2024/10/8 10:30
 * @Author Orion
 **/
@RestController
@CrossOrigin(originPatterns = {"http://*:5173"}, maxAge = 3600L)  //前后端分离允许指定源的浏览器访问，并且浏览器预检请求1个小时向此处发一次
@RequestMapping("/userAddress")
public class AddressController {
    @Autowired
    private AddressService addressService;

    // 添加地址
    @PostMapping
    public Result add(@RequestBody @Valid Address address) {
        return addressService.addAddress(address);
    }

    // 更新地址
    @PutMapping
    public Result update(@RequestBody @Valid Address address) {
        return addressService.updateAddress(address);
    }

    // 删除地址
    @DeleteMapping("/{id}")
    public Result delete(@PathVariable String id) {
        return addressService.deleteAddress(id);
    }

    // 获取地址列表
    @GetMapping
    public Result list() {
        Integer userId = ThreadLocalUtil.getUserId();
        return Result.success(addressService.list(
                new LambdaQueryWrapper<Address>()
                        .eq(Address::getUserId, userId)
                        .eq(Address::getIsDeleted, false)
                        .orderByDesc(Address::getIsDefault)
        ));
    }
}
