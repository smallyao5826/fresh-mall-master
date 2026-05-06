package com.orion;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.BlockAttackInnerInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.OptimisticLockerInnerInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication  //1、标记此类为配置类 2、扫描根包下的所有IOC组件 3、自动加载其它配置类
@MapperScan("com.orion.mapper")  //扫描mapper接口生成其jdk动态代理对象
public class FreshSystemApplication {
    public static void main(String[] args) {
        SpringApplication.run(FreshSystemApplication.class, args);
    }

    /*将MybatisPlusInterceptor拦截器插件注入到ioc容器中，以便配置其它内部插件
    * 一、乐观锁的实现通常包括以下步骤：
        读取记录时，获取当前的版本号（version）。
        在更新记录时，将这个版本号一同传递。
        执行更新操作时，设置 version = newVersion 的条件为 version = oldVersion。
        如果版本号不匹配，则更新失败。
    * */
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor mybatisPlusInterceptor = new MybatisPlusInterceptor();
        mybatisPlusInterceptor.addInnerInterceptor(new BlockAttackInnerInterceptor()); //添加防止全表记录更新或删除插件
        mybatisPlusInterceptor.addInnerInterceptor(new OptimisticLockerInnerInterceptor());   //添加防止高并发场景下多用户同时更新修改数据可能导致数据不一致问题的乐观锁插件
        mybatisPlusInterceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));   //添加分页插件
        return mybatisPlusInterceptor;  //将其实例放入ioc容器
    }

}
