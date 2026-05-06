<script setup>
import {
    User,
    Goods,
    List,
    Coin,
    Discount,
    DataAnalysis,
    SetUp,
    Monitor,
    HomeFilled,
    Ticket,
    Files,
    Setting,
    SwitchButton,
    Avatar,
    Promotion,
    Opportunity,
    CaretBottom
} from '@element-plus/icons-vue'
import { useActiveItemStore } from '@/stores/activedItem.js';
import { useUserInfoStore } from '@/stores/userinfo';
import { useTokenStore } from '@/stores/token.js';
import { useRouter } from 'vue-router';
import { ElMessageBox, ElMessage } from 'element-plus';

const router = useRouter()
const activedItemObj = useActiveItemStore()
const tokenStore = useTokenStore()
const userInfoStore = useUserInfoStore()

// 初始化激活菜单
if (window.location.pathname === '/managerMain/home') {
    activedItemObj.activedItem = '/managerMain/home'
}

const select = (item) => {
    activedItemObj.activedItem = item
}

const handleCommand = (commandValue) => {
    if (commandValue === 'logout') {
        ElMessageBox.confirm('确认要退出登录吗?', '提示', {
            confirmButtonText: '确认',
            cancelButtonText: '取消',
            type: 'warning',
        }).then(() => {
            userInfoStore.removeUserInfo()
            tokenStore.removeToken()
            router.push('/adminlogin')
            ElMessage.success('欢迎下次使用')
        }).catch(() => {
            ElMessage.info('取消退出')
        })
    } else {
        router.push(`/managerMain/${commandValue}`)
    }
}
</script>

<template>
    <el-container class="layout-container">
        <!-- 左侧菜单 -->
        <el-aside width="220px" class="custom-aside">
            <div class="logo-container">
                <img src="@/assets/logo_w.png" alt="生鲜管理后台">
            </div>
            <el-menu active-text-color="var(--color-accent)" background-color="#1A7F4B"
                text-color="rgba(255, 255, 255, 0.9)" :default-active="activedItemObj.activedItem"
                :default-openeds="['1', '2', '3', '4']" router @select="select" class="custom-menu">
                <el-menu-item index="/managerMain/home">
                    <el-icon class="menu-icon">
                        <HomeFilled />
                    </el-icon>
                    <span>数据看板</span>
                </el-menu-item>

                <!-- 商品管理 -->
                <el-sub-menu index="1">
                    <template #title>
                        <el-icon class="menu-icon">
                            <Goods />
                        </el-icon>
                        <span>商品中心</span>
                    </template>
                    <el-menu-item index="/managerMain/goods">
                        <el-icon class="submenu-icon">
                            <List />
                        </el-icon>
                        <span>生鲜管理</span>
                    </el-menu-item>
                    <el-menu-item index="/managerMain/goodsCategory">
                        <el-icon class="submenu-icon">
                            <SetUp />
                        </el-icon>
                        <span>分类管理</span>
                    </el-menu-item>
                    <el-menu-item index="/managerMain/inventory">
                        <el-icon class="submenu-icon">
                            <Monitor />
                        </el-icon>
                        <span>库存管理</span>
                    </el-menu-item>
                </el-sub-menu>

                <!-- 订单管理 -->
                <el-sub-menu index="2">
                    <template #title>
                        <el-icon class="menu-icon">
                            <Ticket />
                        </el-icon>
                        <span>订单中心</span>
                    </template>
                    <el-menu-item index="/managerMain/orders">
                        <el-icon class="submenu-icon">
                            <Files />
                        </el-icon>
                        <span>订单管理</span>
                    </el-menu-item>
                    <el-menu-item index="/managerMain/afterSales">
                        <el-icon class="submenu-icon">
                            <Coin />
                        </el-icon>
                        <span>售后管理</span>
                    </el-menu-item>
                </el-sub-menu>

                <!-- 营销中心 -->
                <el-sub-menu index="3">
                    <template #title>
                        <el-icon class="menu-icon">
                            <Promotion />
                        </el-icon>
                        <span>营销中心</span>
                    </template>
                    
                    <el-menu-item index="/managerMain/slide">
                        <el-icon class="submenu-icon">
                            <Discount />
                        </el-icon>
                        <span>轮播图管理</span>
                    </el-menu-item>

                    <el-menu-item index="/managerMain/recommendCofig">
                        <el-icon class="submenu-icon">
                            <Opportunity />
                        </el-icon>
                        <span>推荐算法管理</span>
                    </el-menu-item>
                </el-sub-menu>

                <!-- 系统管理 -->
                <el-sub-menu index="4">
                    <template #title>
                        <el-icon class="menu-icon">
                            <Setting />
                        </el-icon>
                        <span>系统管理</span>
                    </template>
                    <el-menu-item index="/managerMain/user">
                        <el-icon class="submenu-icon">
                            <User />
                        </el-icon>
                        <span>用户管理</span>
                    </el-menu-item>
                    <el-menu-item index="/managerMain/loginLog">
                        <el-icon class="submenu-icon">
                            <DataAnalysis />
                        </el-icon>
                        <span>登陆日志</span>
                    </el-menu-item>
                </el-sub-menu>
            </el-menu>
        </el-aside>

        <!-- 右侧主区域 -->
        <el-container>
            <!-- 头部区域 -->
            <el-header class="custom-header">
                <el-dropdown @command="handleCommand">
                    <div class="user-panel">
                        <el-avatar :size="40" class="user-avatar">
                            <el-icon :size="20">
                                <Avatar />
                            </el-icon>
                        </el-avatar>
                        <span class="user-name">{{ userInfoStore.userInfo.username }}</span>
                        <el-icon>
                            <CaretBottom />
                        </el-icon>
                    </div>
                    <template #dropdown>
                        <el-dropdown-menu>
                            <el-dropdown-item command="userInfo">
                                <el-icon>
                                    <User />
                                </el-icon>个人中心
                            </el-dropdown-item>
                            <el-dropdown-item command="settings">
                                <el-icon>
                                    <Setting />
                                </el-icon>系统设置
                            </el-dropdown-item>
                            <el-dropdown-item divided command="logout">
                                <el-icon>
                                    <SwitchButton />
                                </el-icon>退出登录
                            </el-dropdown-item>
                        </el-dropdown-menu>
                    </template>
                </el-dropdown>
            </el-header>

            <!-- 主内容区域 -->
            <el-main class="main-content">
                <router-view></router-view>
            </el-main>

            <!-- 底部区域 -->
            <el-footer class="custom-footer">
                © 2025 FreshMall 生鲜商城管理系统 | 提供新鲜每一天
            </el-footer>
        </el-container>
    </el-container>
