package com.orion.customAnnotation;

import com.orion.customAnnotation.validation.IsRoleValidation;
import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import java.lang.annotation.*;

@Documented //元注解：生成文档
@Constraint(  //效验规则类： 指定此注解使用的效验类
        validatedBy = {IsRoleValidation.class}
)
@Target({ElementType.METHOD, ElementType.FIELD})  //注解使用范围：此注解只能在方法形参和类的属性字段上使用
@Retention(RetentionPolicy.RUNTIME)  //注解保留策略：可以在程序运行时保留此注解
public @interface IsRole {
    //效验失败默认提示信息
    String message() default "只能是普通用户 或 管理员!";

    //此直接所属效验组
    Class<?>[] groups() default {};

    //可以通过该属性获取此注解的负载信息
    Class<? extends Payload>[] payload() default {};
}
