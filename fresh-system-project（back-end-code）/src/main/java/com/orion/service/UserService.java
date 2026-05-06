package com.orion.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.orion.pojo.User;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author 每一天都是开始
 * @description 针对表【user】的数据库操作Service
 * @createDate 2024-10-10 23:46:08
 */
public interface UserService extends IService<User> {
    /**
     * 用户注册接口
     * 向用户表中增加一条用户记录(注意： 密码加密后插入)
     */
    Result<String> register(String username, String password, String role);

    /**
     * 用户登录接口
     * 1、从数据库中查询该用户名的一条记录，若查询不到则说明此用户名不存在，
     * 否则效验用户密码是否一致，一致则允许登录并生成token保存到redis中并返回给前端，否则不允许登录
     *
     * @param username
     * @param password
     * @return
     */
    Result<Map> login(String username, String password);

    /**
     * 重置用户密码（注意： 密码加密后在保存）
     *
     * @return
     */
    Result resetPasswd(User user);

    /**
     * 分页条件查询用户所有信息
     *
     * @param pageNumber
     * @param pageSize
     * @param role
     * @param search
     * @return
     */
    Result<PageBean<User>> getUsers(Integer pageNumber, Integer pageSize, String role, String search);

    /**
     * 根据id彻底删除用户信息
     *
     * @param id
     * @return
     */
    boolean deleteById(String id);

    /**
     * 定义修改用户密码的参数
     * 1、先判断用户的原密码是否正确，不正确返回错误
     * 2、判断用户新密码两次输入是否一致，不一致则返回错误
     * 3、最后以上条件都正确，则允许修改密码
     *
     * @param params
     * @return
     */
    Result resetUserPwd(Map<String, Object> params, String token);

    /**
     * 获取前端用户侧已登录用户信息包括收货地址
     *
     * @return
     */
    Result<List<HashMap<String, Object>>> getBeforeUserInfo();

    User getCleanUserInfo(Integer userId);


    User updateUserAvatar(String userId, String data);

    Result<PageBean<User>> getLoginLogs(Integer pageNumber, Integer pageSize, String role, String search);

    void updateLoginInfo(Integer id, String ipAddr);
}
