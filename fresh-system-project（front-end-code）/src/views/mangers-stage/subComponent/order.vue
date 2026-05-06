<script setup>
import { Search, InfoFilled, Sell, Delete, Van } from '@element-plus/icons-vue'
import { ref } from 'vue'
import { obtainOrders, shipOrder, getLogistics } from '@/api/managerStage.js'
import { ElMessage } from 'element-plus'

// 数据状态
const params = ref({
    pageNumber: 1,
    pageSize: 10,
    search: '',
    status: 'all',
    total: 0
})

const orders = ref([])
const drawerVisible = ref(false)
const currentOrder = ref(null)
const statusFilter = ref('all')

// 发货相关状态
const shipVisible = ref(false)
const shipForm = ref({
    orderNumber: '',
    company: '',
    type: 'normal',
    trackingNumber: ''
})

// 物流状态
const logisticsVisible = ref(false)
const logisticsData = ref(null)
const logisticsLoading = ref(false)


const getStatusType = (status) => {
    const types = {
        shipping: 'primary',
        in_transit: 'info',
        delivering: 'warning',
        delivered: 'success'
    }
    return types[status] || ''
}

const getStatusTagType = (status) => {
    return status === 'delivered' ? 'success' : 'primary'
}

// 打开发货抽屉
const openShipDrawer = (order) => {
    shipForm.value = {
        orderNumber: order.orderNumber,
        company: '',
        type: 'normal',
        trackingNumber: ''
    }
    shipVisible.value = true
}

// 确认发货
const confirmShip = async () => {
    try {
        await shipOrder(shipForm.value)
        ElMessage.success('发货操作成功')
        shipVisible.value = false
        await getOrders() // 刷新订单列表
    } catch (error) {
        ElMessage.error('操作失败: ' + error.message)
    }
}


const handleSend = async (row) => {
    openShipDrawer(row)
}

// 时间格式化函数
const formatDateTime = (isoString) => {
    const date = new Date(isoString)
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
}

// 获取订单数据
const getOrders = async () => {
    try {
        const res = await obtainOrders(params.value)
        orders.value = res.data.items.map(order => ({
            orderNumber: order.orderNumber,
            status: order.status,
            sumPrices: order.sumPrices,
            shippingFee: order.shippingFee,        // 新增
            paymentMethod: order.paymentMethod,    // 新增
            paymentTime: order.paymentTime,        // 新增
            remark: order.remark,
            createTime: formatDateTime(order.createTime),  // 应用时间格式化
            details: order.details,
            address: {
                name: order.address.name,
                phone: order.address.phone,
                full: `${order.address.province} ${order.address.city} ${order.address.district} ${order.address.detailedAddress}`
            }
        }))
        params.value.total = res.data.total
    } catch (error) {
        console.error('获取订单失败:', error)
    }
}

// 初始化加载
getOrders()

// 状态筛选
const statusOptions = [
    { label: '全部', value: 'all' },
    { label: '待发货', value: '待发货' },
    { label: '待收货', value: '待收货' },
    { label: '已完成', value: '已完成' },
    { label: '已取消', value: '已取消' }
]

const logisticsCompanies = ref([
    { value: '顺丰物流', label: '顺丰速运 SF' },
    { value: '京东物流', label: '京东物流 JD' }
])

// 操作处理
const handleAction = async (type, row) => {
    switch (type) {
        case 'detail':
            currentOrder.value = row
            drawerVisible.value = true
            break
        case 'send':
            await handleSend(row)
            break
        case 'cancel':
            await handleCancel(row)
            break
        case 'logistics':
            await handleLogistics(row)
            break
    }
}

const handleLogistics = async (order) => {
    try {
        logisticsLoading.value = true
        const res = await getLogistics(order.orderNumber)
        logisticsData.value = {
            ...res.data,
            statusList: JSON.parse(res.data.statusList || '[]')
        }
        logisticsVisible.value = true
    } catch (error) {
        ElMessage.error('获取物流信息失败')
    } finally {
        logisticsLoading.value = false
    }
}


const handleCancel = async (row) => {
    try {
        await cancelOrder(row.orderNumber)
        ElMessage.success('已取消订单')
        await getOrders()
    } catch (error) {
        ElMessage.error('取消失败')
    }
}
</script>

