package com.orion.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.alipay.api.AlipayApiException;
import com.alipay.api.AlipayClient;
import com.alipay.api.DefaultAlipayClient;
import com.alipay.api.request.AlipayTradePagePayRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;

// AlipayService.java
@Service
public class AlipayService {
    @Value("${alipay.appId}") private String appId;
    @Value("${alipay.appPrivateKey}") private String appPrivateKey;
    @Value("${alipay.alipayPublicKey}") private String alipayPublicKey;
    @Value("${alipay.notifyUrl}") private String notifyUrl;

    public String createPayment(String orderNo, BigDecimal amount) throws AlipayApiException {
        AlipayClient alipayClient = new DefaultAlipayClient(
            "https://openapi-sandbox.dl.alipaydev.com/gateway.do",
            appId,
            appPrivateKey,
            "json",
            "UTF-8",
            alipayPublicKey,
            "RSA2"
        );

        AlipayTradePagePayRequest request = new AlipayTradePagePayRequest();
        request.setNotifyUrl(notifyUrl);
        request.setReturnUrl("http://localhost:5173/userMain/payment-success");

        JSONObject bizContent = new JSONObject();
        bizContent.put("out_trade_no", orderNo);
        bizContent.put("total_amount", amount.setScale(2, RoundingMode.HALF_UP));
        bizContent.put("subject", "生鲜商品订单");
        bizContent.put("product_code", "FAST_INSTANT_TRADE_PAY");
        
        request.setBizContent(bizContent.toJSONString());
        
        return alipayClient.pageExecute(request).getBody();
    }
}