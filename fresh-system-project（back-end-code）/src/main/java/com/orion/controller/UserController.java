package com.orion.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.orion.pojo.User;
import com.orion.pojo.dto.AdminLoginDTO;
import com.orion.pojo.dto.RegisterDTO;
import com.orion.pojo.dto.UserLoginDTO;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.service.UserService;
import com.orion.utils.IpUtils;
import com.orion.utils.JwtUtil;
import com.orion.utils.MD5Util;
import com.orion.utils.ThreadLocalUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import org.hibernate.validator.constraints.URL;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import java.util.concurrent.TimeUnit;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/*
 * @Description TODO 用户管理
 * @Date 2024/10/8  10:36
 * @Author Orion
 **/
@Controller   //标记此类为ioc组件
@ResponseBody  //直接返回数据给前端不走视图解析器
@Validated   //使handler方法参数效验注解生效
@CrossOrigin(originPatterns = {"http://*:5173"}, maxAge = 3600L)
//允许前端用户跨域访问handler方法,originPatterns正则允许访问的浏览器源，maxAge浏览器预检请求自动发送间隔秒。
@RequestMapping("user")
public class UserController {
    @Autowired
    UserService userService;

    @Autowired
    StringRedisTemplate redisTemplate;

    @Autowired
    private HttpServletRequest request;

    // 普通用户注册接口
    @PostMapping("register")
    public Result<String> register(@RequestBody @Validated RegisterDTO dto) {
        // 检查两次密码是否一致
        if (!dto.getPassword().equals(dto.getRePassword())) {
            return Result.error("两次输入的密码不一致");
        }

        LambdaQueryWrapper<User> query = new LambdaQueryWrapper<>();
        query.eq(User::getPhone, dto.getPhone());
        if (userService.getOne(query) != null) {
            return Result.error("手机号已注册");
        }

        User user = new User();
        user.setUsername("用户" + dto.getPhone().substring(dto.getPhone().length() - 4));
        user.setPhone(dto.getPhone());
        user.setPassword(MD5Util.encrypt(dto.getPassword()));
        user.setRole("普通用户");
        user.setCreateTime(new Date());
        user.setUpdateTime(new Date());

        boolean saved = userService.save(user);
        return saved ? Result.success("注册成功") : Result.error("注册失败");
    }

    // 普通用户登录接口
    @PostMapping("/login")
    public Result<Map> userLogin(@RequestBody @Validated UserLoginDTO dto) {

        LambdaQueryWrapper<User> query = new LambdaQueryWrapper<>();
        query.eq(User::getPhone, dto.getPhone());
        User user = userService.getOne(query);

        if (user == null) return Result.error("手机号未注册");
        if (!user.getPassword().equals(MD5Util.encrypt(dto.getPassword()))) {
            return Result.error("密码错误");
        }

        userService.updateLoginInfo(user.getId(), IpUtils.getIpAddr(request));

        // 生成token
        Map<String, Object> claims = new HashMap<>();
        claims.put("id", user.getId());
        claims.put("phone", dto.getPhone());
        String token = JwtUtil.genToken(claims);

        // 保存到Redis...
        ValueOperations<String, String> ops = redisTemplate.opsForValue();
        ops.set(token, token, 12, TimeUnit.HOURS);
        ops.set(String.valueOf(user.getId()), user.getRole(), 12, TimeUnit.HOURS);

        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("role", user.getRole());
        return Result.success(data);
    }

    // 管理员登录接口
    @PostMapping("/adminLogin")
    public Result<Map> adminLogin(@RequestBody @Validated AdminLoginDTO dto) {

        LambdaQueryWrapper<User> query = new LambdaQueryWrapper<>();
        query.eq(User::getUsername, dto.getUsername());
        User user = userService.getOne(query);

        if (user == null) return Result.error("用户不存在");
        if (!"管理员".equals(user.getRole())) {
            return Result.error("非管理员账号");
        }
        if (!user.getPassword().equals(MD5Util.encrypt(dto.getPassword()))) {
            return Result.error("密码错误");
        }

        userService.updateLoginInfo(user.getId(), IpUtils.getIpAddr(request));

        // 生成token
        Map<String, Object> claims = new HashMap<>();
        claims.put("id", user.getId());
        claims.put("username", dto.getUsername());
        String token = JwtUtil.genToken(claims);

        // 保存到Redis...
        ValueOperations<String, String> ops = redisTemplate.opsForValue();
        ops.set(token, token, 12, TimeUnit.HOURS);
        ops.set(String.valueOf(user.getId()), user.getRole(), 12, TimeUnit.HOURS);

        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("role", user.getRole());
        return Result.success(data);
    }



    /**
     * 获取当前登录的用户信息
     */
    @GetMapping("info")
    public Result<User> getInfo() {
        Integer userId = ThreadLocalUtil.getUserId();
        User userInfo = userService.getCleanUserInfo(userId); // 获取清理后的用户信息
        return Result.success(userInfo);
    }

