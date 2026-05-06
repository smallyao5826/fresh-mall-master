<script setup>
import { ref, watch, onMounted } from 'vue'
import { ElTable, ElMessage, ElMessageBox } from 'element-plus'
import { storeToRefs } from 'pinia'
import { useRouter } from 'vue-router'
import FreshDetailDialog from '@/views/users-stage/subComponent/freshDetailDialog.vue'
import { useQueryParamsStore, usePageFreshStore } from '@/stores/queryArgs'
import { useUserInfoStore } from '@/stores/userinfo'
import { queryCategoryService } from '@/api/managerStage'
import { addCartService, createOrderService } from '@/api/userStage'

const router = useRouter()

// Pinia 状态管理
const userInfoStore = useUserInfoStore()
const queryParamsStore = useQueryParamsStore()
const pageStore = usePageFreshStore()
const { pagination, filters } = storeToRefs(queryParamsStore)
const { items: freshList, loading: isLoading } = storeToRefs(pageStore)

// 对话框状态
const dialogVisible = ref(false)
const currentProduct = ref(null)

// 常量配置
const EMOJI_LIST = ['🥕', '🍎', '🥩', '🐟', '🥟', '🍚', '🥜', '🌰', '🥥', '🍠']
const freshType = ref([])

// 初始化分类数据
const initCategories = async () => {
  try {
    const { data } = await queryCategoryService()
    freshType.value = data
    if (data.length > 0) {
      handleCategoryChange(data[0])
    }
  } catch (error) {
    ElMessage.error('Failed to load categories')
  }
}

// 分类切换处理
const handleCategoryChange = (category) => {
  queryParamsStore.updateFilters({
    categoryId: category?.id || null
  })
}

// 商品点击处理
const handleProductClick = (product) => {
  currentProduct.value = {
        id: product.id,
        freshName: product.freshName,
        categoryId: product.categoryId,
        prices: product.prices,
        promotionPrice: product.promotionPrice,
        description: product.description,
        feature: product.feature,
        pictureAddress: product.pictureAddress,
        salecount: product.sumRepertory - product.repertory,
        repertory: product.repertory,
        specification: product.specification,
    }
  dialogVisible.value = true
}

// 分页处理
const handlePaginationChange = (current) => {
  queryParamsStore.updatePagination({ current })
}

// 自动加载数据逻辑
watch(
  () => queryParamsStore.getQueryParams(),
  async (params) => {
    try {
      const data = await pageStore.loadItems(params)
      if (data?.total !== undefined) {
        queryParamsStore.pagination.total = data.total
      }
    } catch {
      ElMessage.error('Failed to load products')
    }
  },
  { immediate: true, deep: true }
)

// 处理购买操作
const handleBuy = async ({ id, quantity }) => {
  try {
    if (currentProduct.value.repertory < 1) {
      ElMessage.warning("没有库存啦")
      return
    }

    await createOrderService(id, quantity)
  } catch (error) {
    ElMessage.error(error.message || '操作失败，请稍候重试')
  }
}

