import { defineStore } from "pinia";
import { reactive, ref } from "vue";
import { obtainFreshes } from "@/api/managerStage";

// 查询参数存储
export const useQueryParamsStore = defineStore("queryParams", () => {
  // 分页参数
  const pagination = reactive({
    current: 1,
    pageSize: 8,
    total: 0,
  })

  // 过滤参数
  const filters = reactive({
    freshName: '',
    categoryId: null,
    recommend: null
  })

  // 更新分页参数
  const updatePagination = (newPagination) => {
    Object.assign(pagination, newPagination)
  }

  // 更新过滤参数（自动重置页码）
  const updateFilters = (newFilters) => {
    Object.keys(newFilters).forEach(key => {
      if (newFilters[key] === null || newFilters[key] === '') {
        filters[key] = undefined
      } else {
        filters[key] = newFilters[key]
      }
    })
    pagination.current = 1
  }

  // 获取完整查询参数
  const getQueryParams = () => ({
    pageNumber: pagination.current,
    pageSize: pagination.pageSize,
    freshName: filters.freshName?.trim() || undefined, // 处理空字符串
    categoryId: filters.categoryId || undefined,
    recommend: filters.recommend || undefined
  })

  return {
    pagination,
    filters,
    updatePagination,
    updateFilters,
    getQueryParams
  }
})

// 商品数据存储
export const usePageFreshStore = defineStore("freshData", () => {
  const items = ref([])
  const loading = ref(false)
  const error = ref(null)

  // 加载数据核心方法
  const loadItems = async (params) => {
    try {
      loading.value = true
      error.value = null

      const { data } = await obtainFreshes(params)

      items.value = data.items
      return data

    } catch (err) {
      error.value = err.message || '数据加载失败'
      throw err
    } finally {
      loading.value = false
    }
  }

  return {
    items,
    loading,
    error,
    loadItems
  }
})