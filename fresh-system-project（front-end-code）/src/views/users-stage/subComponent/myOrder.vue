<template>
  <div class="order-container">
    <el-card class="main-card">
      <h1 class="page-title">​My Orders</h1>

      <div class="filter-section">
        <div class="status-filter">
          <el-button v-for="status in statusFilters" :key="status.value" size="large" class="filter-btn"
            :type="activeStatus === status.value ? 'primary' : 'info'" @click="handleStatusChange(status.value)">
            {{ status.label }}
          </el-button>
        </div>
        <el-input v-model="params.search" placeholder="搜索订单..." :prefix-icon="Search" class="search-input" clearable
          @input="getUserOrders" />
      </div>

      <div v-if="!loading && filteredOrders.length === 0" class="empty-container">
        <el-empty description="您还没有任何订单"></el-empty>
      </div>

      <div v-loading="loading" class="order-list">
        <div v-for="order in filteredOrders" :key="order.orderId" class="order-card">
          <div class="order-header" @click="viewDetail(order.orderNumber)">
            <div class="order-meta">
              <span class="order-number">订单号：{{ order.orderNumber }}</span>
            </div>
            <el-tag :type="statusTagMap[order.status]" effect="light" size="large" class="status-tag">
              {{ order.status }}
            </el-tag>
          </div>

          <div class="goods-preview" @click="viewDetail(order.orderNumber)">
            <div class="images">
              <el-image v-for="(detail, index) in order.details.slice(0, 3)" :key="index" :src="detail.pictureAddress"
                fit="cover" class="goods-thumb" />
              <div v-if="order.details.length > 3" class="ellipsis">
                +{{ order.details.length - 3 }}
              </div>
            </div>
            <div class="price-info">
              <span class="amount">¥{{ order.sumPrices.toFixed(2) }}</span>
            </div>
          </div>

          <div class="action-buttons">
            <template v-if="order.status === '待发货'">
              <el-button type="primary" class="action-btn" @click="viewDetail(order.orderNumber)">
                <el-icon>
                  <View />
                </el-icon>
                <span>查看详情</span>
              </el-button>
              <el-button type="warning" class="action-btn" @click="handleUrge(order)">
                <el-icon>
                  <Bell />
                </el-icon>
                <span>催促发货</span>
              </el-button>
            </template>

            <template v-if="order.status === '待收货'">
              <el-button type="success" class="action-btn" @click="openLogisticsDialog(order.orderNumber)">
                <el-icon>
                  <ZoomIn />
                </el-icon>
                <span>查看物流</span>
              </el-button>
              <el-button type="warning" class="action-btn" @click="handleConfirm(order)">
                <el-icon>
                  <Check />
                </el-icon>
                <span>确认收货</span>
              </el-button>
            </template>

            <template v-if="order.status === '已完成'">
              <el-button type="info" class="action-btn" @click="openApplyDialog(order)">
                <el-icon>
                  <Document />
                </el-icon>
                <span>申请售后</span>
              </el-button>
              <el-button type="danger" class="action-btn" @click="handleDelete(order)">
                <el-icon>
                  <Delete />
                </el-icon>
                <span>删除订单</span>
              </el-button>
            </template>
          </div>
        </div>
      </div>

      <div v-if="loadingMore" class="loading-more">
        <el-icon class="loading-icon">
          <Loading />
        </el-icon>
        <span class="loading-text">正在加载更多订单...</span>
      </div>

    </el-card>

    <!-- 物流详情弹窗 -->
    <el-dialog v-model="logisticsDialog" title="物流详情" width="680px" top="5vh" class="logistics-dialog"
      @closed="logisticsData = null">
      <div v-loading="logisticsLoading" class="dialog-content">
        <!-- 基础信息卡 -->
        <el-card shadow="never" class="info-card">
          <div class="info-grid">
            <div class="info-item">
              <el-icon :size="20">
                <ColdDrink v-if="logisticsData?.type === 'cold'" />
              </el-icon>
              <span class="label">物流公司：</span>
              <span class="value">{{ logisticsData?.company }}</span>
              <div class="info-item highlight">
                <el-tag :type="logisticsData?.type === 'cold' ? 'danger' : 'info'" effect="dark" class="type-tag">
                  {{ logisticsData?.type === 'cold' ? '冷链物流' : '普通物流' }}
                </el-tag>
              </div>
            </div>
            <div class="info-item">
              <el-icon :size="20">
                <Box />
              </el-icon>
              <span class="label">运单号：</span>
              <span class="value">{{ logisticsData?.trackingNumber }}</span>
            </div>
            <div class="info-item">
              <el-icon :size="20">
                <Van />
              </el-icon>
              <span class="label">当前状态：</span>
              <el-tag effect="plain" class="logisticsData-tag">
                {{ logisticsData?.currentStatus }}
              </el-tag>
            </div>
          </div>
        </el-card>

        <!-- 时间轴 -->
        <el-timeline v-if="logisticsData?.histories?.length" class="timeline">
          <el-timeline-item v-for="(event, index) in logisticsData.histories" :key="index"
            :timestamp="formatTime(event.eventTime)" placement="top">
            <div class="timeline-card">
              <div class="card-header">
                <el-icon :size="24" :color="statusColors[event.status]">
                  <component :is="statusIcons[event.status]" />
                </el-icon>
                <span class="status-text">{{ event.status }}</span>
              </div>
              <div v-if="logisticsData.type === 'cold'" class="temperature">
                <el-icon :size="16">
                  <ColdDrink />
                </el-icon>
                <span class="text">温度：{{ event.temperature }}℃</span>
              </div>
            </div>
          </el-timeline-item>
        </el-timeline>

        <el-empty v-else description="暂无物流轨迹信息" />
      </div>
    </el-dialog>

    <!-- 申请售后 -->
    <el-dialog v-model="applyDialog" title="申请售后" width="500px">
      <el-form :model="applyForm" :rules="rules" ref="applyFormRef" label-width="80px">
        <!-- 订单号显示 -->
        <el-form-item label="订单号">
          <el-input v-model="selectedOrder.orderNumber" disabled />
        </el-form-item>

        <!-- 售后类型选择 -->
        <el-form-item label="类型" prop="serviceType">
          <el-select v-model="applyForm.serviceType" placeholder="请选择">
            <el-option label="退款" value="退款" />
            <el-option label="退款退货" value="退款退货" />
            <el-option label="换货" value="换货" />
          </el-select>
        </el-form-item>

        <!-- 申请原因输入 -->
        <el-form-item label="原因" prop="applyReason">
          <el-input v-model="applyForm.applyReason" type="textarea" :rows="4" placeholder="请详细描述问题（建议附上照片凭证）" />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="applyDialog = false">取消</el-button>
        <el-button type="primary" @click="submitApply">提交申请</el-button>
      </template>
    </el-dialog>


  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Search, View, Check, Document, Delete, Loading, Bell, ZoomIn } from '@element-plus/icons-vue'
