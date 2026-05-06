//导入向后端发送异步请求的工具
import request from '@/utils/request.js';

/* 公告管理  */

//定义向后端添加公告的函数
export const addNoticeSerive = (notice) => {
    return request.post('/notice/add', notice)   //将成功响应后来的数据返回
}

//定义查询所有公告信息的异步函数
export const noticePageService = (params) => {
    return request.get("/notice/queryNotices", { params: { search: params.search, pageNumber: params.pageNumber, pageSize: params.pageSize } })
}

//定义修改公告信息的请求接口
export const noticeModifyService = (notice) => {
    return request.put("/notice/modifyNotice", notice)
}

//定义删除公告的请求接口
export const noticeDeleteService = (idValue) => {
    return request.delete("/notice/delete", { params: { id: idValue } })
}

/* 生鲜分类销量管理*/
export const getFreshSaleCountService = () => {
    return request.get("/category/freshCategorySale")
}


/*交流管理 */
//定义向后端发送交流分页查询的接口
export const talkService = (args) => {
    return request.get("/communication/all", { params: { search: args.search, pageNumber: args.pageNumber, pageSize: args.pageSize } })
}


//定义删除用户动态的请求接口
export const deleteTalk = (id) => {
    return request.delete(`/communication/delete?id=${id}`)
}





/* 分类管理 */
//定义查询分类的后端请求接口
export const queryCategoryService = (search) => {
    return request.get("/category/all", { params: { search: search } })
}

//定义添加分类的后端请求接口
export const addCategoryService = (typeName) => {
    const params = new URLSearchParams()
    params.append("typeName", typeName)
    return request.post("/category/add", params)
}

//定义编辑分类的异步函数
export const editCategoryService = (editModel) => {
    const params = new URLSearchParams()
    params.append("id", editModel.id)
    params.append("typeName", editModel.categoryContent)
    return request.patch("/category/edit", params)

}

//定义删除按钮的请求接口
export const deleteCategoryService = (id) => {
    return request.delete("/category/delete", { params: { id: id } })
}



/* 生鲜管理 */

//定义新增生鲜的请求接口
export const saveFreshes = (ruleForm) => {
    return request.post('/fresh/saveFreshes', ruleForm)
}

//定义查询生鲜的请求接口
export const obtainFreshes = (args) => {
    return request.get("/fresh/getFreshes", { params: args })
}


//定义修改生鲜的后端请求接口
export const updateFresh = (ruleForm) => {
    return request.put("/fresh/updateFresh", ruleForm)
}

//定义删除生鲜的后端请求接口
export const deleteFreshService = (freshId) => {
    return request.delete("/fresh/deleteFresh", { params: { id: freshId } })
}


/* 订单管理 */

//定义获取所有用户订单的后端请求接口
export const obtainOrders = (orderObj) => {
    return request.get("/order/getOrders", { params: orderObj })
}

//定义发货按钮的后端请求接口
export const sendItem = (id, status) => {
    const params = new URLSearchParams()
    params.append("id", id)
    params.append("status", status)
    return request.patch("/order/sendGood", params)
}


/* 轮播图管理 */

//定义上传文件的后端请求接口
export const uploadSlideUrl = (url) => {
    const params = new URLSearchParams()
    params.append("slideUrl", url)
    return request.post("/slidePicture", params)
}

//定义获取所有轮播图的接口
export const getSlides = (pageObj) => {
    return request.get("/slidePicture", { params: pageObj })
}

//定义修改轮播图的后端请求接口
export const updateSlideService = (slideId, slideUrl) => {
    const params = new URLSearchParams()
    params.append("id", slideId)
    params.append("url", slideUrl)
    return request.patch("/slidePicture", params)
}

//定义删除轮播图的后端请求接口
export const deleteSlideService = (slideId) => {
    return request.delete("/slidePicture", { params: { id: slideId } })
}


/* 配送地址管理 */

//定义向后端发送添加配送地址的请求
export const addAddressService = (addressArg) => {
    return request.post("/shoppingAddress", { address: addressArg })
}

//定义获取所有配送地址的请求接口
export const getAllAddress = (pageInfo) => {
    return request.get("/shoppingAddress", { params: pageInfo })
}

//定义编辑配送地址的后端请求接口
export const editAddressService = (formObj) => {
    const params = new URLSearchParams()
    params.append("id", formObj.id)
    params.append("address", formObj.address)
    return request.patch("/shoppingAddress", params)
}

//定义删除配送地址的后端请求接口
export const deleteAddressService = (idArg) => {
    return request.delete("/shoppingAddress", { params: { id: idArg } })
}

export const uploadFileService = (file) => {
    const formData = new FormData();
    formData.append('file', file);
    return instance.post('/file/upload', formData, {
        headers: {
            'Content-Type': 'multipart/form-data'
        }
    });
};

export const shipOrder = (shipData) => {
    return request.post('/order/ship', shipData)
}

export const getLogistics = (orderNumber) => {
    return request({
        url: `/logistics/${orderNumber}`,
        method: 'get'
    })
}

export const getAfterSalesList = (params) => {
    return request.get("/afterSales/admin/list", { params: params })
}

export const processAfterSale = (data) => {
    return request({
        url: '/afterSales/admin/process',
        method: 'post',
        data
    })
}

// 获取推荐配置
export const getRecommendConfig = () => {
    return request({
        url: '/recommend/config',
        method: 'get'
    })
}

// 更新推荐配置
export const updateRecommendConfig = (params) => {
    return request({
        url: '/recommend/config',
        method: 'post',
        data: params
    })
}

export const getLoginLogs = (params) => {
    return request({
      url: '/user/login-logs',
      method: 'get',
      params: {
        pageNumber: params.pageNumber,
        pageSize: params.pageSize,
        role: params.role,
        search: params.search
      }
    })
  }