<template>
    <div class="container">
        <el-card class="table-manager">
            <template #header>
                <div class="header">
                    <h2 class="title">订单管理</h2>
                    <div class="header-right">
                        <div class="search-group">
                            <el-select v-model="statusFilter" @change="() => {
                                params.pageNumber = 1
                                params.status = statusFilter // 同步参数
                                getOrders()
                            }" style="width: 120px">
                                <el-option v-for="item in statusOptions" :key="item.value" :label="item.label"
                                    :value="item.value" />
                            </el-select>

                            <el-input v-model="params.search" placeholder="订单编号/收货人" :prefix-icon="Search"
                                style="width: 240px" @input="getOrders" />
                        </div>
                    </div>
                </div>
            </template>

            <el-table :data="orders" v-loading="loading" height="calc(100vh - 300px)">
                <el-table-column prop="orderNumber" label="订单号" width="220" align="center" />
                <el-table-column label="商品" min-width="120" align="center">
                    <template #default="{ row }">
                        <div class="avatar-stack">
                            <el-avatar v-for="(item, index) in row.details.slice(0, 5)" :key="index"
                                :src="item.pictureAddress" :size="40" shape="square" :style="{
                                    zIndex: 5 - index,
                                    position: 'absolute',
                                    left: `${index * 20}px`,
                                    transition: 'all 0.3s'
                                }" class="stacked-avatar" />
                        </div>
                    </template>
                </el-table-column>

                <el-table-column prop="address.name" label="收货人" width="180" align="center" />
                <el-table-column prop="address.phone" label="联系电话" width="180" align="center" />
                <el-table-column prop="status" label="状态" width="120" align="center">
                    <template #default="{ row }">
                        <el-tag :type="{
                            '待发货': 'warning',
                            '待收货': 'primary',
                            '已完成': 'success',
                            '已取消': 'danger'
                        }[row.status]">
                            {{ row.status }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="sumPrices" label="金额" width="180" align="center">
                    <template #default="{ row }">¥{{ row.sumPrices.toFixed(2) }}</template>
                </el-table-column>
                <el-table-column prop="createTime" label="下单时间" width="180" align="center" />
                <el-table-column label="操作" width="180" align="center">
                    <template #default="{ row }">
                        <div class="flex gap-2 justify-center">
                            <el-tooltip content="物流详情" placement="top" v-if="['待收货', '已完成'].includes(row.status)">
                                <el-button type="warning" :icon="Van" circle @click="handleAction('logistics', row)" />
                            </el-tooltip>
                            <el-tooltip content="发货" placement="top" v-if="row.status === '待发货'">
                                <el-button type="primary" :icon="Sell" circle @click="handleAction('send', row)" />
                            </el-tooltip>
                            <el-tooltip content="详情" placement="top">
                                <el-button type="info" :icon="InfoFilled" circle @click="handleAction('detail', row)" />
                            </el-tooltip>

                            <el-tooltip content="取消订单" placement="top" v-if="row.status !== '已取消'">
                                <el-button type="danger" :icon="Delete" circle @click="handleAction('cancel', row)" />
                            </el-tooltip>
                        </div>
                    </template>
                </el-table-column>
            </el-table>

            <div class="pagination-wrapper" v-if="params.total > 0">
                <el-pagination v-model:current-page="params.pageNumber" v-model:page-size="params.pageSize"
                    :total="params.total" layout="total, sizes, prev, pager, next" :page-sizes="[10, 20, 50]"
                    @current-change="getOrders" @size-change="getOrders" :background="true" />
            </div>
        </el-card>

        <!-- 订单详情抽屉 -->
        <el-drawer v-model="drawerVisible" title="订单详情" size="40%">
            <div v-if="currentOrder" class="detail-container">


                <div class="detail-section">
                    <h4 class="section-title">基本信息</h4>
                    <div class="info-grid">

                        <div class="info-item">
                            <span class="info-label">订单号：</span>
                            <span class="order-number">{{ currentOrder.orderNumber }}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">状态：</span>
                            <span class="info-value">
                                {{ currentOrder.status }}
                            </span>

                        </div>
                        <div class="info-item">
                            <span class="info-label">下单时间：</span>
                            <span class="info-value">{{ currentOrder.createTime }}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">付款时间：</span>
                            <span class="info-value">
                                {{ currentOrder.paymentTime ? formatDateTime(currentOrder.paymentTime) : '无' }}
                            </span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">订单金额：</span>
                            <span class="info-value price">¥{{ currentOrder.sumPrices.toFixed(2) }}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">运费：</span>
                            <span class="info-value price">¥{{ currentOrder.shippingFee?.toFixed(2) }}</span>
                        </div>

                        <div class="info-item">
                            <span class="info-label">付款方式：</span>
                            <span class="info-value">{{ currentOrder.paymentMethod || '未选择' }}</span>
                        </div>

                        <div class="info-item">
                            <span class="info-label">订单备注：</span>
                            <span class="info-value">{{ currentOrder.remark || '无备注信息' }}</span>
                        </div>
                    </div>
                </div>

                <el-divider class="my-6" />

                <div class="detail-section">
                    <h4 class="section-title">收货信息</h4>
                    <div class="info-grid">
                        <div class="info-item">
                            <span class="info-label">收货人：</span>
                            <span class="info-value">{{ currentOrder.address.name }}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">联系电话：</span>
                            <span class="info-value">{{ currentOrder.address.phone }}</span>
                        </div>
                        <div class="info-item full-width">
                            <span class="info-label">收货地址：</span>
                            <span class="info-value">{{ currentOrder.address.full }}</span>
                        </div>
                    </div>
                </div>

                <el-divider class="my-6" />

                <div class="detail-section">
                    <h4 class="section-title">商品清单</h4>
                    <div class="goods-list">
                        <div v-for="(item, index) in currentOrder.details" :key="index" class="goods-item">
                            <el-avatar :src="item.pictureAddress" :size="50" shape="square" />
                            <div class="goods-info">
                                <div class="goods-name">{{ item.freshName }}</div>
                                <div class="goods-spec">
                                    <span class="price">¥{{ item.price.toFixed(2) }}</span>
                                    <span class="count">×{{ item.count }}</span>
                                </div>
                            </div>
                            <div class="goods-total">
                                ¥{{ (item.price * item.count).toFixed(2) }}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </el-drawer>

        <!-- 发货抽屉 -->
        <el-drawer v-model="shipVisible" title="填写物流信息">
            <el-form :model="shipForm" label-width="100px">
                <el-form-item label="物流公司" prop="company">
                    <el-select v-model="shipForm.company" placeholder="请选择物流公司" style="width: 100%">
                        <el-option v-for="item in logisticsCompanies" :key="item.value" :label="item.label"
                            :value="item.value" />
                    </el-select>
                </el-form-item>
                <el-form-item label="物流类型" prop="type">
                    <el-radio-group v-model="shipForm.type">
                        <el-radio label="normal">普通物流</el-radio>
                        <el-radio label="cold">冷链物流</el-radio>
                    </el-radio-group>
                </el-form-item>

                <el-form-item label="物流单号" prop="trackingNumber">
                    <el-input v-model="shipForm.trackingNumber" />
                </el-form-item>
            </el-form>

            <div class="drawer-footer">
                <el-button @click="shipVisible = false">取消</el-button>
                <el-button type="primary" @click="confirmShip">确认发货</el-button>
            </div>
        </el-drawer>

        <!-- 物流信息抽屉 -->
        <el-drawer v-model="logisticsVisible" title="物流追踪" size="40%">
            <div v-loading="logisticsLoading" class="logistics-container">
                <!-- 基础信息展示 -->
                <div class="logistics-header">
                    <div class="left">
                        <div class="company">{{ logisticsData.company }} <el-tag effect="plain" type="info">
                                {{ logisticsData.type === 'cold' ? '冷链物流' : '普通物流' }}
                            </el-tag></div>
                        <div class="text-gray-500 text-sm">物流单号：{{ logisticsData.trackingNumber }}</div>
                        <span class="text-gray-500 text-sm">
                            最后更新：{{ formatDateTime(logisticsData.histories[0]?.eventTime) }}
                        </span>
                    </div>
                    <div class="right">
                        <el-tag :type="logisticsData.currentStatus === '运输中' ? 'success' : 'primary'">
                            {{ logisticsData.currentStatus }}

                        </el-tag>
                    </div>



                </div>

                <!-- 时间轴展示 -->
                <el-timeline v-if="logisticsData.histories?.length">
                    <el-timeline-item v-for="(event, index) in logisticsData.histories" :key="index"
                        :timestamp="formatDateTime(event.eventTime)" placement="top"
                        :type="getStatusType(event.status)">
                        <div class="event-card">
                            <div>
                                <div class="font-medium">
                                    {{ event.status }}
                                </div>
                                <div v-if="logisticsData.type === 'cold'" class="text-sm text-gray-500 mt-1">
                                    当前温度：{{ event.temperature }}℃
                                </div>
                            </div>
                            <div>
                                <el-tag :type="getStatusTagType(event.status)" size="small">
                                    {{ event.status === 'delivered' ? '已签收' : '运输中' }}
                                </el-tag>
                            </div>
                        </div>
                    </el-timeline-item>
                </el-timeline>

                <!-- 空状态 -->
                <el-empty v-else description="暂无物流轨迹信息" />
            </div>
        </el-drawer>
    </div>
</template>

<style scoped lang="scss">
/* 原有样式保持不变 */
.container {
    height: calc(100vh - 150px);
    box-sizing: border-box;

    :deep(.el-card__header) {
        padding: 0;
    }
}

.table-manager {
    height: 100%;

    :deep(.el-card__body) {
        padding: 16px !important;
    }
}

.header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 20px;
    background: #fff;

    .title {
        color: var(--el-color-primary);
        font-size: 20px;
        font-weight: 600;
        margin: 0;
        letter-spacing: 0.5px;
    }

    .header-right {
        display: flex;
        align-items: center;
        gap: 16px;

        .search-group {
            display: flex;
            align-items: center;
            gap: 12px;
            height: 40px;

            :deep {
                .el-input__wrapper {
                    height: 40px;

                    &:hover {
                        box-shadow: 0 0 0 1px var(--el-color-primary) inset;
                    }
                }

                .el-select__wrapper {
                    height: 40px;
                    border-radius: 8px;
                    padding: 0 16px;
                }
            }
        }
    }
}

