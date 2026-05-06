package com.orion.config;

import com.orion.interceptors.TokenInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration  //标记此类为配置类放入ioc容器
public class WebMvcConfig implements WebMvcConfigurer {
    @Autowired
    private TokenInterceptor tokenInterceptor;

    /**
     * 注册token拦截器： 对所有非登录和注册页发给handler方法的请求都进行拦截token效验
     *
     * @param registry
     */

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(tokenInterceptor)
                .excludePathPatterns("/user/login")
                .excludePathPatterns("/user/adminLogin")
                .excludePathPatterns("/user/register")
                .excludePathPatterns("/user/forgetPasswd")
                .excludePathPatterns("/slidePicture/all")
                .excludePathPatterns("/fresh/recommendAll")
                .excludePathPatterns("/recommend")
                .excludePathPatterns("/fresh/getFreshes")
                .excludePathPatterns("/category/all")
                .excludePathPatterns("/file/download/**")
                .excludePathPatterns("/file/upload-avatar")
                .excludePathPatterns("/user/update")
                .excludePathPatterns("/user/updateUserInfo");
    }
}
