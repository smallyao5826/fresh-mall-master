<script setup>
import { ref } from 'vue';
import { Lock, Unlock, CircleCheck, Check, Refresh } from '@element-plus/icons-vue'
import { useTokenStore } from '@/stores/token.js';
import { useUserInfoStore } from '@/stores/userinfo.js';
import { useActiveItemStore } from '@/stores/activedItem.js';
import { useQueryParamsStore, usePageFreshStore } from '@/stores/queryArgs.js';
import { resetPasswd } from '@/api/user.js';
import { ElMessage } from 'element-plus';
import { useRouter } from 'vue-router';

// 状态管理
const tokenStore = useTokenStore()
const userInfoStore = useUserInfoStore()
const activeItemStore = useActiveItemStore()
const queryParamStore = useQueryParamsStore()
const pageFreshStore = usePageFreshStore()
const router = useRouter()

// 表单相关
const userPwdModel = ref({
    initPwd: '',
    newPwd: '',
    reNewPwd: ''
})

const ruleFormRef = ref()

// 验证规则
const checkRePasswd = (rule, value, callback) => {
    const { reNewPwd, newPwd } = userPwdModel.value
    if (!reNewPwd) return callback(new Error("请再次输入新密码"))
    if (reNewPwd.length < 5 || reNewPwd.length > 18) return callback(new Error("密码长度应为5-18个字符"))
    if (newPwd !== reNewPwd) return callback(new Error("两次输入密码不一致"))
    callback()
}

const rules = ref({
    initPwd: [
        { required: true, message: '请输入当前密码', trigger: 'blur' },
        { min: 5, max: 18, message: '密码长度应为5-18个字符', trigger: 'blur' }
    ],
    newPwd: [
        { required: true, message: '请输入新密码', trigger: 'blur' },
        { min: 5, max: 18, message: '密码长度应为5-18个字符', trigger: 'blur' }
    ],
    reNewPwd: [
        { required: true, validator: checkRePasswd, trigger: 'blur' }
    ],
})

// 表单操作
const resetForm = () => {
    if (ruleFormRef.value) {
        ruleFormRef.value.resetFields()
    }
}

const submitForm = async () => {
    try {
        const result = await resetPasswd(userPwdModel.value)
        ElMessage.success(result.message || "密码重置成功，请重新登录")

        // 清理状态
        userInfoStore.removeUserInfo()
        tokenStore.removeToken()
        pageFreshStore.removePageFreshesModel()
        queryParamStore.resetQueryParams()
        activeItemStore.removeActivedItem()

        router.push("/")
    } catch (error) {
        ElMessage.error(error.message || "密码修改失败")
    }
}
</script>

<template>
    <div class="user-profile-container">
        <el-card class="modern-card">
            <!-- 卡片头部 -->
            <div class="modern-header">
                <h1 class="designer-title">
                    <el-icon :size="28" class="title-icon">
                        <Lock style="color: var(--color-primary);" />
                    </el-icon>
                    Reset Password
                </h1>
            </div>

            <!-- 主体内容 -->
            <div class="password-form-container">
                <div class="neo-card form-card">
                    <el-form ref="ruleFormRef" :model="userPwdModel" :rules="rules" label-position="top"
                        class="modern-form" status-icon>
                        <div class="form-grid">
                            <el-form-item label="当前密码" prop="initPwd">
                                <el-input v-model="userPwdModel.initPwd" type="password" placeholder="请输入当前密码"
                                    class="modern-input" show-password>
                                    <template #prefix>
                                        <el-icon style="color: var(--color-primary)">
                                            <Lock />
                                        </el-icon>
                                    </template>
                                </el-input>
                            </el-form-item>

                            <el-form-item label="新密码" prop="newPwd">
                                <el-input v-model="userPwdModel.newPwd" type="password" placeholder="请输入新密码"
                                    class="modern-input" show-password>
                                    <template #prefix>
                                        <el-icon style="color: var(--color-primary)">
                                            <Unlock />
                                        </el-icon>
                                    </template>
                                </el-input>
                            </el-form-item>

                            <el-form-item label="确认密码" prop="reNewPwd">
                                <el-input v-model="userPwdModel.reNewPwd" type="password" placeholder="请再次输入新密码"
                                    class="modern-input" show-password>
                                    <template #prefix>
                                        <el-icon style="color: var(--color-primary)">
                                            <CircleCheck />
                                        </el-icon>
                                    </template>
                                </el-input>
                            </el-form-item>
                        </div>

                        <div class="form-actions">
                            <el-button type="primary" class="floating-action" @click="submitForm">
                                <el-icon>
                                    <Check />
                                </el-icon>
                                确认修改
                            </el-button>
                            <el-button class="floating-action secondary" @click="resetForm">
                                <el-icon>
                                    <Refresh />
                                </el-icon>
                                重置
                            </el-button>
                        </div>
                    </el-form>
                </div>
            </div>
        </el-card>
    </div>
</template>

<style lang="scss" scoped>
.user-profile-container {
    padding: 24px;
    min-height: calc(100vh - 48px);

    .modern-card {
        border-radius: 12px;
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

.password-form-container {
    max-width: 680px;
    margin: 0 auto;
    padding: 32px;

    .form-card {
        background: #ffffff;
        border-radius: 8px;
        padding: 32px;
    }
}

.modern-form {
    .form-grid {
        display: grid;
        gap: 24px;
        margin-bottom: 32px;
    }
}

.form-actions {
    display: flex;
    gap: 16px;
    justify-content: center;
    margin-top: 40px;

    .floating-action {
        padding: 12px 28px;
        border-radius: 8px;
        font-weight: 500;
        transition: all 0.3s ease;

        &.el-button--primary {
            background: linear-gradient(135deg, var(--color-primary), #3acf8e);
            border: none;

            &:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(34, 163, 86, 0.2);
            }
        }

        &.secondary {
            background: #f5f7fa;
            color: var(--color-text-regular);
            border: 1px solid var(--color-border-light);

            &:hover {
                background: #ebedf0;
            }
        }
    }
}

.modern-input {
    :deep(.el-input__wrapper) {
        border-radius: 8px;
        padding: 10px 16px;
        border: 1px solid var(--color-border-light);
        transition: border-color 0.3s;

        &:hover {
            border-color: var(--color-primary-light);
        }

        &.is-focus {
            border-color: var(--color-primary);
            box-shadow: 0 0 0 1px var(--color-primary);
        }
    }

    .el-icon {
        font-size: 18px;
        margin-right: 8px;
    }
}

@media (max-width: 768px) {
    .password-form-container {
        padding: 16px;
    }

    .form-actions {
        flex-direction: column;

        .floating-action {
            width: 100%;
        }
    }
}
</style>