.pagination-wrapper {
    padding: 12px 0;

    :deep(.el-pagination) {
        justify-content: flex-end;
        padding: 8px 16px;
        background: #fff;
        border-radius: 8px;
    }
}

:deep(.el-button--small) {
    padding: 15px !important;
}

:deep(.el-table) {
    border-radius: 8px;
    font-size: 14px;

    th {
        background: #f8f9fa !important;
        color: #606266;
        font-weight: 600;
    }

    td {
        padding: 12px 0;
    }

    tr:hover td {
        background: #f5f7fa !important;
    }

    .el-button {
        padding: 6px;
        margin: 0 4px;
        border: 1px solid;
        transition: all 0.2s;

        &.is-circle {
            border-radius: 50%;
        }

        &:hover {
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
        }
    }
}

/* 新增样式 */
.avatar-stack {
    position: relative;
    width: 120px;
    height: 40px;
    margin: 0 auto;

    .stacked-avatar {
        border: 2px solid white;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
        cursor: pointer;
        transition: transform 0.3s;

        &:hover {
            transform: translateY(-5px);
            z-index: 10 !important;
        }
    }

}

.detail-container {
    padding: 20px;

    .detail-header {
        display: flex;
        justify-content: space-between;
        align-items: center;

        .order-number {
            margin: 0;
            font-size: 16px;
            color: var(--el-text-color-primary);
        }
    }

    .section-title {
        font-size: 15px;
        color: var(--el-text-color-primary);
        margin: 0 0 16px 0;
        font-weight: 600;
    }

    .info-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 16px;

        .info-item {
            display: flex;
            align-items: center;
            font-size: 14px;

            &.full-width {
                grid-column: 1 / -1;
            }

            .info-label {
                color: var(--el-text-color-secondary);
                min-width: 80px;
            }

            .info-value {
                color: var(--el-text-color-primary);

                &.price {
                    color: var(--el-color-primary);
                    font-weight: 600;
                }
            }
        }
    }

    .goods-list {
        .goods-item {
            display: flex;
            align-items: center;
            padding: 12px;
            background: var(--el-fill-color-light);
            margin-bottom: 8px;
            border-radius: 8px;

            .goods-info {
                flex: 1;
                margin-left: 12px;

                .goods-name {
                    font-size: 14px;
                    color: var(--el-text-color-primary);
                }

                .goods-spec {
                    font-size: 12px;
                    color: var(--el-text-color-secondary);
                    margin-top: 4px;

                    .price {
                        margin-right: 8px;
                    }
                }
            }

            .goods-total {
                font-weight: 500;
                color: var(--el-text-color-primary);
            }
        }
    }
}

