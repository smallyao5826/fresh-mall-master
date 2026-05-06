<script setup>
import { ref, reactive, watch, nextTick } from 'vue'
import { User, Lock } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { registerService, userLoginService, getUserInfoService } from '@/api/user'
import { useTokenStore } from '@/stores/token'
import { useUserInfoStore } from '@/stores/userinfo'

const tokenStore = useTokenStore()
const userInfoStore = useUserInfoStore()

const emit = defineEmits(['success', 'update:modelValue'])
const props = defineProps({
    modelValue: Boolean
})

// 响应式数据
const dialogWidth = ref('500px')
const isRegister = ref(false)
const passwordInputRef = ref(null)

// 表单数据
const formData = reactive({
    phone: '',
    password: '',
    rePassword: ''
})

// 动态验证规则
const rules = reactive({
    phone: {
        pattern: /^1[3-9]\d{9}$/,
        message: '请输入有效的手机号',
        trigger: 'blur'
    },
    password: {
        validator: (rule, value, callback) => {
            if (!value) {
                callback(new Error('请输入密码'))
            } else if (isRegister.value && value.length < 6) {
                callback(new Error('密码需6-18位'))
            }
            callback()
        },
        trigger: 'blur'
    },
    rePassword: {
        validator: (rule, value, callback) => {
            if (isRegister.value && value !== formData.password) {
                callback(new Error('两次密码不一致'))
            }
            callback()
        },
        trigger: 'blur'
    }
})

// 监听注册状态变化
watch(isRegister, (newVal) => {
    if (!newVal) {
        formData.rePassword = ''
        nextTick(() => {
            passwordInputRef.value?.focus()
        })
    }
})

// 处理注册
const handleRegister = async () => {
    try {
        await registerService({
            phone: formData.phone,
            password: formData.password,
            rePassword: formData.rePassword
        })
        
        ElMessage.success('注册成功，已自动填充登录信息')
        isRegister.value = false
        formData.rePassword = ''

        nextTick(() => {
            passwordInputRef.value?.focus()
        })
    } catch (err) {
        ElMessage.error(err.message || '注册失败')
    }
}

// 处理登录
const handleLogin = async () => {
    try {
        const res = await userLoginService(formData.phone, formData.password)
        emit('success', res.data)
        
        tokenStore.setToken(res.data.token)
        
        const userRes = await getUserInfoService()
        userInfoStore.setUserInfo(userRes.data)
        
        closeDialog()
        ElMessage.success('登录成功')
    } catch (err) {
        ElMessage.error(err.message || '登录失败')
    }
}

// 关闭对话框
const closeDialog = () => {
    emit('update:modelValue', false)
    Object.assign(formData, {
        phone: '',
        password: '',
        rePassword: ''
    })
    isRegister.value = false
}
</script>

<template>
    <el-dialog 
        :model-value="modelValue" 
        @update:model-value="closeDialog" 
        :width="dialogWidth" 
        :show-close="false"
        custom-class="login-dialog"
    >
        <template #header>
            <div class="dialog-header">
                <h2>{{ isRegister ? '用户注册' : '用户登录' }}</h2>
            </div>
        </template>

        <el-form 
            :model="formData" 
            :rules="rules" 
            @submit.prevent="isRegister ? handleRegister() : handleLogin()"
        >
            <!-- 手机号 -->
            <el-form-item prop="phone">
                <el-input 
                    v-model="formData.phone" 
                    :prefix-icon="User" 
                    placeholder="请输入手机号" 
                    size="large" 
                />
            </el-form-item>

            <!-- 密码 -->
            <el-form-item prop="password">
                <el-input
                    ref="passwordInputRef"
                    v-model="formData.password"
                    :prefix-icon="Lock"
                    type="password"
                    :placeholder="isRegister ? '设置6-18位密码' : '请输入密码'"
                    size="large"
                    show-password
                />
            </el-form-item>

            <!-- 确认密码 -->
            <el-form-item v-if="isRegister" prop="rePassword">
                <el-input
                    v-model="formData.rePassword"
                    :prefix-icon="Lock"
                    type="password"
                    placeholder="确认密码"
                    size="large"
                    show-password
                />
            </el-form-item>

            <el-button 
                type="primary" 
                native-type="submit" 
                size="large" 
                class="submit-btn"
            >
                {{ isRegister ? '立即注册' : '立即登录' }}
            </el-button>
        </el-form>

        <template #footer>
            <div class="dialog-footer">
                <span @click="isRegister = !isRegister" class="toggle-text">
                    {{ isRegister ? '已有账号？去登录' : '没有账号？立即注册' }}
                </span>
            </div>
        </template>
    </el-dialog>
</template>

<style lang="scss" scoped>
$mobile-breakpoint: 768px;
$primary-color: var(--color-primary);
$text-color: var(--color-text);

.dialog-header {
    text-align: center;
    padding: 20px;
    h2 {
        color: $primary-color;
        font-size: 24px;
        font-weight: 600;
        margin: 0;
    }
}

.submit-btn {
    width: 100%;
    background: $primary-color;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    padding: 18px;
    transition: all 0.3s;
    margin: 15px 0;

    &:hover {
        opacity: 0.9;
        transform: translateY(-1px);
        box-shadow: 0 2px 8px rgba($primary-color, 0.3);
    }
}

.toggle-text {
    color: $text-color;
    cursor: pointer;
    font-size: 14px;
    transition: color 0.3s;

    &:hover {
        color: $primary-color;
    }
}

:deep(.login-dialog) {
    border-radius: 16px;
    overflow: hidden;
    
    .el-dialog__body {
        padding: 20px 30px;
    }
    
    .el-input__wrapper {
        border-radius: 8px;
        padding: 12px 15px;
        box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        
        &.is-focus {
            box-shadow: 0 0 0 2px rgba($primary-color, 0.2);
        }
    }
    
    .el-form-item {
        margin-bottom: 28px;
    }
}

@media (max-width: $mobile-breakpoint) {
    .dialog-header h2 {
        font-size: 20px;
    }
    
    :deep(.login-dialog) {
        width: 90% !important;
        max-width: 400px;
        
        .el-dialog__body {
            padding: 15px 20px;
        }
    }
    
    .submit-btn {
        padding: 14px;
        font-size: 14px;
    }
}
</style>