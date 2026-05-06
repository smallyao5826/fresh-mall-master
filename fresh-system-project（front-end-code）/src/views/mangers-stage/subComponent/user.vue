<script lang="ts" setup>
import { Edit, Delete, Search, Plus } from '@element-plus/icons-vue'
import { ref, reactive } from 'vue'
import {
    obtainUsers,
    insertUser,
    updateUserService,
    deleteUserService,
    getUserInfoService
} from '@/api/user.js'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useTokenStore } from '@/stores/token.js'
import { useUserInfoStore } from '@/stores/userinfo.js'

const tokenStore = useTokenStore()
const userInfoStore = useUserInfoStore()

// 数据相关
const originalUsers = ref([])
const users = ref([])
const searchParams = reactive({
    role: null,
    keyword: null,
    pageNumber: 1,
    pageSize: 10,
    total: 0
})

// 表单相关
const userForm = reactive({
    id: null,
    username: '',
    password: '',
    email: '',
    phone: '',
    role: '',
    avatar: ''
})
const formRules = reactive({
    username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
    password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
    email: [{ type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }],
    role: [{ required: true, message: '请选择角色', trigger: 'change' }]
})

// 控制抽屉
const drawerVisible = ref(false)
const drawerTitle = ref('')

// 获取用户数据
const fetchUsers = async () => {
    try {
        const res = await obtainUsers({
            role: searchParams.role,
            search: searchParams.keyword,
            pageNumber: searchParams.pageNumber,
            pageSize: searchParams.pageSize
        })

        originalUsers.value = res.data.items
        searchParams.total = res.data.total
        updateDisplayData()
    } catch (e) {
        ElMessage.error('数据加载失败')
    }
}

// 前端分页处理
const updateDisplayData = () => {
    const start = (searchParams.pageNumber - 1) * searchParams.pageSize
    const end = start + searchParams.pageSize
    users.value = originalUsers.value.slice(start, end)
}

// 搜索处理
const handleSearch = () => {
    searchParams.pageNumber = 1
    fetchUsers()
}

// 打开抽屉
const openDrawer = (type, row = null) => {
    drawerTitle.value = type
    if (type === '编辑用户') {
        Object.assign(userForm, row)
    } else {
        resetForm()
    }
    drawerVisible.value = true
}

// 提交表单
const submitForm = async () => {
    try {
        if (drawerTitle.value === '新增用户') {
            await insertUser(userForm)
            ElMessage.success('用户创建成功')
        } else {
            await updateUserService(userForm)
            ElMessage.success('用户更新成功')
            // 更新当前用户信息
            if (userForm.id === userInfoStore.userInfo.id) {
                const res = await getUserInfoService()
                userInfoStore.setUserInfo(res.data)
            }
        }
        drawerVisible.value = false
        await fetchUsers()
    } catch (error) {
        ElMessage.error(error.message)
    }
}

// 删除用户
const handleDelete = async (id) => {
    try {
        await ElMessageBox.confirm('确认删除该用户？', '警告', {
            confirmButtonText: '确认',
            cancelButtonText: '取消',
            type: 'warning'
        })
        await deleteUserService(id)
        await fetchUsers()
        ElMessage.success('删除成功')
    } catch (error) {
        if (error !== 'cancel') {
            ElMessage.error('删除失败')
        }
    }
}

// 重置表单
const resetForm = () => {
    Object.assign(userForm, {
        id: null,
        username: '',
        password: '',
        email: '',
        phone: '',
        role: '',
        avatar: ''
    })
}

// 初始化加载
fetchUsers()
</script>