import { obtainUserOrderService, deleteMyOrderService, applyAfterSales } from '@/api/userStage.js'
import { getLogistics } from '@/api/managerStage.js'
import { ElMessage } from 'element-plus'
import { ColdDrink, Clock, Box, Van, CircleCheckFilled } from '@element-plus/icons-vue'


// 物流弹窗相关状态
const logisticsDialog = ref(false)
const logisticsData = ref(null)
const logisticsLoading = ref(false)

// 状态图标映射
const statusIcons = {
  '已发货': Box,
  '运输中': Van,
  '已签收': CircleCheckFilled
}

// 状态颜色映射
const statusColors = {
  '已发货': '#409EFF',
  '运输中': '#E6A23C',
  '已签收': '#67C23A'
}

// 打开物流弹窗
const openLogisticsDialog = async (orderNumber) => {
  try {
    logisticsLoading.value = true
    const res = await getLogistics(orderNumber)
    logisticsData.value = res.data
    logisticsDialog.value = true
  } catch (error) {
    ElMessage.error('获取物流信息失败')
  } finally {
    logisticsLoading.value = false
  }
}

// 时间格式化
const formatTime = (isoString) => {
  const date = new Date(isoString)
  return `${date.toLocaleDateString()} ${date.toLocaleTimeString('en-GB')}`
}

// 状态筛选配置
const statusFilters = [
  { label: '全部', value: 'all' },
  { label: '待发货', value: '待发货' },
  { label: '待收货', value: '待收货' },
  { label: '已完成', value: '已完成' },
  { label: '已取消', value: '已取消' }
]

// 响应式数据
const applyDialog = ref(false)
const applyForm = ref({
  serviceType: '',
  applyReason: ''
})

