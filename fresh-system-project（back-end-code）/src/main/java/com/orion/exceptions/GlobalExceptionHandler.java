package com.orion.exceptions;

import com.orion.pojo.helper.Result;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;

@ControllerAdvice  //标记此类为全局异常处理类
@ResponseBody //直接返回数据给前端
public class GlobalExceptionHandler {

    /**
     * 全局异常: handler接口访问出现异常，直接返回给前端异常信息（handler方法捕获的异常将失效）
     * 经测试发现当有多个异常处理方法命中异常时，只执行异常范围最小、最精确的一个处理方法。
     *
     * @param exception
     * @return
     */
    @ExceptionHandler(Exception.class)
    public Result<String> exceptionHandler(Exception exception) {
        exception.printStackTrace();  //打印异常信息
        return Result.error(StringUtils.hasLength(exception.getMessage()) ? exception.getMessage() : "服务异常!");
    }

    /**
     * 参数效验异常处理类(范围小的异常优先级高)
     *
     * @param exception
     * @return
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<String> ValidExceptionHandler(Exception exception) {
        exception.printStackTrace();
        return Result.error("您填写的信息缺少或有误，请检查后重新提交");
    }

    /**
     * 某生鲜重复添加到购物车导致数据库主键冲突异常捕获
     *
     * @param duplicateKeyException
     * @return
     */
    @ExceptionHandler(DuplicateKeyException.class)
    public Result<String> DuplicateKeyExceptionHandler(DuplicateKeyException duplicateKeyException) {
        duplicateKeyException.printStackTrace();
        return Result.error("抱歉!有重复了");
    }

}
