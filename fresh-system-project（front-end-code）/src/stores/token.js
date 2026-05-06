//导入定义store的函数
import { defineStore } from "pinia";
import { ref } from "vue";

/* 
一、pinia状态管理库存储各组件共享的数据
1、安装pinia依赖包: npm install pinia
2、在main.js的vue实例使用createPinia()返回的实例
3、在/src/stores/*.js中定义store即共享存储的数据（步骤此文件内容） 
4、在其他组件文件中导入defineStore()函数返回的函数
5、在其他组件文件中调用函数获取defineStore()第二个参数函数返回的对象数据并使用

二、pinia-persistedstate-plugin持久化数据存储插件使用
1、安装插件： npm install pinia-persistedstate-plugin
2、在main.js中导入并将pinia实例使用插件：
           import {createPersistedstate} from 'pinia-persistedstate-plugin'
           const persist = createPersistedstate()
           pinia.use(persist)
3、在定义store的defineStore(, , {persisted: true})第三个参数中使用数据持久存储
*/



/* 
    参数1： store的标识名称（必须唯一）
    参数2： 函数---里面定义store所有内容
    返回值： 返回的是一个函数，在其他组件调用此函数可以获取参数2函数返回的js对象
*/
import { jwtDecode } from 'jwt-decode'

const useTokenStore = defineStore("token", () => {

    // 定义token响应式变量
    const token = ref('')

    // 定义设置token的方法
    const setToken = (newToken) => {
        token.value = newToken
    }

    // 定义清除token的方法
    const removeToken = () => {
        token.value = ''
    }
    // 新增过期时间检查
    const isExpired = () => {
        if (!token.value) return true
        try {
            const { exp } = jwtDecode(token.value)
            return Date.now() > exp * 1000
        } catch {
            return true
        }
    }

    return { token, setToken, removeToken, isExpired } // 新增isExpired
}, { 
    persist: true 
})   //定义状态数据持久化存储

//导出函数供其他组件使用
export {useTokenStore}