<script setup>
import { ref, reactive, watch, onMounted } from 'vue'
import { Search, Edit, Close, DocumentAdd, Upload } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { useTokenStore } from '@/stores/token'
import {
    obtainFreshes,
    updateFresh,
    queryCategoryService,
} from '@/api/managerStage'  // 修改API名称

const userStore = useTokenStore()

// 分类数据
const categories = ref([])
const loadCategories = async () => {
    try {
        const res = await queryCategoryService()
        categories.value = res.data.map(item => ({
            value: item.id,
            label: item.categoryName
        }))
    } catch (error) {
        ElMessage.error('分类加载失败')
    }
}

// 表单配置
const formSchema = reactive({
    id: '',
    freshName: '',
    categoryId: null,
    pictureAddress: '',
    repertory: 0,       // 当前库存
    sumRepertory: 0     // 总库存
})

// 操作处理
const handleSubmit = async (data, isEdit) => {
    try {
        const submitData = {
            ...data,
            categoryId: Number(data.categoryId),
            repertory: Number(data.repertory),
            sumRepertory: Number(data.sumRepertory)
        }

        if (submitData.repertory > submitData.sumRepertory) {
            ElMessage.error('当前库存不能大于总库存')
            return
        }

        await updateFresh(submitData)  // 修改API调用
        ElMessage.success('库存更新成功')
        dialogVisible.value = false
        loadTableData()
    } catch (error) {
        ElMessage.error(error.message || '操作失败')
    }
}

// 状态管理
const dialogVisible = ref(false)
const currentTitle = ref('库存调整')
const tableData = ref([])
const searchParams = reactive({
    freshName: '',
    categoryId: null,
})
const formModel = reactive({ ...formSchema })
const pagination = reactive({
    page: 1,
    size: 10,
    total: 0
})
const fileList = ref([])

// 文件上传配置（保持原有）
const uploadConfig = reactive({
    action: 'http://localhost:8080/file/upload',
    headers: { Authorization: userStore.token },
    name: 'file',
    accept: ['image/jpeg', 'image/png'],
    maxSize: 2
})

// 数据加载
const loadTableData = async () => {
    try {
        const params = {
            freshName: searchParams.freshName,
            categoryId: searchParams.categoryId,
            pageNumber: pagination.page,
            pageSize: pagination.size
        }
        const { code, data } = await obtainFreshes(params)  // 修改API调用
        if (code === 0) {
            tableData.value = data.items
            pagination.total = data.total
        }
    } catch (error) {
        ElMessage.error('数据加载失败')
    }
}

// 弹窗操作
const openDialog = (row) => {
    fileList.value = []
    if (row) {
        Object.assign(formModel, {
            ...row,
            categoryId: row.category?.id
        })
        if (row.pictureAddress) {
            fileList.value = [{ name: 'current', url: row.pictureAddress }]
        }
    } else {
        Object.assign(formModel, formSchema)
    }
    dialogVisible.value = true
}

// 初始化
onMounted(() => {
    loadCategories()
    loadTableData()
})

// 监听搜索条件
watch(
    () => ({ ...searchParams }),
    () => {
        pagination.page = 1
        loadTableData()
    },
    { deep: true }
)
</script>

