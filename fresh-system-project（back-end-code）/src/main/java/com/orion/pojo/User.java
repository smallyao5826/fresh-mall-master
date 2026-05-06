package com.orion.pojo;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.orion.customAnnotation.IsRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.groups.Default;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Date;

/**
 * @TableName user
 */
@Data  //自动为实体类添加get、set、toString方法
@TableName("user")  //标记此类对应的数据表名
public class User implements Serializable {

    @TableId(type = IdType.AUTO)
    private Integer id;

    @Pattern(regexp = "^\\S{2,10}$", groups = {ForgetPasswd.class, AddUser.class})  //指定参数效验所属组
    private String username;

    @Pattern(regexp = "^\\S{5,18}$", groups = {ForgetPasswd.class, AddUser.class})
    private String password;


    @Email(groups = {ForgetPasswd.class, AddUser.class})
    private String email;

    @Pattern(regexp = "\\d{11}", groups = {AddUser.class})
    private String phone;

    private String avatar;

    @IsRole(groups = {AddUser.class})
    private String role;

    @TableField("last_login_time")  // 确保与数据库列名一致
    private LocalDateTime lastLoginTime;

    @TableField("last_login_ip")     // 确保与数据库列名一致
    private String lastLoginIp;


    @JsonIgnore
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date createTime;

    @JsonIgnore
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date updateTime;

    @JsonIgnore
    private Integer isDeleted;

    @Version   //标记此属性为对应数据表的版本号字段
    @JsonIgnore
    private Integer version;

    private static final long serialVersionUID = 1L;

    /*定义重置密码参数效验的分组接口*/
    public interface ForgetPasswd extends Default {
    }


    public interface AdminAdd {} // 管理员添加校验
    public interface AddUser {}  // 普通用户注册校验
}