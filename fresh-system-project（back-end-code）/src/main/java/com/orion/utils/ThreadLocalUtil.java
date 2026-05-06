package com.orion.utils;

import java.util.Map;
import java.util.HashMap;

/**
 * ThreadLocal 工具类
 * ThreadLocal用来存储线程隔离的数据，存储的数据可以在三层架构的任意接口获取，并且每个用户线程获取的都是自己的数据。
 * 好处：
 * 1、避免参数在三层架构接口方法间的重复传递
 * 2、在三层架构各接口方法间共享数据（每位用户只能获取自己存储的数据）
 */
@SuppressWarnings("all")
public class ThreadLocalUtil {
    //提供ThreadLocal对象,
    /*private static final ThreadLocal THREAD_LOCAL = new ThreadLocal();*/
    private static final ThreadLocal<Map<String, Object>> THREAD_LOCAL =
            ThreadLocal.withInitial(HashMap::new);
    //根据键获取值
    public static <T> T get() {
        return (T) THREAD_LOCAL.get();
    }

    //获取用户ID
    /*public static Integer getUserId() {
        Map map = ThreadLocalUtil.get();
        Integer id = (Integer) map.get("id");
        return id;
    }*/
    public static Integer getUserId() {
        Map<String, Object> context = THREAD_LOCAL.get();
        Object idValue = context.get("id");

        if (idValue instanceof Integer) {
            return (Integer) idValue;
        } else if (idValue != null) {
            try {
                return Integer.parseInt(idValue.toString());
            } catch (NumberFormatException e) {
                throw new IllegalStateException("非法的用户ID格式: " + idValue);
            }
        }
        return null;
    }


    //存储键值对
    public static void set(Object value) {
        THREAD_LOCAL.set((Map<String, Object>) value);
    }


    //清除ThreadLocal 防止内存泄漏
    public static void remove() {
        THREAD_LOCAL.remove();
    }
}
