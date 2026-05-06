<template>
    <div class="user-profile-container">
        <el-card class="modern-card">
            <!-- 卡片头部 -->
            <div class="modern-header">
                <h1 class="designer-title">
                    <el-icon :size="36" class="title-icon">
                        <Avatar />
                    </el-icon>
                    Personal Profile
                </h1>
            </div>

            <!-- 主体内容 -->
            <div class="grid-layout">
                <!-- 左侧头像区域 -->
                <div class="neo-card primary-glow">
                    <div class="card-content">
                        <div class="avatar-wrapper">
                            <el-upload class="avatar-uploader" :action="uploadAction" :headers="uploadHeaders"
                                :show-file-list="false" :on-success="handleAvatarSuccess"
                                :before-upload="beforeAvatarUpload">
                                <el-avatar :size="120" :src="userFormModel.avatar" class="hover-zoom">
                                    <template v-if="!userFormModel.avatar">
                                        <el-icon :size="60">
                                            <Avatar />
                                        </el-icon>
                                    </template>
                                </el-avatar>
                                <div class="upload-mask">
                                    <el-icon :size="24">
                                        <Upload />
                                    </el-icon>
                                </div>
                            </el-upload>
                        </div>
                        <div class="user-meta">
                            <h3 class="user-name">{{ userFormModel.username || '未设置昵称' }}</h3>
                            <p class="user-role">{{ roleMap[userFormModel.role] }}</p>

                            <div class="contact-info">
                                <el-icon>
                                    <Iphone />
                                </el-icon>
                                {{ userFormModel.phone || '未绑定手机' }}
                            </div>
                            <div class="contact-info">
                                <el-icon>
                                    <Message />
                                </el-icon>
                                {{ userFormModel.email || '未绑定邮箱' }}
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 右侧表单区域 -->
                <div class="neo-card form-card">
                    <el-form ref="myForm" :model="userFormModel" :rules="rules" label-position="top"
                        class="modern-form">
                        <div class="form-grid">
                            <el-form-item label="用户名" prop="username">
                                <el-input v-model="userFormModel.username" placeholder="请输入用户名" class="modern-input">
                                    <template #prefix>
                                        <el-icon>
                                            <User />
                                        </el-icon>
                                    </template>
                                </el-input>
                            </el-form-item>





                            <el-form-item label="联系电话" prop="phone">
                                <el-input v-model="userFormModel.phone" placeholder="+86 138 0000 0000"
                                    class="modern-input">
                                    <template #prefix>
                                        <el-icon>
                                            <Iphone />
                                        </el-icon>
                                    </template>
                                </el-input>
                            </el-form-item>

                            <el-form-item label="邮箱地址" prop="email">
                                <el-input v-model="userFormModel.email" placeholder="name@example.com"
                                    class="modern-input">
                                    <template #prefix>
                                        <el-icon>
                                            <Message />
                                        </el-icon>
                                    </template>
                                </el-input>
                            </el-form-item>

                        </div>

                        <div class="form-actions">
                            <el-button type="primary" class="floating-action" @click="updateUser">
                                <el-icon>
                                    <Check />
                                </el-icon>
                                保存更改
                            </el-button>
                        </div>
                    </el-form>
                </div>
            </div>
        </el-card>
    </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useUserInfoStore } from '@/stores/userinfo'
import { useTokenStore } from '@/stores/token'
import { useRouter } from 'vue-router'
import {
    Avatar, Check, User, Iphone, Message
} from '@element-plus/icons-vue'
import { updateUserService } from '@/api/user.js'
import { getUserInfoService } from '@/api/user.js'
import { ElMessage, ElMessageBox } from 'element-plus'

const router = useRouter()
const userInfoStore = useUserInfoStore()
const tokenStore = useTokenStore()

// 上传配置（使用计算属性保证实时性）
const uploadAction = 'http://localhost:8080/file/upload-avatar'
const uploadHeaders = computed(() => ({
    Authorization: `Bearer ${tokenStore.token}`
}))

