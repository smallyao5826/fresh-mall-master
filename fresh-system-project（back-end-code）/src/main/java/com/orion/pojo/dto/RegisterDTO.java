package com.orion.pojo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

// RegisterDTO.java
@Data
public class RegisterDTO {
    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "\\d{11}", message = "手机号格式错误")
    private String phone;

    @NotBlank(message = "密码不能为空")
    @Pattern(regexp = "\\S{5,18}", message = "密码需5-18位非空字符")
    private String password;

    @NotBlank(message = "确认密码不能为空")
    private String rePassword; // 不需要正则校验，只需与password一致
}