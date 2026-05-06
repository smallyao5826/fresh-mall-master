package com.orion.service.impl;

import com.orion.mapper.RecommendConfigMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class RecommendConfigService {
    private static final Set<String> VALID_KEYS =
        Set.of("cf_weight", "content_weight", "random_factor", "min_similarity");
    
    @Autowired
    private RecommendConfigMapper configMapper;

    @Autowired
    private Recommender recommender;

    // 获取配置参数（带缓存）
    @Cacheable(value = "recommendConfig")
    public Map<String, Double> getConfigParams() {
        // 直接获取值，无需二次get
        Map<String, Double> config = configMapper.getConfigParams()
                .entrySet().stream()
                .collect(Collectors.toMap(
                        Map.Entry::getKey,
                        Map.Entry::getValue  // 直接取Double值
                ));

        // 填充默认值
        VALID_KEYS.forEach(key ->
                config.putIfAbsent(key, getDefaultValue(key))
        );
        return config;
    }

    // 更新配置（带参数校验）
    @Transactional
    @CacheEvict(value = "recommendConfig", allEntries = true)
    public void updateConfig(Map<String, Double> paramMap) {
        paramMap.forEach((key, value) -> {
            if (value == null || value < 0 || value > 1) {
                throw new IllegalArgumentException("参数值越界: " + key);
            }
            configMapper.upsertParam(key, value);
        });
        recommender.refreshConfig();
    }

    private Double getDefaultValue(String key) {
        return switch (key) {
            case "cf_weight" -> 0.6;
            case "content_weight" -> 0.3;
            case "random_factor" -> 0.1;
            case "min_similarity" -> 0.2;
            default -> 0.0;
        };
    }
}