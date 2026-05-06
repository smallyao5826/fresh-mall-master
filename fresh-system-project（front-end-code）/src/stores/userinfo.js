import { defineStore } from 'pinia'
export const useUserInfoStore = defineStore('user', {
  state: () => ({
    userInfo: null // 初始化为 null
  }),
  actions: {
    // 设置用户信息
    setUserInfo(data) {
      this.userInfo = {
        id: data?.id || '',
        username: data?.username || '',
        email: data?.email || '',
        phone: data?.phone || '',
        role: data?.role || '',
        avatar: data?.avatar || '',
        account: data?.account || 0 // 确保包含账户字段
      }
    },
    // 新增清除方法
    removeUserInfo() {
      this.userInfo = null
    }
  }
})