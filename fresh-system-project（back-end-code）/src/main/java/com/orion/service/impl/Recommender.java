package com.orion.service.impl;

import com.orion.mapper.CartMapper;
import com.orion.mapper.FreshMapper;
import com.orion.mapper.RecommendConfigMapper;
import com.orion.pojo.Fresh;
import com.orion.pojo.dto.UserBehavior;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Service
public class Recommender {
    private static final Logger logger = LoggerFactory.getLogger(Recommender.class);

    @Autowired
    private FreshMapper freshMapper;

    @Autowired
    private CartMapper cartMapper;

    @Autowired
    private RecommendConfigMapper configMapper;

    // 物品相似度缓存（线程安全）
    private final ConcurrentHashMap<String, Double> similarityCache = new ConcurrentHashMap<>();

    // 默认配置参数
    private static final Map<String, Double> DEFAULT_CONFIG = Map.of(
            "cf_weight", 0.6,
            "content_weight", 0.3,
            "random_factor", 0.1,
            "min_similarity", 0.2
    );


    public List<Fresh> recommend(Integer userId) {
        long startTime = System.currentTimeMillis();
        try {
            // 1. 加载动态配置
            Map<String, Double> config = loadConfig();

            // 2. 获取全量数据
            List<Fresh> allItems = freshMapper.selectAll();
            List<UserBehavior> allBehaviors = cartMapper.selectAllUserItems();

            // 3. 构建用户-物品矩阵
            Map<Integer, List<Integer>> userItemMap = allBehaviors.stream()
                    .collect(Collectors.groupingBy(
                            UserBehavior::getUserId,
                            Collectors.mapping(UserBehavior::getItemId, Collectors.toList())
                    ));

            // 4. 并行计算推荐得分
            Map<Fresh, Double> scores = new ConcurrentHashMap<>();
            allItems.parallelStream().forEach(item -> {
                double contentScore = calculateContentScore(item);
                double cfScore = calculateCFScore(item.getId(), userItemMap, config);
                double randomFactor = (Math.random() * 2 - 1) * config.get("random_factor");

                double finalScore = config.get("content_weight") * contentScore
                        + config.get("cf_weight") * cfScore
                        + randomFactor;

                scores.put(item, finalScore);
            });

            // 5. 生成排序结果
            return scores.entrySet().stream()
                    .sorted((e1, e2) -> Double.compare(e2.getValue(), e1.getValue()))
                    .map(Map.Entry::getKey)
                    .collect(Collectors.toList());

        } finally {
            logger.info("推荐计算完成，耗时：{}ms", System.currentTimeMillis() - startTime);
        }
    }


    private double calculateContentScore(Fresh item) {
        double score = 0.0;

        // 推荐权重（40%）
        if (item.getIsRecommend()) score += 0.4;

        // 价格因子（价格越低得分越高）
        score += (1 - item.getPrices().doubleValue() / 100) * 0.3;

        // 库存因子（库存充足加分）
        score += (item.getRepertory() > 50 ? 0.2 : 0.1);

        return score;
    }


    private double calculateCFScore(Integer itemId,
                                    Map<Integer, List<Integer>> userItemMap,
                                    Map<String, Double> config) {
        // 1. 构建相似度矩阵
        if (similarityCache.isEmpty()) {
            buildSimilarityMatrix(userItemMap);
        }

        // 2. 查找相似物品
        List<Integer> similarItems = freshMapper.selectAllIds().stream()
                .filter(id -> !id.equals(itemId))
                .filter(id -> {
                    double sim = similarityCache.getOrDefault(
                            getCacheKey(itemId, id), 0.0);
                    return sim > config.get("min_similarity");
                })
                .collect(Collectors.toList());

        // 3. 计算协同得分
        return similarItems.stream()
                .mapToDouble(similarItem -> {
                    long cooccurrence = userItemMap.values().stream()
                            .filter(items -> items.contains(itemId) && items.contains(similarItem))
                            .count();
                    return cooccurrence * similarityCache.get(getCacheKey(itemId, similarItem));
                })
                .sum();
    }


    private synchronized void buildSimilarityMatrix(Map<Integer, List<Integer>> userItemMap) {
        if (!similarityCache.isEmpty()) return;

        List<Integer> allItems = freshMapper.selectAllIds();
        int total = allItems.size();

        allItems.parallelStream().forEach(item1 -> {
            allItems.forEach(item2 -> {
                if (item1 < item2) {
                    // 计算共现次数
                    long coUsers = userItemMap.values().stream()
                            .filter(items -> items.contains(item1) && items.contains(item2))
                            .count();

                    // 计算各自出现次数
                    long count1 = userItemMap.values().stream()
                            .filter(items -> items.contains(item1)).count();
                    long count2 = userItemMap.values().stream()
                            .filter(items -> items.contains(item2)).count();

                    // 改进的相似度公式（加入平滑处理）
                    Double similarity = (double) coUsers /
                            (Math.log(1 + count1) * Math.log(1 + count2) + 1e-6);

                    // 对称存储
                    similarityCache.put(getCacheKey(item1, item2), similarity);
                    similarityCache.put(getCacheKey(item2, item1), similarity);
                }
            });
        });

        logger.info("相似度矩阵构建完成，物品数量：{}", total);
    }


    private Map<String, Double> loadConfig() {
        Map<String, Double> config = new HashMap<>(DEFAULT_CONFIG);
        try {
            configMapper.getConfigParams().forEach((k, v) -> {
                // 确保数值类型转换
                if (v instanceof Number) {
                    config.put(k, ((Number) v).doubleValue());
                }
            });
        } catch (Exception e) {
            logger.warn("加载推荐配置失败，使用默认配置", e);
        }
        return config;
    }

    private String getCacheKey(int item1, int item2) {
        return item1 + "_" + item2;
    }

    public void refreshConfig() {
    }
}