<template>
    <div class="container">
        <el-card class="table-manager">
            <template #header>
                <div class="header">
                    <h3 class="title">用户管理</h3>
                    <div class="header-right">
                        <div class="search-group">

                            <el-select v-model="searchParams.role" placeholder="全部角色" clearable @change="handleSearch"
                                style="width: 120px">
                                <el-option label="管理员" value="管理员" />
                                <el-option label="普通用户" value="普通用户" />
                            </el-select>


                            <el-input v-model="searchParams.keyword" placeholder="搜索用户" clearable :prefix-icon="Search"
                                style="width: 240px" @keyup.enter="handleSearch" />

                        </div>
                        <el-button type="primary" class="new-button" @click="openDrawer('新增用户')">
                            新增用户
                        </el-button>
                    </div>
                </div>
            </template>

            <!-- 数据表格 -->
            <el-table :data="users" height="calc(100vh - 300px)" size="small">
                <el-table-column prop="id" label="ID" min-width="80" fixed align="center" />
                <el-table-column label="头像" min-width="80" align="center">
                    <template #default="{ row }">
                        <el-avatar :size="36" :src="row.avatar" />
                    </template>
                </el-table-column>
                <el-table-column prop="username" label="用户名" min-width="120" align="center" />
                <el-table-column prop="email" label="邮箱" min-width="180" align="center" />
                <el-table-column prop="phone" label="手机号" min-width="130" align="center" />
                <el-table-column prop="role" label="角色" min-width="100" align="center" />
                <el-table-column label="操作" width="120" fixed="right" align="center">
                    <template #default="{ row }">
                        <el-button type="primary" :icon="Edit" circle size="small" @click="openDrawer('编辑用户', row)" />
                        <el-button type="danger" :icon="Delete" circle size="small" @click="handleDelete(row.id)" />
                    </template>
                </el-table-column>
            </el-table>

            <!-- 分页组件 -->
            <div class="pagination-wrapper">
                <el-pagination v-model:current-page="searchParams.pageNumber" v-model:page-size="searchParams.pageSize"
                    :page-sizes="[10, 20, 50]" layout="total, sizes, prev, pager, next" :total="searchParams.total"
                    background small @size-change="fetchUsers" @current-change="fetchUsers" />
            </div>
        </el-card>

        <!-- 编辑抽屉 -->
        <el-drawer v-model="drawerVisible" :title="drawerTitle" size="500px" @closed="resetForm">
            <el-form :model="userForm" :rules="formRules" label-width="80px">
                <el-form-item label="头像" prop="avatar">
                    <el-upload class="avatar-uploader" action="http://localhost:8080/file/uploadAvatar"
                        :show-file-list="false" :headers="{ Authorization: tokenStore.token }"
                        :on-success="(res) => userForm.avatar = res.data">
                        <img v-if="userForm.avatar" :src="userForm.avatar" class="avatar" />
                        <el-icon v-else class="avatar-uploader-icon">
                            <Plus />
                        </el-icon>
                    </el-upload>
                </el-form-item>
                <el-form-item label="用户名" prop="username">
                    <el-input v-model="userForm.username" placeholder="请输入用户名" />
                </el-form-item>
                <el-form-item label="密码" prop="password" v-if="drawerTitle === '新增用户'">
                    <el-input v-model="userForm.password" type="password" show-password placeholder="请输入密码"/>
                </el-form-item>
                <el-form-item label="邮箱" prop="email">
                    <el-input v-model="userForm.email" placeholder="请输入邮箱" />
                </el-form-item>
                <el-form-item label="手机号" prop="phone">
                    <el-input v-model="userForm.phone" placeholder="请输入手机号" />
                </el-form-item>
                <el-form-item label="角色" prop="role">
                    <el-select v-model="userForm.role" placeholder="请选择角色">
                        <el-option label="管理员" value="管理员" />
                        <el-option label="普通用户" value="普通用户" />
                    </el-select>
                </el-form-item>

                <el-form-item>
                    <el-button type="primary" @click="submitForm">提交</el-button>
                    <el-button @click="drawerVisible = false">取消</el-button>
                </el-form-item>
            </el-form>
        </el-drawer>
    </div>
</template>

<style scoped>
/* 完全同步分类管理样式 */
.container {
    height: calc(100vh - 150px);
    box-sizing: border-box;
}

:deep(.el-card__header) {
    padding: 0;
}

.table-manager {
    height: 100%;

    :deep(.el-card__body) {
        padding: 16px !important;
    }
}

.header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 20px;
    background: #fff;

    .title {
        color: var(--el-color-primary);
        font-size: 20px;
        font-weight: 600;
        margin: 0;
        letter-spacing: 0.5px;
    }

    .header-right {
        display: flex;
        align-items: center;
        gap: 16px;

        :deep(.el-select) {
            height: 40px;

            .el-select__wrapper {
                height: 40px;
            }
        }

        .search-group {
            display: flex;
            align-items: center;
            gap: 12px;
            height: 40px;

            :deep(.el-input__wrapper) {
                height: 40px;
                padding: 0 16px;
            }

            :deep(.el-input-group__append) {
                padding: 0 !important;
            }


        }
    }

    .new-button {
        height: 40px;
        padding: 0 24px;
        border-radius: 8px;
        font-weight: 500;
        letter-spacing: 0.5px;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
        transition: all 0.2s;

        &:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(24, 144, 255, 0.2);
        }
    }
}

:deep(.el-button--small) {
    padding: 15px !important;
}

.pagination-wrapper {
    margin-top: 16px;
    display: flex;
    justify-content: flex-end;

    :deep(.el-pagination) {
        justify-content: flex-end;

        .btn-prev,
        .btn-next,
        .number {
            min-width: 32px;
            height: 32px;
            border-radius: 8px;
            margin: 0 4px;
        }

        .number.active {
            background: var(--el-color-primary);
            color: white;
        }
    }
}

/* 表格样式同步 */
:deep(.el-table) {
    border-radius: 8px;
    font-size: 14px;

    th {
        background-color: #f8f9fa !important;
        color: #606266;
        font-weight: 600;
    }

    td {
        padding: 12px 0;
    }

    tr:hover td {
        background-color: #f5f7fa !important;
    }
}

/* 操作按钮样式 */
:deep(.el-button) {
    margin: 0 4px;
    border: 1px solid;

    &.is-circle {
        border-radius: 50%;
    }

    &:hover {
        transform: translateY(-1px);
    }
}

/* 抽屉表单样式 */
:deep(.el-drawer) {
    .el-drawer__header {
        margin-bottom: 0;
        padding: 20px 24px;
        border-bottom: 1px solid #ebeef5;
    }

    .el-drawer__body {
        padding: 24px;

        .el-form-item {
            margin-bottom: 22px;

            &__label {
                color: #606266;
                font-weight: 500;
            }
        }

        .el-input__wrapper {
            border-radius: 8px;
            height: 40px;
        }
    }

    .el-drawer__footer {
        padding: 16px 24px;
        border-top: 1px solid #ebeef5;
    }
}

/* 头像上传样式 */
.avatar-uploader {
    :deep(.el-upload) {
        border: 1px dashed var(--el-border-color);
        border-radius: 6px;
        cursor: pointer;
        position: relative;
        overflow: hidden;
        transition: var(--el-transition-duration-fast);

        &:hover {
            border-color: var(--el-color-primary);
        }
    }

    .avatar {
        width: 120px;
        height: 120px;
        display: block;
    }

    .avatar-uploader-icon {
        font-size: 28px;
        color: #8c939d;
        width: 120px;
        height: 120px;
        line-height: 120px;
        text-align: center;
    }
}
</style>