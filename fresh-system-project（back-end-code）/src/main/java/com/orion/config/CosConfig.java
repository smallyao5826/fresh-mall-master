package com.orion.config;

import com.qcloud.cos.COSClient;
import com.qcloud.cos.ClientConfig;
import com.qcloud.cos.auth.BasicCOSCredentials;
import com.qcloud.cos.auth.COSCredentials;
import com.qcloud.cos.region.Region;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CosConfig {
    
    @Value("${tencent.cos.secret-id}")
    private String secretId;
    
    @Value("${tencent.cos.secret-key}")
    private String secretKey;
    
    @Value("${tencent.cos.region}")
    private String region;

    @Bean
    public COSClient cosClient() {
        // 1. 初始化密钥
        COSCredentials cred = new BasicCOSCredentials(secretId, secretKey);
        
        // 2. 配置地域
        ClientConfig clientConfig = new ClientConfig(new Region(region));
        
        // 3. 创建客户端
        return new COSClient(cred, clientConfig);
    }
}