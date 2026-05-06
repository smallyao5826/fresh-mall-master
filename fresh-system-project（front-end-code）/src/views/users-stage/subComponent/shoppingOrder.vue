<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus, ArrowLeft, ArrowRight } from '@element-plus/icons-vue'
import { pcaTextArr } from 'element-china-area-data'
import { useRouter } from 'vue-router'
import { useRoute } from 'vue-router'
import {
    getUserAddressListService,
    addUserAddressService,
    createOrderService
} from '@/api/userStage.js'

const scrollContainer = ref(null)
const scroll = (delta) => {
    if (scrollContainer.value) {
        scrollContainer.value.scrollBy({
            left: delta,
            behavior: 'smooth'
        })
    }
}

const router = useRouter()
const route = useRoute()

// 订单数据
const orderItems = ref([])
const totalAmount = ref(0)
const isCartOrder = ref(false)

const addresses = ref([])
const selectedAddressId = ref(null)
const showAddressForm = ref(false)
const paymentMethod = ref('微信支付')
const remark = ref('') // 新增备注绑定

// 地址表单
const addressForm = ref({
    name: '',
    phone: '',
    selectedOptions: [],
    province: '',
    city: '',
    district: '',
    detailedAddress: '',
    isDefault: true
})

// 运费相关
const shippingFee = ref(12) // 基础运费
const coldChainFee = ref(0) // 冷链附加费
const totalFee = ref(0) // 总费用

onMounted(async () => {
    isCartOrder.value = route.query.isCart === 'true'
    orderItems.value = JSON.parse(route.query.items || '[]')

    // 先检查冷链
    await checkColdChain()

    // 计算初始总金额
    totalAmount.value = parseFloat(route.query.total || 0)
    calculateTotalFee()

    await loadAddresses()
})

// 计算总费用
const calculateTotalFee = () => {
    totalFee.value = Number(totalAmount.value) + Number(shippingFee.value) + Number(coldChainFee.value)
}

// 冷链检查
const checkColdChain = async () => {
    const coldChainCategories = [1,2,3,4,5]
    const hasColdChain = orderItems.value.some(item =>
        coldChainCategories.includes(item.fresh.categoryId)
    )

    if (hasColdChain) {
        coldChainFee.value = 8  // 冷链附加费
        shippingFee.value = 12  // 冷链基础运费
    } else {
        coldChainFee.value = 0
        shippingFee.value = 12
    }
}

const loadAddresses = async () => {
    try {
        const res = await getUserAddressListService()
        addresses.value = res.data
        const defaultAddr = res.data.find(a => a.isDefault)
        selectedAddressId.value = defaultAddr?.id
    } catch (error) {
        ElMessage.error('地址加载失败')
    }
}

const handleAreaChange = (value) => {
    const [province, city, district] = value
    addressForm.value.province = province
    addressForm.value.city = city
    addressForm.value.district = district
}

const submitAddress = async () => {
    try {
        await addUserAddressService({
            ...addressForm.value,
            address: `${addressForm.value.province}${addressForm.value.city}${addressForm.value.district} ${addressForm.value.detailedAddress}`
        })
        ElMessage.success('地址添加成功')
        showAddressForm.value = false
        await loadAddresses()
    } catch (error) {
        ElMessage.error('地址添加失败')
    }
}

const submitOrder = async () => {
    try {
        const params = {
            addressID: selectedAddressId.value,
            sumMoney: totalFee.value.toFixed(2), // 使用计算后的总费用
            freshList: orderItems.value.map(item => ({
                freshId: item.fresh.id,
                purchaseCount: item.count
            })),
            paymentMethod: paymentMethod.value,
            remark: remark.value,
            isCartOrder: isCartOrder.value,
            shippingFee: shippingFee.value + coldChainFee.value, // 传递运费
        }

        const res = await createOrderService(params)
        // 支付宝支付处理
        if (paymentMethod.value === '支付宝' && res.code === 0) {
            const div = document.createElement('div')
            div.innerHTML = res.data
            document.body.appendChild(div)
            document.forms[0].submit() // 自动提交支付宝表单
            return
        }

        // 其他支付方式处理
        if (res.code === 0) {
            ElMessage.success('订单创建成功')
            router.push("/userMain/myOrder")
        }
    } catch (error) {
        ElMessage.error(error.message || '订单创建失败')
    }
}
</script>

