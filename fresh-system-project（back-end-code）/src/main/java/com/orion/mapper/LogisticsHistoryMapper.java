package com.orion.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orion.pojo.LogisticsHistory;
import org.apache.ibatis.annotations.Select;

import java.util.List;

public interface LogisticsHistoryMapper extends BaseMapper<LogisticsHistory> {
    @Select("SELECT * FROM logistics_history WHERE logistics_id = #{logisticsId} ORDER BY event_time DESC")
    List<LogisticsHistory> selectHistories(Integer logisticsId);
}