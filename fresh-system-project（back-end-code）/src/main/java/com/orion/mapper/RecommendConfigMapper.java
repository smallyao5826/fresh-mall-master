package com.orion.mapper;

import com.baomidou.mybatisplus.annotation.InterceptorIgnore;
import org.apache.ibatis.annotations.*;

import java.util.Map;

@Mapper
public interface RecommendConfigMapper {

    @MapKey("config_key")  // 指定Map的key字段
    Map<String, Double> getConfigParams();
    @InterceptorIgnore(blockAttack = "true")  // 关键注解
    void upsertParam(@Param("key") String key, @Param("value") Double value);
}