// 头像上传成功处理
const handleAvatarSuccess = (response) => {
    if (response.code === 0) {
        userInfoStore.setUserInfo(response.data)  // 更新Pinia
        userFormModel.value = { ...response.data } // 更新本地表单
        ElMessage.success('头像已更新')
    } else {
        ElMessage.error(response.message || '上传失败')
    }
}

// 错误处理（增强版）
const handleUploadError = (error) => {
    console.error('上传错误详情:', error)

    // Token过期处理
    if (error.status === 401 || tokenStore.isExpired()) {
        ElMessage.error('登录已过期，请重新登录')
        tokenStore.removeToken()
        userInfoStore.removeUserInfo()
        router.push('/login')
    } else {
        ElMessage.error(`上传失败：${error.message || '服务器错误'}`)
    }
}

// 上传前校验（保持原逻辑）
const beforeAvatarUpload = (file) => {
    const validTypes = ['image/jpeg', 'image/png']
    const isImage = validTypes.includes(file.type)
    const isLt2M = file.size / 1024 / 1024 < 2

    if (!isImage) {
        ElMessage.error('仅支持 JPG/PNG 格式!')
        return false
    }
    if (!isLt2M) {
        ElMessage.error('图片大小不能超过 2MB!')
        return false
    }
    return true
}

// 用户表单数据（响应式绑定）
const userFormModel = ref({
    ...userInfoStore.userInfo
})

// 表单验证规则（保持原逻辑）
const rules = reactive({
    username: [
        { required: true, message: '用户名不能为空', trigger: 'blur' },
        { min: 2, max: 16, message: '长度在2到16个字符', trigger: 'blur' }
    ],
    email: {
        validator: (rule, value, callback) => {
            const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
            if (!value || regex.test(value)) callback()
            else callback(new Error('请输入有效的邮箱地址'))
        },
        trigger: 'blur'
    },
    phone: [
        {
            pattern: /^1[3-9]\d{9}$/,
            message: '请输入有效的手机号码',
            trigger: 'blur'
        }
    ]
})

// 角色映射（保持原逻辑）
const roleMap = {
    '管理员': '系统管理员',
    '普通用户': '普通用户'
}

// 更新用户信息（增强版）
const updateUser = async () => {
    try {
        await ElMessageBox.confirm('确认保存个人信息修改吗？', '提示', {
            confirmButtonText: '确认',
            cancelButtonText: '取消',
            type: 'warning'
        })

        // 发送更新请求
        const response = await updateUserService(userFormModel.value);

        // 处理响应
        if (response.code === 0) {
            // 更新Pinia存储
            userInfoStore.setUserInfo(response.data);

            // 更新本地表单数据
            userFormModel.value = { ...response.data };

            ElMessage.success('信息更新成功');
        } else {
            ElMessage.error(response.message || '更新失败');
        }


    } catch (error) {
        if (error !== 'cancel') {
            console.error('更新失败详情:', error)
            ElMessage.error(` ${error.response?.data?.message || error.message}`)
        }
    }
}
</script>

<style lang="scss" scoped>
.user-profile-container {
    padding: 24px;
    min-height: calc(100vh - 48px);
    /* background: var(--color-bg); */

    .modern-card {
        border-radius: 16px;
        box-shadow: 0 4px 24px rgba(0, 0, 0, 0.06);
        border: none;

        :deep(.el-card__body) {
            padding: 0;
        }
    }
}

.modern-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 32px;
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


}

.grid-layout {
    display: grid;
    grid-template-columns: 480px 1fr;
    gap: 2rem;
    padding: 32px;
}

