<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElLoading } from 'element-plus'
import { getRecommendConfig, updateRecommendConfig } from '@/api/managerStage'
import { Edit } from '@element-plus/icons-vue'

// 合法参数白名单
const VALID_KEYS = ['cf_weight', 'content_weight', 'random_factor', 'min_similarity']

// 配置数据（设置更合理的默认值）
const configParams = ref({
  cf_weight: 0.6,
  content_weight: 0.3,
  random_factor: 0.1,
  min_similarity: 0.2
})

// 抽屉控制
const drawerVisible = ref(false)
const formLoading = ref(false)

// 加载配置数据（修复版）
const loadConfig = async () => {
  const loading = ElLoading.service({
    lock: true,
    text: '配置加载中...',
    background: 'rgba(255, 255, 255, 0.8)'
  })
  try {
    const { data } = await getRecommendConfig()

    // 转换嵌套结构为扁平结构
    const newConfig = VALID_KEYS.reduce((acc, key) => {
      // 安全访问嵌套属性
      const value = data[key]?.config_value
      acc[key] = typeof value === 'number' ? value : configParams.value[key]
      return acc
    }, {})

    configParams.value = newConfig
  } catch (e) {
    console.error('配置加载失败:', e)
    ElMessage.error('配置加载失败，请检查网络连接')
  } finally {
    loading.close()
  }
}

// 保存配置（增强版）
const handleSave = async () => {
  formLoading.value = true
  try {
    // 客户端校验增强
    const validations = [
      {
        check: () => configParams.value.cf_weight + configParams.value.content_weight > 1,
        message: '协同过滤与内容推荐权重总和不能超过1'
      },
      {
        check: () => configParams.value.random_factor < 0 || configParams.value.random_factor > 0.2,
        message: '随机因子需在0-0.2之间'
      },
      {
        check: () => configParams.value.min_similarity < 0.05 || configParams.value.min_similarity > 0.5,
        message: '最小相似度需在0.05-0.5之间'
      }
    ]

    // 执行所有校验
    validations.forEach(({ check, message }) => {
      if (check()) throw new Error(message)
    })

    // 转换请求参数格式
    const payload = VALID_KEYS.reduce((acc, key) => {
      acc[key] = Number(configParams.value[key]) || 0
      return acc
    }, {})

    await updateRecommendConfig(payload)
    ElMessage.success('配置更新成功')
    drawerVisible.value = false
    await loadConfig()  // 重新加载最新配置
  } catch (error) {
    console.error('配置保存失败:', error)
    ElMessage.error(error.message || '配置保存失败，请检查参数')
  } finally {
    formLoading.value = false
  }
}

// 初始化加载（增加错误边界）
onMounted(() => {
  loadConfig().catch(e => {
    console.error('初始化加载失败:', e)
    ElMessage.error('初始化配置加载失败')
  })
})
</script>

