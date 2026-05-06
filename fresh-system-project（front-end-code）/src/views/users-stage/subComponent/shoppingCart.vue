<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Delete, Wallet, Plus, Box } from '@element-plus/icons-vue'
import QuantityPicker from './quantityPicker.vue'

// API
import {
    getCartDataService,
    deleteCartService,
} from "@/api/userStage.js"

// Pinia
import { useUserInfoStore } from '@/stores/userinfo.js'

// 购物车数据
const tableData = ref([])
const fetchCartData = async () => {
    try {
        const result = await getCartDataService()
        tableData.value = result.data || []  // 确保数组类型
    } catch (error) {
        ElMessage.error('获取购物车数据失败,请先登录')
        tableData.value = []
    }
}

// 用户地址处理
const userStore = useUserInfoStore()
const addressID = ref(null)

// 初始化
onMounted(async () => {
    await fetchCartData()

    // 正确获取地址逻辑
    if (userStore.userInfo?.addressList?.length > 0) {
        addressID.value = userStore.userInfo.addressList[0].addressID
    }
})

// 计算属性优化
const sumMoney = computed(() => {
    let sum = 0
    let restSum = 0

    tableData.value.forEach(item => {
        // 安全解构对象属性
        const {
            promotionPrice = undefined,
            prices: originalPrice = 0
        } = item.fresh || {}

        // 验证促销价有效性（必须同时满足三个条件）
        const isValidPromotion =
            typeof promotionPrice === 'number' &&
            promotionPrice > 0 &&
            promotionPrice < originalPrice

        // 价格计算逻辑
        const unitPrice = isValidPromotion ? promotionPrice : originalPrice
        const count = item.count || 0

        sum += unitPrice * count

        // 节省金额计算（仅在有效促销时计算）
        if (isValidPromotion) {
            restSum += (originalPrice - promotionPrice) * count
        }
    })

    return [sum, restSum]
})
// 删除操作优化
const handleDelete = async (row) => {
    try {
        await deleteCartService(row.fresh?.id)
        await fetchCartData()
        ElMessage.success('删除成功')
    } catch (error) {
        ElMessage.error(error.message || '删除失败')
    }
}

import { useRouter } from 'vue-router'
const router = useRouter()
const handleCheckout = () => {
    if (tableData.value.length === 0) {
        ElMessage.warning('购物车为空')
        return
    }

    // 跳转到订单页，携带商品数据
    router.push({
        path: '/userMain/shoppingOrder',
        query: {
            items: JSON.stringify(tableData.value),
            total: sumMoney.value[0],
            isCart: true
        }
    })
}
</script>

