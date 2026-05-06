package com.orion.pojo.helper;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 定义响应给前端的Json统一数据格式工具类
 */
@NoArgsConstructor
@AllArgsConstructor
@Data
public class Result<T> {
    private Integer code;
    private String message;
    private T data;

    /**
     * 定义成功状态的返回的数据格式（携带数据）
     *
     * @param data
     * @param <T>
     * @return
     */
    public static <T> Result<T> success(T data) {
        return new Result<>(0, "操作成功", data);
    }

    /**
     * 定义成功状态不携带数据的格式
     *
     * @param <T>
     * @return
     */
    public static <T> Result<T> success() {
        return new Result<>(0, "操作成功", null);
    }

    /**
     * 定义失败状态返回的数据格式
     *
     * @param message
     * @param <T>
     * @return
     */
    public static <T> Result<T> error(String message) {
        return new Result<>(1, message, null);
    }

}