// 表单验证规则
const rules = {
  serviceType: [
    { required: true, message: '请选择售后类型', trigger: 'change' }
  ],
  applyReason: [
    { required: true, message: '请填写申请原因', trigger: 'blur' },
    { min: 10, message: '至少输入10个字符', trigger: 'blur' }
  ]
}

// 打开申请弹窗
const openApplyDialog = (order) => {
  selectedOrder.value = order
  applyDialog.value = true
}

const applyFormRef = ref(null)

// 提交申请
const submitApply = async () => {
  try {
    await applyFormRef.value.validate()

    const params = {
      orderNumber: selectedOrder.value.orderNumber, // 使用订单号
      ...applyForm.value
    }

    const res = await applyAfterSales(params)
    if (res.data.code === 0) {
      ElMessage.success('申请提交成功，请等待审核')
      applyDialog.value = false
    }
  } catch (error) {
    ElMessage.error(error.response?.data?.message || '请检查后重新提交')
  }
}

// 响应式数据
const activeStatus = ref('all')
const loading = ref(false)
const loadingMore = ref(false)
const detailVisible = ref(false)
const selectedOrder = ref(null)

// 订单数据
const orders = ref([])
const params = ref({
  pageNumber: 1,
  pageSize: 1000, // 全量加载
  search: '',
  total: 0
})

// 状态标签颜色映射
const statusTagMap = {
  '待发货': 'warning',
  '待收货': 'primary',
  '已完成': 'success',
  '已取消': 'danger'
}




// 过滤后的订单数据
const filteredOrders = computed(() => {
  if (activeStatus.value === 'all') return orders.value
  return orders.value.filter(order => order.status === activeStatus.value)
})

// 获取订单数据
const getUserOrders = async () => {
  try {
    loading.value = true
    const result = await obtainUserOrderService(params.value)
    orders.value = result.data.items
    params.value.total = result.data.total
  } catch (error) {
    ElMessage.error('获取订单数据失败,请先登录')
    tableData.value = []
  } finally {
    loading.value = false
  }
}

// 状态筛选处理
const handleStatusChange = (status) => {
  activeStatus.value = status
}

import { useRouter } from 'vue-router'

const router = useRouter()

// 显示详情弹窗
const viewDetail = (orderNumber) => {
  router.push(`/userMain/orderDetail/${orderNumber}`)
}

// 催促发货处理
const handleUrge = (order) => {
  ElMessage.success({
    message: '已催促商家尽快发货，请耐心等待～',
    duration: 3000,
    showClose: true
  })
}

// 确认收货处理
const handleConfirm = async (order) => {
  try {
    ElMessage.success('收货成功')
    await getUserOrders()
  } catch (error) {
    ElMessage.error(error.message)
  }
}

// 删除订单处理
const handleDelete = async (order) => {
  try {
    await deleteMyOrderService(order.orderNumber)
    ElMessage.success('删除成功')
    await getUserOrders()
  } catch (error) {
    ElMessage.error(error.message)
  }
}

onMounted(() => {
  getUserOrders()
})
</script>

<style lang="scss" scoped>
.order-container {
  padding: 24px;
  min-height: calc(100vh - 48px);
  box-sizing: border-box;



  .main-card {
    border-radius: 16px;
    padding: 24px;
  }

  .page-title {
    font-family: var(--font-title);
    font-size: 36px;
    color: var(--color-primary);
    margin-bottom: 32px;
    letter-spacing: 2px;
    font-weight: bold;
    text-align: center;
  }

  .filter-section {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
    margin-bottom: 32px;
    justify-content: space-between;
    align-items: center;

    .status-filter {
      display: flex;
      gap: 0.1rem;
      flex-wrap: wrap;
      justify-content: center;

      .filter-btn {
        border-radius: 16px;
        padding: 0 24px;
      }
    }

    .search-input {
      width: 100%;
      max-width: 480px;
      border-radius: 16px;

      :deep(.el-input__wrapper) {
        border-radius: 32px;
        height: 48px;
        font-size: 16px;
      }

      :deep(.el-input__inner) {
        border-radius: 16px;
        height: 48px;
        font-size: 16px;
      }
    }
  }

  .empty-container {
    padding: 80px 0;
    text-align: center;

    :deep(.el-empty__description) {
      p {
        color: rgba(51, 51, 51, 0.6);
        font-family: 'Inter', sans-serif;
        font-size: 1.1rem;
        margin: 16px 0;
      }
    }
  }
}


