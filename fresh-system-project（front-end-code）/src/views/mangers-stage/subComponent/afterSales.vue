<script setup>
import { Search, Refresh, Operation, CircleCheck, CircleClose, InfoFilled } from '@element-plus/icons-vue'
import { ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { getAfterSalesList } from '@/api/managerStage.js'
import { processAfterSale } from '@/api/managerStage.js'
import { ElMessage } from 'element-plus'

const router = useRouter()

// 数据状态
const params = ref({
    pageNumber: 1,
    pageSize: 10,
    total: 0
})

const filters = ref({
    orderNumber: '',
    serviceType: '',
    status: '',
    startTime: null,
    endTime: null,
})

const afterSalesList = ref([])
const loading = ref(false)

// 状态选项
const statusOptions = [
    { label: '全部', value: '' },
    { label: '待处理', value: '待处理' },
    { label: '已通过', value: '已通过' },
    { label: '已拒绝', value: '已拒绝' }
]

// 服务类型选项
const serviceTypeOptions = [
    { label: '退款', value: '退款' },
    { label: '退货退款', value: '退货退款' },
    { label: '换货', value: '换货' },
]

// 新增服务类型标签映射
const serviceTypeTagMap = {
    '退款': 'danger',
    '退货退款': 'warning',
    '换货': 'success'
}

// 时间格式化
const formatDateTime = (isoString) => {
    if (!isoString) return '-'
    const date = new Date(isoString)
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
}

// 获取售后数据（带防抖）
let searchTimer = null
const getList = async () => {
    clearTimeout(searchTimer)
    searchTimer = setTimeout(async () => {
        loading.value = true
        try {
            const res = await getAfterSalesList({
                page: params.value.pageNumber,
                pageSize: params.value.pageSize,
                orderNumber: filters.value.orderNumber,
                serviceType: filters.value.serviceType,
                status: filters.value.status,
                startTime: filters.value.startTime,
                endTime: filters.value.endTime
            })

            afterSalesList.value = res.data.items.map(item => ({
                ...item,
                applyTime: formatDateTime(item.applyTime),
                processTime: formatDateTime(item.processTime)
            }))
            params.value.total = res.data.total
        } catch (error) {
            console.error('获取售后列表失败:', error)
        } finally {
            loading.value = false
        }
    }, 300)
}

// 新增状态
const drawerVisible = ref(false)
const currentAfterSale = ref(null)
const processForm = ref({
    result: '通过',
    comment: ''
})

// 打开处理抽屉
const openProcessDrawer = (item) => {
    currentAfterSale.value = item
    processForm.value = { result: '通过', comment: '' }
    drawerVisible.value = true
}

// 提交处理结果
const submitProcess = async () => {
    try {
        await processAfterSale({
            id: currentAfterSale.value.id,
            processResult: processForm.value.result,
            processComment: processForm.value.comment
        })
        ElMessage.success('处理成功')
        drawerVisible.value = false
        getList() // 刷新列表
    } catch (error) {
        ElMessage.error('处理失败: ' + error.message)
    }
}

// 处理售后申请
const handleProcess = (id) => {
    const item = afterSalesList.value.find(v => v.id === id)
    if (item) openProcessDrawer(item)
}

// 初始化加载
getList()

// 重置筛选条件
const resetFilters = () => {
    filters.value = {
        orderNumber: '',
        serviceType: '',
        status: '',
        startTime: null,
        endTime: null,
    }
    getList()
}

// 自动监听过滤条件变化
watch([
    () => filters.value.serviceType,
    () => filters.value.status,
], () => getList())
</script>

<template>
    <div class="container">
        <el-card class="table-manager">
            <template #header>
                <div class="header">
                    <h2 class="title">售后管理</h2>
                    <div class="header-right">
                        <div class="search-group">
                            <el-select v-model="filters.serviceType" placeholder="售后类型" clearable style="width: 120px">
                                <el-option v-for="item in serviceTypeOptions" :key="item.value" :label="item.label"
                                    :value="item.value" />
                            </el-select>

                            <el-select v-model="filters.status" placeholder="处理状态" clearable style="width: 120px">
                                <el-option v-for="item in statusOptions" :key="item.value" :label="item.label"
                                    :value="item.value" />
                            </el-select>


                            <el-input v-model="filters.orderNumber" placeholder="输入订单号搜索" clearable
                                :prefix-icon="Search" style="width: 240px" @input="getList" />

                            <el-button @click="resetFilters" :icon="Refresh">重置</el-button>
                        </div>
                    </div>
                </div>
            </template>

            <el-table :data="afterSalesList" v-loading="loading" height="calc(100vh - 300px)" style="width: 100%"
                stripe>
                <el-table-column prop="id" label="售后单号" min-width="180" align="center" fixed />
                <el-table-column prop="orderNumber" label="订单编号" min-width="180" align="center" />
                <el-table-column prop="serviceType" label="售后类型" min-width="120" align="center">
                    <template #default="{ row }">
                        <el-tag :type="{
                            '退款': 'danger',
                            '退货退款': 'warning',
                            '换货': 'success'
                        }[row.serviceType]">
                            {{ row.serviceType }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="status" label="处理状态" min-width="120" align="center">
                    <template #default="{ row }">
                        <el-tag :type="{
                            '待处理': 'warning',
                            '已通过': 'success',
                            '已拒绝': 'danger'
                        }[row.status]">
                            {{ row.status }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="processResult" label="处理结果" min-width="120" align="center">
                    <template #default="{ row }">
                        <el-tag :type="{
                            '已通过': 'success',
                            '已拒绝': 'danger'
                        }[row.status]">
                            {{ row.processResult }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="applyTime" label="申请时间" min-width="180" align="center" />
                <el-table-column prop="processTime" label="处理时间" min-width="180" align="center" />
                <el-table-column label="操作" min-width="120" align="center" fixed="right">
                    <template #default="{ row }">
                        <el-tooltip content="处理" placement="top" v-if="row.status === '待处理'">
                            <el-button type="primary" :icon="Operation" circle size="small"
                                @click="handleProcess(row.id)" />
                        </el-tooltip>
                        <el-tooltip content="详细" placement="top" v-else>
                            <el-button type="info" :icon="InfoFilled" circle size="small"
                                @click="handleProcess(row.id)" />
                        </el-tooltip>

                    </template>
                </el-table-column>
            </el-table>

            <div class="pagination-wrapper" v-if="params.total > 0">
                <el-pagination v-model:current-page="params.pageNumber" v-model:page-size="params.pageSize"
                    :total="params.total" :page-sizes="[10, 20, 50]" layout="total, sizes, prev, pager, next, jumper"
                    background @current-change="getList" @size-change="getList" />
            </div>
        </el-card>

        <!-- 新增处理抽屉 -->
        <el-drawer v-model="drawerVisible" title="处理售后申请" size="40%">
            <div v-if="currentAfterSale" class="detail-container">
                <!-- 基本信息 -->
                <div class="detail-section">
                    <h4 class="section-title">售后信息</h4>
                    <div class="info-grid">
                        <div class="info-item">
                            <span class="info-label">售后单号：</span>
                            <span class="info-value">{{ currentAfterSale.id }}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">订单编号：</span>
                            <span class="info-value">{{ currentAfterSale.orderNumber }}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">售后类型：</span>
                            <el-tag :type="serviceTypeTagMap[currentAfterSale.serviceType]">
                                {{ currentAfterSale.serviceType }}
                            </el-tag>
                        </div>
                        <div class="info-item">
                            <span class="info-label">申请时间：</span>
                            <span class="info-value">{{ currentAfterSale.applyTime }}</span>
                        </div>
                    </div>
                </div>

                <el-divider />

                <!-- 申请原因 -->
                <div class="detail-section">
                    <h4 class="section-title">申请原因</h4>
                    <div class="reason-box">
                        {{ currentAfterSale.applyReason }}
                    </div>
                </div>

                <el-divider />

                <!-- 处理表单 -->
                <div class="detail-section">
                    <h4 class="section-title">处理操作</h4>
                    <el-form :model="processForm" label-width="80px" v-if="currentAfterSale.status === '待处理'">
                        <el-form-item label="处理结果" required>
                            <el-radio-group v-model="processForm.result">
                                <el-radio label="通过" border>
                                    <el-icon :size="16">
                                        <CircleCheck />
                                    </el-icon>
                                    <span class="ml-1">同意申请</span>
                                </el-radio>
                                <el-radio label="拒绝" border class="mt-2">
                                    <el-icon :size="16">
                                        <CircleClose />
                                    </el-icon>
                                    <span class="ml-1">拒绝申请</span>
                                </el-radio>
                            </el-radio-group>
                        </el-form-item>

                        <el-form-item label="处理备注" prop="comment" required>
                            <el-input v-model="processForm.comment" type="textarea" :rows="3" placeholder="请输入处理备注"
                                maxlength="200" show-word-limit />
                        </el-form-item>
                    </el-form>

                    <div v-else class="process-result-box">
                        <div class="result-item">
                            <span class="result-label">处理结果：</span>
                            <el-tag :type="currentAfterSale.status === '已通过' ? 'success' : 'danger'">
                                {{ currentAfterSale.processResult || '暂无结果' }}
                            </el-tag>
                        </div>
                        <div class="result-item">
                            <span class="result-label">处理时间：</span>
                            <span class="result-value">
                                {{ currentAfterSale.processTime || '暂无处理时间' }}
                            </span>
                        </div>
                        <div class="result-item" v-if="currentAfterSale.processComment">
                            <span class="result-label">处理备注：</span>
                            <div class="comment-box">
                                {{ currentAfterSale.processComment }}
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 底部操作栏 -->
            <template #footer>
                <div class="drawer-footer" v-if="currentAfterSale?.status === '待处理'">
                    <el-button @click="drawerVisible = false">取消</el-button>
                    <el-button type="primary" @click="submitProcess">确认处理</el-button>
                </div>
            </template>
        </el-drawer>
    </div>
</template>

<style scoped lang="scss">
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

                .el-input__wrapper,
                .el-select__wrapper {
                    height: 40px;
                    border-radius: 8px;

                    &:hover {
                        box-shadow: 0 0 0 1px var(--el-color-primary) inset;
                    }

                    &.is-focus {
                        box-shadow: 0 0 0 1px var(--el-color-primary) inset;
                    }
                }
            }
        }

        :deep(.el-button) {
            padding: 20px;
            transition: all 0.2s;

            &:hover {
                transform: translateY(-1px);
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

        .btn-prev,
        .btn-next,
        li {
            background: var(--el-fill-color-light);
            border-radius: 6px;
            margin: 0 4px;
        }

        .el-pager li {
            background: var(--el-color-primary);
            color: white;
            border-radius: 6px;
            margin: 0 4px;

            &:hover {
                color: var(--el-color-primary) !important;
            }

            &.is-active {
                color: white !important;
            }
        }
    }
}

