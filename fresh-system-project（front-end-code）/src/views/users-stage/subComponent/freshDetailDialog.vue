<template>
  <el-dialog :model-value="visible" :title="title" class="fresh-dialog" width="760px" :before-close="handleClose"
    @update:modelValue="val => $emit('update:visible', val)">
    <div class="dialog-content">
      <el-row :gutter="30">
        <!-- 商品图片 -->
        <el-col :span="12">
          <div class="product-image-wrapper">
            <el-image :src="detail.pictureAddress" fit="cover" class="main-image" />
            <div class="sales-badge">已售 {{ detail.salecount }}件</div>
          </div>
        </el-col>

        <!-- 商品详情 -->
        <el-col :span="12">
          <div class="product-info">
            <!-- 商品名称 -->
            <h1 class="product-title">{{ detail.freshName }}</h1>

            <!-- 商品描述 -->
            <div class="product-description">{{ detail.description }}</div>

            <!-- 商品特色 -->
            <div class="feature-tag">
              <el-tag class="feature-badge">{{ detail.feature }}</el-tag>
            </div>

            <!-- 价格区域 -->
            <div class="price-section">
              <div class="original-price" :class="{ 'has-promotion': detail.promotionPrice }">
                <span class="price-label">{{ detail.promotionPrice ? '原价' : '价格' }}</span>
                <span class="price-value">¥{{ detail.prices }}/{{ detail.specification }}</span>
              </div>

              <!-- 仅在存在促销价时显示促销信息 -->
              <div class="current-price" v-if="detail.promotionPrice">
                <span class="price-label">促销价</span>
                <span class="price-value">¥{{ detail.promotionPrice }}/{{ detail.specification }}</span>
              </div>
            </div>

            <!-- 购买数量和总价 -->
            <div class="quantity-price">
              <div class="quantity-section">
                <h3 class="section-title"></h3>
                <QuantityPicker v-model="quantity" :min="1" class="quantity-input" />
              </div>
              <div class="total-price">
                合计:
                <span class="price">¥{{ totalPrice.toFixed(2) }}</span>
              </div>
            </div>

            <!-- 操作按钮 -->
            <div class="action-buttons">
              <el-button class="buy-btn" type="danger" @click="handleBuy">
                立即购买
              </el-button>
              <el-button class="cart-btn" @click="handleAddCart">
                <el-icon class="cart-icon">
                  <ShoppingCart />
                </el-icon>
                加入购物车
              </el-button>
            </div>
          </div>
        </el-col>
      </el-row>
    </div>
  </el-dialog>
</template>

<script setup>
import { computed, ref } from 'vue'
import { ShoppingCart } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import QuantityPicker from './quantityPicker.vue'
const props = defineProps({
  visible: {
    type: Boolean,
    required: true
  },
  title: {
    type: String,
    default: '商品详情'
  },
  detail: {
    type: Object,
    required: true,
    default: () => ({
      id: null,
      freshName: '',
      prices: 0,
      promotionPrice: 0,
      description: '',
      feature: '',
      pictureAddress: '',
      salecount: 0,
      repertory: 0,
      specification: '',
    })
  }
})

const emit = defineEmits(['update:visible', 'buy', 'add-cart'])

const quantity = ref(1)

// 计算总价
const totalPrice = computed(() => {
  const price = props.detail.promotionPrice > 0
    ? props.detail.promotionPrice
    : props.detail.prices
  return price * quantity.value
})

// 关闭弹窗
const handleClose = (done) => {
  emit('update:visible', false)
  done()
}

import { useRouter } from 'vue-router'
const router = useRouter()

import { useTokenStore } from '@/stores/token'
const tokenStore = useTokenStore()
// 立即购买
const handleBuy = () => {
  if (tokenStore.token) {
    // 构造与购物车一致的数据结构
    const item = {
      fresh: props.detail, // 携带完整商品信息
      count: quantity.value
    }

    router.push({
      path: '/userMain/shoppingOrder',
      query: {
        isCart: false,
        items: JSON.stringify([item]), // 保持数组结构
        total: totalPrice.value
      }
    })
  }
  else {
    ElMessage.warning('登录后才能继续操作哟')
  }

}

// 加入购物车
const handleAddCart = () => {
  if (tokenStore.token) {
    emit('add-cart', {
      id: props.detail.id,
      quantity: quantity.value
    })
    handleClose()
  } else {
    ElMessage.warning('登录后才能继续操作哟')
  }


}
</script>

<style lang="scss" scoped>
.fresh-dialog {
  overflow: hidden;

  :deep(.el-dialog__header) {
    background: linear-gradient(135deg, #22A356, #2ECC71);
    margin: 0;
    padding: 18px 24px;

    .el-dialog__title {
      color: white;
      font-size: 18px;
      letter-spacing: 1px;
    }

    .el-dialog__headerbtn {
      top: 18px;
      right: 24px;

      .el-icon {
        color: white;
      }
    }
  }

  :deep(.el-dialog__body) {
    padding: 24px;
  }
}

.dialog-content {
  .product-image-wrapper {
    position: relative;
    border-radius: 12px;
    overflow: hidden;

    .main-image {
      width: 100%;
      height: 420px;
      border-radius: 12px;
      transition: transform 0.3s ease;
    }

    .sales-badge {
      position: absolute;
      top: 16px;
      right: 16px;
      background: rgba(255, 80, 80, 0.9);
      color: white;
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 12px;
      backdrop-filter: blur(4px);
    }
  }
}



.product-info {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  height: 90%;

  .product-title {
    font-size: 24px;
    color: #303133;
    line-height: 1.3;
  }

  .product-description {
    color: #606266;
    font-size: 14px;
    line-height: 1.6;
  }

  .feature-badge {
    background: linear-gradient(135deg, #22A356, #2ECC71);
    color: white;
    border: none;
    border-radius: 6px;
    padding: 8px 16px;
    font-size: 14px;
  }
}

.quantity-price {
  display: flex;
  justify-content: space-between;
  padding: 0 5px;

  .quantity-section {
    display: flex;
    align-items: center;
  }
}

.price-section {
  background: #f8fafc;
  border-radius: 8px;
  padding: 16px;

  .original-price {
    color: #666;
    font-size: 14px;

    &.has-promotion {
      text-decoration: line-through;
      color: #999;
    }
  }

  .current-price {
    color: #ff4d4f;
    font-size: 24px;
    font-weight: 600;
    margin-top: 8px;
  }

  .price-label {
    margin-right: 8px;
  }
}

.section-title {
  display: flex;
  align-items: center;
  color: #303133;
  font-size: 16px;
  margin: 16px 0 12px;
}

.total-price {
  text-align: right;
  font-size: 16px;
  color: #606266;
  margin: 20px 0;

  .price {
    color: #ff4d4f;
    font-size: 24px;
    font-weight: 600;
    margin-left: 12px;
  }
}

.action-buttons {
  display: flex;
  gap: 12px;

  .buy-btn {
    width: 45%;
    background: linear-gradient(135deg, #ff6b6b, #ff4d4f);
    border: none;
    height: 48px;
    font-size: 16px;
    border-radius: 8px;
    transition: all 0.3s ease;

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(255, 77, 79, 0.3);
    }
  }

  .cart-btn {
    width: 45%;
    height: 48px;
    border: 1px solid #22A356;
    color: #22A356;
    font-size: 16px;
    border-radius: 8px;
    transition: all 0.3s ease;

    &:hover {
      background: rgba(34, 163, 86, 0.1);
      transform: translateY(-2px);
    }

    .cart-icon {
      margin-right: 8px;
      font-size: 18px;
    }
  }
}
</style>