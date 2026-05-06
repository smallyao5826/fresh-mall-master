<script setup>
import { ref, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Edit, Delete, Plus } from '@element-plus/icons-vue'
import { getSlides, deleteSlideService, uploadSlideUrl, updateSlideService } from '@/api/managerStage.js'

// 主数据
const params = ref({
    pageNumber: 1,
    pageSize: 10,
    total: 0
})

const slidesModel = ref([])
const loading = ref(false)

// 抽屉控制
const drawerVisible = ref(false)
const currentSlide = ref({
    id: null,
    pictureAddress: ''
})

// 初始化加载数据
const getSlideData = async () => {
    loading.value = true
    try {
        const res = await getSlides(params.value)
        params.value.total = res.data.total
        slidesModel.value = res.data.items.map(item => ({
            ...item,
            pictureAddress: item.pictureAddress.replace(/\t/g, '')
        }))
    } catch (error) {
        ElMessage.error('数据加载失败')
    } finally {
        loading.value = false
    }
}

// 删除操作
const handleDelete = async (id) => {
    try {
        await deleteSlideService(id)
        ElMessage.success('删除成功')
        getSlideData()
    } catch (error) {
        ElMessage.error('删除失败')
    }
}

// 保存操作
const handleSave = async () => {
    try {
        if (currentSlide.value.id) {
            // 更新操作
            await updateSlideService(currentSlide.value.id, currentSlide.value)
        } else {
            // 新增操作
            await uploadSlideUrl(currentSlide.value)
        }
        ElMessage.success('保存成功')
        drawerVisible.value = false
        getSlideData()
    } catch (error) {
        ElMessage.error('保存失败')
    }
}

// 分页变化监听
watch(() => [params.value.pageNumber, params.value.pageSize], getSlideData)

// 初始化加载
getSlideData()
</script>

<template>
    <div class="container">
        <el-card class="table-manager">
            <template #header>
                <div class="header">
                    <h2 class="title">轮播图管理</h2>
                    <div class="header-right">
                        <el-button 
                            type="primary" 
                            @click="
                                drawerVisible = true;
                                currentSlide = { id: null, pictureAddress: '' };
                            "
                        >
                            新增轮播图
                        </el-button>
                    </div>
                </div>
            </template>

            <el-table 
                :data="slidesModel" 
                v-loading="loading" 
                height="calc(100vh - 300px)" 
                style="width: 100%" 
                stripe
            >
                <el-table-column 
                    label="序号" 
                    min-width="60"
                    type="index" 
                    align="center" 
                />

                <el-table-column 
                    label="预览图" 
                    min-width="60" 
                    align="center"
                >
                    <template #default="{ row }">
                        <el-image 
                            :src="row.pictureAddress" 
                            fit="cover" 
                            class="slide-image"
                            :preview-src-list="[row.pictureAddress]" 
                            hide-on-click-modal
                        />
                    </template>
                </el-table-column>

                <el-table-column 
                    label="图片地址" 
                    prop="pictureAddress" 
                    min-width="240"
                    show-overflow-tooltip 
                    align="center" 
                />

                <el-table-column 
                    label="创建时间" 
                    prop="createTime" 
                    max-width="180" 
                    align="center" 
                />

                <el-table-column 
                    label="更新时间" 
                    prop="updateTime" 
                    max-width="180" 
                    align="center" 
                />

                <el-table-column 
                    label="操作" 
                    max-width="80" 
                    align="center" 
                    fixed="right"
                >
                    <template #default="{ row }">
                        <div class="action-buttons">
                            <el-tooltip content="编辑" placement="top">
                                <el-button 
                                    type="primary" 
                                    :icon="Edit" 
                                    circle 
                                    size="small"
                                    @click="
                                        drawerVisible = true;
                                        currentSlide = { ...row };
                                    "
                                />
                            </el-tooltip>

                            <el-popconfirm
                                title="确定删除该轮播图?" 
                                @confirm="handleDelete(row.id)"
                            >
                                <template #reference>
                                    <el-tooltip content="删除" placement="top">
                                        <el-button 
                                            type="danger" 
                                            :icon="Delete" 
                                            circle 
                                            size="small" 
                                            class="ml-2"
                                        />
                                    </el-tooltip>
                                </template>
                            </el-popconfirm>
                        </div>
                    </template>
                </el-table-column>

                <template #empty>
                    <el-empty description="暂无数据" />
                </template>
            </el-table>

            <div class="pagination-wrapper" v-if="params.total > 0">
                <el-pagination
                    v-model:current-page="params.pageNumber"
                    v-model:page-size="params.pageSize"
                    :page-sizes="[10, 20, 50]"
                    layout="total, sizes, prev, pager, next, jumper"
                    :total="params.total"
                    background
                />
            </div>
        </el-card>

        <!-- 抽屉组件 -->
        <el-drawer 
            v-model="drawerVisible" 
            :title="currentSlide.id ? '编辑轮播图' : '新增轮播图'" 
            size="40%" 
            direction="rtl"
        >
            <div class="drawer-content">
                <el-form :model="currentSlide" label-width="100px">
                    <el-form-item label="图片上传">
                        <div class="upload-placeholder">
                            <el-icon :size="60" color="var(--el-color-info)">
                                <Plus />
                            </el-icon>
                            <div class="upload-tip">点击上传轮播图</div>
                        </div>
                    </el-form-item>

                    <el-form-item label="图片地址">
                        <el-input 
                            v-model="currentSlide.pictureAddress" 
                            placeholder="请输入图片URL地址"
                            clearable
                        />
                    </el-form-item>
                </el-form>
            </div>

            <template #footer>
                <div class="drawer-footer">
                    <el-button @click="drawerVisible = false">取消</el-button>
                    <el-button 
                        type="primary" 
                        @click="handleSave"
                    >
                        {{ currentSlide.id ? '保存修改' : '确认新增' }}
                    </el-button>
                </div>
            </template>
        </el-drawer>
    </div>
