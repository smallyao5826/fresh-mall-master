package com.orion.utils;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;

import java.util.Date;
import java.util.Map;

/**
 * token组成:
 * header:  算法，类型
 * loader: 键值对业务数据
 * sign: 数字签名部分
 */
public class JwtUtil {

    //定义token数据签名部分加解密使用的密钥
    private static final String KEY = "Root123";

    //接收业务数据,生成token并返回
    public static String genToken(Map<String, Object> claims) {
        return JWT.create()  //获取token构建工具
                .withClaim("claims", claims) //为token载荷中间部分添加业务数据，指定键值对
                .withExpiresAt(new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 12)) //设置token在被创建12小时后失效
                .sign(Algorithm.HMAC256(KEY));   //设置token使用的密钥
    }

    //接收token,验证token,并返回业务数据(解析报错情况: 1、头和业务数据被修改 2、密钥不一致 3、有效时间过了)
    public static Map<String, Object> parseToken(String token) {
        return JWT.require(Algorithm.HMAC256(KEY))  //获取token效验并指定解析token的密钥（生成和解析使用的密钥是一样的）
                .build()   //获取token效验工具
                .verify(token)  //解析token
                .getClaim("claims")//获取token载荷中间部分的键值对类型的业务数据
                .asMap();  //将获取到的数据转换为map类型返回
    }

}