<template>
    <div class="container">
        <el-card class="table-manager">
            <template #header>
                <div class="header">
                    <h3 class="title">库存管理</h3>
                    <div class="header-right">
                        <div class="search-group">
                            <el-input v-model="searchParams.freshName" placeholder="搜索商品名称" clearable
                                style="width: 240px">
                                <template #append>
                                    <el-button :icon="Search" @click="loadTableData" />
                                </template>
                            </el-input>

                            <el-select v-model="searchParams.categoryId" placeholder="全部分类" clearable
                                style="width: 160px">
                                <el-option v-for="item in categories" :key="item.value" :label="item.label"
                                    :value="item.value" />
                            </el-select>
                        </div>
                    </div>
                </div>
            </template>

            <!-- 数据表格 -->
            <el-table :data="tableData" height="calc(100vh - 300px)" size="small" >
                <el-table-column prop="id" label="ID" width="80" fixed align="center" />
                <el-table-column label="图片" width="120" align="center">
                    <template #default="{ row }">
                        <el-image :src="row.pictureAddress" style="width: 80px; height: 80px" fit="cover"
                            :preview-src-list="[row.pictureAddress]" hide-on-click-modal />
                    </template>
                </el-table-column>
                <el-table-column prop="freshName" label="商品名称" max-width="50" align="center" />
                <el-table-column label="分类" max-width="100" align="center">
                    <template #default="{ row }">{{ row.category?.categoryName || '-' }}</template>
                </el-table-column>
                <el-table-column label="当前库存" min-width="120" align="center">
                    <template #default="{ row }">
                        <span :class="{ 'low-stock': row.repertory / row.sumRepertory < 0.15 }">
                            {{ row.repertory }}
                        </span>
                    </template>
                </el-table-column>
                <el-table-column prop="sumRepertory" label="总库存" min-width="120" align="center" />
                <el-table-column label="操作" width="80" fixed="right" align="center">
                    <template #default="{ row }">
                        <el-button type="primary" :icon="Edit" circle size="small" @click="openDialog(row)" />
                    </template>
                </el-table-column>
            </el-table>

            <!-- 分页组件 -->
            <div class="pagination-wrapper">
                <el-pagination v-model:current-page="pagination.page" v-model:page-size="pagination.size"
                    :page-sizes="[10, 20, 50, 100]" layout="total, sizes, prev, pager, next" :total="pagination.total"
                    background small @size-change="loadTableData" @current-change="loadTableData" />
            </div>
        </el-card>

        <!-- 编辑抽屉 -->
        <el-drawer v-model="dialogVisible" title="库存调整" size="500px">
            <el-form :model="formModel" label-width="100px">
                <el-form-item label="ID" v-if="formModel.id">
                    <el-input v-model="formModel.id" disabled />
                </el-form-item>

                <el-form-item label="商品名称" required>
                    <el-input v-model="formModel.freshName" disabled />
                </el-form-item>

                <el-form-item label="商品分类" required>
                    <el-select v-model="formModel.categoryId" disabled style="width: 100%">
                        <el-option v-for="item in categories" :key="item.value" :label="item.label"
                            :value="item.value" />
                    </el-select>
                </el-form-item>

                <el-form-item label="当前库存" required>
                    <el-input-number v-model="formModel.repertory" :min="0" :max="formModel.sumRepertory"
                        controls-position="right" style="width: 100%" />
                </el-form-item>

                <el-form-item label="总库存" required>
                    <el-input-number v-model="formModel.sumRepertory" :min="formModel.repertory"
                        controls-position="right" style="width: 100%" />
                </el-form-item>

                <el-form-item>
                    <el-button type="primary" @click="handleSubmit(formModel, true)">提交</el-button>
                    <el-button @click="dialogVisible = false">取消</el-button>
                </el-form-item>
            </el-form>
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

/* 头部样式 */
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

/* 分页器样式 */
.pagination-wrapper {
  margin-top: 16px;
  padding: 12px 0;
  border-radius: 8px;

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

:deep(.el-button--small){
  padding: 15px !important;
}

/* 表格样式 */
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

/* 库存预警样式 */
.low-stock {
  color: #f56c6c;
  font-weight: 600;
}

/* 抽屉表单样式 */
:deep(.el-drawer) {
  .el-drawer__header {
    margin-bottom: 0;
    padding: 20px 24px;
    border-bottom: 1px solid #ebeef5;
    color: #303133;
    font-size: 16px;
    font-weight: 600;
  }

  .el-drawer__body {
    padding: 24px;

    .el-form-item {
      margin-bottom: 22px;

      &__label {
        color: #606266;
        font-weight: 500;
        padding-right: 16px;
      }

      .el-input__wrapper {
        border-radius: 8px;
        height: 40px;
      }
    }
  }

  .el-drawer__footer {
    padding: 16px 24px;
    border-top: 1px solid #ebeef5;
  }
}

/* 数字输入框样式 */
:deep(.el-input-number) {
  width: 100%;
  
  .el-input__wrapper {
    padding-right: 40px;
  }
  
  .el-input-number__decrease,
  .el-input-number__increase {
    background: #f5f7fa;
    border-left: 1px solid #ebeef5;
  }
}
</style>