<template>
  <div class="container">
    <el-card class="table-manager">
      <template #header>
        <div class="header">
          <h2 class="title">推荐算法配置管理</h2>
          <div class="header-right">
            <el-button type="primary" @click="drawerVisible = true" :icon="Edit">
              编辑配置
            </el-button>
          </div>
        </div>
      </template>

      <!-- 配置展示区域 -->
      <el-descriptions border :column="2" label-align="right" class="config-descriptions">
        <el-descriptions-item label="协同过滤权重">
          {{ configParams.cf_weight.toFixed(2) }}
        </el-descriptions-item>

        <el-descriptions-item label="内容推荐权重">
          {{ configParams.content_weight.toFixed(2) }}
        </el-descriptions-item>

        <el-descriptions-item label="随机因子">
          {{ configParams.random_factor.toFixed(2) }}
        </el-descriptions-item>

        <el-descriptions-item label="最小相似度">
          {{ configParams.min_similarity.toFixed(2) }}
        </el-descriptions-item>
      </el-descriptions>

      <!-- 配置说明 -->
      <div class="config-tips mt-4">
        <el-alert title="配置说明" type="info" :closable="false">
          <ul class="tip-list">
            <li>• 权重总和限制：协同过滤 + 内容推荐 ≤ 1</li>
            <li>• 随机因子范围：0 ~ 0.2</li>
            <li>• 相似度阈值：0.05 ~ 0.5</li>
            <li>• 所有数值支持两位小数精度</li>
          </ul>
        </el-alert>
      </div>
    </el-card>

    <!-- 编辑抽屉 -->
    <el-drawer v-model="drawerVisible" title="推荐算法参数配置" size="30%" direction="rtl" :close-on-click-modal="false">
      <div class="drawer-content">
        <el-form :model="configParams" label-width="120px" label-position="right" @submit.prevent>
          <!-- 协同过滤权重 -->
          <el-form-item label="协同过滤权重" prop="cf_weight" :rules="[{
            type: 'number',
            min: 0,
            max: 1,
            message: '请输入0-1之间的数值'
          }]">
            <el-input-number v-model="configParams.cf_weight" :min="0" :max="1" :step="0.05" :precision="2"
              controls-position="right" />
          </el-form-item>

          <!-- 内容推荐权重 -->
          <el-form-item label="内容推荐权重" prop="content_weight" :rules="[{
            type: 'number',
            min: 0,
            max: 1,
            message: '请输入0-1之间的数值'
          }]">
            <el-input-number v-model="configParams.content_weight" :min="0" :max="1" :step="0.05" :precision="2"
              controls-position="right" />
          </el-form-item>

          <!-- 随机因子 -->
          <el-form-item label="随机因子" prop="random_factor" :rules="[{
            type: 'number',
            min: 0,
            max: 0.2,
            message: '请输入0-0.2之间的数值'
          }]">
            <el-input-number v-model="configParams.random_factor" :min="0" :max="0.2" :step="0.01" :precision="2"
              controls-position="right" />
          </el-form-item>

          <!-- 最小相似度 -->
          <el-form-item label="最小相似度" prop="min_similarity" :rules="[{
            type: 'number',
            min: 0.05,
            max: 0.5,
            message: '请输入0.05-0.5之间的数值'
          }]">
            <el-input-number v-model="configParams.min_similarity" :min="0.05" :max="0.5" :step="0.01" :precision="2"
              controls-position="right" />
          </el-form-item>
        </el-form>
      </div>

      <template #footer>
        <div class="drawer-footer">
          <el-button :disabled="formLoading" @click="drawerVisible = false">
            取消
          </el-button>
          <el-button type="primary" :loading="formLoading" @click="handleSave">
            {{ formLoading ? '保存中...' : '确认修改' }}
          </el-button>
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
}

.config-descriptions {
  padding: 20px;
  border-radius: 8px;

  :deep(.el-descriptions__body) {
    background-color: #fff;
  }

  :deep(.el-descriptions__label) {
    width: 140px;
    font-weight: 500;
    color: #606266;
  }

  :deep(.el-descriptions__content) {
    color: #303133;
    font-weight: 500;
  }
}

.config-tips {
  padding: 0 20px;

  .el-alert {
    border: 1px solid #ebeef5;
    background-color: #f8f9fc;
    border-radius: 8px;

    .tip-list {
      margin: 0;
      padding-left: 20px;
      color: #606266;
      line-height: 1.8;

      li {
        font-size: 13px;
      }
    }
  }
}

.drawer-content {
  padding: 20px 30px;

  .el-form-item {
    margin-bottom: 24px;

    :deep(.el-input-number) {
      width: 220px;

      .el-input__inner {
        text-align: center;
      }
    }

    :deep(.el-form-item__label) {
      font-weight: 500;
      color: #606266;
    }
  }
}

:deep(.el-drawer__footer){
  padding: 0 !important;
}

.drawer-footer {
  padding: 16px 24px;
  border-top: 1px solid #e4e7ed;
  text-align: right;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 24px;

  .title {
    color: var(--el-color-primary);
    font-size: 20px;
    font-weight: 600;
    margin: 0;
    letter-spacing: 0.5px;
  }

  .header-right {
    :deep(.el-button) {
      border-radius: 6px;
      transition: all 0.3s;
      height: 40px;

      &:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(64, 158, 255, 0.2);
      }
    }
  }
}

.mr-2 {
  margin-right: 8px;
}
</style>