<template>
    <div class="el-mainCard">
        <el-scrollbar>
            <el-card class="main-card">
                <!-- 轮播图 -->
                <div class="carousel-wrapper">
                    <el-carousel :interval="5000" type="card" height="400px">
                        <el-carousel-item v-for="(slide, index) in slideshow" :key="index">
                            <el-image :src="slide" fit="cover" class="carousel-image" />
                        </el-carousel-item>
                    </el-carousel>
                </div>

                <!-- 内容区域 -->
                <div class="content-section">

                    <!-- 猜你喜欢 -->
                    <div class="recommend-section">
                        <div class="section-header green-bg">
                            <span class="title-decorate">❤ Your Daily Harvest ❤</span>
                        </div>
                        <div class="recommend-list">
                            <el-row :gutter="20">
                                <el-col v-for="(item, index) in recommendFreshModel" :key="index" :xs="12" :sm="8"
                                    :md="6" @click="openFreshDetail(item)">
                                    <div class="product-card">
                                        <div class="image-wrapper">
                                            <el-image :src="item.pictureAddress" fit="cover" class="product-image"
                                                lazy />
                                            <div class="price-tag">
                                                ¥{{ item.promotionPrice > 0 ? item.promotionPrice : item.prices }}
                                            </div>
                                        </div>
                                        <div class="product-content">
                                            <h3 class="product-title">{{ item.freshName }}</h3>
                                            <div class="product-desc">{{ item.description }}</div>
                                            <el-tag class="feature-tag" type="success">{{ item.feature }}</el-tag>
                                        </div>
                                    </div>
                                </el-col>
                            </el-row>
                        </div>
                    </div>

                </div>

                <!-- 商品详情对话框 -->
                <FreshDetailDialog v-model:visible="dialogVisible" :detail="currentProduct" @buy="handleBuy"
                    @add-cart="handleAddCart" />
            </el-card>
        </el-scrollbar>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Star } from '@element-plus/icons-vue'
import FreshDetailDialog from '@/views/users-stage/subComponent/freshDetailDialog.vue';

// Pinia Stores
import { useUserInfoStore } from '@/stores/userinfo.js'
import { useTokenStore } from "@/stores/token.js"
import { useQueryParamsStore, usePageFreshStore } from '@/stores/queryArgs.js'

// API Functions
import {
    getSlides,
    getRecommendFreshService,
    createOrderService,
    addCartService
} from '@/api/userStage.js'
import { obtainFreshes } from "@/api/managerStage.js"

// 初始化存储实例
const tokenStore = useTokenStore()
const userInfoStore = useUserInfoStore()
const queryParamsStore = useQueryParamsStore()
const pageFreshStore = usePageFreshStore()

// 轮播图数据
const slideshow = ref([])
const getslideshow = async () => {
    const result = await getSlides()
    slideshow.value = result.data
}

const currentIndex = ref(0)

const handleCarouselChange = (index) => {
    currentIndex.value = index
}

// 推荐商品数据
const recommendFreshModel = ref([])
const recommendFreshes = async () => {
    const result = await getRecommendFreshService()
    recommendFreshModel.value = result.data
}

// 对话框状态
const dialogVisible = ref(false)
const currentProduct = ref({
    id: null,
    freshName: '',
    prices: 0,
    promotionPrice: 0,
    description: '',
    feature: '',
    pictureAddress: '',
    salecount: 0,
    repertory: 0,
    specification: ''

})

// 打开商品详情
const openFreshDetail = (fresh) => {
    currentProduct.value = {
        id: fresh.id,
        freshName: fresh.freshName,
        categoryId: fresh.categoryId,
        prices: fresh.prices,
        promotionPrice: fresh.promotionPrice,
        description: fresh.description,
        feature: fresh.feature,
        pictureAddress: fresh.pictureAddress,
        salecount: fresh.sumRepertory - fresh.repertory,
        repertory: fresh.repertory,
        specification: fresh.specification

    }
    dialogVisible.value = true
}

// 处理购买操作
const handleBuy = async ({ id, quantity }) => {
    try {
        if (currentProduct.value.repertory < 1) {
            ElMessage.warning("库存不足")
            return
        }

        const restMoney = userInfoStore.userInfo.account - (currentProduct.value.promotionPrice || currentProduct.value.prices) * quantity
        if (restMoney < 0) {
            ElMessage.error("余额不足")
            return
        }

        await createOrderService(id, quantity)
        ElMessage.success("购买成功")
        dialogVisible.value = false
        userInfoStore.userInfo.account = restMoney
    } catch (error) {
        ElMessage.error(error.message || '购买失败')
    }
}

