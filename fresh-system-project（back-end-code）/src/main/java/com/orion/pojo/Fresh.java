package com.orion.pojo;

import com.baomidou.mybatisplus.annotation.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.validation.groups.Default;
import lombok.Data;
import lombok.experimental.Accessors;
import net.minidev.json.annotate.JsonIgnore;
import org.hibernate.validator.constraints.URL;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * @TableName fresh
 */
@Data
@TableName("fresh")  //指定此类对应的数据库中的那张表，BaseMap接口中的方法通过此类的此注解操作对应表
@Accessors(chain = true)
public class Fresh implements Serializable {
    @TableId(type = IdType.AUTO)
    private Integer id;

    @NotEmpty
    private String freshName;

    @NotEmpty
    private String feature;

    @NotEmpty
    private String description;

    @NotEmpty
    private String specification;

    @URL
    @NotEmpty
    private String pictureAddress;

    @NotNull(message = "商品价格不能为空")
    @DecimalMin(value = "0", message = "原价不能小于0元!")
    private BigDecimal prices;

    @DecimalMin(value = "0", message = "折扣价不能小于0元!")
    private BigDecimal promotionPrice;

    private Integer repertory;

    private Integer sumRepertory;

    @NotNull
    private Boolean isRecommend;

    @NotEmpty
    private Integer  categoryId;

    @TableField(exist = false)
    private Category category;

    @JsonIgnore
    private LocalDateTime createTime;

    @JsonIgnore
    private LocalDateTime updateTime;

    @TableLogic
    @TableField("is_deleted")
    private Boolean isDeleted;

    @JsonIgnore
    @Version   //标记此属性为对应数据表的版本号字段
    private Integer version;

    private static final long serialVersionUID = 1L;

    //定义分组效验接口
    public interface FreshGroup1 extends Default {
    }
}