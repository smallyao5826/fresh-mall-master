<template>
    <div class="order-detail-container">
        <!-- 标题区域 -->
        <div class="header-container">
            <el-page-header @back="handleBack" class="page-header">
                <template #content>
                    <div class="header-main">
                        <h1 class="header-title">订单详情</h1>
                        <el-tag :type="statusTagMap[orderData.status]" effect="light" size="large"
                            class="status-tag animate__animated animate__fadeIn">
                            {{ orderData.status }}
                        </el-tag>
                    </div>
                </template>
            </el-page-header>
        </div>

        <!-- 主体内容 -->
        <el-card class="main-card animate__animated animate__fadeInUp">
            <!-- 商品清单 -->
            <section class="goods-section">
                <h2 class="section-title">
                    <el-icon class="title-icon">
                        <Goods />
                    </el-icon>
                    商品清单（共{{ orderData.details?.length || 0 }}件）
                </h2>
                <div class="goods-list">
                    <div v-for="(item, index) in orderData.details" :key="index"
                        class="goods-item animate__animated animate__fadeIn"
                        :style="{ 'animation-delay': `${index * 0.1}s` }">
                        <el-image :src="item.pictureAddress" fit="cover" class="goods-image"
                            :preview-src-list="[item.pictureAddress]" :zoom-rate="1.2" :max-scale="7" :min-scale="0.2">
                            <template #error>
                                <div class="image-error">
                                    <el-icon>
                                        <Picture />
                                    </el-icon>
                                </div>
                            </template>
                        </el-image>
                        <div class="goods-info">
                            <div class="goods-name">{{ item.freshName }}</div>
                            <div class="goods-spec">
                                <span class="price">
                                    ¥{{ item.price.toFixed(2) }}
                                    <span class="original-price" v-if="item.originalPrice > item.price">
                                        ¥{{ item.originalPrice.toFixed(2) }}
                                    </span>
                                </span>
                                <span class="count">×{{ item.count }}</span>
                            </div>
                        </div>
                        <div class="goods-total accent-red">
                            ¥{{ (item.price * item.count).toFixed(2) }}
                        </div>
                    </div>
                </div>
            </section>

            <!-- 信息区块 -->
            <div class="info-grid">
                <!-- 订单信息 -->
                <div class="info-card animate__animated animate__fadeInLeft">
                    <h3 class="info-title">
                        <el-icon class="title-icon">
                            <Document />
                        </el-icon>
                        订单信息
                    </h3>
                    <el-descriptions :column="1">
                        <el-descriptions-item label="订单编号：">
                            {{ orderData.orderNumber }}
                            <el-tooltip content="复制订单号">
                                <el-icon class="copy-icon" @click="copyOrderNumber">
                                    <DocumentCopy />
                                </el-icon>
                            </el-tooltip>

                        </el-descriptions-item>
                        <el-descriptions-item label="下单时间：">
                            {{ formatTime(orderData.createTime) || '无'}}
                        </el-descriptions-item>
                        <el-descriptions-item label="支付方式：">
                            {{ orderData.paymentMethod || '无'}}
                        </el-descriptions-item>
                        <el-descriptions-item label="订单备注：">
                            {{ orderData.remark || '无' }}
                        </el-descriptions-item>
                    </el-descriptions>
                </div>

                <!-- 收货信息 -->
                <div class="info-card">
                    <h3 class="info-title">
                        <el-icon class="title-icon">
                            <Location />
                        </el-icon>
                        收货信息
                    </h3>
                    <el-descriptions :column="1" class="address-desc">
                        <el-descriptions-item label="收货人：">
                            {{ orderData.address?.name }}
                        </el-descriptions-item>
                        <el-descriptions-item label="联系电话：">
                            {{ orderData.address?.phone }}
                        </el-descriptions-item>
                        <el-descriptions-item label="收货地址：">
                            {{ fullAddress }}
                        </el-descriptions-item>
                    </el-descriptions>
                </div>
            </div>

            <!-- 金额汇总 -->
            <div class="amount-card info-card animate__animated animate__fadeInUp">
                <h3 class="info-title">
                    <el-icon class="title-icon">
                        <Money />
                    </el-icon>
                    费用明细
                </h3>
                <div class="amount-content">
                    <div class="amount-item">
                        <span class="amount-label">商品总额</span>
                        <span class="amount-value">
                            ¥{{ (orderData.sumPrices - orderData.shippingFee).toFixed(2) }}
                        </span>
                    </div>
                    <div class="amount-item">
                        <span class="amount-label">运费</span>
                        <span class="amount-value accent-blue">
                            + ¥{{ orderData.shippingFee?.toFixed(2) }}
                        </span>
                    </div>
                    <div class="amount-divider"></div>
                    <div class="amount-item total">
                        <span class="amount-label">实付金额</span>
                        <span class="amount-value accent-red">
                            ¥{{ orderData.sumPrices?.toFixed(2) }}
                        </span>
                    </div>
                </div>
            </div>

            <!-- 操作按钮 -->
            <div class="action-buttons">
                <el-button v-if="orderData.status === '待发货'" type="warning" size="large" class="action-btn"
                    @click="handleUrge">
                    <el-icon>
                        <Bell />
                    </el-icon>
                    催促发货
                </el-button>
                <el-button v-if="orderData.status === '待收货'" type="warning" size="large" class="action-btn"
                    @click="handleConfirm">
                    <el-icon>
                        <CircleCheck />
                    </el-icon>
                    确认收货
                </el-button>
            </div>
        </el-card>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElNotification } from 'element-plus'