<template>
    <div class="order-container">
        <el-card class="main-card">
            <!-- 主标题 -->
            <h1 class="page-title">Order Confirmation</h1>

            <section class="address-section">
                <div class="section-header">
                    <div class="decorated-title">
                        <span class="decorator"></span>
                        <h3 class="section-label">配送地址</h3>
                    </div>
                </div>

                <!-- 带箭头的滚动容器 -->
                <div class="scroll-container">
                    <div class="arrow left-arrow" @click="scroll(-300)">
                        <el-icon>
                            <ArrowLeft />
                        </el-icon>
                    </div>

                    <div class="address-scroll" ref="scrollContainer">
                        <div class="address-cards">
                            <div v-for="addr in addresses" :key="addr.id" class="address-card" :class="{
                                'selected': selectedAddressId === addr.id,
                                'default': addr.isDefault
                            }" @click="selectedAddressId = addr.id">
                                <div class="card-content">
                                    <div class="header-line">
                                        <span class="name">{{ addr.name }}</span>
                                        <el-tag v-if="addr.isDefault" size="small" type="success">默认</el-tag>
                                    </div>
                                    <div class="phone">{{ addr.phone }}</div>
                                    <div class="address-detail">
                                        {{ addr.province }}{{ addr.city }}{{ addr.district }}
                                        {{ addr.detailedAddress }}
                                    </div>
                                </div>
                            </div>

                            <!-- 添加地址卡片 -->
                            <div class="add-card" @click="showAddressForm = true">
                                <el-icon class="plus-icon">
                                    <Plus />
                                </el-icon>
                                <div class="add-text">添加新地址</div>
                            </div>
                        </div>
                    </div>

                    <div class="arrow right-arrow" @click="scroll(300)">
                        <el-icon>
                            <ArrowRight />
                        </el-icon>
                    </div>
                </div>
            </section>

            <!-- 备注 -->
            <section class="remark-section">
                <div class="decorated-title">
                    <span class="decorator"></span>
                    <h3 class="section-label">订单备注</h3>
                    <div class="fee-notice" v-if="coldChainFee > 0">
                        <el-icon color="#409EFC" :size="16">
                            <Warning />
                        </el-icon>
                        <span>包含冷链商品，已启用冷链运输（+¥{{ coldChainFee }}）</span>
                    </div>
                </div>
                <div class="remark-container">
                    <el-input v-model="remark" type="textarea" :rows="1" placeholder="请输入特殊要求或备注信息" maxlength="50"
                        show-word-limit resize="none" class="remark-input" />
                </div>
            </section>

            <!-- 商品清单 -->
            <section class="goods-section">
                <div class="decorated-title">
                    <span class="decorator"></span>
                    <h3 class="section-label">商品清单</h3>
                </div>
                <div class="goods-list">
                    <div v-for="item in orderItems" :key="item.fresh.id" class="goods-item">
                        <el-image :src="item.fresh.pictureAddress" class="goods-image" fit="cover" />
                        <div class="goods-info">
                            <div class="name">{{ item.fresh.freshName }}</div>
                            <div class="spec">{{ item.fresh.specification }}</div>
                        </div>
                        <div class="goods-right">
                            <div class="price">
                                ¥{{ (item.fresh.promotionPrice || item.fresh.prices).toFixed(2) }}
                            </div>
                            <div class="quantity">x{{ item.count }}</div>
                            <div class="subtotal">
                                ¥{{ ((item.fresh.promotionPrice || item.fresh.prices) * item.count).toFixed(2) }}
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </el-card>

        <!-- 底部固定栏 -->
        <div class="sticky-footer">
            <div class="footer-content">
                <div class="payment-method">
                    <span class="label">支付方式：</span>
                    <el-radio-group v-model="paymentMethod">
                        <el-radio label="微信支付">微信支付</el-radio>
                        <el-radio label="支付宝">支付宝</el-radio>
                    </el-radio-group>
                </div>

                <div class="total-amount">
                    <span>实付款：</span>
                    <span class="price">¥{{ totalFee.toFixed(2) }}</span>
                    <div class="fee-item">
                        <span>包含运费：</span>
                        <span>¥{{ (shippingFee + coldChainFee).toFixed(2) }}</span>
                    </div>
                </div>

                <el-button type="primary" size="large" class="submit-btn" @click="submitOrder"
                    :disabled="!selectedAddressId">
                    立即下单
                </el-button>
            </div>
        </div>

        <!-- 新增地址弹窗 -->
        <el-dialog v-model="showAddressForm" title="新增地址" width="600px">
            <el-form :model="addressForm" label-width="80px">
                <el-form-item label="收货人" required>
                    <el-input v-model="addressForm.name" placeholder="请输入姓名" maxlength="10" />
                </el-form-item>
                <el-form-item label="联系电话" required>
                    <el-input v-model="addressForm.phone" placeholder="请输入手机号" maxlength="11" />
                </el-form-item>
                <el-form-item label="所在地区" required>
                    <el-cascader v-model="addressForm.selectedOptions" :options="pcaTextArr" @change="handleAreaChange"
                        placeholder="请选择省/市/区" class="full-width" />
                </el-form-item>
                <el-form-item label="详细地址" required>
                    <el-input v-model="addressForm.detailedAddress" placeholder="街道门牌、楼栋号等" maxlength="50" />
                </el-form-item>
                <el-form-item label="默认地址">
                    <el-switch v-model="addressForm.isDefault" />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="showAddressForm = false">取消</el-button>
                <el-button type="primary" @click="submitAddress">确认添加</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<style lang="scss" scoped>
