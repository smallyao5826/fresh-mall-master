<template>
    <div class="layout-container">
        <el-header>
            <el-menu router="true" mode="horizontal" :ellipsis="false" 是否省略多余的菜单项
                :default-active="activeItemStore.activedItem" @select="handleSelect" 点击菜单的回调函数>
                <el-menu-item>
                    <a href="/userMain/freshHome">
                        <img style="width: 90px" src="@/assets/logo_w.png" alt="生鲜商城" />
                    </a>
                </el-menu-item>
                <el-menu-item index="/userMain/freshHome">
                    <strong>生鲜首页</strong>
                </el-menu-item>
                <el-menu-item index="/userMain/freshCategory">
                    <strong>生鲜分类</strong>
                </el-menu-item>
                <el-menu-item index="/userMain/shoppingCart">
                    <strong>购物车</strong>
                </el-menu-item>
                <el-menu-item index="/userMain/myorder">
                    <strong>我的订单</strong>
                </el-menu-item>

                <!-- 搜索框 -->
                <el-input v-model="queryParamStore.filters.freshName" @keyup.enter="handleSearchEnter"
                    placeholder="搜索新鲜好物..." clearable class="modern-search" @clear="handleSearchClear">
                    <template #suffix>
                        <el-icon class="search-icon">
                            <Search />
                        </el-icon>
                    </template>
                </el-input>

                <!-- 用户头像下拉菜单 -->
                <div class="auth-section">
                    <!-- 已登录状态 -->
                    <el-dropdown v-if="tokenStore.token && !tokenStore.isExpired()" placement="bottom-end"
                        @command="handleCommand" class="user-dropdown">
                        <span class="el-dropdown__box user-trigger">
                            <el-avatar :size="100" class="user-avatar">
                                <el-icon :size="20">
                                    <Avatar />
                                </el-icon>
                            </el-avatar>
                            <div class="user-info">
                                <span class="nickname">{{ userInfoStore.userInfo?.username }}</span>
                            </div>
                            <el-icon class="trigger-icon">
                                <CaretBottom />
                            </el-icon>
                        </span>

                        <template #dropdown>
                            <el-dropdown-menu class="user-menu">
                                <el-dropdown-item command="userInfo" class="menu-item">
                                    <template #icon>
                                        <User />
                                    </template>
                                    个人资料
                                </el-dropdown-item>
                                <el-dropdown-item command="userResetPassword" class="menu-item">
                                    <template #icon>
                                        <User />
                                    </template>
                                    修改密码
                                </el-dropdown-item>
                                <el-dropdown-item command="shoppingAddress" class="menu-item">
                                    <template #icon>
                                        <Position />
                                    </template>
                                    收货地址
                                </el-dropdown-item>
                                <el-dropdown-item v-if="userInfoStore.userInfo?.role === '管理员'" command="admin"
                                    class="menu-item">
                                    <template #icon>
                                        <Setting />
                                    </template>
                                    后台管理
                                </el-dropdown-item>
                                <el-dropdown-item command="logout" class="menu-item logout-item">
                                    <template #icon>
                                        <SwitchButton />
                                    </template>
                                    退出登录
                                </el-dropdown-item>
                            </el-dropdown-menu>
                        </template>
                    </el-dropdown>
                    <!-- 未登录状态 -->
                    <el-button v-else type="primary" class="login-btn" @click="showLogin = true">
                        立即登录
                    </el-button>
                </div>

            </el-menu>
        </el-header>
        <router-view />
    </div>

    <login-dialog v-model="showLogin" @success="handleLoginSuccess" />
</template>

