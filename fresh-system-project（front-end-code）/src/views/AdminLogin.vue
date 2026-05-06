<script setup>
// 组合式API引用（网页5、网页9）
import { ref, reactive } from 'vue'
import { Lock, User } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'
import { useTokenStore } from '@/stores/token'
import { adminLoginService,getUserInfoService } from '@/api/user'
import { useUserInfoStore } from '@/stores/userinfo'

const router = useRouter()
const tokenStore = useTokenStore()
const userInfoStore = useUserInfoStore()
// 响应式数据（网页5）
const formRef = ref(null)
const isLoading = ref(false)
const capsLockWarning = ref(false)

const formData = reactive({
    username: '',
    password: ''
})

// 验证规则（网页6）
const rules = reactive({
    username: [
        { required: true, message: '请输入管理员账号', trigger: 'blur' },
        { min: 3, max: 16, message: '长度3-16位', trigger: 'blur' }
    ],
    password: [
        { required: true, message: '请输入安全密码', trigger: 'blur' },
        { min: 5, max: 20, message: '长度5-20位', trigger: 'blur' }
    ]
})

// 登录逻辑（网页9）
const handleLogin = async () => {
    try {
        isLoading.value = true
        await formRef.value.validate()

        const res = await adminLoginService(formData) 
        tokenStore.setToken(res.data.token)

        const userRes = await getUserInfoService()
        userInfoStore.setUserInfo(userRes.data)

        await router.push('/managerMain/home')
        ElMessage.success(`欢迎回来，${formData.username}`)
    } catch (err) {
        ElMessage.error(err.message || '认证失败')
    } finally {
        isLoading.value = false
    }
}

// 键盘事件检测（网页6）
const checkCapsLock = (e) => {
    capsLockWarning.value = e.getModifierState('CapsLock')
}
</script>

<template>
    <div class="admin-login-container">
        <!-- 登录卡片 -->
        <el-card class="login-card">
            <h1 class="system-title">生鲜商城后台管理系统</h1>
            <div class="divider-line"></div>

            <el-form ref="formRef" :model="formData" :rules="rules" @keyup.enter="handleLogin" @keyup="checkCapsLock">
                <el-form-item prop="username">
                    <el-input v-model="formData.username" :prefix-icon="User" placeholder="管理员账号" clearable />
                </el-form-item>

                <el-form-item prop="password">
                    <el-input v-model="formData.password" :prefix-icon="Lock" type="password" placeholder="安全密码"
                        show-password />
                    <transition name="el-zoom-in-top">
                        <div v-if="capsLockWarning" class="capslock-warning">
                            ⚠️ 大写锁定已开启
                        </div>
                    </transition>
                </el-form-item>

                <el-button type="primary" :loading="isLoading" @click="handleLogin" class="login-btn">
                    {{ isLoading ? '认证中...' : '进入管理系统' }}
                </el-button>
            </el-form>

            <div class="security-tips">
                <el-icon>
                    <Lock />
                </el-icon>
                <span>冷链溯源保障 · 2025生鲜中枢系统 | 三重生物认证防护</span>
            </div>
        </el-card>
    </div>
</template>

<style lang="scss" scoped>
/* 全局变量扩展（网页1、网页6） */
:root {
    --admin-primary: #22A356;
}

.admin-login-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    position: relative;
    background: url('@/assets/login_bg2.jpg') center/cover;
    overflow: hidden;

    .login-card {
    position: static; 
    transform: none;
    margin: 20px; 
    width: 540px;
    border-radius: 16px;
    box-shadow: 0 12px 48px rgba(0, 0, 0, 0.15);
    background: rgba(255, 255, 255, 0.98);
    border: none;
    z-index: 1; 

    :deep(.el-card__body) {
        padding: 40px;
    }
}

    &::before {
        content: '';
        position: absolute;
        inset: 0;
        background: rgba(255, 255, 255, 0.5);
        backdrop-filter: blur(8px);
        z-index: 0; 
    }
}



.system-title {
    font: bold 28px/1.2;
    color: var(--admin-primary);
    text-align: center;
    letter-spacing: 2px;
    margin-bottom: 24px;
}

.divider-line {
    height: 2px;
    background: linear-gradient(90deg, transparent, var(--admin-primary) 50%, transparent);
    margin: 28px 0;
}

.el-form-item {
    margin-bottom: 32px;
}

:deep(.el-input__inner) {
    height: 48px;
    font-size: 15px;
    border-radius: 8px;
    transition: all 0.3s;
}

.login-btn {
    width: 100%;
    height: 48px;
    font-size: 16px;
    letter-spacing: 1px;
    margin-top: 12px;
    transition: all 0.3s;

    &:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(34, 163, 86, 0.3);
    }
}

.capslock-warning {
    color: #e6a23c;
    font-size: 12px;
    margin-top: 8px;
}

.security-tips {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    color: rgba(51, 51, 51, 0.7);
    font-size: 12px;
    margin-top: 32px;

    .el-icon {
        font-size: 14px;
    }
}
</style>