    /**
     * 分页查询用户的所有信息
     *
     * @param pageNumber
     * @param pageSize
     * @param role
     * @param search
     * @return
     */
    @GetMapping("getUserAll")
    public Result<PageBean<User>> getUserAll(@NotNull Integer pageNumber, @NotNull Integer pageSize, String role, String search) {
        return userService.getUsers(pageNumber, pageSize, role, search);
    }

    /**
     * 定义添加用户的接口
     */
    @PostMapping("addUser")
    /*public Result addUser(@RequestBody @Validated({User.AddUser.class}) User user) {
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getUsername, user.getUsername());
        User one = userService.getOne(queryWrapper);
        if (one != null) {
            return Result.error("用户名已被占用!");
        }
        Date date = new Date(System.currentTimeMillis());
        user.setCreateTime(date);
        user.setUpdateTime(date);
        user.setPassword(MD5Util.encrypt(user.getPassword()));
        boolean save = userService.save(user);
        return save ? Result.success() : Result.error("新增用户失败!");
    }*/

    /**
     * 定义更新用户信息的接口
     */

    @PutMapping("/update")
    public Result<User> updateUserInfo(@RequestBody @Validated User user) {
        try {
            // 获取当前用户信息（带版本号）
            User currentUser = userService.getById(user.getId());

            // 设置更新参数
            user.setVersion(currentUser.getVersion() + 1); // 版本号+1
            user.setUpdateTime(new Date());

            // 执行更新
            boolean success = userService.updateById(user);

            // 获取更新后的完整数据
            User updatedUser = userService.getById(user.getId());

            return success ?
                    Result.success(updatedUser) :
                    Result.error("更新失败");

        } catch (Exception e) {
            return Result.error("服务器错误: " + e.getMessage());
        }
    }

    /**
     * 定义删除用户的接口
     */
    @DeleteMapping("delete")
    public Result deleteUser(@NotEmpty String id, @RequestHeader("Authorization") String token) {
        boolean row = userService.deleteById(id);
        if (row && ThreadLocalUtil.getUserId().equals(id)) {
            redisTemplate.delete(token); //如果管理员删除的是自己，则将Redis中存储的当前用户token信息删除进而使用户token失效，跳转到登录也。
            redisTemplate.delete(String.valueOf(ThreadLocalUtil.getUserId()));
        } else if (row) {
            redisTemplate.delete(id); //删除的是普通用户则将Redis中存储的用户基本信息删除，从而使正在登录的用户跳转到登录页。
        }
        return row ? Result.success() : Result.error("删除用户失败!");
    }

    /**
     * 定义上传用户头像地址的接口
     *
     * @param
     * @return
     */
    @PatchMapping("uploadAvatarUrl")
    public Result uploadAvatarUrl(@NotEmpty @URL String avatar) {
        User user = new User();
        user.setAvatar(avatar);
        user.setId(ThreadLocalUtil.getUserId());
        boolean row = userService.updateById(user);
        return row ? Result.success() : Result.error("修改用户头像失败!");
    }

    /**
     * 定义重置用户密码的接口
     * Map集合接收参数：
     * params参数----1、需要在Map形参前添加@RequestParam注解
     * Json数据-----1、需要在形参前添加@RequestBody注解
     *
     * @param params
     * @return
     */
    @PatchMapping("resetPasswd")
    public Result resetPasswd(@RequestBody Map<String, Object> params, @RequestHeader("Authorization") String token) {
        if (params.get("initPwd").toString().length() < 5 || params.get("initPwd").toString().length() > 18) {
            return Result.error("原密码长度有误!");
        }
        if (params.get("newPwd").toString().length() < 5 || params.get("newPwd").toString().length() > 18) {
            return Result.error("新密码长度有误!");
        }
        return userService.resetUserPwd(params, token);
    }

    /**
     * 获取前端用户侧已登录用户的信息包括收货地址
     *
     * @return
     */
    @GetMapping("beforeUserInfo")
    public Result<List<HashMap<String, Object>>> getBeforeInfo() {
        return userService.getBeforeUserInfo();
    }

    /**
     * 新版用户信息更新接口
     * 路径改为 /updateUserInfo
     * 增加详细日志输出
     */
    @PutMapping("/updateUserInfo")
    @Transactional
    public Result<User> updateUserInfoV2(@RequestBody @Validated User user) {
        // 强制从数据库获取最新数据（避免缓存）
        User currentUser = userService.getById(user.getId());
        if (currentUser == null) {
            return Result.error("用户不存在");
        }


        // 使用当前时间（修复未来时间问题）
        user.setUpdateTime(new Date());

        // 执行更新
        boolean success = userService.updateById(user);
        if (!success) {
            return Result.error("更新失败");
        }

        // 重新查询数据库获取最新数据
        User updatedUser = userService.getById(user.getId());
        return Result.success(updatedUser);
    }

    // 新增登录日志查询接口
    @GetMapping("/login-logs")
    public Result<PageBean<User>> getLoginLogs(
            @RequestParam(defaultValue = "1") Integer pageNumber,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String role) {
        return userService.getLoginLogs(pageNumber, pageSize, role, search);
    }
}