import {
    Document,
    Goods,
    Picture,
    Bell,
    CircleCheck,
    DocumentCopy,
    Location,
    Money
} from '@element-plus/icons-vue'
import { getOrderDetailService } from '@/api/userStage'

const route = useRoute()
const router = useRouter()
const loading = ref(true)
const orderData = ref({
    address: {},
    details: []
})

// 计算属性
const fullAddress = computed(() => {
    const addr = orderData.value.address
    return [addr?.province, addr?.city, addr?.district, addr?.detailedAddress].filter(Boolean).join(' ')
})

// 状态标签颜色映射
const statusTagMap = {
    '待发货': 'warning',
    '待收货': 'primary',
    '已完成': 'success',
    '已取消': 'danger'
}

// 获取订单详情
const fetchOrderDetail = async () => {
    try {
        loading.value = true
        const { data } = await getOrderDetailService(route.params.orderNumber)
        orderData.value = data
    } catch (error) {
        ElMessage.error('获取订单详情失败')
        console.error(error)
    } finally {
        loading.value = false
    }
}

// 格式化时间
const formatTime = (timeString) => {
  return new Date(timeString).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

// 复制订单号
const copyOrderNumber = () => {
    navigator.clipboard.writeText(orderData.value.orderNumber)
    ElNotification.success({
        title: '复制成功',
        message: '订单号已复制到剪贴板',
        duration: 2000
    })
}

// 返回处理
const handleBack = () => {
    router.push("/userMain/myorder")
}


onMounted(fetchOrderDetail)
</script>

<style lang="scss" scoped>
.order-detail-container {
    margin: 24px;
    padding: 24px;
    min-height: calc(100vh - 48px);

    .header-container {
        margin-bottom: 32px;

        .page-header {
            :deep(.el-page-header__content) {
                display: flex;
                align-items: center;
                padding-left: 8px;
            }

            .header-main {
                display: flex;
                align-items: center;
                gap: 24px;

                .header-title {
                    font-size: 28px;
                    font-weight: 600;
                    color: #1a1a1a;
                    margin: 0;
                    letter-spacing: 1px;
                }

                .status-tag {
                    font-size: 16px;
                    padding: 8px 20px;
                    border-radius: 20px;
                    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
                }
            }
        }
    }

    .main-card {
        border-radius: 16px;
        padding: 40px;
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
        border: none;

        .section-title {
            font-size: 22px;
            color: #2c3e50;
            margin: 0 0 32px 0;
            padding-bottom: 16px;
            border-bottom: 2px solid #eee;
            display: flex;
            align-items: center;

            .title-icon {
                margin-right: 12px;
                font-size: 24px;
                color: var(--el-color-primary);
            }
        }

        .goods-list {
            margin-bottom: 40px;

            .goods-item {
                display: flex;
                align-items: center;
                padding: 20px;
                margin-bottom: 16px;
                background: white;
                border-radius: 12px;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);

                &:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                }

                .goods-image {
                    width: 120px;
                    height: 120px;
                    border-radius: 8px;
                    margin-right: 24px;
                    transition: transform 0.3s;
                }

                .goods-info {
                    flex: 1;

                    .goods-name {
                        font-size: 18px;
                        font-weight: 600;
                        color: #333;
                        margin-bottom: 12px;
                    }

                    .goods-spec {
                        display: flex;
                        align-items: center;
                        gap: 24px;

                        .price {
                            font-size: 18px;
                            color: var(--el-color-primary);
                            font-weight: 600;

                            .original-price {
                                font-size: 14px;
                                color: #999;
                                text-decoration: line-through;
                                margin-left: 8px;
                            }
                        }

                        .count {
                            font-size: 16px;
                            color: #666;
                        }
                    }
                }

                .goods-total {
                    min-width: 140px;
                    text-align: right;
                    font-size: 20px;
                    font-weight: 700;
                    color: var(--el-color-primary);

                    &.accent-red {
                        color: #ff4444;
                    }
                }
            }
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr );
            gap: 32px;
            margin: 40px 0;

            .info-card {
                background: white;
                border-radius: 12px;
                padding: 24px;
                box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);

                .info-title {
                    font-size: 20px;
                    color: #2c3e50;
                    margin: 0 0 24px 0;
                    display: flex;
                    align-items: center;

                    .title-icon {
                        margin-right: 12px;
                        font-size: 24px;
                        color: var(--el-color-primary);
                    }
                }



                :deep(.el-descriptions) {

                    .el-descriptions__label {
                        font-weight: 500;
                        color: #666;
                    }

                    .el-descriptions__content {
                        color: #333;
                    }
                }

                .copy-wrapper {
                    display: flex;
                    align-items: center;
                    gap: 8px;

                    .order-number {
                        font-family: 'Fira Code', monospace;
                    }

                    .copy-icon {
                        cursor: pointer;
                        color: #666;
                        transition: color 0.2s;

                        &:hover {
                            color: var(--el-color-primary);
                        }
                    }
                }

                .address-content {
                    line-height: 1.6;
                    font-size: 15px;
                    color: #444;
                }
            }
        }

        .amount-card {
            margin-top: 32px;
            padding: 24px;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);

            .info-title {
                margin-bottom: 20px;
                font-size: 18px;
                font-weight: 600;
                color: #2c3e50;
                display: flex;
                align-items: center;

                .title-icon {
                    margin-right: 10px;
                    font-size: 22px;
                    color: var(--el-color-primary);
                }
            }

            .amount-content {
                .amount-item {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    padding: 12px 0;

                    .amount-label {
                        font-size: 14px;
                        color: #666;
                    }

                    .amount-value {
                        font-size: 15px;
                        font-weight: 500;
                        color: #333;

                        &.accent-blue {
                            color: #409eff;
                        }

                        &.accent-red {
                            font-size: 18px;
                            font-weight: 700;
                            color: #ff4757;
                        }
                    }

                    &.total {
                        padding-top: 16px;
                        border-top: 1px solid #eee;

                        .amount-label {
                            font-weight: 500;
                            color: #333;
                        }
                    }
                }

                .amount-divider {
                    margin: 8px 0;
                    border-bottom: 1px dashed #eee;
                }
            }
        }

        .action-buttons {
            margin-top: 40px;
            display: flex;
            justify-content: flex-end;
            gap: 24px;

            .action-btn {
                padding: 14px 32px;
                border-radius: 8px;
                font-size: 16px;
                letter-spacing: 1px;
                transition: all 0.3s;

                .el-icon {
                    margin-right: 8px;
                    font-size: 18px;
                }

                &:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                }
            }
        }
    }
}

// 动画优化
.animate__animated {
    --animate-duration: 0.6s;
}
</style>