// 处理加入购物车
const handleAddCart = async ({ id, quantity }) => {
    try {
        if (currentProduct.value.repertory < 1) {
            ElMessage.warning("库存不足")
            return
        }

        await addCartService(id, quantity)
        ElMessage.success("已加入购物车")
    } catch (error) {
        ElMessage.error(error.message || '操作失败')
    }
}

// 初始化数据
onMounted(() => {
    getslideshow()
    recommendFreshes()
})
</script>

<style lang="scss" scoped>
.el-mainCard {
    .main-card {
        background: #f8fafc;
        border: none;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);

        .carousel-wrapper {
            padding: 30px;

            :deep(.el-carousel) {

                /* 主容器 */
                .el-carousel__container {
                    display: flex;
                    height: 400px !important;
                    justify-content: center;
                }

                /* 卡片项 */
                .el-carousel__item {
                    margin: 0 1%;
                    border-radius: 12px;
                    overflow: hidden;
                    transition: transform 0.3s ease;

                    /* 非激活状态 */
                    &:not(.is-active) {
                        transform: scale(0.9);
                        opacity: 0.85;
                    }
                }

                /* 图片样式 */
                .carousel-image {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                }

                /* 指示器 */
                .el-carousel__indicators {
                    bottom: -30px;

                    & button {
                        background: #e8e8e8;

                        &.is-active {
                            background: #22A356;
                        }
                    }
                }
            }
        }
    }

    .content-section {
        margin-top: 30px;
    }

    /* 猜你喜欢样式 */
    .recommend-section {
        margin: 40px auto;

        .section-header {
            font-family: var(--font-title);
            display: flex;
            align-items: center;
            color: #22A356;
            font-weight: bold;
            font-size: 24px; // 增大字号
            letter-spacing: 2px; // 增加字间距
            justify-content: center; // 水平居中
            padding: 20px 0;
            margin-bottom: 30px;
            position: relative;


            &::before {
                left: 15%
            }

            &::after {
                right: 15%
            }

            .title-decorate {
                position: relative;
                padding: 0 20px;

                // 动态闪烁效果
                &::after {
                    content: '✨';
                    position: absolute;
                    right: -10px;
                    top: -8px;
                    animation: twinkle 1.5s infinite;
                }
            }

            .el-icon {
                font-size: 28px;
                margin-right: 15px;
            }
        }

        /* 商品列表区域 */
        .recommend-list {
            padding: 0 30px;

            .el-row {
                // 允许商品自由换行布局
                display: flex;
                flex-wrap: wrap;
                justify-content: flex-start;

                // 每个商品卡片的宽度
                .el-col {
                    width: calc(25% - 20px); // 每个商品卡片宽度为容器宽度的25%，减去间距
                    margin-bottom: 30px;
                }
            }

            .product-card {
                height: 100%;
                margin-bottom: 20px;
                background: white;
                border-radius: 12px;
                /* overflow: hidden; */
                transition: all 0.3s ease;
                position: relative;

                &:hover {
                    transform: translateY(-5px);
                    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
                    transform: scale(1.05);
                }

                .image-wrapper {
                    height: 240px;
                    border-radius: 12px;
                    /* overflow: hidden; */
                    position: relative;

                    .product-image {
                        width: 100%;
                        height: 100%;
                        transition: transform 0.3s ease;
                    }

                    .price-tag {
                        position: absolute;
                        bottom: 10px;
                        left: 10px;
                        background: rgba(34, 163, 86, 0.9);
                        color: white;
                        padding: 4px 12px;
                        border-radius: 20px;
                        font-weight: bold;
                    }
                }

                .product-content {
                    padding: 15px;

                    .product-title {
                        font-size: 16px;
                        margin: 8px 0;
                    }

                    .product-desc {
                        color: #666;
                        font-size: 13px;
                        line-height: 1.4;
                        margin-bottom: 10px;
                    }

                    .feature-tag {
                        margin-top: 8px;
                        border-radius: 4px;
                    }
                }
            }
        }
    }

    /* 闪烁动画 */
    @keyframes twinkle {
        0% {
            opacity: 0.2
        }

        50% {
            opacity: 1
        }

        100% {
            opacity: 0.2
        }
    }
}

