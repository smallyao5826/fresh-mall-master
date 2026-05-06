<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Plus, Select, Delete, Edit, Location } from '@element-plus/icons-vue'
import { pcaTextArr } from 'element-china-area-data'
import {
  getUserAddressListService,
  addUserAddressService,
  updateUserAddressService,
  deleteUserAddressService
} from '@/api/userStage.js'

// 地址列表数据
const addressList = ref([])

// 弹窗相关状态
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref()
const formData = reactive({
  id: '',
  name: '',
  phone: '',
  selectedOptions: [],
  province: '',
  city: '',
  district: '',
  detailedAddress: '',
  isDefault: false
})

// 表单验证规则
const formRules = reactive({
  name: [{ required: true, message: '请输入收货人姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  selectedOptions: [
    { required: true, message: '请选择所在地区', trigger: 'change' }
  ],
  detailedAddress: [
    { required: true, message: '请输入详细地址', trigger: 'blur' }
  ]
})

// 初始化加载地址列表
const loadAddressList = async () => {
  try {
    const res = await getUserAddressListService()
    addressList.value = res.data
  } catch (e) {
    console.error(e)
  }
}

// 地区选择处理
const handleAreaChange = (value) => {
  const [province, city, district] = value
  formData.province = province
  formData.city = city
  formData.district = district
}

// 提交表单
const submitForm = async () => {
  await formRef.value.validate()

  const payload = {
    ...formData,
    address: `${formData.province}${formData.city}${formData.district} ${formData.detailedAddress}`
  }

  try {
    if (isEdit.value) {
      await updateUserAddressService(payload)
    } else {
      await addUserAddressService(payload)
    }
    dialogVisible.value = false
    loadAddressList()
  } catch (e) {
    console.error(e)
  }
}

// 删除地址
const handleDelete = async (id) => {
  try {
    await deleteUserAddressService(id)
    loadAddressList()
  } catch (e) {
    console.error(e)
  }
}

// 打开新增弹窗
const handleAdd = () => {
  isEdit.value = false
  Object.assign(formData, {
    id: '',
    name: '',
    phone: '',
    selectedOptions: [],
    province: '',
    city: '',
    district: '',
    detailedAddress: '',
    isDefault: false
  })
  dialogVisible.value = true
}

// 打开编辑弹窗
const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(formData, {
    ...row,
    selectedOptions: [row.province, row.city, row.district]
  })
  dialogVisible.value = true
}

onMounted(() => {
  loadAddressList()
})
</script>

<template>
  <div class="address-container">
    <div class="container">
      <!-- 头部 -->
      <div class="modern-header">
        <h1 class="designer-title">
          <el-icon :size="36" class="title-icon">
            <Location />
          </el-icon>
          Shopping Address
        </h1>
        <el-button type="primary" @click="handleAdd" round class="floating-action">
          <el-icon>
            <Plus />
          </el-icon>新增地址
        </el-button>
      </div>

      <!-- 地址列表 -->
      <div class="modern-card">
        <transition-group name="list" tag="div" class="grid-layout">
          <div v-for="item in addressList" :key="item.id" class="neo-card" :class="{ 'primary-glow': item.isDefault }">
            <div class="card-content">
              <div class="header-line">
                <span class="user-name">{{ item.name }}</span>
                <div class="contact-info">{{ item.phone }}</div>
              </div>
              <div class="address-detail">
                {{ [item.province, item.city, item.district, item.detailedAddress].join(' ') }}
              </div>
            </div>

            <div class="bottom">
              <div class="left-section">
                <div v-if="item.isDefault" class="default-label">
                  <span>默认</span>
                </div>
              </div>
              <div class="action-bar">
                <el-button circle :icon="Edit" @click="handleEdit(item)" class="icon-hover" />
                <el-button circle :icon="Delete" @click="handleDelete(item.id)" class="icon-hover danger" />
              </div>
            </div>
          </div>
        </transition-group>

        <!-- 空状态 -->
        <el-empty v-if="!addressList.length" description="暂无收货地址" class="artistic-empty" />
      </div>
    </div>

    <!-- 编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑地址' : '新增地址'" width="600px">
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="80px">
        <el-form-item label="收货人" prop="name">
          <el-input v-model="formData.name" placeholder="请输入姓名" />
        </el-form-item>

        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="formData.phone" placeholder="请输入手机号" />
        </el-form-item>

        <el-form-item label="所在地区" prop="selectedOptions">
          <el-cascader v-model="formData.selectedOptions" :options="pcaTextArr" @change="handleAreaChange"
            placeholder="请选择省/市/区" />
        </el-form-item>

        <el-form-item label="详细地址" prop="detailedAddress">
          <el-input v-model="formData.detailedAddress" placeholder="街道门牌、楼栋号等" />
        </el-form-item>

        <el-form-item label="默认地址">
          <el-switch v-model="formData.isDefault" />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.address-container {
  padding: 24px;
  min-height: calc(100vh - 48px);
  background: var(--color-bg);

  .container {
    box-shadow: 0 4px 24px rgba(0, 0, 0, 0.06);
    border-radius: 16px;
    background: white;
    overflow: hidden;
  }
}

