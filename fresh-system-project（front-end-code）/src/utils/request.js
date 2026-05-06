//导入axios
import axios from "axios";
import { ElMessage } from "element-plus";

//定义请求路径公共前缀
//const baseURL='/api'    //会向当前axios所在前端服务器源发送请求（标识）如： http://localhost:5173/api/*
const baseURL='http://localhost:8080'
//创建请求实例
const instance=axios.create({baseURL})

//定义向后端发送请求携带token的请求拦截器
import { useTokenStore } from "@/stores/token.js";

instance.interceptors.request.use((config)=>{
    //请求发送之前调用
    const tokenStore = useTokenStore()
    if(tokenStore.token){
        config.headers.Authorization=tokenStore.token  //请求头中携带token
    }
    return config
},(error)=>{
    //请求失败调用
    Promise.reject(error)
})


//定义响应拦截器
import router from '@/routers/index.js'  //获取创建的路由器实例（注意:由于函数的加载顺序在此处不能使用useRouter函数来获取路由器实例）

instance.interceptors.response.use(
    result=>{
        if(result.data.code===0){
            return result.data //将成功响应的数据放行
        }   
        ElMessage.error(result.data.message?result.data.message:'服务异常!')
        //ElMessage.error('服务异常!')
        return Promise.reject(result.data)
    },
    error=>{
        //用户未登录向后端发送请求不携带token会响应401未授权错误，提示用户登录，并跳转到登录页
        if(error.response.status===401){
            // 获取当前路由路径
            const currentRoute = router.currentRoute.value.path
            
            // 定义无需跳转登录的白名单路由
            const whiteList = [
                '/userMain/freshHome', 
                '/userMain/freshCategory'
            ]

            if (whiteList.includes(currentRoute)) {
                // 白名单路由保持当前页，仅提示信息
                ElMessage.warning('登录后才能继续操作哟')
                return Promise.reject(error)
        }}else{
            // 非白名单路由跳转主页
            ElMessage.warning('请先登录')
            router.push('/userMain/freshHome')  // 跳转主页而非登录页
            return Promise.reject(error)
        }
        return Promise.reject(error)  //将异步请求响应的状态转为错误状态，这样catch()函数就可以捕获到错误信息
    },
    config => {
        const tokenStore = useTokenStore()
        // 新增主动过期检查
        if (tokenStore.isExpired()) {
            tokenStore.removeToken()
            router.push('/login?expired=1')
            return Promise.reject('Token expired')
        }
        return config
    }
)

export default instance  //将异步请求实例默认导出