:deep(.el-dialog) {
    border-radius: 12px
}

.fresh-dialog {
    overflow: hidden;



    :deep(.el-dialog__header) {
        background: linear-gradient(135deg, #22A356, #2ECC71);
        margin: 0;
        padding: 18px 24px;

        .el-dialog__title {
            color: white;
            font-size: 18px;
            letter-spacing: 1px;
        }

        .el-dialog__headerbtn {
            top: 18px;
            right: 24px;

            .el-icon {
                color: white;
            }
        }
    }

    :deep(.el-dialog__body) {
        padding: 24px;
    }
}

.dialog-content {
    .product-image-wrapper {
        position: relative;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);

        .main-image {
            width: 100%;
            height: 420px;
            border-radius: 12px;
            transition: transform 0.3s ease;

            &:hover {
                transform: scale(1.02);
            }
        }

        .sales-badge {
            position: absolute;
            top: 16px;
            right: 16px;
            background: rgba(255, 80, 80, 0.9);
            color: white;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            backdrop-filter: blur(4px);
        }
    }
}

.product-info {
    .product-title {
        margin: 0 0 12px;
        font-size: 24px;
        color: #303133;
        line-height: 1.3;
    }

    .product-description {
        color: #606266;
        font-size: 14px;
        line-height: 1.6;
        margin-bottom: 16px;
    }

    .feature-badge {
        background: linear-gradient(135deg, #22A356, #2ECC71);
        color: white;
        border: none;
        border-radius: 6px;
        padding: 8px 16px;
        font-size: 14px;
        margin-bottom: 20px;
    }

    .quantity-price {
        display: flex;
        justify-content: space-between;
        margin: 15px 0;
        padding: 0 5px;

        .quantity-section {
            display: flex;
            align-items: center;
            gap: 10px;
        }
    }
}

.price-section {
    background: #f8fafc;
    border-radius: 8px;
    padding: 16px;
    margin: 10px 0;

    .original-price {
        color: #909399;
        font-size: 14px;
        text-decoration: line-through;
        margin-bottom: 8px;
    }

    .current-price {
        display: flex;
        align-items: center;

        .price-label {
            color: #606266;
            margin-right: 8px;
        }

        .price-value {
            color: #ff4d4f;
            font-size: 24px;
            font-weight: 600;
        }
    }
}

.section-title {
    display: flex;
    align-items: center;
    color: #303133;
    font-size: 16px;
    margin: 16px 0 12px;

    .el-icon {
        margin-right: 8px;
        font-size: 18px;
    }
}

.address-select {
    width: 100%;

    :deep(.el-input__inner) {
        border-radius: 8px;
        padding: 10px 12px;
    }
}

.empty-address {
    display: flex;
    align-items: center;
    color: #ff4d4f;
    padding: 12px;
    background: #fff0f0;
    border-radius: 8px;

    .el-icon {
        margin-right: 8px;
        font-size: 18px;
    }
}

.quantity-input {

    width: 100px;
    /* margin-left: 20px; */

    :deep(.el-input-number__decrease),
    :deep(.el-input-number__increase) {
        background: #f5f7fa;
        border: none;
        font-size: 16px;
    }

    :deep(.el-input__inner) {
        text-align: center;
        font-size: 16px;
    }
}

.total-price {
    text-align: right;
    font-size: 16px;
    color: #606266;
    margin: 20px 0;

    .price {
        color: #ff4d4f;
        font-size: 24px;
        font-weight: 600;
        margin-left: 12px;
    }
}

.action-buttons {
    display: flex;
    gap: 12px;

    .buy-btn {
        width: 45%;
        background: linear-gradient(135deg, #ff6b6b, #ff4d4f);
        border: none;
        height: 48px;
        font-size: 16px;
        border-radius: 8px;
        transition: all 0.3s ease;

        &:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255, 77, 79, 0.3);
        }
    }

    .cart-btn {
        width: 45%;
        height: 48px;
        border: 1px solid #22A356;
        color: #22A356;
        font-size: 16px;
        border-radius: 8px;
        transition: all 0.3s ease;

        &:hover {
            background: rgba(34, 163, 86, 0.1);
            transform: translateY(-2px);
        }

        .cart-icon {
            margin-right: 8px;
            font-size: 18px;
        }
    }
}

// 辅助样式
@mixin text-ellipsis($line: 1) {
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: $line;
    -webkit-box-orient: vertical;
}
</style>