// 处理加入购物车
const handleAddCart = async ({ id, quantity }) => {
  try {
    if (currentProduct.value.repertory < 1) {
      ElMessage.warning("没有库存啦")
      return
    }

    await addCartService(id, quantity)
    ElMessage.success("添加购物车成功")
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

onMounted(() => {
  initCategories()
  pageStore.loadItems(queryParamsStore.getQueryParams())
})
</script>

<template>
  <div class="fresh-market">
    <el-row :gutter="20">
      <!-- 左侧分类导航 -->
      <el-col :xs="24" :sm="8" :md="6" :lg="5" class="category-col">
        <el-card class="category-box shadow-box">
          <div class="category-header">
            <h2>Category</h2>
            <div class="select">
              <el-button class="filter-btn" type="primary" @click="handleCategoryChange(null)">
                默认
              </el-button>
              <el-button class="filter-btn" type="primary">
                最新
              </el-button>
              <el-button class="filter-btn" type="primary">
                热门
              </el-button>
            </div>
          </div>

          <el-table :data="freshType" highlight-current-row @current-change="handleCategoryChange"
            class="category-table">
            <el-table-column>
              <template #default="{ row, $index }">
                <div class="category-item">
                  <span class="emoji">
                    {{ EMOJI_LIST[$index % EMOJI_LIST.length] }}
                  </span>
                  {{ row.categoryName }}
                </div>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <!-- 右侧商品展示 -->
      <el-col :xs="24" :sm="16" :md="18" :lg="19">
        <div class="product-container">
          <el-card class="product-box shadow-box">
            <el-row v-loading="isLoading" :gutter="20">
              <template v-if="freshList.length > 0">
                <el-col v-for="item in freshList" :key="item.id" :xs="24" :sm="12" :md="8" :lg="6" class="product-item">
                  <el-card shadow="hover" class="product-card" @click="handleProductClick(item)">
                    <div class="image-container">
                      <img :src="item.pictureAddress" class="product-image" />
                    </div>
                    <h3 class="product-title">{{ item.freshName }}</h3>
                    <div class="price">
                      ¥{{ item.promotionPrice || item.prices }}
                      <div class="spec">/{{item.specification}}</div>
                    </div>
                    <el-tag type="success" effect="dark">{{ item.feature }}</el-tag>
                  </el-card>
                </el-col>
              </template>
              <el-empty v-else description="没有找到相关生鲜" />
            </el-row>
          </el-card>

          <!-- 固定分页器 -->
          <div class="pagination-fixed">
            <el-pagination v-model:current-page="pagination.current" :page-size="pagination.pageSize"
              :total="pagination.total" :disabled="isLoading" layout="total, prev, pager, next, jumper" background
              @current-change="handlePaginationChange" />
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 商品详情弹窗 -->
    <FreshDetailDialog v-model:visible="dialogVisible" :detail="currentProduct" @buy="handleBuy"
      @add-cart="handleAddCart" />
  </div>
</template>

<style lang="scss" scoped>
.fresh-market {
  padding: 20px;
  background: #f8f9fa;
  min-height: 100vh;
  box-sizing: border-box;

  .category-col {
    margin-bottom: 20px;

    .category-box {
      height: calc(100vh - 100px);
      overflow: hidden;
      border-radius: 12px;
      transition: transform 0.3s;

      .category-header {
        padding: 0 0 16px 0;
        margin-bottom: 12px;

        h2 {
          text-align: center;
          font-family: var(--font-title);
          font-weight: 600;
          font-size: 2.2rem;
          margin-bottom: 1rem;
          color: var(--color-primary);
        }

        .select {
          display: flex;
          justify-content: center;
          flex-wrap: wrap;
          gap: 8px;
        }

        .filter-btn {
          border-radius: 8px;
          padding: 8px 16px;
          margin: 4px;
          transition: all 0.3s;

          &:hover {
            transform: translateY(-2px);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
          }
        }
      }

      .category-table {
        :deep(.el-table__body) {
          tr:hover>td {
            background-color: rgba(34, 163, 89, 0.05) !important;
          }
        }

        .category-item {
          padding: 12px 16px;
          cursor: pointer;
          transition: all 0.2s;
          display: flex;
          align-items: center;

          .emoji {
            font-size: 1.5em;
            margin-right: 12px;
            transition: transform 0.3s;
          }

          &:hover {
            background: rgba(34, 163, 89, 0.05);

            .emoji {
              transform: scale(1.2);
            }
          }
        }
      }
    }
  }

  .product-container {
    position: relative;
    height: calc(100vh - 100px);

    .product-box {
      height: calc(100% - 65px);
      overflow-y: auto;
      border-radius: 12px 12px 0 0;

      :deep(.el-row) {
        position: relative;

        .el-empty {
          position: absolute;
          left: 45%;
          right: 45%;
          transform: translateY(50%);
          text-align: center;
          font-size: 1.2em;
          color: #666;
        }
      }

      .product-item {
        margin-bottom: 20px;
        padding: 0 10px;

        .product-card {
          cursor: pointer;
          border: none;
          border-radius: 12px;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
          transition: all 0.3s;
          min-height: 320px;
          max-height: 380px;
          display: flex;
          flex-direction: column;

          .image-container {
            height: 200px;
            min-height: 200px;
            max-height: 240px;
            overflow: hidden;
            border-radius: 8px;
            flex-shrink: 0;

            .product-image {
              width: 100%;
              height: 100%;
              object-fit: cover;
              transition: transform 0.3s;
            }
          }

          .product-title {
            margin: 12px 0;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            line-clamp: 2;
            -webkit-box-orient: vertical;
            flex-grow: 1;
          }

          .price {
            color: #ff4d4f;
            font-size: 1.2rem;
            font-weight: 600;
            margin: 8px 0;
            display: flex;
            align-items:center;

            

            .spec{
              font-size: 1rem;
              color: #666;
            }

          }

          &:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);

            .product-image {
              transform: scale(1.05);
            }
          }
        }
      }
    }

    .pagination-fixed {
      position: sticky;
      bottom: 0;
      background: white;
      padding: 16px 0;
      box-shadow: 0 -2px 12px rgba(0, 0, 0, 0.06);
      border-radius: 0 0 12px 12px;

      :deep(.el-pagination) {
        justify-content: center;

        .btn-prev,
        .btn-next,
        .number {
          min-width: 36px;
          height: 36px;
          border-radius: 8px;
          margin: 0 4px;
        }

        .number.active {
          background: #22a359 !important;
          color: white;
        }
      }
    }
  }

  .shadow-box {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);

    &:hover {
      box-shadow: 0 6px 16px rgba(0, 0, 0, 0.12);
    }
  }
}

@media (max-width: 768px) {
  .fresh-market {
    padding: 10px;

    .category-col .category-box {
      height: auto;
    }

    .product-container {
      height: auto;

      .product-box {
        height: auto;
      }

      .pagination-fixed {
        position: static;
        box-shadow: none;
      }
    }
  }
}
</style>