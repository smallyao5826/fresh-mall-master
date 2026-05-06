<script setup>
import { ref } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { getLoginLogs } from '@/api/managerStage'

const queryParams = ref({
    search: '',
    role: '',
    pageNumber: 1,
    pageSize: 10,
    total: 0
})

const logList = ref([])
const loading = ref(false)
const roleOptions = [
    { label: '全部', value: '' },
    { label: '管理员', value: '管理员' },
    { label: '普通用户', value: '普通用户' }
]

const fetchData = async () => {
    loading.value = true
    try {
        const res = await getLoginLogs(queryParams.value)
        logList.value = res.data.items
        queryParams.value.total = res.data.total
    } finally {
        loading.value = false
    }
}

// 时间格式化函数
const formatDateTime = (isoString) => {
    const date = new Date(isoString)
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
}

const handleSearch = () => {
    queryParams.value.pageNumber = 1
    fetchData()
}

// 初始化加载
fetchData()
</script>

<template>
    <div class="container">
        <el-card class="table-manager">
            <template #header>
                <div class="header">
                    <h2 class="title">登录日志</h2>
                    <div class="header-right">
                        <div class="search-group">
                            <el-select v-model="queryParams.role" placeholder="用户角色" clearable style="width: 120px"
                                @change="handleSearch">
                                <el-option v-for="item in roleOptions" :key="item.value" :label="item.label"
                                    :value="item.value" />
                            </el-select>

                            <el-input v-model="queryParams.search" placeholder="搜索用户名" clearable :prefix-icon="Search"
                                style="width: 240px" @keyup.enter="handleSearch" />
                        </div>
                    </div>
                </div>
            </template>

            <el-table :data="logList" v-loading="loading" height="calc(100vh - 300px)" style="width: 100%" stripe>
                <el-table-column prop="username" label="用户名" min-width="120" align="center" />
                <el-table-column prop="role" label="角色" min-width="120" align="center">
                    <template #default="{ row }">
                        <el-tag :type="row.role === '管理员' ? 'primary' : 'success'">
                            {{ row.role }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="lastLoginIp" label="登录IP" min-width="150" align="center" />
                <el-table-column label="登录时间" min-width="180" align="center">
                    <template #default="{ row }">
                        {{ formatDateTime(row.lastLoginTime) }}
                    </template>
                </el-table-column>
            </el-table>

            <div class="pagination-wrapper" v-if="queryParams.total > 0">
                <el-pagination v-model:current-page="queryParams.pageNumber" v-model:page-size="queryParams.pageSize"
                    :total="queryParams.total" :page-sizes="[10, 20, 50]"
                    layout="total, sizes, prev, pager, next, jumper" background @current-change="fetchData"
                    @size-change="fetchData" />
            </div>
        </el-card>
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

    .el-tag {
        margin: 2px;
    }
}
</style>