<template>
    <div class="cart-container">
        <el-card class="modern-cart">
            <template #header>
                <div class="cart-header">
                    <h3 class="cart-title">Basket ({{ tableData.length }})</h3>
                </div>
            </template>

            <!-- 商品表格 -->
            <el-table :data="tableData" class="enhanced-table" :row-class-name="tableRowClass"
                header-cell-class-name="table-header">

                <template #empty>
                    <el-empty description="购物车空空如也" class="artistic-empty">
                    </el-empty>
                </template>

                <el-table-column label="商品">
                    <template #default="{ row }">
                        <div class="product-image-wrapper">
                            <el-avatar shape="square" :size="120" fit="cover" :src="row.fresh.pictureAddress"
                                class="product-image" />
                        </div>
                    </template>
                </el-table-column>

                <el-table-column label="商品信息">
                    <template #default="{ row }">
                        <div class="product-info">
                            <div class="product-name">{{ row.fresh.freshName }}</div>
                            <div class="product-spec">{{ row.fresh.specification }}</div>
                            <div class="product-time">加入时间：{{ row.purchaseTime }}</div>
                        </div>
                    </template>
                </el-table-column>

                <el-table-column label="价格" align="center">
                    <template #default="{ row }">
                        <div class="price-display">
                            <div v-if="row.fresh.promotionPrice" class="original-price">
                                ¥{{ row.fresh.prices.toFixed(2) }}
                            </div>
                            <div class="current-price">
                                ¥{{ (row.fresh.promotionPrice || row.fresh.prices).toFixed(2) }}
                            </div>
                        </div>
                    </template>
                </el-table-column>

                <el-table-column label="数量" align="center">
                    <template #default="{ row }">
                        <div class="quantity-control">
                            <QuantityPicker v-model="row.count" :min="1" class="table-quantity-picker" />
                        </div>
                    </template>
                </el-table-column>

                <el-table-column label="小计" align="center">
                    <template #default="{ row }">
                        <div class="subtotal">
                            <span v-if="row.fresh.promotionPrice">
                                ¥{{ (row.fresh.promotionPrice * row.count).toFixed(2) }}
                            </span>
                            <span v-else>¥{{ (row.fresh.prices * row.count).toFixed(2) }}</span>

                        </div>
                    </template>
                </el-table-column>

                <el-table-column label="操作" align="center">
                    <template #default="{ row }">
                        <el-tooltip content="删除商品" placement="top">
                            <el-button type="danger" circle plain class="delete-btn" @click="handleDelete(row)">
                                <el-icon>
                                    <Delete />
                                </el-icon>
                            </el-button>
                        </el-tooltip>
                    </template>
                </el-table-column>
            </el-table>


        </el-card>
        <!-- 固定结算栏 -->
        <div class="sticky-summary">
            <div class="summary-content">
                <div class="price-info">
                    <span class="saved">已省 ¥{{ sumMoney[1].toFixed(2) }}</span>
                    <div class="total">
                        合计：<span class="total-price">¥{{ sumMoney[0].toFixed(2) }}</span>
                    </div>
                </div>
                <el-button type="primary" class="checkout-btn" :disabled="tableData.length === 0"
                    @click="handleCheckout">
                    <el-icon class="wallet-icon">
                        <Wallet />
                    </el-icon>
                    立即结算
                </el-button>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.cart-container {
    padding: 24px;
    min-height: calc(100vh - 48px);
    padding-bottom: 100px;
    box-sizing: border-box;
    --shadow-color: rgba(0, 0, 0, 0.08);
    --border-color: #e4e7ed;
    --accent-color: #22A356;
    --danger-color: #ff4d4f;
}