.order-list {
  display: grid;
  gap: 24px;
  grid-template-columns: repeat(auto-fill, minmax(480px, 1fr));

  .order-card {
    padding: 24px;
    border-radius: 16px;
    background: #fff;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    transition: transform 0.2s;

    &:hover {
      transform: translateY(-4px);
    }

    .order-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;

      .order-meta {
        .order-number {
          font-size: 16px;
          color: #666;
          font-weight: 500;
        }

        .order-time {
          font-size: 14px;
          color: #999;
        }
      }

      .status-tag {
        border-radius: 16px;
        padding: 8px 16px;
      }
    }

    .goods-preview {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;

      .images {
        display: flex;
        overflow: visible; // 改为可见溢出
        position: relative;
        flex-shrink: 0; // 防止图片缩小;

        .goods-thumb {
          width: 80px;
          height: 80px;
          border: 1px solid #eee;
          border-radius: 8px;
          margin-right: 5px;
        }

        .ellipsis {
          width: 80px;
          height: 80px;
          border: 1px solid #eee;
          border-radius: 8px;
          background: #f8f9fa;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 16px;
          color: #666;
        }
      }

      .price-info .amount {
        font-size: 24px;
        color: #ff4d4f;
        font-weight: 700;
      }
    }

    .action-buttons {
      display: flex;
      gap: 16px;
      justify-content: flex-end;

      .action-btn {
        padding: 20px 20px;
        border-radius: 16px;
        font-size: 15px;
        display: flex;
        align-items: center;
        gap: 8px;
        transition: all 0.2s;


        &:hover {
          opacity: 0.9;
          transform: scale(1.02);
        }

        &[type='primary'] {
          background: transparent !important;
          border-color: transparent !important;
          color: var(--color-primary);

          &:hover {
            background: transparent !important;
            border-color: transparent !important;
            color: var(--color-primary) !important;
            opacity: 0.8;
          }

          &:active {
            opacity: 0.6;
          }
        }

        &[type='success'] {
          background: #67c23a;
          border-color: #67c23a;
          color: white;
        }

        &[type='warning'] {
          background: #e6a23c;
          border-color: #e6a23c;
          color: white;
        }

        &[type='danger'] {
          background: #f56c6c;
          border-color: #f56c6c;
          color: white;
        }

        &[type='info'] {
          background: #909399;
          border-color: #909399;
          color: white;
        }
      }
    }
  }
}

.loading-more {
  text-align: center;
  padding: 24px;
  color: #666;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;

  .loading-icon {
    animation: rotating 2s linear infinite;
  }
}