.order-container {
    padding: 24px;
    min-height: calc(100vh - 48px);
    box-sizing: border-box;

    .page-title {
        font-family: var(--font-title);
        text-align: center;
        font-size: 2.4rem;
        color: var(--color-primary);
        margin: 0 0 30px;
        font-weight: bold;
    }

    .main-card {
        border-radius: 16px;
        box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
        margin-bottom: 80px;

        :deep(.el-card__body) {
            padding: 30px;
        }
    }

    .decorated-title {
        display: flex;
        align-items: center;
        margin-bottom: 25px;

        .decorator {
            width: 4px;
            height: 16px;
            background: #22A356;
            margin-right: 8px;
            border-radius: 2px;
        }

        .section-label {
            font-size: 16px;
            color: #333;
            font-weight: 600;
            margin: 0;
        }
    }



    .address-section {
        margin-bottom: 30px;

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .scroll-container {
            position: relative;
            padding: 0 40px;
            margin: 16px;

            .arrow {
                position: absolute;
                top: 50%;
                transform: translateY(-50%);
                width: 32px;
                height: 32px;
                background: white;
                border-radius: 50%;
                box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                z-index: 1;
                transition: all 0.2s;

                &:hover {
                    background: #f5f5f5;
                    transform: translateY(-50%) scale(1.1);
                }

                &.left-arrow {
                    left: 0
                }

                &.right-arrow {
                    right: 0
                }
            }
        }

        .address-scroll {
            overflow-x: auto;
            scrollbar-width: none;
            /* Firefox */
            -ms-overflow-style: none;
            /* IE */

            &::-webkit-scrollbar {
                display: none;
                /* Chrome/Safari */
            }

            .address-cards {
                display: flex;
                gap: 16px;
            }
        }

        .address-card {
            flex: 0 0 300px;
            height: 120px;
            border: 1px solid #e4e7ed;
            border-radius: 16px;
            padding: 20px;
            cursor: pointer;
            transition: all 0.2s;
            background: white;
            position: relative;
            overflow: hidden;

            &:hover {
                border-color: #22A356;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            }

            &.selected {
                border-color: #22A356;
                background: rgba(34, 163, 86, 0.05);
            }

            .card-content {
                height: 100%;
                display: flex;
                flex-direction: column;

                .header-line {
                    display: flex;
                    align-items: center;
                    margin-bottom: 12px;

                    .name {
                        font-size: 16px;
                        font-weight: 600;
                        margin-right: 12px;
                    }

                    .el-tag {
                        margin-left: auto;
                    }
                }

                .phone {
                    color: #666;
                    font-size: 14px;
                    margin-bottom: 8px;
                }

                .address-detail {
                    color: #666;
                    font-size: 14px;
                    /* 适当放大字号 */
                    line-height: 1.4;
                    /* 调小行高 */
                    height: 2.8em;
                    /* 行高1.4 × 2行 = 2.8em */
                    overflow: hidden;
                    display: -webkit-box;
                    -webkit-line-clamp: 2;
                    line-clamp: 2;
                    -webkit-box-orient: vertical;
                    margin-top: 8px;
                    /* 增加与上方元素的间距 */
                }
            }

            .select-indicator {
                position: absolute;
                bottom: 12px;
                right: 12px;

                .check-icon {
                    color: #22A356;
                    font-size: 20px;
                }
            }
        }

        .add-card {
            flex: 0 0 300px;
            height: 160px;
            border: 2px dashed #e4e7ed;
            border-radius: 12px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
            background: rgba(245, 245, 245, 0.5);

            &:hover {
                border-color: #22A356;
                background: rgba(34, 163, 86, 0.05);

                .plus-icon,
                .add-text {
                    color: #22A356;
                }
            }

            .plus-icon {
                font-size: 32px;
                color: #999;
                margin-bottom: 12px;
                transition: all 0.2s;
            }

            .add-text {
                color: #666;
                font-size: 14px;
                font-weight: 500;
                transition: all 0.2s;
            }
        }
    }

    .remark-section {
        margin: 25px 0;

        .fee-notice {
            color: #409EFF;
            font-size: 13px;
            display: flex;
            align-items: center;

            .el-icon {
                margin-right: 6px;
            }
        }

        .remark-container {
            border-radius: 8px;
            padding: 15px;

            .remark-input {
                :deep(.el-textarea__inner) {
                    font-size: 14px;
                    line-height: 1.5;
                    padding: 12px;
                }
            }
        }
    }

    .goods-section {
        .goods-list {
            border-top: 1px solid #eee;
        }

        .goods-item {
            display: flex;
            align-items: center;
            padding: 20px 0;
            border-bottom: 1px solid #eee;

            .goods-image {
                width: 80px;
                height: 80px;
                border-radius: 8px;
                margin-right: 20px;
            }

            .goods-info {
                flex: 1;
                margin-right: 20px;

                .name {
                    font-size: 15px;
                    color: #333;
                    margin-bottom: 6px;
                    font-weight: 500;
                }

                .spec {
                    color: #999;
                    font-size: 13px;
                }
            }

            .goods-right {
                width: 240px;
                display: flex;
                justify-content: space-between;
                align-items: center;

                .price {
                    color: #666;
                    width: 80px;
                }

                .quantity {
                    width: 60px;
                    text-align: center;
                    color: #666;
                }

                .subtotal {
                    color: #ff4d4f;
                    font-weight: 600;
                    width: 100px;
                    text-align: right;
                }
            }
        }
    }

    .sticky-footer {
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        margin: 0 24px 20px;
        background: white;
        padding: 16px 32px;
        box-shadow: 0 -4px 24px rgba(0, 0, 0, 0.08);
        z-index: 1000;
        border-radius: 16px;

        .footer-content {
            display: flex;
            justify-content: space-between;
            align-items: center;

           

            .payment-method {
                flex: 1;
                display: flex;
                align-items: center;

                .label {
                    color: #666;
                    margin-right: 15px;
                    white-space: nowrap;
                }

                :deep(.el-radio-group) {
                    .el-radio {
                        margin-right: 30px;
                    }
                }
            }

            .total-amount {
                font-size: 16px;
                margin: 0 40px;
                white-space: nowrap;

                .fee-item {
                    font-size: 13px;
                    color: #606266;
                    line-height: 1.8;

                    &:last-child {
                        color: #666666;
                    }
                }

                .price {
                    color: #ff4d4f;
                    font-size: 24px;
                    font-weight: 700;
                }
            }

            .submit-btn {
                height: 48px;
                padding: 0 40px;
                border-radius: 24px;
                font-size: 16px;
                background: #22A356;
                border: none;
                transition: all 0.2s;

                &:hover {
                    opacity: 0.9;
                    transform: translateY(-1px);
                }
            }
        }
    }

    .full-width {
        width: 100%;
    }
}

@media (max-width: 768px) {
    .order-container {
        padding: 15px 15px 100px;

        .main-card {
            :deep(.el-card__body) {
                padding: 20px;
            }
        }

        .sticky-footer {
            padding: 12px 15px;

            .footer-content {
                flex-wrap: wrap;
                gap: 10px;

                .payment-method {
                    order: 1;
                    width: 100%;
                    margin-bottom: 10px;
                }

                .total-amount {
                    order: 2;
                    margin: 0;
                }

                .submit-btn {
                    order: 3;
                    width: 100%;
                }
            }
        }
    }
}
</style>