:deep(.el-button--small){
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
        background: var(--el-color-primary-light-9) !important;
    }

    .el-button {
        padding: 6px;
        margin: 0 4px;
        transition: all 0.2s;

        &:hover {
            transform: translateY(-1px);
            box-shadow: 0 2px 6px var(--el-color-primary-light-5);
        }

        &.is-circle {
            border-radius: 50%;
        }
    }
}

.detail-container {
    padding: 20px;

    .process-result-box {
        padding: 0 16px;

        .result-item {
            margin-bottom: 18px;

            &:last-child {
                margin-bottom: 0;
            }
        }

        .result-label {
            color: var(--el-text-color-secondary);
            min-width: 80px;
            margin-right: 12px;
        }

        .comment-box {
            padding: 12px;
            background: var(--el-fill-color-light);
            border-radius: 6px;
            margin-top: 8px;
        }
    }

    .section-title {
        font-size: 15px;
        color: var(--el-text-color-primary);
        margin: 0 0 16px 0;
        font-weight: 600;
        position: relative;
        padding-left: 8px;

        &::before {
            content: '';
            position: absolute;
            left: 0;
            top: 4px;
            height: 16px;
            width: 3px;
            background: var(--el-color-primary);
            border-radius: 2px;
        }
    }

    .info-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 16px;

        .info-item {
            display: flex;
            align-items: center;
            font-size: 14px;
            min-height: 32px;

            .info-label {
                color: var(--el-text-color-secondary);
                min-width: 80px;
                margin-right: 12px;
            }

            .info-value {
                color: var(--el-text-color-primary);
                flex: 1;

                .el-tag {
                    margin-left: 8px;
                }
            }
        }
    }

    .reason-box {
        padding: 16px;
        background: var(--el-fill-color-light);
        border-radius: 8px;
        line-height: 1.6;
        color: var(--el-text-color-primary);
        min-height: 80px;
    }

    // 处理表单样式
    .el-form {
        padding: 0 16px;

        .el-form-item {
            margin-bottom: 22px;

            &:last-child {
                margin-bottom: 0;
            }

            .el-radio-group {
                width: 100%;

                :deep(.el-radio) {

                    // 隐藏原始单选框
                    .el-radio__input {
                        display: none;
                    }

                    .el-radio__label {
                        display: flex !important;
                        align-items: center;
                        padding-left: 8px !important;
                    }
                }

                .el-radio {
                    width: 25%;
                    padding: 12px 16px;
                    border-radius: 8px;
                    transition: all 0.3s;



                    &.is-checked {
                        background: var(--el-color-primary-light-9);
                        border-color: var(--el-color-primary);
                    }

                    .el-icon {
                        vertical-align: -2px;
                    }
                }
            }

            .el-textarea__inner {
                resize: vertical;
                min-height: 80px;
            }
        }
    }
}

// 抽屉底部操作栏
.drawer-footer {
    position: absolute;
    right: 0;
    bottom: 0;
    width: 100%;
    padding: 16px;
    background: var(--el-bg-color);
    border-top: 1px solid var(--el-border-color);
    text-align: right;
}

// 抽屉公共样式
:deep(.el-drawer) {
    .el-drawer__header {
        margin-bottom: 0;
        padding: 20px;
        border-bottom: 1px solid var(--el-border-color);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    }

    .el-drawer__body {
        padding: 0;
        position: relative;
        height: calc(100% - 64px);
        overflow-y: auto;
    }

    .el-divider {
        margin: 24px 0;
        background-color: var(--el-border-color-light);
    }
}
</style>