<script setup>
import { ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import {
    CaretBottom,
    Search,
    User,
    SwitchButton,
    Position,
    Setting,
    Avatar
} from '@element-plus/icons-vue';
import { ElMessageBox, ElMessage } from 'element-plus';

// store导入
import { useUserInfoStore } from '@/stores/userinfo.js';
import { useTokenStore } from '@/stores/token.js';
import { useActiveItemStore } from '@/stores/activedItem.js';
import { useQueryParamsStore, usePageFreshStore } from '@/stores/queryArgs.js';

// 组件导入
import LoginDialog from '@/views/users-stage/subComponent/loginDialog.vue';
import { pushMoneyService } from '@/api/user.js';

// 初始化store
const userInfoStore = useUserInfoStore();
const tokenStore = useTokenStore();
const activeItemStore = useActiveItemStore();
const queryParamStore = useQueryParamsStore();
const pageFreshStore = usePageFreshStore();

// Router
const route = useRoute();
const router = useRouter();

// 数据定义
const showLogin = ref(false);
const formRef = ref(null);
const waletDialog = ref({
    dialogVisible: false,
});

// 表单数据
const fromData = ref({
    restMoney: null,
    addMoney: null
});

// watch
watch(
    () => route.query.search,
    (newSearch) => {
        if (route.path === '/userMain/freshCategory') {
            queryParamStore.updateFilters({
                freshMoney: newSearch || ''
            });
        }
    },
    { immediate: true }
);

// 菜单处理
const handleSelect = (item) => {
    activeItemStore.setActivedItem(item);
};

// 下拉菜单
const handleCommand = (commandValue) => {
    if (commandValue === 'logout') {
        ElMessageBox.confirm(
            '确认要退出登录吗?',
            '消息提示',
            {
                confirmButtonText: '确认',
                cancelButtonText: '取消',
                type: 'warning',
            }
        ).then(() => {
            userInfoStore.removeUserInfo();
            tokenStore.removeToken();
            pageFreshStore.removePageFreshesModel();
            queryParamStore.resetQueryParams();
            activeItemStore.removeActivedItem();
            router.push('/login');
            ElMessage.success('欢迎来到登录页');
        });
    } else if (commandValue === 'admin') {
        router.push('/managerMain/home');
    } else {
        router.push(`/userMain/${commandValue}`);
    }
};

// 搜索处理
const handleSearchEnter = () => {
    queryParamStore.updateFilters({
        freshMoney: queryParamStore.filters.freshMoney,
        categoryId: null
    });

    if (route.path !== '/userMain/freshCategory') {
        router.push({
            path: '/userMain/freshCategory',
            query: { search: queryParamStore.filters.freshMoney }
        });
    }
};

const handleSearchClear = () => {
    queryParamStore.updateFilters({
        freshMoney: '',
        categoryId: null
    });

    if (route.path === '/userMain/freshCategory') {
        router.replace({ query: {} });
    }
};

// 登录处理
const handleLoginSuccess = () => {
    showLogin.value = false;
};

</script>



<style lang="scss" scoped>
// 强制Element容器去除边框
.el-container {
    border: none !important;

    &::before,
    &::after {
        display: none !important;
    }
}

.layout-container {
    display: flex;
    flex-direction: column;
    background: var(--color-bg); // 改为实际需要的背景色
    overflow: hidden; // 隐藏溢出内容

    /* 导航栏样式 */
    .el-header {
        padding: 0px;
        flex-shrink: 0;

        .el-menu {
            --el-menu-bg-color: #22A356;
            --el-menu-text-color: #ffffff;
            --el-menu-hover-bg-color: transparent; // 全局透明背景
            display: flex;
            justify-content: space-around;

            // 水平菜单特殊处理
            &.el-menu--horizontal {
                >.el-menu-item {
                    border-bottom: 0 !important;
                    transition: transform 0.2s ease;

                    // 悬停状态
                    &:hover {
                        background-color: transparent !important;
                        transform: translateY(-3px);
                    }

                    // 激活状态
                    &.is-active {
                        background-color: transparent !important;
                    }
                }
            }

            .el-menu-item {
                // 基础样式
                position: relative;
                overflow: hidden;
                margin: 0 12px;
                border-radius: 8px;
                transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
                transform-origin: center;
                perspective: 1000px;

                // 全局背景重置
                &,
                &:hover,
                &:active,
                &.is-active {
                    background: transparent !important;
                }

                // 文字容器
                strong {
                    position: relative;
                    display: inline-flex;
                    align-items: center;
                    color: inherit;
                    font-weight: 600;
                    letter-spacing: 0.8px;
                    transition: all 0.4s cubic-bezier(0.68, -0.55, 0.27, 1.55);
                    transform-style: preserve-3d;

                    // 文字下划线
                    &::after {
                        content: '';
                        position: absolute;
                        bottom: -4px;
                        left: 0;
                        width: 100%;
                        height: 2px;
                        background: currentColor;
                        transform: scaleX(0);
                        transform-origin: right;
                        transition: transform 0.3s ease;
                    }
                }

                // 悬浮背景特效层
                &::before {
                    content: '';
                    position: absolute;
                    top: 50%;
                    left: 50%;
                    width: 110%;
                    height: 110%;
                    background: radial-gradient(circle at var(--x) var(--y),
                            rgba(255, 243, 176, 0.15) 0%,
                            transparent 70%);
                    transform: translate(-50%, -50%);
                    opacity: 0;
                    pointer-events: none;
                    transition: opacity 0.3s ease;
                }

                // 悬浮状态
                &:hover {

                    // 背景光晕追踪
                    &::before {
                        opacity: 1;
                    }

                    strong {
                        color: #FFF3B0;
                        transform: translateY(-2px) rotateX(10deg);

                        // 下划线动画
                        &::after {
                            transform: scaleX(1);
                            transform-origin: left;
                        }
                    }

                    // 悬浮粒子效果
                    &::after {
                        content: '';
                        position: absolute;
                        top: -20px;
                        left: -20px;
                        right: -20px;
                        bottom: -20px;
                        background: radial-gradient(circle at var(--x) var(--y),
                                rgba(255, 243, 176, 0.2) 10%,
                                transparent 30%);
                        animation: particleFlow 1.2s linear infinite;
                    }
                }

                // 激活状态
                &.is-active {
                    animation: itemActive 0.6s ease forwards;

                    strong {
                        color: #FFF3B0;
                        text-shadow: 0 2px 8px rgba(255, 243, 176, 0.3);
                        transform: scale(1.08) translateY(-1px);

                        &::after {
                            transform: scaleX(1);
                            background: #FFD700;
                        }
                    }

                    // 激活状态光环
                    &::before {
                        opacity: 1;
                        background: radial-gradient(circle at center,
                                rgba(255, 211, 0, 0.2) 0%,
                                transparent 70%);
                        animation: activeGlow 2s ease-in-out infinite;
                    }
                }

                // 点击状态
                &:active {
                    transform: scale(0.95) translateY(1px);
                    transition-duration: 0.1s;

                    // 点击涟漪效果
                    &::after {
                        content: '';
                        position: absolute;
                        top: 50%;
                        left: 50%;
                        width: 2px;
                        height: 2px;
                        background: rgba(255, 243, 176, 0.4);
                        border-radius: 50%;
                        animation: ripple 0.6s ease-out;
                    }
                }
            }

            // 关键帧动画
            @keyframes particleFlow {
                0% {
                    transform: translateY(0) scale(0.8);
                    opacity: 0.8;
                }

                100% {
                    transform: translateY(-40px) scale(1.2);
                    opacity: 0;
                }
            }

            @keyframes itemActive {
                0% {
                    transform: scale(1);
                }

                50% {
                    transform: scale(1.05);
                }

                100% {
                    transform: scale(1);
                }
            }

            @keyframes activeGlow {

                0%,
                100% {
                    opacity: 0.6;
                    transform: translate(-50%, -50%) scale(1);
                }

                50% {
                    opacity: 0.3;
                    transform: translate(-50%, -50%) scale(1.2);
                }
            }

            @keyframes ripple {
                0% {
                    transform: scale(1);
                    opacity: 1;
                }

                100% {
                    transform: scale(40);
                    opacity: 0;
                }
            }


            /* 搜索框动态样式 */
            .modern-search {
                padding: 0.5rem 0;
                width: 300px;
                transition: all 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);

                :deep(.el-input__wrapper) {
                    background: rgba(255, 255, 255, 0.9);
                    border-radius: 30px;
                    box-shadow:
                        0 4px 6px rgba(34, 163, 86, 0.1),
                        inset 0 0 0 1px rgba(34, 163, 86, 0.2);
                    transition: all 0.4s cubic-bezier(0.23, 1, 0.32, 1);

                    // 输入框内容
                    .el-input__inner {
                        color: #2d3748;
                        font-weight: 500;
                        padding-left: 12px;

                        &::placeholder {
                            color: #94a3b8;
                            transition: opacity 0.3s ease;
                        }
                    }

                    // 搜索图标
                    .search-icon {
                        color: #22A356;
                        font-size: 1.2em;
                        margin-right: 8px;
                        transition:
                            transform 0.3s ease,
                            color 0.3s ease;
                    }

                    // 清除按钮
                    .el-input__clear {
                        color: #94d3a2;
                        transition: all 0.3s ease;

                        &:hover {
                            color: #22A356;
                            transform: scale(1.2);
                        }
                    }
                }

                /* 悬停状态 */
                &:hover {
                    /* transform: translateY(-2px); */
                    width: 350px;

                    :deep(.el-input__wrapper) {
                        box-shadow:
                            0 6px 12px rgba(34, 163, 86, 0.15),
                            inset 0 0 0 1px rgba(34, 163, 86, 0.3);

                        .el-input__inner::placeholder {
                            opacity: 0.8;
                        }

                        .search-icon {
                            transform: rotate(10deg) scale(1.1);
                        }
                    }
                }

                /* 聚焦状态 */
                &.is-focused {
                    width: 400px;

                    :deep(.el-input__wrapper) {
                        border-radius: 12px;
                        box-shadow:
                            0 8px 16px rgba(34, 163, 86, 0.2),
                            inset 0 0 0 2px #22A356;

                        .search-icon {
                            color: #ffffff;
                            background: #22A356;
                            padding: 6px;
                            border-radius: 50%;
                            transform: rotate(360deg) scale(1.1);
                        }
                    }
                }

                /* 输入内容后的状态 */
                &:not(.is-empty) {
                    :deep(.el-input__wrapper) {
                        .search-icon {
                            animation: pulseGlow 1.5s infinite;
                        }
                    }
                }
            }

            @keyframes pulseGlow {
                0% {
                    filter: drop-shadow(0 0 2px rgba(34, 163, 86, 0.2));
                }

                50% {
                    filter: drop-shadow(0 0 6px rgba(34, 163, 86, 0.4));
                }

                100% {
                    filter: drop-shadow(0 0 2px rgba(34, 163, 86, 0.2));
                }
            }

            li {
                font-size: 17px;
            }

            .auth-section {
                display: flex;
                align-items: center;
                padding-right: 20px;

                :deep(.user-dropdown) {
                    --dropdown-radius: 12px;
                    --dropdown-bg: rgba(255, 255, 255, 0.95);
                    --text-primary: #2c3e50;
                    --text-secondary: #666;
                    --hover-bg: #f5f7fa;

                    .user-trigger {
                        display: flex;
                        align-items: center;
                        padding: 5px 10px;
                        border-radius: 30px;
                        background: rgba(255, 255, 255, 0.1);
                        transition: all 0.3s ease;
                        cursor: pointer;

                        &:hover {
                            background: rgba(255, 255, 255, 0.2);
                            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

                            .user-avatar {
                                transform: scale(1.05);
                            }
                        }
                    }

                    .user-avatar {
                        width: 36px;
                        height: 36px;
                        border: 2px solid rgba(255, 255, 255, 0.3);
                        transition: transform 0.3s ease;
                    }

                    .user-info {
                        margin: 0 12px 0 8px;
                        line-height: 1.4;

                        .nickname {
                            display: block;
                            color: #fff;
                            font-size: 14px;
                            font-weight: 600;
                            max-width: 120px;
                            overflow: hidden;
                            text-overflow: ellipsis;
                        }

                    }

                    .trigger-icon {
                        color: rgba(255, 255, 255, 0.8);
                        font-size: 14px;
                        margin-left: 4px;
                    }

                    /* 下拉菜单样式穿透 */
                    :deep(.user-menu) {
                        border: none;
                        border-radius: var(--dropdown-radius);
                        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
                        padding: 8px 0;

                        .menu-item {
                            padding: 12px 20px;
                            font-size: 14px;
                            color: var(--text-primary);
                            transition: all 0.2s ease;

                            &:hover {
                                background: var(--hover-bg);
                                color: var(--text-primary);
                            }

                            &.logout-item {
                                color: #ff4d4f;

                                &:hover {
                                    background: #fff1f0;
                                }
                            }

                            /* 图标样式 */
                            .el-icon {
                                margin-right: 8px;
                                font-size: 16px;
                            }
                        }

                        /* 分割线 */
                        .el-dropdown-menu__item:not(:last-child) {
                            border-bottom: 1px solid rgba(0, 0, 0, 0.06);
                        }
                    }
                }

                .login-btn {
                    /* 基础样式 */
                    position: relative;
                    padding: 1.2rem 1.8rem;
                    border: 2px solid rgba(255, 255, 255, 0.3);
                    border-radius: 2rem;
                    background: linear-gradient(135deg,
                            rgba(255, 255, 255, 0.15) 0%,
                            rgba(255, 255, 255, 0.05) 100%);
                    color: #fff;
                    font-weight: 600;
                    letter-spacing: 0.05rem;
                    backdrop-filter: blur(4px);
                    transition: all 0.4s cubic-bezier(0.23, 1, 0.32, 1);

                    /* 悬浮效果 */
                    &:hover {
                        transform: translateY(-2px);
                        box-shadow:
                            0 4px 15px rgba(34, 163, 86, 0.3),
                            0 0 0 2px rgba(255, 255, 255, 0.1);
                        background: linear-gradient(135deg,
                                rgba(255, 255, 255, 0.2) 0%,
                                rgba(255, 255, 255, 0.1) 100%);
                        border-color: rgba(255, 255, 255, 0.5);
                    }

                    /* 点击效果 */
                    &:active {
                        transform: translateY(1px);
                        box-shadow:
                            0 2px 8px rgba(34, 163, 86, 0.2),
                            inset 0 2px 4px rgba(0, 0, 0, 0.1);
                    }

                    /* 添加右侧箭头图标 */
                    &::after {
                        content: '→';
                        display: inline-block;
                        margin-left: 0.8rem;
                        opacity: 0.8;
                        transition: transform 0.3s ease;
                    }

                    &:hover::after {
                        transform: translateX(3px);
                    }
                }
            }

        }
    }

    .main {
        padding: 10px 85px;
    }

}
</style>