.modern-cart {

    padding: 20px;
    border: none;
    box-shadow: 0 4px 24px var(--shadow-color);
    border-radius: 16px;
    overflow: visible;

    :deep(.el-card__header) {
        border-bottom: 1px solid var(--border-color);
        padding: 20px 32px;
    }

    .cart-header {
        display: flex;
        justify-content: space-between;
        align-items: center;

        .cart-title {
            font-family: var(--font-title);
            font-size: 2.4rem;
            font-weight: bolder;
            color: #22A356;
            margin: 0;
        }

        .address-wrapper {
            display: flex;
            align-items: center;
            gap: 12px;

            :deep(.el-select__wrapper) {
                border-radius: 16px !important;
            }

            .address-label {
                color: #666;
                font-size: 14px;
                white-space: nowrap;
            }

            .minimal-select {
                width: 320px;

                :deep(.el-input__inner) {
                    height: 40px;
                    border-radius: 8px;
                    border: 1px solid var(--border-color);
                    transition: all 0.2s;

                    &:hover {
                        border-color: var(--accent-color);
                    }

                    &:focus {
                        box-shadow: 0 0 0 2px rgba(34, 163, 86, 0.1);
                    }
                }
            }


        }
    }

    .enhanced-table {
        border-radius: 8px;
        overflow: hidden;

        .artistic-empty {
            padding: 48px 0;

            :deep(.el-empty__description) {
                p {
                    color: rgba(51, 51, 51, 0.6);
                    font-family: 'Inter', sans-serif;
                    font-size: 1.1rem;
                    margin: 16px 0;
                }
            }

        }

        @keyframes float {

            0%,
            100% {
                transform: translateY(0);
            }

            50% {
                transform: translateY(-20px);
            }
        }



        :deep(.table-header) {
            th {
                color: #666;
                font-weight: 600;
                font-size: 14px;
                height: 56px;
            }
        }

        :deep(.el-table__row) {
            height: 96px;
            transition: all 0.2s;

            &:hover {
                transform: translateX(4px);
                box-shadow: 0 4px 12px var(--shadow-color);
            }

            td {
                border-bottom: 1px solid var(--border-color);
            }
        }

        .product-image-wrapper {
            position: relative;

            .product-image {
                border-radius: 8px;
                transition: transform 0.3s;

                &:hover {
                    transform: scale(1.05);
                }
            }

        }

        .product-info {
            .product-name {
                font-size: 16px;
                font-weight: 600;
                margin-bottom: 8px;
            }

            .product-spec {
                color: #999;
                font-size: 12px;
                margin-bottom: 8px;
            }

            .product-time {
                color: #ccc;
                font-size: 12px;
            }
        }

        .price-display {
            .original-price {
                color: #999;
                font-size: 12px;
                text-decoration: line-through;
            }

            .current-price {
                color: var(--danger-color);
                font-size: 16px;
                font-weight: 600;
            }
        }

        .enhanced-counter {

            :deep(.el-input-number__decrease),
            :deep(.el-input-number__increase) {
                width: 32px;
                background: #f5f5f5;
                color: #666;
                font-size: 16px;
                transition: all 0.2s;

                &:hover {
                    background: var(--accent-color);
                    color: white;
                }
            }
        }

        .subtotal {
            color: #1a1a1a;
            font-weight: 600;
            font-size: 16px;
        }

        .delete-btn {
            border-color: var(--danger-color);

            &:hover {
                background: var(--danger-color);
                color: white !important;
            }
        }
    }


}

.sticky-summary {
    position: fixed;
    margin: 0 24px 20px;
    left: 0;
    right: 0;
    bottom: 0;
    background: white;
    padding: 16px 32px;
    box-shadow: 0 4px 24px var(--shadow-color);
    z-index: 10;
    border-radius: 16px;

    .summary-content {
        display: flex;
        justify-content: space-between;
        align-items: center;

        .price-info {
            .saved {
                color: var(--accent-color);
                font-size: 14px;
                margin-right: 24px;
            }

            .total {
                display: inline-block;
                font-size: 16px;

                .total-price {
                    color: var(--danger-color);
                    font-size: 24px;
                    font-weight: 700;
                    margin-left: 8px;
                }
            }
        }

        .checkout-btn {
            height: 48px;
            padding: 0 40px;
            border-radius: 24px;
            font-weight: 600;
            font-size: 16px;
            background: var(--accent-color);
            border: none;
            transition: all 0.3s;

            &:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(34, 163, 86, 0.3);
            }

            .wallet-icon {
                margin-right: 8px;
                font-size: 18px;
            }
        }
    }
}

@media (max-width: 768px) {
    .cart-container {
        padding: 12px;
    }

    .modern-cart {
        :deep(.el-card__header) {
            padding: 16px;
        }

        .enhanced-table {
            margin: 0 12px;

            :deep(.el-table__row) {
                height: auto;
                padding: 12px 0;
            }

            .product-image {
                width: 72px !important;
                height: 72px !important;
            }
        }

        .sticky-summary {
            position: fixed;
            left: 0;
            right: 0;
            bottom: 0;
            padding: 12px;
            border-radius: 0;

            .summary-content {
                flex-direction: column;
                gap: 12px;

                .price-info {
                    width: 100%;
                    display: flex;
                    justify-content: space-between;
                }

                .checkout-btn {
                    width: 100%;
                }
            }
        }
    }
}
</style>