import { defineStore } from "pinia";
import { ref } from "vue";

const useActiveItemStore = defineStore("item", () => {
  // 有效路由列表
  const validPaths = [
    '/userMain/freshHome',
    '/userMain/freshCategory',
    '/userMain/shoppingCart',
    '/userMain/myorder'
  ]

  // 当前激活项
  const activedItem = ref('')

  // 方法：校验并设置激活项
  const validateAndSetActivedItem = (path) => {
    activedItem.value = validPaths.includes(path) ? path : ''
  }

  // 方法：强制设置激活项（跳过校验）
  const setActivedItem = (path) => {
    activedItem.value = path
  }

  // 方法：清空激活项
  const removeActivedItem = () => {
    activedItem.value = ''
  }

  return { 
    activedItem,
    validateAndSetActivedItem,
    setActivedItem,
    removeActivedItem 
  }
}, { persist: true })

export { useActiveItemStore }