package com.orion.pojo.vo;

import lombok.Data;
import lombok.experimental.Accessors;

@Data
@Accessors(chain = true)
public class AddressVO {
    private String name;       // 收货人
    private String phone;   // 联系电话
    private String province;
    private String city;
    private String district;
    private String detailedAddress;
}