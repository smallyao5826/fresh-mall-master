package com.orion.interceptors;

import com.orion.utils.JwtUtil;
import com.orion.utils.ThreadLocalUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import java.util.Map;

@Component  //将次拦截器放入ioc容器
public class TokenInterceptor implements HandlerInterceptor {
    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    // 接口白名单（需与WebMvcConfig保持一致）
    private static final String[] ALLOWED_PATHS = {
            "/fresh/recommendAll",
            "/fresh/getFreshes",
            "/category/all",
            "/fresh/home",
            "/fresh/category"
    };

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 处理预检请求
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String path = request.getServletPath();

        // 白名单路径直接放行
        if (isAllowed(path)) {
            return true;
        }

        try {
            String token = request.getHeader("Authorization");
            if (token == null || token.isBlank()) {
                response.setStatus(401);
                return false;
            }

            Map<String, Object> parseToken = JwtUtil.parseToken(token);
            String redisToken = stringRedisTemplate.opsForValue().get(token);
            String userName = stringRedisTemplate.opsForValue().get(parseToken.get("id").toString());

            if (redisToken == null || userName == null) {
                response.setStatus(401);
                return false;
            }

            ThreadLocalUtil.set(parseToken);
        } catch (Exception e) {
            response.setStatus(401);
            return false;
        }
        return true;
    }

    private boolean isAllowed(String path) {
        for (String allowedPath : ALLOWED_PATHS) {
            if (path.startsWith(allowedPath)) {
                return true;
            }
        }
        return false;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        //handler方法执行完毕后、handlerAdapter组件之前调用置拦截器
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        //DispatcherSelvet前端控制器返回数据给前端时调用
        ThreadLocalUtil.remove();  //一次请求业务处理完毕删除存储在线程里面的业务数据
    }
}