// 物流信息抽屉样式
.logistics-container {
    padding: 24px;
    background: #f8fafc;
    min-height: 100%;
}

/* 物流头部信息 */
.logistics-header {
    display: flex;
    justify-content: space-between;
    background: white;
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
    margin-bottom: 28px;

    .left {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .right {
        display: flex;
        align-items: center;
    }

    .company {
        font-size: 18px;
        font-weight: 600;
        display: flex;
        align-items: center;

        .el-tag {
            margin-left: 8px;
            font-size: 12px;
            padding: 4px 8px;
        }

    }

    .status-tag {
        padding: 8px 16px;
        border-radius: 20px;
        font-weight: 600;

        &.shipping {
            background: #eef6ff;
            color: #3b82f6;
        }

        &.delivering {
            background: #f5f3ff;
            color: #8b5cf6;
        }

        &.delivered {
            background: #ecfdf5;
            color: #10b981;
        }
    }

    .company-info {
        display: flex;
        align-items: center;
        gap: 12px;
        margin: 16px 0;

        .company-logo {
            width: 48px;
            height: 48px;
            border-radius: 8px;
            background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }

        .text-group {
            .company-name {
                font-size: 18px;
                font-weight: 600;
                color: #1e293b;
            }

            .tracking-number {
                color: #64748b;
                font-family: monospace;
                font-size: 14px;
            }
        }
    }

    .meta-info {
        display: flex;
        gap: 16px;

        .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            background: #f1f5f9;
            border-radius: 6px;

            .label {
                color: #64748b;
                font-size: 12px;
            }

            .value {
                color: #1e293b;
                font-weight: 500;
            }
        }
    }
}