.neo-card {
    background: white;
    border-radius: 16px;
    padding: 24px;
    border: 1px solid var(--color-border);
    transition: all 0.3s ease;

    .card-content {
        width: 100%;
        height: 100%;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }

    &.primary-glow {
        background: linear-gradient(145deg, #ffffff, #f3faf6);
        border-color: var(--color-primary);
    }

    .avatar-uploader {
        position: relative;
        cursor: pointer;
    }

    .upload-mask {
        position: absolute;
        width: 98.5%;
        height: 98.5%;
        background: rgba(0, 0, 0, 0.5);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 0;
        transition: opacity 0.3s;
        color: white;
    }

    .avatar-uploader:hover .upload-mask {
        opacity: 1;
    }

    .hover-zoom {
        transition: transform 0.3s;
    }

    .hover-zoom:hover {
        transform: scale(1.05);
    }

    .user-meta {
        text-align: center;

        .user-name {
            font-size: 1.4rem;
            margin: 16px 0 8px;
            color: var(--color-text);
        }

        .user-role {
            color: var(--color-primary);
            background: rgba(34, 163, 86, 0.1);
            padding: 6px 12px;
            border-radius: 20px;
            display: inline-block;
            font-size: 0.9rem;
        }

        .contact-info {
            margin: 16px 0;
            color: rgba(51, 51, 51, 0.8);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-size: 0.95rem;

            .el-icon {
                color: var(--color-primary);
            }
        }
    }
}

.modern-form {
    .form-grid {
        display: flex;
        flex-direction: column;
        gap: 24px;
    }

    .modern-input {
        :deep(.el-input__wrapper) {
            border-radius: 12px;
            padding: 12px 16px;
            border: 1px solid var(--color-border);
            transition: all 0.2s;

            &:hover {
                border-color: var(--color-primary);
            }

            &.is-focus {
                box-shadow: 0 0 0 2px rgba(34, 163, 86, 0.1);
            }
        }

        .el-icon {
            color: var(--color-primary);
            font-size: 1.2rem;
        }
    }


    .modern-datepicker {
        :deep(.el-input__wrapper) {
            border-radius: 12px;
            padding: 12px 16px;
            border: 1px solid var(--color-border);
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: none;
            height: 48px; // 与其他输入框高度统一

            &:hover {
                border-color: var(--color-primary);
            }

            &.is-focus {
                border-color: var(--color-primary);
                box-shadow: 0 0 0 2px rgba(34, 163, 86, 0.1);
            }
        }

        // 日期面板样式调整
        :deep(.el-picker__popper) {
            .el-picker__panel {
                border-radius: 12px;
                box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
                border: 1px solid var(--color-border);

                .el-date-picker__header,
                .el-picker-panel__content {
                    margin: 8px;
                }

                .el-date-table th {
                    color: var(--color-text-secondary);
                }

                .el-date-table td.current:not(.disabled) span {
                    background-color: var(--color-primary);
                    color: white;
                }

                .el-button--text {
                    color: var(--color-primary);
                }
            }
        }

        // 图标颜色调整
        :deep(.el-input__prefix) {
            .el-icon {
                color: var(--color-primary);
                font-size: 18px;
                margin-left: 8px;
            }
        }
    }
}

.form-actions {
    margin-top: 32px;
    text-align: center;

    .floating-action {
        padding: 14px 28px;
        border-radius: 12px;
        font-weight: 600;
        background: linear-gradient(135deg, var(--color-primary), #3acf8e);
        box-shadow: 0 4px 12px rgba(34, 163, 86, 0.2);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);

        &:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(34, 163, 86, 0.3);
        }

        .el-icon {
            margin-right: 8px;
        }
    }
}

@media (max-width: 768px) {
    .grid-layout {
        grid-template-columns: 1fr;
        padding: 16px;
    }

    .modern-header {
        padding: 24px;
        flex-direction: column;
        gap: 16px;
        text-align: center;

        .designer-title {
            font-size: 1.6rem;
        }
    }

    .form-grid {
        grid-template-columns: 1fr !important;
    }
}
</style>