</template>

<style scoped lang="scss">
.container {
    height: calc(100vh - 150px);
    box-sizing: border-box;

    :deep(.el-card__header) {
        padding: 0;
    }
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
        height: 100%;

        :deep(.el-button) {
            height: 40px;
            font-size: 14px;
        }
        
    }
}

.slide-image {
    width: 120px;
    height: 80px;
    border-radius: 4px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

:deep(.el-button--small){
  padding: 15px !important;
}

.action-buttons {
    display: flex;
    align-items: center;
    justify-content: center;
    
    .ml-2 {
        margin-left: 8px;
    }
}

.pagination-wrapper {
    padding: 12px 0;

    :deep(.el-pagination) {
        justify-content: flex-end;
        padding: 8px 16px;
        background: #fff;
        border-radius: 8px;

        .btn-prev,
        .btn-next,
        li {
            background: var(--el-fill-color-light);
            border-radius: 6px;
            margin: 0 4px;
        }

        .el-pager li {
            background: var(--el-color-primary);
            color: white;
            border-radius: 6px;
            margin: 0 4px;

            &:hover {
                color: var(--el-color-primary) !important;
            }

            &.is-active {
                color: white !important;
            }
        }
    }
}

.drawer-content {
    padding: 20px;

    .upload-placeholder {
        width: 100%;
        height: 200px;
        border: 2px dashed var(--el-border-color);
        border-radius: 8px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: border-color 0.3s;

        &:hover {
            border-color: var(--el-color-primary);
        }

        .upload-tip {
            color: var(--el-text-color-secondary);
            margin-top: 12px;
            font-size: 14px;
        }
    }
}

.drawer-footer {
    padding: 16px;
    border-top: 1px solid var(--el-border-color);
    text-align: right;
}

:deep(.el-drawer) {
    .el-drawer__header {
        margin-bottom: 0;
        padding: 20px;
        border-bottom: 1px solid var(--el-border-color);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    }

    .el-drawer__body {
        padding: 0;
        position: relative;
        height: calc(100% - 64px);
        overflow-y: auto;
    }
}
</style>