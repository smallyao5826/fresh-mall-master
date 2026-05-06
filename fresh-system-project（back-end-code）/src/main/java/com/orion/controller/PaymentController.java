package com.orion.controller;

import com.alipay.api.AlipayApiException;
import com.alipay.api.internal.util.AlipaySignature;
import com.orion.service.OrderService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.stream.Collectors;

// PaymentController.java
@RestController
@RequestMapping("/payment")
public class PaymentController {

    @Value("${alipay.alipayPublicKey}") // 添加此注解
    private String alipayPublicKey;

    @Autowired
    private OrderService orderService;

    @PostMapping("/alipay/notify")
    public String handleAlipayNotify(HttpServletRequest request) {
        Map<String, String> params = convertRequestParams(request);
        
        try {
            boolean signVerified = AlipaySignature.rsaCheckV1(
                params,
                alipayPublicKey,
                "UTF-8",
                "RSA2"
            );

            if (signVerified) {
                String tradeStatus = params.get("trade_status");
                String orderNo = params.get("out_trade_no");
                
                if ("TRADE_SUCCESS".equals(tradeStatus)) {
                    orderService.updateOrderStatus(orderNo, "已支付");
                    return "success";
                }
            }
        } catch (AlipayApiException e) {
            throw new RuntimeException(e);
        }
        return "failure";
    }

    private Map<String, String> convertRequestParams(HttpServletRequest request) {
        return request.getParameterMap().entrySet().stream()
            .collect(Collectors.toMap(
                Map.Entry::getKey,
                entry -> String.join(",", entry.getValue())
            ));
    }
}