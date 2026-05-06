package com.orion.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.orion.pojo.Slideshow;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;

import java.util.List;

/**
 * @author Orion
 * @description 针对表【slideshow(轮播图地址存放表)】的数据库操作Service
 * @createDate 2024-11-06 00:08:54
 */
public interface SlideshowService extends IService<Slideshow> {

    /**
     * 添加轮播图
     *
     * @param slideUrl
     * @return
     */
    Result addSlide(String slideUrl);

    /**
     * 分页查询所有轮播图
     *
     * @param pageNumber
     * @param pageSize
     * @param search
     * @return
     */
    Result<PageBean<Slideshow>> pageSlides(Integer pageNumber, Integer pageSize, String search);

    /**
     * 获取所有的轮播图地址
     *
     * @return
     */
    Result<List<String>> obtainAll();
}