.modern-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 32px 32px 16px;
  border-bottom: 1px solid var(--color-border);

  .designer-title {
    display: flex;
    align-items: center;
    font-family: var(--font-title);
    font-size: 2rem;
    color: var(--color-primary);
    margin: 0;
    gap: 12px;

    .title-icon {
      background: rgba(34, 163, 86, 0.1);
      padding: 8px;
      border-radius: 8px;
      color: var(--color-primary);
    }
  }

  .floating-action {
    padding: 20px 28px;
    font-weight: 500;
    background: var(--color-primary);
    border: none;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 16px rgba(34, 163, 86, 0.3);
    }

    .el-icon {
      margin-right: 8px;
    }
  }
}

.modern-card {
  padding: 32px;
}

.grid-layout {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 24px;
}

.neo-card {
  position: relative;
  padding: 24px;
  background: white;
  border-radius: 12px;
  border: 1px solid var(--color-border);
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  }

  &.primary-glow {
    border-color: var(--color-primary);
    background: linear-gradient(145deg, #ffffff, #f3faf6);
  }

  .card-content {
    .header-line {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;

      .user-name {
        font-size: 1.2rem;
        font-weight: 600;
        color: var(--color-text);
      }

      .contact-info {
        color: rgba(51, 51, 51, 0.8);
        font-size: 0.95rem;
      }
    }

    .address-detail {
      color: rgba(51, 51, 51, 0.8);
      line-height: 1.6;
      font-size: 0.95rem;
    }
  }

  .bottom {
    margin-top: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;

    .left-section {
      flex-grow: 1;
    }

    .default-label {
      background: rgba(34, 163, 86, 0.1);
      color: var(--color-primary);
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 0.85rem;
      font-weight: 500;
      display: inline-block;
    }

    .action-bar {
      display: flex;
      gap: 8px;

      .el-button {
        width: 36px;
        height: 36px;
        border: 1px solid var(--color-border);

        &:hover {
          background: var(--color-primary);
          color: white;
          border-color: var(--color-primary);

          &.danger {
            background: var(--color-price);
            border-color: var(--color-price);
          }
        }
      }
    }
  }
}

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

.el-dialog {
  border-radius: 16px !important;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);

  &__header {
    border-bottom: 1px solid var(--color-border);
    padding: 24px;
    margin: 0;

    .el-dialog__title {
      font-family: 'Inter', sans-serif;
      font-weight: 600;
      color: var(--color-text);
    }
  }

  &__body {
    padding: 24px 32px;
  }

  .el-form-item {
    margin-bottom: 22px;

    &__label {
      color: var(--color-text);
      font-weight: 500;
    }
  }

  .el-input,
  .el-cascader {
    :deep(.el-input__wrapper) {
      border-radius: 8px;
      border: 1px solid var(--color-border);
      transition: all 0.2s;

      &:hover {
        border-color: var(--color-primary);
      }

      &.is-focus {
        box-shadow: 0 0 0 1px var(--color-primary);
      }
    }
  }

  .el-switch {
    --el-switch-on-color: var(--color-primary);
  }
}

.list-enter-active,
.list-leave-active {
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.list-enter-from,
.list-leave-to {
  opacity: 0;
  transform: translateY(20px) scale(0.95);
}

@media (max-width: 768px) {
  .modern-header {
    padding: 24px;

    .designer-title {
      font-size: 1.8rem;

      &::after {
        width: 40px;
        bottom: -6px;
      }
    }
  }

  .modern-card {
    padding: 24px;
  }

  .neo-card {
    padding: 20px;
  }
}
</style>