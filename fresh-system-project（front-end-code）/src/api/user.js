//导入向后端发送异步请求的工具
import request from '@/utils/request.js';

// 用户注册（手机号注册）
export const registerService = (data) => {
    return request.post('/user/register', data, {
        headers: {
            'Content-Type': 'application/json'
        }
    })
}
// 普通用户登录（手机号登录）
export const userLoginService = (phone, password) => {
    return request.post('/user/login', { phone, password })
}

// 管理员登录（用户名登录）
export const adminLoginService = (formData) => { 
    return request.post('/user/adminLogin',
        formData, 
        {
            headers: {
                'Content-Type': 'application/json'
            }
        }
    )
}

// 获取用户基本信息
export const getUserInfoService = () => {
    return request.get('/user/info')
}

//定义向后端发送忘记密码的函数
export const forgetPasswdService = (forgetInfo) => {
    return request.put("/user/forgetPasswd", forgetInfo)
}



//定义获取所有用户信息的后端请求方法
export const obtainUsers = (conditionObj) => {
    return request.get("/user/getUserAll", { params: conditionObj })
}

//定义新增用户的后端请求接口
export const insertUser = (userObj) => {
    return request.post("/user/addUser", userObj)
}

//定义更新用户信息的接口
export const updateUserService = (userObj) => {
    return request.put("/user/updateUserInfo", userObj)
}

//定义删除用户的接口
export const deleteUserService = (userId) => {
    return request.delete("/user/delete", { params: { id: userId } })
}

//定义将用户头像地址保存到后端的接口
export const uploadAvatarUrlService = (url) => {
    const params = new URLSearchParams()
    params.append("avatar", url)
    return request.patch("/user/uploadAvatarUrl", params);
}

//定义向后端发送重置密码的请求接口
export const resetPasswd = (passwdFormObj) => {
    return request.patch("/user/resetPasswd", passwdFormObj)
}

//定义向后端发送获取前端用户前台已登录用户信息的接口
export const getBeforeUserInfoService = () => {
    return request.get("/user/beforeUserInfo")
}

//定义用户充钱后端请求接口实现
export const pushMoneyService = (money) => {
    const params = new URLSearchParams()
    params.append("money", money)
    return request.patch("/user/addMoney", params)
}

