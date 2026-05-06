<script setup>
import { Search, Edit, Delete } from '@element-plus/icons-vue'
import { ref } from 'vue'
import {
    queryCategoryService,
    addCategoryService,
    editCategoryService,
    deleteCategoryService
} from '@/api/managerStage.js'
import { ElMessage, ElMessageBox } from 'element-plus'

// 原始数据
const originalCategories = ref([])
// 显示数据
const categories = ref([])
const search = ref('')
const dialogVisible = ref(false)
const title = ref('')
const categoryModel = ref({ categoryContent: '', id: '' })

// 分页相关
const pagination = ref({
    currentPage: 1,
    pageSize: 10,
    total: 0
})

// 获取数据（保持原有API调用）
const searchAll = async () => {
    const result = await queryCategoryService(search.value)
    originalCategories.value = result.data
    pagination.value.total = originalCategories.value.length
    updateDisplayData()
}

// 前端分页处理
const updateDisplayData = () => {
    const start = (pagination.value.currentPage - 1) * pagination.value.pageSize
    const end = start + pagination.value.pageSize
    categories.value = originalCategories.value.slice(start, end)
}

// 分页变化处理
const handleCurrentChange = (val) => {
    pagination.value.currentPage = val
    updateDisplayData()
}

// 初始化加载
searchAll()

// 保持原有弹窗逻辑
const openDialog = (type, row) => {
    title.value = type
    categoryModel.value = type === '新增分类' ?
        { categoryContent: '', id: '' } :
        { categoryContent: row.categoryName, id: row.id }
    dialogVisible.value = true
}

// 保持原有提交逻辑
const submitCategory = async () => {
    try {
        if (title.value === '添加分类') {
            await addCategoryService(categoryModel.value.categoryContent)
            ElMessage.success('添加成功')
        } else {
            await editCategoryService(categoryModel.value)
            ElMessage.success('修改成功')
        }
        dialogVisible.value = false
        await searchAll()
    } catch (error) {
        ElMessage.error(error.message)
    }
}

// 保持原有删除逻辑
const handleDelete = async (id) => {
    try {
        await ElMessageBox.confirm('确认删除该分类？', '警告', {
            confirmButtonText: '确认',
            cancelButtonText: '取消',
            type: 'warning'
        })
        await deleteCategoryService(id)
        await searchAll()
        ElMessage.success('删除成功')
    } catch (error) {
        if (error !== 'cancel') {
            ElMessage.error('删除失败')
        }
    }
}
</script>

<template>
    <div class="container">
        <el-card class="table-manager">
            <template #header>
                <div class="header">
                    <h3 class="title">分类管理</h3>
                    <div class="header-right">
                        <div class="search-group">
                            <el-input v-model="search" placeholder="搜索分类名称" clearable style="width: 240px"
                                @change="searchAll">
                                <template #append>
                                    <el-button :icon="Search" @click="searchAll" />
                                </template>
                            </el-input>
                        </div>
                        <el-button type="primary" class="new-button" @click="openDialog('新增分类')">
                            新增分类
                        </el-button>
                    </div>
                </div>
            </template>

            <!-- 数据表格 -->
            <el-table :data="categories" height="calc(100vh - 300px)" size="small" >
                <el-table-column prop="id" label="ID" width="80" fixed align="center" />
                <el-table-column prop="categoryName" label="分类名称" min-width="200" align="center" />
                <el-table-column label="操作" width="120" fixed="right" align="center">
                    <template #default="{ row }">
                        <el-button type="primary" :icon="Edit" circle size="small" @click="openDialog('编辑分类', row)" />
                        <el-button type="danger" :icon="Delete" circle size="small" @click="handleDelete(row.id)" />
                    </template>
                </el-table-column>
            </el-table>

            <!-- 分页组件 -->
            <div class="pagination-wrapper">
                <el-pagination v-model:current-page="pagination.currentPage" v-model:page-size="pagination.pageSize"
                    :page-sizes="[10, 20, 50]" layout="total, sizes, prev, pager, next" :total="pagination.total"
                    background small @size-change="searchAll" @current-change="handleCurrentChange" />
            </div>
        </el-card>

        <!-- 编辑/新增抽屉 -->
        <el-drawer v-model="dialogVisible" :title="title" size="500px"
            @closed="categoryModel = { categoryContent: '', id: '' }">
            <el-form :model="categoryModel" label-width="100px">
                <el-form-item label="分类名称" required>
                    <el-input v-model="categoryModel.categoryContent" placeholder="请输入分类名称" />
                </el-form-item>

                <el-form-item>
                    <el-button type="primary" @click="submitCategory">提交</el-button>
                    <el-button @click="dialogVisible = false">取消</el-button>
                </el-form-item>
            </el-form>
        </el-drawer>
    </div>
</template>

<style scoped>
/* 完全同步商品管理样式 */
.container {
    height: calc(100vh - 150px);
    box-sizing: border-box;
}

:deep(.el-card__header) {
    padding: 0;
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

            :deep(.el-input__wrapper) {
                height: 40px;
                padding: 0 16px;
            }

            :deep(.el-input-group__append){
                padding: 0 !important;
            }
        }
    }

    .new-button {
        height: 40px;
        padding: 0 24px;
        border-radius: 8px;
        font-weight: 500;
        letter-spacing: 0.5px;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
        transition: all 0.2s;

        &:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(24, 144, 255, 0.2);
        }
    }
}

:deep(.el-button--small) {
    padding: 15px !important;
}

.pagination-wrapper {
    margin-top: 16px;
    display: flex;
    justify-content: flex-end;

    :deep(.el-pagination) {
        justify-content: flex-end;

        .btn-prev,
        .btn-next,
        .number {
            min-width: 32px;
            height: 32px;
            border-radius: 8px;
            margin: 0 4px;
        }

        .number.active {
            background: var(--el-color-primary);
            color: white;
        }
    }
}

/* 表格样式同步 */
:deep(.el-table) {
    border-radius: 8px;
    font-size: 14px;

    th {
        background-color: #f8f9fa !important;
        color: #606266;
        font-weight: 600;
    }

    td {
        padding: 12px 0;
    }

    tr:hover td {
        background-color: #f5f7fa !important;
    }
}

/* 操作按钮样式 */
:deep(.el-button) {
    margin: 0 4px;
    border: 1px solid;

    &.is-circle {
        border-radius: 50%;
    }

    &:hover {
        transform: translateY(-1px);
    }
}

/* 抽屉表单样式 */
:deep(.el-drawer) {
    .el-drawer__header {
        margin-bottom: 0;
        padding: 20px 24px;
        border-bottom: 1px solid #ebeef5;
    }

    .el-drawer__body {
        padding: 24px;

        .el-form-item {
            margin-bottom: 22px;

            &__label {
                color: #606266;
                font-weight: 500;
            }
        }

        .el-input__wrapper {
            border-radius: 8px;
            height: 40px;
        }
    }

    .el-drawer__footer {
        padding: 16px 24px;
        border-top: 1px solid #ebeef5;
    }
}
</style>