import './assets/main.scss'   //导入css扩展语言包

import { createApp } from 'vue'   //导入创建vue实例的函数
import App from './App.vue'   //将根组件文件导入

import Element from 'element-plus'   //导入Element-plus软件包
import 'element-plus/dist/index.css'  //导入Element-plus相关css样式
import locale from 'element-plus/es/locale/lang/zh-cn'  //导入Element-plus中文语言包

import { createPinia } from 'pinia'   //导入创建pinia实例的函数
import { createPersistedState } from 'pinia-persistedstate-plugin'
const persist = createPersistedState()  //获取持久化存储插件
const pinia = createPinia()
pinia.use(persist)  //pinia使用持久化插件

import Router from '@/routers/index.js';   //导入路由器实例 

const app=createApp(App)   //创建vue实例

app.use(Element,{locale})   //使用Element-plus软件包
app.use(pinia)
app.use(Router)   

app.mount('#app')    //将vue实例挂载到项目的默认入口文件上
