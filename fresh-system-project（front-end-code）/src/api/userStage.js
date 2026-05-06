//导入向后端发送异步请求的工具
import request from '@/utils/request.js';

//获取所有轮播图
export const getSlides = () => {
    return request.get("/slidePicture/all")
}

//定义获取生鲜销售排行榜的接口
export const getSaleGradeService = () => {
    return request.get("/fresh/saleGrade")
}

//定义向后端发送获取推荐生鲜信息的接口
export const getRecommendFreshService = () => {
    return request.get("/fresh/recommendAll")
}
/* export const getRecommendFreshService = () => {
    return request.get("/recommend")
} */

//定义生成订单的后端接口
export const createOrderService = (orderData) => {
    return request.post("/order/create", orderData)
  }

//定义获取用户订单的后端请求接口
export const obtainUserOrderService = (params) => {
    return request.get("/order/userOrders", { params: params })
}

//定义删除订单的后端请求接口
export const deleteMyOrderService = (orderNumber) => {
    return request.delete(`/order?orderNumber=${orderNumber}`)
}


//定义商品加入购物车的后端请求接口
export const addCartService = (id, purchaseCount) => {
    const params = new URLSearchParams()
    params.append("id", id)
    params.append("purchaseCount", purchaseCount)
    return request.post("/cart", params)
}

//定义向后端发送请求获取购物车数据的接口
export const getCartDataService = () => {
    return request.get("/cart")
}


//定义删除购物车生鲜的后端请求接口
export const deleteCartService = (freshId) => {
    return request.delete(`/cart/${freshId}`)
}


//定义购物车生鲜立即结算的后端请求接口
export const createCartOrderService = (orderData) => {
    return request.post("/order/cartHandle", orderData)
}


//定义添加用户地址的后端请求接口
export const addUserAddressService = (address) => {
    return request.post("/userAddress",
        JSON.stringify(address), // 手动序列化为JSON字符串
        {
            headers: {
                'Content-Type': 'application/json' // 明确指定请求头
            }
        }
    )
}

//定义查看用户地址的后端请求接口
export const getUserAddressListService = () => {
    return request.get("/userAddress")
}

//定义更新用户地址的后端请求接口
export const updateUserAddressService = (address) => {
    return request.put("/userAddress",
        JSON.stringify(address),
        {
            headers: {
                'Content-Type': 'application/json'
            }
        }
    )
}

//定义删除用户地址的后端请求接口
export const deleteUserAddressService = (id) => {
    return request.delete(`/userAddress/${id}`)
}

//定义查询所有用户发表的动态后端请求接口
export const getUsersCommService = () => {
    return request.get("/communication/userlogs")
}

//定义发布新帖子的异步函数
export const addCommunicationService = (content) => {
    const params = new URLSearchParams()
    params.append("content", content)
    return request.post("/communication/addContent", params)
}


//定义编辑帖子的后端请求接口
export const modifyPostService = (editObj) => {
    return request.patch("/communication", editObj)
}

//定义获取所有通知的后端请求接口
export const getNoticeSevice = (search) => {
    return request.get("/notice/all", { params: { title: search } })
}

export const getOrderDetailService = (orderNumber) => {
    return request.get(`/order/detail/${orderNumber}`)
}

/* 售后管理 */
// 提交售后申请
export const applyAfterSales = (data) => {
    return request.post('/afterSales/apply', data)
}

