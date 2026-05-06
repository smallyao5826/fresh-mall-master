<script setup>
import { ref, onMounted,onBeforeUnmount  } from 'vue'
import * as echarts from 'echarts'
import { 
  getFreshSaleCountService,
  obtainOrders,
  getAfterSalesList,
  getLoginLogs,
  obtainFreshes
} from '@/api/managerStage.js'
import { Calendar, Warning, Box } from '@element-plus/icons-vue'

// 生鲜销量饼图
const pieChart = ref(null)
const pieOption = ref({
  title: { text: '生鲜分类销量', left: 'center' },
  tooltip: { trigger: 'item' },
  legend: { bottom: 0 },
  series: [{
    type: 'pie',
    radius: '65%',
    center: ['50%', '45%'],
    itemStyle: { borderRadius: 8 },
    data: []
  }]
})

// 核心指标
const metrics = ref({
  todayOrders: 0,
  pendingAfterSales: 0,
  unshippedOrders: 0
})

// 实时数据
const realtimeData = ref({
  logins: [],
  popularGoods: []
})

// 加载生鲜数据
const loadSalesData = async () => {
  const res = await getFreshSaleCountService()
  pieOption.value.series[0].data = res.data
  pieChart.value.setOption(pieOption.value)
}

// 加载关键指标
const loadMetrics = async () => {
  const [orders, afterSales] = await Promise.all([
    obtainOrders({ status: '未发货', pageSize: 1000 , pageNumber: 1 }),
    getAfterSalesList({ status: '待处理' })
  ])
  
  metrics.value = {
    todayOrders: orders.data.total,
    pendingAfterSales: afterSales.data.total,
    unshippedOrders: orders.data.total
  }
}

// 加载实时动态
const loadRealtimeData = async () => {
  const [logins, goods] = await Promise.all([
    getLoginLogs({ pageSize: 5 }),
    obtainFreshes({ sort: 'sales', pageSize: 5 , pageNumber: 1})
  ])
  
  realtimeData.value.logins = logins.data.items
  realtimeData.value.popularGoods = goods.data
}

// 时间格式化函数
const formatDateTime = (isoString) => {
    const date = new Date(isoString)
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
}

// 初始化图表
onMounted(() => {
  pieChart.value = echarts.init(document.getElementById('sales-pie'))
  
  const loadAllData = async () => {
    await Promise.all([
      loadSalesData(),
      loadMetrics(),
      loadRealtimeData()
    ])
  }
  
  loadAllData()
  const timer = setInterval(loadAllData, 30000)
  
  onBeforeUnmount(() => clearInterval(timer))
})
</script>

<template>
  <div class="dashboard-container">
    <!-- 核心指标 -->
    <el-row :gutter="20" class="metric-row">
      <el-col :span="8">
        <el-card class="metric-card">
          <div class="metric-content">
            <el-icon><Calendar /></el-icon>
            <div>
              <div class="label">今日订单</div>
              <div class="value">{{ metrics.todayOrders }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card class="metric-card">
          <div class="metric-content">
            <el-icon><Warning /></el-icon>
            <div>
              <div class="label">待处理售后</div>
              <div class="value">{{ metrics.pendingAfterSales }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card class="metric-card">
          <div class="metric-content">
            <el-icon><Box /></el-icon>
            <div>
              <div class="label">待发货订单</div>
              <div class="value">{{ metrics.unshippedOrders }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 数据可视化 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :span="16">
        <el-card>
          <div id="sales-pie" style="height:500px"></div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card class="data-list">
          <h3>最新登录</h3>
          <div v-for="log in realtimeData.logins" :key="log.id" class="list-item">
            <div>{{ log.username }}</div>
            <div class="subtext">{{ formatDateTime(log.lastLoginTime) }}</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

  </div>
</template>

<style scoped>
.dashboard-container {
  padding: 20px;
}

.metric-row {
  margin-bottom: 20px;
}

.metric-card {
  margin-bottom: 0;
  display: flex;
  align-items: center;
  border-radius: 12px;
  min-height: 120px;
}

.metric-content {
  display: flex;
  align-items: center;
  gap: 15px;
  
  
  .el-icon {
    font-size: 32px;
    padding: 12px;
    border-radius: 8px;
    background: var(--el-color-primary-light-9);
    color: var(--el-color-primary);
  }
  
  .label {
    color: var(--el-text-color-secondary);
    font-size: 14px;
  }
  
  .value {
    font-size: 24px;
    font-weight: 600;
  }
}

.chart-row {
  margin-bottom: 20px;
  
  .data-list {
    height: 100%;
    h3 {
      margin: 0 0 15px 0;
      color: var(--el-text-color-primary);
    }
    
    .list-item {
      padding: 12px 0;
      border-bottom: 1px solid var(--el-border-color);
      
      &:last-child {
        border-bottom: none;
      }
      
      .subtext {
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }
  }
}

.goods-row {
  margin-top: 20px;
}
</style>