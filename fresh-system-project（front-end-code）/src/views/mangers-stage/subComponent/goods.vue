<script setup>
import { ref, reactive, watch, onMounted } from 'vue'
import { Search, Edit, Delete, Close, DocumentAdd, Upload } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useTokenStore } from '@/stores/token'
import {
  obtainFreshes,
  saveFreshes,
  updateFresh,
  deleteFreshService,
  queryCategoryService,
} from '@/api/managerStage'

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
  specification: '',
  feature: '',
  description: '',
  categoryId: null,
  pictureAddress: '',
  prices: 0,
  promotionPrice: null,
  isRecommend: 0
})

// 操作处理
const handleSubmit = async (data, isEdit) => {
  try {
    if (!data.pictureAddress) {
      ElMessage.warning('请上传商品图片')
      return
    }

    const submitData = {
      ...data,
      categoryId: Number(data.categoryId),
      prices: Number(data.prices),
      promotionPrice: data.promotionPrice ? Number(data.promotionPrice) : null
    }

    const operation = isEdit ? updateFresh(submitData) : saveFreshes(submitData)
    await operation
    ElMessage.success(isEdit ? '修改成功' : '新增成功')
    dialogVisible.value = false
    loadTableData()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

// 状态管理
const dialogVisible = ref(false)
const currentTitle = ref('新增')
const tableData = ref([])
const searchParams = reactive({
  freshName: '',
  categoryId: null,
  recommend: null
})
const formModel = reactive({ ...formSchema })
const pagination = reactive({
  page: 1,
  size: 10,
  total: 0
})
const fileList = ref([])

// 文件上传配置
const uploadConfig = reactive({
  action: 'http://localhost:8080/file/upload',
  headers: { Authorization: userStore.token },
  name: 'file', // 和后端接口参数名一致
  accept: ['image/jpeg', 'image/png'],
  maxSize: 2 // MB
})

// 文件处理
const handleUpload = ({ code, data }) => {
  if (code === 0) {
    // 使用服务器返回的URL替换本地预览
    fileList.value = [{
      name: 'uploaded',
      url: data,
      status: 'success'
    }]
    formModel.pictureAddress = data
  }
}


const handleRemove = () => {
  fileList.value = []
  formModel.pictureAddress = ''
}

const handleExceed = () => {
  ElMessage.warning('只能上传一张图片')
}

const beforeUpload = (file) => {
  return new Promise((resolve, reject) => {
    // 1. 格式验证
    const isImage = ['image/jpeg', 'image/png'].includes(file.type)
    const isSizeValid = file.size <= 2 * 1024 * 1024

    if (!isImage) {
      ElMessage.error('仅支持 JPG/PNG 格式')
      return reject(false)
    }

    if (!isSizeValid) {
      ElMessage.error('文件大小不能超过2MB')
      return reject(false)
    }

    // 2. 使用FileReader进行本地预览
    const reader = new FileReader()
    reader.onload = (e) => {
      // 保持文件对象引用
      file.preview = e.target.result
      resolve(true)
    }
    reader.readAsDataURL(file)
  })
}
// 数据加载
const loadTableData = async () => {
  try {
    const params = {
      freshName: searchParams.freshName,
      categoryId: searchParams.categoryId,
      recommend: searchParams.recommend,
      pageNumber: pagination.page,
      pageSize: pagination.size
    }
    const { code, data } = await obtainFreshes(params)
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
  currentTitle.value = row ? '编辑' : '新增'
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

const resetForm = () => {
  Object.assign(formModel, formSchema)
  fileList.value = []
}

// 删除处理
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(`确定删除【${row.freshName}】吗？`, '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await deleteFreshService(Number(row.id))
    ElMessage.success('删除成功')

    // 处理删除后分页逻辑
    if (tableData.value.length === 1 && pagination.page > 1) {
      pagination.page--
    }
    loadTableData()

  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
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

// 监听弹窗关闭
watch(dialogVisible, val => !val && resetForm())
</script>

<template>
  <div class="container">
    <el-card class="table-manager">
      <!-- 头部搜索区域 -->
      <template #header>
        <div class="header">
          <h3 class="title">生鲜管理</h3>
          <div class="header-right">
            <div class="search-group">

              <el-select v-model="searchParams.categoryId" placeholder="全部分类" clearable style="width: 160px">
                <el-option v-for="item in categories" :key="item.value" :label="item.label" :value="item.value" />
              </el-select>

              <el-select v-model="searchParams.recommend" placeholder="推荐状态" clearable style="width: 140px">
                <el-option label="推荐" value="1" />
                <el-option label="未推荐" value="0" />
              </el-select>

              <el-input v-model="searchParams.freshName" placeholder="搜索生鲜名称" clearable @clear="loadTableData"
                style="width: 240px">
                <template #append>
                  <el-button :icon="Search" @click="loadTableData" />
                </template>
              </el-input>


            </div>
            <el-button type="primary" @click="openDialog()" class="new-button">
              新增生鲜
            </el-button>
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
        <el-table-column prop="freshName" label="名称" min-width="150" align="center" />
        <el-table-column prop="specification" label="规格" min-width="100" align="center" />
        <el-table-column prop="feature" label="特征" min-width="120" align="center" />
        <el-table-column prop="description" label="描述" min-width="160" align="center" />
        <el-table-column label="分类" min-width="100" align="center">
          <template #default="{ row }">{{ row.category?.categoryName || '-' }}</template>
        </el-table-column>
        <el-table-column label="价格" width="120" align="center">
          <template #default="{ row }">
            <div class="price-group">
              <span class="current-price">￥{{ row.prices.toFixed(2) }}</span>
              <span v-if="row.promotionPrice" class="promotion-price">
                ￥{{ row.promotionPrice.toFixed(2) }}
              </span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="推荐" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.isRecommend ? 'success' : 'info'" size="small">
              {{ row.isRecommend ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right" align="center">
          <template #default="{ row }">
            <el-button type="primary" :icon="Edit" circle size="small" @click="openDialog(row)" />
            <el-button type="danger" :icon="Delete" circle size="small" @click="handleDelete(row)" />
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页组件 -->
      <div class="pagination-wrapper">
        <el-pagination v-model:current-page="pagination.page" v-model:page-size="pagination.size"
          :page-sizes="[10, 20, 50, 100]" layout="total, sizes, prev, pager, next" :total="pagination.total" background
          small @size-change="loadTableData" @current-change="loadTableData" />
      </div>
    </el-card>

    <!-- 编辑/新增抽屉 -->
    <el-drawer v-model="dialogVisible" :title="`${currentTitle}生鲜`" size="500px" @closed="resetForm">
      <el-form :model="formModel" label-width="100px">
        <el-form-item label="ID" v-if="formModel.id">
          <el-input v-model="formModel.id" disabled />
        </el-form-item>

        <el-form-item label="商品名称" required>
          <el-input v-model="formModel.freshName" placeholder="请输入商品名称" />
        </el-form-item>

        <el-form-item label="商品规格">
          <el-input v-model="formModel.specification" placeholder="如：500g" />
        </el-form-item>

        <el-form-item label="商品特征">
          <el-input v-model="formModel.feature" placeholder="请输入商品特点" />
        </el-form-item>

        <el-form-item label="商品描述">
          <el-input v-model="formModel.description" type="textarea" placeholder="详细商品说明" />
        </el-form-item>

        <el-form-item label="商品分类" required>
          <el-select v-model="formModel.categoryId" placeholder="选择分类" style="width: 100%">
            <el-option v-for="item in categories" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>

        <el-form-item label="商品图片" required>
          <el-upload :action="uploadConfig.action" :headers="uploadConfig.headers" :name="uploadConfig.name"
            :file-list="fileList" :limit="1" :accept="uploadConfig.accept.join(',')" :on-exceed="handleExceed"
            :on-success="handleUpload" :on-remove="handleRemove" :before-upload="beforeUpload" list-type="picture-card"
            class="custom-uploader" :show-file-list="true" :auto-upload="true">
            <template #trigger>
              <div class="upload-trigger">
                <el-icon class="upload-icon">
                  <DocumentAdd />
                </el-icon>
              </div>
            </template>

            <template #file="{ file }">
              <div class="image-preview">
                <img :src="file.url" class="upload-image" />
                <div class="hover-mask">
                  <el-icon class="reupload-icon" @click.stop="$refs.uploadRef.$el.querySelector('.el-upload').click()">
                    <Upload />
                  </el-icon>
                </div>
                <span class="remove-icon" @click.stop="handleRemove">
                  <el-icon>
                    <Close />
                  </el-icon>
                </span>
              </div>
            </template>
          </el-upload>
        </el-form-item>

        <el-form-item label="销售价格" required>
          <el-input-number v-model="formModel.prices" :min="0" :precision="2" controls-position="right"
            style="width: 100%" />
        </el-form-item>

        <el-form-item label="促销价格">
          <el-input-number v-model="formModel.promotionPrice" :min="0" :precision="2" controls-position="right"
            style="width: 100%" />
        </el-form-item>

        <el-form-item label="推荐状态">
          <el-switch v-model="formModel.isRecommend" :active-value="1" :inactive-value="0" />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSubmit(formModel, !!formModel.id)">提交</el-button>
          <el-button @click="dialogVisible = false">取消</el-button>
        </el-form-item>
      </el-form>
    </el-drawer>
  </div>
</template>

<style scoped>
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

      :deep(.el-select__wrapper) {
        height: 40px;
        border-radius: 8px;
        padding: 0 16px;
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
  }
}

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

:deep(.el-button--small) {
  padding: 15px !important;
}

.pagination-wrapper {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}

.price-group {
  display: flex;
  flex-direction: column;

  .current-price {
    color: var(--el-color-primary);
    font-weight: 500;
  }

  .promotion-price {
    color: #f56c6c;
    font-size: 12px;
    text-decoration: line-through;
  }
}

.custom-uploader {
  position: relative;
}

:deep(.el-upload-list--picture-card) {
  flex-wrap: nowrap
}


/* 图片上传样式 */
.image-preview {
  position: relative;

  .upload-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 6px;
  }

  .remove-icon {
    position: absolute;
    height: 10px;
    width: 10px;
    right: 4px;
    top: 4px;
    background: #ff4d4f;
    border-radius: 50%;
    padding: 3px;
    color: white;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;

    &:hover {
      background: #ff7875;
      transform: scale(1.1);
    }
  }
}

.upload-icon {
  width: 24px;
  height: 24px;
  fill: #909399;
}

/* 表单间距优化 */
.el-form-item {
  margin-bottom: 22px;

  :deep(.el-form-item__label) {
    padding-right: 16px;
  }
}
</style>