package com.orion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.baomidou.mybatisplus.core.toolkit.StringUtils;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.orion.mapper.UserMapper;
import com.orion.pojo.User;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.service.UserService;
import com.orion.utils.IpUtils;
import com.orion.utils.JwtUtil;
import com.orion.utils.MD5Util;
import com.orion.utils.ThreadLocalUtil;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.TimeUnit;

/**
 * @author 每一天都是开始
 * @description 针对表【user】的数据库操作Service实现
 * @createDate 2024-10-10 23:46:08
 */
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User>
        implements UserService {

    @Autowired
    UserMapper userMapper;

    @Autowired
    StringRedisTemplate stringRedisTemplate;    //服务启动时会自动将此bean组件放入ioc容器

    @Autowired
    private HttpServletRequest request;
    @Override
    public Result<String> register(String username, String password, String role) {
        LambdaQueryWrapper<User> lambdaQueryWrapper = new LambdaQueryWrapper<>();
        lambdaQueryWrapper.eq(User::getUsername, username);
        User user = userMapper.selectOne(lambdaQueryWrapper);
        if (user != null) {
            return Result.error("用户名已被占用");
        }
        String encrypt = MD5Util.encrypt(password);
        User userInsert = new User();
        userInsert.setUsername(username);
        userInsert.setPassword(encrypt);
        userInsert.setRole(role);
        Date date = new Date(System.currentTimeMillis());
        userInsert.setCreateTime(date);
        userInsert.setUpdateTime(date);
        int rows = userMapper.insert(userInsert);
        if (rows > 0)
            return Result.success();
        return Result.error("注册失败!");
    }

    @Override
    public Result<Map> login(String username, String password) {
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getUsername, username);
        User user = userMapper.selectOne(queryWrapper);
        if (user == null) {
            return Result.error("用户名不存在!");
        }
        String encrypt = MD5Util.encrypt(password);
        if (!user.getPassword().equals(encrypt)) {
            return Result.error("密码不正确!");
        }



        //生成token分别保存到redis中并返回前端
        HashMap<String, Object> hashMap = new HashMap<>();
        hashMap.put("id", user.getId());
        hashMap.put("username", user.getUsername());
        String token = JwtUtil.genToken(hashMap);
        ValueOperations<String, String> opsForValue = stringRedisTemplate.opsForValue();
        opsForValue.set(token, token, 12, TimeUnit.HOURS);  //将token保存到redis中（键值对）
        opsForValue.set(String.valueOf(user.getId()), user.getUsername(), 12, TimeUnit.HOURS);  //将用户的基本信息保存到Redis中，用于前端用户被删除时立刻跳转到登录页（token+userID双机制）。
        HashMap<String, Object> date = new HashMap<>();
        date.put("token", token);  //定义登录成功返回给前端的数据
        date.put("role", user.getRole());
        return Result.success(date);
    }

    @Override
    public Result resetPasswd(User user) {
        int rows = userMapper.updateById(user);
        if (rows < 1) {
            return Result.error("重置密码失败!");
        }
        return Result.success();
    }

    @Override
    public Result<PageBean<User>> getUsers(Integer pageNumber, Integer pageSize, String role, String search) {
        Page<User> userPage = new Page<>(pageNumber, pageSize);
        userMapper.getPageUser(userPage, role, search);
        PageBean<User> userPageBean = new PageBean<>();
        userPageBean.setItems(userPage.getRecords());
        userPageBean.setTotal(userPage.getTotal());
        return Result.success(userPageBean);
    }

    @Override
    public boolean deleteById(String id) {
        Integer rows = userMapper.deleteUser(id);
        return rows >= 1;
    }

    @Override
    public Result resetUserPwd(Map<String, Object> params, String token) {
        //判断用户原密码是否填写错误
        User user = userMapper.selectById(ThreadLocalUtil.getUserId());
        if (!user.getPassword().equals(MD5Util.encrypt(params.get("initPwd").toString()))) {
            return Result.error("原密码不正确!");
        }
        //判断两次新密码是否一致
        if (!params.get("newPwd").equals(params.get("reNewPwd"))) {
            return Result.error("新密码前后输入不一致!");
        }
        //修改密码
        String newPwd = (String) params.get("newPwd");
        User user1 = new User();
        user1.setId(ThreadLocalUtil.getUserId());
        user1.setPassword(MD5Util.encrypt(newPwd));
        Date date = new Date(System.currentTimeMillis());
        user1.setUpdateTime(date);
        user1.setVersion(user.getVersion());
        int rows = userMapper.updateById(user1);
        if (rows < 1)
            return Result.error("修改密码失败!");
        //清空Redis中保存的用户token和id用户名
        stringRedisTemplate.delete(token);
        stringRedisTemplate.delete(String.valueOf(ThreadLocalUtil.getUserId()));
        return Result.success();
    }

    @Override
    public Result<List<HashMap<String, Object>>> getBeforeUserInfo() {
        // 获取当前用户ID
        Integer userId = ThreadLocalUtil.getUserId();

        // 从数据库查询原始数据
        List<Map<String, Object>> userList = userMapper.selectBeforeUserInfo(userId);

        // 处理用户基本信息
        List<HashMap<String, Object>> userInfoList = userList.stream()
                .map(userInfo -> {
                    HashMap<String, Object> userMap = new HashMap<>();
                    userMap.put("id", userInfo.get("id"));
                    userMap.put("username", userInfo.get("username"));
                    userMap.put("role", userInfo.get("role"));
                    userMap.put("nickName", userInfo.get("nickName"));
                    userMap.put("account", userInfo.get("account"));
                    userMap.put("avatar", userInfo.get("avatar"));
                    userMap.put("birthday", userInfo.get("birthday"));
                    userMap.put("email", userInfo.get("email"));
                    userMap.put("phone", userInfo.get("phone"));
                    return userMap;
                })
                .distinct()
                .toList();

        // 处理地址信息（核心修正）
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        List<HashMap<String, Object>> addressList = userList.stream()
                .filter(userInfo ->
                        userInfo.get("addressID") != null &&  // 仅检查 addressID 是否存在
                                userInfo.get("province") != null      // 确保省份字段存在
                )
                .map(userInfo -> {
                    HashMap<String, Object> addressMap = new HashMap<>();

                    // 填充地址字段（使用修正后的别名）
                    addressMap.put("name", userInfo.get("addressName"));      // 修正别名
                    addressMap.put("phone", userInfo.get("addressPhone"));    // 修正别名
                    addressMap.put("province", userInfo.get("province"));
                    addressMap.put("city", userInfo.get("city"));
                    addressMap.put("district", userInfo.get("district"));
                    addressMap.put("detailedAddress", userInfo.get("detailedAddress"));
                    addressMap.put("addressID", userInfo.get("addressID"));

                    // 处理时间字段
                    LocalDateTime createTime = (LocalDateTime) userInfo.get("createTime");
                    LocalDateTime updateTime = (LocalDateTime) userInfo.get("updateTime");
                    addressMap.put("createTime", createTime.format(formatter));
                    addressMap.put("updateTime", updateTime.format(formatter));

                    return addressMap;
                })
                .toList();

        // 合并数据
        if (!userInfoList.isEmpty()) {
            userInfoList.get(0).put("addressList", addressList);
        }

        return Result.success(userInfoList);
    }

    @Override
    public User getCleanUserInfo(Integer userId) {
        User user = this.getById(userId);
        // 清理敏感/不必要字段
        user.setPassword(null);
        user.setIsDeleted(null);
        user.setVersion(null);
        user.setCreateTime(null); // 按需保留
        user.setUpdateTime(null);
        return user;
    }

    @Override
    public User updateUserAvatar(String userId, String avatarUrl) {
        // 创建更新条件
        UpdateWrapper<User> updateWrapper = new UpdateWrapper<>();
        updateWrapper.eq("id", userId)
                .set("avatar", avatarUrl)
                .set("update_time", new Date());

        // 执行更新
        boolean success = this.update(updateWrapper);

        // 返回最新用户信息
        return success ? this.getById(userId) : null;
    }

    @Override
    public Result<PageBean<User>> getLoginLogs(Integer pageNumber, Integer pageSize, String role, String search) {
        Page<User> page = new Page<>(pageNumber, pageSize);

        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper
                .like(StringUtils.isNotBlank(search), User::getUsername, search)
                .eq(StringUtils.isNotBlank(role), User::getRole, role)
                .isNotNull(User::getLastLoginTime)
                .orderByDesc(User::getLastLoginTime);

        this.page(page, queryWrapper);

        PageBean<User> pageBean = new PageBean<>();
        pageBean.setItems(page.getRecords());
        pageBean.setTotal(page.getTotal());
        return Result.success(pageBean);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateLoginInfo(Integer userId, String ip) {
        User updateUser = new User();
        updateUser.setId(userId);
        updateUser.setLastLoginIp(ip);
        updateUser.setLastLoginTime(LocalDateTime.now());
        this.updateById(updateUser);
    }


}




