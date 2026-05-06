package com.orion.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.orion.pojo.User;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.MapKey;

import java.util.List;
import java.util.Map;

/**
 * @author 每一天都是开始
 * @description 针对表【user】的数据库操作Mapper
 * @createDate 2024-10-10 23:46:08
 * @Entity com.orion.pojo.User
 */

public interface UserMapper extends BaseMapper<User> {

    /**
     * 分页动态SQL查询
     *
     * @param userPage
     * @param role
     * @param search
     */
    IPage<User> getPageUser(Page<User> userPage, String role, String search);

    /**
     * 根据用户ID彻底删除用户
     *
     * @param id
     * @return
     */
    @Delete("delete from fresh_system.user where id = #{id}")
    Integer deleteUser(String id);

    /**
     * 获取用户信息以及其收货地址
     *
     * @param userId
     * @return
     */
    @MapKey("addressID")
    List<Map<String, Object>> selectBeforeUserInfo(Integer userId);
}




