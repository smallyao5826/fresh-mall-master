package com.orion.controller;

import com.orion.pojo.Slideshow;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.service.SlideshowService;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import org.hibernate.validator.constraints.URL;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/*
 * @Description TODO 轮播图管理
 * @Date 2024/10/25  10:35
 * @Author Orion
 **/
@RestController
@CrossOrigin(originPatterns = {"http://*:5173"}, maxAge = 3600L)
@Validated
@RequestMapping("slidePicture")
public class SlideshowController {

    @Autowired
    private SlideshowService slideshowService;

    /**
     * 添加轮播图接口
     *
     * @param slideUrl
     * @return
     */
    @PostMapping()
    public Result addSlidePicture(@URL @NotEmpty String slideUrl) {
        return slideshowService.addSlide(slideUrl);
    }

    /**
     * 获取所有轮播图接口
     */
    @GetMapping()
    public Result<PageBean<Slideshow>> getSlides(@NotNull Integer pageNumber, @NotNull Integer pageSize, String search) {
        return slideshowService.pageSlides(pageNumber, pageSize, search);
    }

    /**
     * 定义修改轮播图的接口
     */
    @PatchMapping()
    public Result modifySlideUrl(@NotEmpty String id, @NotEmpty String url) {
        Slideshow slideshow = new Slideshow();
        slideshow.setId(id);
        slideshow.setPictureAddress(url);
        slideshow.setUpdateTime(LocalDateTime.now());
        Boolean statue = slideshowService.updateById(slideshow);
        return statue ? Result.success() : Result.error("轮播图修改失败!");
    }

    /**
     * 定义删除轮播图的方法
     */
    @DeleteMapping()
    public Result deleteSlide(@NotEmpty String id) {
        boolean status = slideshowService.removeById(id);
        return status ? Result.success() : Result.error("轮播图删除失败!");
    }


    /**
     * 获取所有的轮播图
     *
     * @return
     */
    @GetMapping("all")
    public Result<List<String>> getAll() {
        return slideshowService.obtainAll();
    }
}