.detail-dialog {
  .order-detail {
    max-height: 70vh;
    display: flex;
    flex-direction: column;

    .goods-section {
      flex: 1;
      overflow: hidden;

      .goods-scroll {
        max-height: 240px;
        overflow-y: auto;
        padding-right: 8px;

        .goods-item {
          display: flex;
          align-items: center;
          padding: 12px;
          margin-bottom: 12px;
          background: #f8f9fa;
          border-radius: 8px;

          .goods-image {
            width: 60px;
            height: 60px;
            margin-right: 16px;
            border-radius: 6px;
          }

          .goods-info {
            flex: 1;
            min-width: 0;

            .goods-name {
              font-size: 14px;
            }

            .goods-spec {
              display: flex;
              justify-content: space-between;
              margin-top: 8px;

              .price {
                color: #e4393c;
                font-weight: 500;

                .original-price {
                  color: #999;
                  text-decoration: line-through;
                  margin-left: 8px;
                }
              }

              .quantity {
                color: #666;
              }
            }
          }
        }
      }
    }

    .compact-order-info {
      :deep(.el-descriptions) {
        .dual-column {
          display: flex;
          padding: 0 !important;
          border: none;

          .left-col,
          .right-col {
            flex: 1;
            padding: 20px;
            min-width: 320px;

            &:first-child {
              border-right: 1px solid #EBEEF5;
            }
          }
        }

        .info-block {
          margin-bottom: 25px;

          &:last-child {
            margin-bottom: 0;
          }
        }

        .info-title {
          font-size: 16px;
          color: #303133;
          margin: 0 0 15px 0;
          padding-bottom: 8px;
          border-bottom: 1px dashed #E4E7ED;

          i {
            margin-right: 8px;
            color: #409EFF;
          }
        }

        .info-row {
          display: flex;
          align-items: flex-start;
          margin: 12px 0;
          font-size: 14px;

          .label {
            color: #909399;
            min-width: 80px;
            margin-right: 12px;


          }

          .value {
            color: #606266;
            flex: 1;
            word-break: break-word;
          }

          &.highlighted {
            .el-tag {
              font-size: 13px;
              padding: 6px 12px;
              border-radius: 14px;
            }
          }

          &.amount-row {
            flex-direction: column;
            background: #f8fafc;
            border-radius: 4px;
            padding: 12px;
            margin: 15px 0;

            >div {
              display: flex;
              width: 100%;
              margin: 6px 0;
            }

            .total-amount {
              margin-top: 10px;
              padding-top: 10px;
              border-top: 1px solid #EBEEF5;

              .value {
                font-size: 18px;
                color: #F56C6C;
                font-weight: 600;
              }
            }
          }

          &.address-row .value {
            line-height: 1.5;
            white-space: pre-wrap;
          }
        }

        .payment-method {
          color: #67C23A;

          i {
            margin-right: 6px;
          }
        }

        .remark {
          font-style: italic;
          color: #909399;
        }
      }
    }

    // 商品图片样式
    .goods-image {
      width: 80px;
      height: 80px;
      border-radius: 6px;
      margin-right: 15px;
      border: 1px solid #eee;
    }

    // 价格显示优化
    .original-price {
      text-decoration: line-through;
      color: #999;
      font-size: 12px;
      margin-left: 5px;
    }

    // 时间信息组
    .time-info {
      background: #f8f9fa;
      padding: 12px;
      border-radius: 6px;
      margin-top: 10px;

      .info-item {
        font-size: 13px;
        color: #666;
      }
    }
  }
}

@media (max-width: 768px) {
  .order-container {
    padding: 16px;

    .page-title {
      font-size: 24px;
      margin-bottom: 24px;
    }

    .filter-section {
      .status-filter {
        gap: 8px;

        .filter-btn {
          flex: 1;
          text-align: center;
        }
      }

      .search-input {
        :deep(.el-input__inner) {
          height: 40px;
          font-size: 14px;
        }
      }
    }

    .order-list {
      grid-template-columns: 1fr;

      .order-card {
        padding: 16px;

        .action-buttons {
          flex-wrap: wrap;

          .action-btn {
            flex: 1;
            justify-content: center;
          }
        }
      }
    }

    .detail-dialog {
      width: 95%;

      .goods-item {
        flex-direction: column;
        align-items: center;

        .goods-image {
          width: 80px;
          height: 80px;
        }
      }
    }
  }
}

@keyframes rotating {
  from {
    transform: rotate(0deg);
  }

  to {
    transform: rotate(360deg);
  }
}

// 弹窗样式
.logistics-dialog {
  :deep(.el-dialog__body) {
    padding: 20px;
    max-height: 70vh;
    overflow: visible;
  }

  .dialog-content {
    display: grid;
    gap: 24px;
  }

  .info-card {
    border-radius: 12px;
    border: 1px solid #ebeef5;

    :deep(.el-card__body) {
      padding: 16px;
    }

    .info-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 16px;

      .info-item {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;

        .label {
          color: #606266;
        }

        .value {
          color: #303133;
          font-weight: 500;
        }

        &.highlight {
          grid-column: span 2;
          justify-content: center;
        }

        .type-tag {
          font-size: 14px;
          padding: 8px 16px;
          border-radius: 18px;
        }

        .status-tag {
          font-size: 13px;
          border: none;
        }
      }
    }
  }

  .timeline {
    padding-left: 20px;

    :deep(.el-timeline-item__timestamp) {
      color: #909399;
      font-size: 13px;
      margin-bottom: 8px;
    }

    .timeline-card {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 16px;
      border-radius: 12px;
      background: #f8fafc;
      border-radius: 8px;
      padding: 16px;
      border: 1px solid #ebeef5;

      .card-header {
        display: flex;
        align-items: center;
        gap: 12px;

        .status-text {
          font-weight: 500;
          color: #303133;
        }
      }

      .temperature {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #409EFF;
        background: rgba(64, 158, 255, 0.1);
        padding: 6px 12px;
        border-radius: 16px;
        width: fit-content;

        .text {
          font-size: 13px;
        }
      }
    }
  }
}
</style>