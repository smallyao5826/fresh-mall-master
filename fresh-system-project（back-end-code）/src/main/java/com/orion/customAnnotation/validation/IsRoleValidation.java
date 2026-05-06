package com.orion.customAnnotation.validation;

import com.orion.customAnnotation.IsRole;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import org.springframework.util.StringUtils;

/**
 * 泛型1: 要绑定的自定义效验注解
 * 泛型2：要效验的实体类的属性所属类型
 */
public class IsRoleValidation implements ConstraintValidator<IsRole, String> {
    /**
     * @param s                          要效验的实体类属性前端传递来的值
     * @param constraintValidatorContext
     * @return true:效验通过, false：效验失败
     */
    @Override
    public boolean isValid(String s, ConstraintValidatorContext constraintValidatorContext) {
        if (!StringUtils.hasLength(s))
            return false;
        return s.equals("普通用户") || s.equals("管理员");
    }
}
