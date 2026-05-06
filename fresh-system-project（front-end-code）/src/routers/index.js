//导入创建路由器实例和路由模式的依赖
import { createRouter, createWebHistory } from "vue-router";
import { useUserInfoStore } from '@/stores/userinfo' 
import LoginVue from '@/views/AdminLogin.vue';
import UserMainVue from '@/views/users-stage/userMain.vue';
import MangerMainVue from '@/views/mangers-stage/managerMain.vue';

//导入后台管理子组件
import GoodsVue from "@/views/mangers-stage/subComponent/goods.vue";
import GoodsCategoryVue from "@/views/mangers-stage/subComponent/goodsCategory.vue";
import HomeVue from "@/views/mangers-stage/subComponent/home.vue";
import OrderVue from "@/views/mangers-stage/subComponent/order.vue";
import SlideshowVue from "@/views/mangers-stage/subComponent/slideshow.vue";
import UserVue from "@/views/mangers-stage/subComponent/user.vue";
import UserInfoVue from '@/views/public-user/userInfo.vue';
import UserResetPasswordVue from '@/views/public-user/userResetPassword.vue';
import Inventory from "@/views/mangers-stage/subComponent/inventory.vue";
import AfterSales from "@/views/mangers-stage/subComponent/afterSales.vue";
import RecommendCofig from "@/views/mangers-stage/subComponent/recommendCofig.vue";
import LoginLog from "@/views/mangers-stage/subComponent/loginLog.vue";

//导入前台管理子组件
import FreshHomeVue from '@/views/users-stage/subComponent/freshHome.vue';
import MyOrderVue from '@/views/users-stage/subComponent/myOrder.vue';
import FreshCategory from "@/views/users-stage/subComponent/freshCategory.vue";
import ShoppingAddress from '@/views/users-stage/subComponent/shoppingAddress.vue';
import ShoppingCartVue from '@/views/users-stage/subComponent/shoppingCart.vue';
import ShoppingOrder from '@/views/users-stage/subComponent/shoppingOrder.vue';
import OrderDetail from "@/views/users-stage/subComponent/orderDetail.vue";
import PaymentResult from "@/views/users-stage/subComponent/PaymentResult.vue";

import { useActiveItemStore } from '@/stores/activedItem'

//定义路由路径映射关系
const routes = [
    {
        path: "/",
        redirect: "/userMain"   /* 重定向到主页 */
    },
    {
        path: "/adminlogin",
        component: LoginVue
    },
    {
        path: "/userMain",
        redirect: "/userMain/freshHome", /* 用户前台默认重定向到生鲜首页 */
        component: UserMainVue,
        children: [
            {path: "/userMain/shoppingAddress", component: ShoppingAddress},
            {path: "/userMain/freshHome", component: FreshHomeVue},
            {path: "/userMain/freshCategory", component: FreshCategory},
            {path: "/userMain/myOrder", component: MyOrderVue},
            {path: "/userMain/shoppingCart", component: ShoppingCartVue},
            {path: "/userMain/userResetPassword",component: UserResetPasswordVue},
            {path: "/userMain/shoppingOrder", component: ShoppingOrder},
            {path: "/userMain/userInfo",component: UserInfoVue},
            { 
                path: "orderDetail/:orderNumber", // 添加动态参数
                component: OrderDetail,
                props: true // 启用props接收参数
            },
            {path : "/userMain/payment-success",component: PaymentResult}
            

        ]
    },
    {
        path: "/managerMain",
        redirect: "/managerMain/home",  /* 后台管理默认重定向到首页 */
        component: MangerMainVue,
        children: [
            {path: "/managerMain/home", component: HomeVue},
            {path: "/managerMain/orders", component: OrderVue},
            {path: "/managerMain/goods", component: GoodsVue},
            {path: "/managerMain/goodsCategory", component: GoodsCategoryVue},
            {path: "/managerMain/user", component: UserVue},
            {path: "/managerMain/slide", component: SlideshowVue},
            {path: "/managerMain/userInfo",component: UserInfoVue},
            {path: "/managerMain/userResetPassword",component: UserResetPasswordVue},
            {path: "/managerMain/inventory",component: Inventory},
            {path: "/managerMain/afterSales",component: AfterSales},
            {path: "/managerMain/recommendCofig",component: RecommendCofig},
            {path: "/managerMain/loginLog",component: LoginLog}
        ]
    }
]

//创建路由器实例
const  router = createRouter({
    history: createWebHistory(),  //指定路由模式
    routes: routes  //指定路由关系
})

router.beforeEach((to) => {
    const store = useActiveItemStore()
    store.validateAndSetActivedItem(to.path) // 每次路由跳转时校验
  })


//将路由器实例默认导出
export default router