/* 时间轴样式 */
.timeline-wrapper {
    position: relative;
    padding-left: 32px;

    &::before {
        content: '';
        position: absolute;
        left: 11px;
        top: 16px;
        bottom: 16px;
        width: 2px;
        background: #e2e8f0;
        border-radius: 2px;
    }
}

.timeline-item {
    position: relative;
    padding: 16px 0;

    .timeline-marker {
        position: absolute;
        left: -32px;
        top: 20px;
        width: 24px;
        height: 24px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        background: white;
        border: 2px solid #e2e8f0;
        transition: all 0.3s;

        .inner-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #94a3b8;
        }
    }

    &.active {
        .timeline-marker {
            border-color: #3b82f6;

            .inner-dot {
                background: #3b82f6;
                transform: scale(1.4);
            }
        }
    }
}

.event-card {
    display: flex;
    justify-content: space-between;
    background: white;
    border-radius: 12px;
    padding: 16px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    transition: transform 0.3s;

    &:hover {
        transform: translateX(8px);
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
    }

    .event-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 12px;

        .event-title {
            font-weight: 600;
            color: #1e293b;
            font-size: 15px;
        }

        .event-status {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;

            &.shipping {
                background: #dbeafe;
                color: #1d4ed8;
            }

            &.delivering {
                background: #ede9fe;
                color: #6d28d9;
            }

            &.delivered {
                background: #dcfce7;
                color: #15803d;
            }
        }
    }

    .event-body {
        display: grid;
        grid-template-columns: 1fr auto;
        gap: 12px;

        .event-time {
            color: #64748b;
            font-size: 13px;
        }

        .temperature {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 6px 10px;
            background: #fff7ed;
            border-radius: 20px;
            color: #ea580c;
            font-weight: 500;

            i {
                font-size: 14px;
            }
        }
    }
}

/* 空状态样式 */
.empty-logistics {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 40px 0;

    .empty-icon {
        width: 80px;
        height: 80px;
        margin-bottom: 16px;
        opacity: 0.6;
    }

    .empty-text {
        color: #94a3b8;
        font-size: 14px;
    }
}

:deep(.el-timeline) {
    padding-left: 20px;

    .el-timeline-item__timestamp {
        color: var(--el-text-color-secondary);
        font-size: 13px;
        margin-bottom: 8px;
    }
}

.text-gray-500 {
    color: var(--el-text-color-secondary);
}

:deep(.el-timeline) {
    padding-left: 20px;

    .el-timeline-item__timestamp {
        color: var(--el-text-color-secondary);
        font-size: 13px;
    }

    .el-card {
        margin-bottom: 12px;

        &__header {
            padding: 8px 12px;
        }

        &__body {
            padding: 8px 12px;
        }
    }
}

:deep(.el-drawer) {

    // 表单容器
    .el-form {
        padding: 20px;

        // 表单项间距
        .el-form-item {
            margin-bottom: 22px;
        }
    }

    // 底部操作栏
    .drawer-footer {
        position: absolute;
        bottom: 0;
        width: 100%;
        padding: 16px;
        background: var(--el-bg-color);
        border-top: 1px solid var(--el-border-color);
        text-align: right;
    }
}

:deep(.el-drawer) {
    .el-drawer__header {
        margin-bottom: 0;
        padding: 20px;
        border-bottom: 1px solid var(--el-border-color);
    }

    .el-drawer__body {
        padding: 0;
    }
}
</style>