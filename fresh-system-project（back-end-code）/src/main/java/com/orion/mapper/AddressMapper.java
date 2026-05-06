package com.orion.mapper;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.orion.pojo.Address;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

/**
 * @author Orion
 * @description 针对表【address(收货地址表)】的数据库操作Mapper
 * @createDate 2024-11-07 01:40:02
 * @Entity com.orion.pojo.Address
 */
public interface AddressMapper extends BaseMapper<Address> {
    // 根据用户ID查询地址列表
    @Select("SELECT * FROM address WHERE user_id = #{userId} AND is_deleted = 0")
    List<Address> selectByUserId(String userId);

    // 清除默认地址状态
    @Update("UPDATE address SET is_default = 0 WHERE user_id = #{userId}")
    int clearDefaultAddress(Integer userId);

}




