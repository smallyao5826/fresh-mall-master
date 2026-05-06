package com.orion.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.orion.mapper.SlideshowMapper;
import com.orion.pojo.Slideshow;
import com.orion.pojo.helper.PageBean;
import com.orion.pojo.helper.Result;
import com.orion.service.SlideshowService;
import com.orion.utils.ThreadLocalUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * @author Orion
 * @description 针对表【slideshow(轮播图地址存放表)】的数据库操作Service实现
 * @createDate 2024-11-06 00:08:54
 */
@Service
public class SlideshowServiceImpl extends ServiceImpl<SlideshowMapper, Slideshow>
        implements SlideshowService {

    @Autowired
    private SlideshowMapper slideshowMapper;

    @Override
    public Result addSlide(String slideUrl) {
        Slideshow slideshow = new Slideshow();
        slideshow.setPictureAddress(slideUrl);
        slideshow.setCreateTime(LocalDateTime.now());
        slideshow.setUpdateTime(LocalDateTime.now());
        int row = slideshowMapper.insert(slideshow);
        return row > 0 ? Result.success() : Result.error("发布轮播图失败!");
    }

    @Override
    public Result<PageBean<Slideshow>> pageSlides(Integer pageNumber, Integer pageSize, String search) {
        Page<Slideshow> slideshowPage = new Page<>(pageNumber, pageSize);
        slideshowMapper.pageSlidesAll(slideshowPage, search);
        PageBean<Slideshow> mapPageBean = new PageBean<>();
        mapPageBean.setTotal(slideshowPage.getTotal());
        mapPageBean.setItems(slideshowPage.getRecords());
        return Result.success(mapPageBean);
    }

    @Override
    public Result<List<String>> obtainAll() {
        java.util.List<String> list = slideshowMapper.selectAll();
        return Result.success(list);
    }
}




