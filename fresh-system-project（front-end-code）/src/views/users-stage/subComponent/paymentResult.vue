<template>
    <div class="payment-result">
      <el-result
        :icon="resultIcon"
        :title="resultTitle"
        :sub-title="resultSubtitle"
      >
        <template #extra>
          <el-button type="primary" @click="handleBack">返回订单</el-button>
        </template>
      </el-result>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  
  const route = useRoute()
  const router = useRouter()
  
  const resultIcon = ref('success')
  const resultTitle = ref('支付成功！')
  const resultSubtitle = ref('订单已进入打包流程')

  
  const handleBack = () => {
    router.push('/userMain/myOrder')
  }
  </script>
  
  <style scoped>
  .payment-result {
    padding: 24px;
    min-height: calc(100vh - 110px);
    max-width: 1440px;
    margin: auto;
    border-radius: 16px;
  }

  :deep(.el-result) {
    text-align: center;
    padding: 100px;
    background-color: white;
    border-radius: 16px;
    box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
  }
  </style>