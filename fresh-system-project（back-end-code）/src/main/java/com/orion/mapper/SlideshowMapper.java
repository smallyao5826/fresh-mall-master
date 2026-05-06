package com.orion.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.orion.pojo.Slideshow;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

/**
 * @author Orion
 * @description 针对表【slideshow(轮播图地址存放表)】的数据库操作Mapper
 * @createDate 2024-11-06 00:08:54
 * @Entity com.orion.pojo.Slideshow
 */
public interface SlideshowMapper extends BaseMapper<Slideshow> {

    /**
     * 分页查询轮播图
     *
     * @param slideshowPage
     * @param search
     * @return
     */
    IPage<Map<String, Object>> pageSlidesAll(Page<Slideshow> slideshowPage, String search);

    /**
     * 查询所有轮播图
     *
     * @return
     */
    @Select("select picture_address from fresh_system.slideshow where is_deleted=false order by update_time desc")
    List<String> selectAll();
}