</template>

<style lang="scss" scoped>
.layout-container {
    height: 100vh;
    background: #f8fafc;

    .custom-aside {
        background: #1A7F4B;
        transition: width 0.3s;

        .logo-container {
            height: 64px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 32px;
            background: rgba(0, 0, 0, 0.1);

            img {
                width: 100%;
                object-fit: contain;
                filter: brightness(0) invert(1);
            }
        }

        .custom-menu {
            border-right: none;
            background: #1A7F4B;

            // 修复图标颜色问题
            :deep(.el-menu-item),
            :deep(.el-sub-menu__title) {
                height: 48px;
                line-height: 48px;
                font-size: 14px;
                color: rgba(255, 255, 255, 0.9);
                transition: all 0.2s;

                .menu-icon,
                .submenu-icon {
                    color: rgba(255, 255, 255, 0.9);
                    transition: color 0.2s;
                }

                &:hover {
                    background: rgba(255, 255, 255, 0.1) !important;
                }
            }

            // 激活状态样式
            :deep(.el-menu-item.is-active) {
                background: rgba(0, 0, 0, 0.2) !important;
                color: var(--color-accent) !important;

                .menu-icon,
                .submenu-icon {
                    color: var(--color-accent) !important;
                }
            }

            // 父级菜单激活状态
            :deep(.el-sub-menu.is-active) {
                >.el-sub-menu__title {
                    color: var(--color-accent) !important;

                    .menu-icon {
                        color: var(--color-accent) !important;
                    }
                }
            }
        }
    }

    .custom-header {
        height: 64px;
        display: flex;
        align-items: center;
        justify-content: flex-end;
        padding: 0 24px;
        background: #fff;
        box-shadow: 0 2px 8px rgba(51, 51, 51, 0.1);
        border-bottom: 1px solid rgba(51, 51, 51, 0.1);

        .user-panel {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            padding: 8px 12px;
            border-radius: 6px;
            transition: background 0.3s;

            &:hover {
                background: rgba(26, 127, 75, 0.05);
            }

            .user-name {
                color: #333;
                font-size: 14px;
                font-weight: 500;
            }
        }
    }

    .main-content {
        background: #f8fafc;
        min-height: calc(100vh - 128px);
    }

    .custom-footer {
        height: 45px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: rgba(51, 51, 51, 0.7);
        font-size: 14px;
        border-top: 1px solid rgba(51, 51, 51, 0.1);
    }
}

// 覆盖element-plus组件样式
:deep(.el-dropdown-menu) {
    border: 1px solid rgba(26, 127, 75, 0.1);
    box-shadow: 0 2px 12px rgba(26, 127, 75, 0.1);

    .el-dropdown-menu__item {
        font-size: 14px;
        color: #333;

        &:hover {
            background: var(--color-accent) !important;
            color: #1A7F4B !important;
        }

        .el-icon {
            margin-right: 8px;
            color: #1A7F4B;
        }
    }
}

:deep(.el-message-box) {
    border: 1px solid #1A7F4B;

    .el-message-box__header {
        .el-message-box__title {
            color: #1A7F4B;
        }
    }

    .el-button--primary {
        background: #1A7F4B;
        border-color: #1A7F4B;

        &:hover {
            background: #15643D;
        }
    }
}
</style>