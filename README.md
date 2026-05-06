# 社区生鲜配送系统

## 项目简介

社区生鲜配送系统是一个基于前后端分离架构的在线生鲜购物平台，旨在为社区居民提供便捷的生鲜商品购买服务。系统集成了商品浏览、购物车管理、订单处理、支付结算、物流追踪等核心功能。

## 技术栈

### 后端技术
| 技术 | 版本 | 描述 |
| :--- | :--- | :--- |
| Java | 17 | 编程语言 |
| Spring Boot | 3.x | 后端框架 |
| MyBatis-Plus | 3.x | ORM框架 |
| MySQL | 8.0 | 关系型数据库 |
| Redis | 6.x | 缓存数据库 |
| JWT | - | 身份认证 |

### 前端技术
| 技术 | 版本 | 描述 |
| :--- | :--- | :--- |
| Node.js | 18+ | 运行环境 |
| Vue | 3.x | 前端框架 |
| Vite | 5.x | 构建工具 |
| Element Plus | 2.x | UI组件库 |
| Pinia | 2.x | 状态管理 |
| Axios | - | HTTP客户端 |

## 功能模块

### 普通用户端功能
- **商品浏览**：浏览生鲜商品分类、商品列表、商品详情
- **购物车**：添加商品到购物车、修改数量、删除商品
- **订单管理**：创建订单、查看订单列表、订单详情
- **支付结算**：支持在线支付、查看支付结果
- **收货地址**：管理收货地址（添加、修改、删除）
- **个人中心**：用户信息查看、密码修改

### 管理员端功能
- **商品管理**：商品的增删改查、库存管理
- **分类管理**：商品分类的增删改查
- **订单管理**：订单列表查看、订单状态管理
- **用户管理**：用户信息查看、用户状态管理
- **售后管理**：售后申请处理、售后状态更新
- **物流管理**：物流信息录入、物流追踪
- **轮播图管理**：轮播图的增删改查
- **推荐配置**：商品推荐规则配置
- **登录日志**：管理员登录记录查看

## 项目结构

```
fresh-mall-master/
├── fresh-system-project（back-end-code）/    # 后端代码
│   ├── src/main/java/com/orion/
│   │   ├── controller/           # REST API控制层
│   │   ├── service/              # 业务逻辑层
│   │   ├── mapper/               # 数据访问层
│   │   ├── pojo/                 # 实体类
│   │   ├── config/               # 配置类
│   │   ├── interceptors/         # 拦截器
│   │   ├── exceptions/           # 异常处理
│   │   └── utils/                # 工具类
│   ├── src/main/resources/
│   │   ├── mapper/               # MyBatis映射文件
│   │   ├── application.yaml      # 应用配置
│   │   └── fresh_system.sql      # 数据库脚本
│   └── pom.xml                   # Maven配置
├── fresh-system-project（front-end-code）/   # 前端代码
│   ├── src/
│   │   ├── views/                # 页面组件
│   │   ├── api/                  # API接口
│   │   ├── stores/               # Pinia状态管理
│   │   ├── routers/              # 路由配置
│   │   ├── utils/                # 工具函数
│   │   └── assets/               # 静态资源
│   ├── index.html
│   ├── package.json
│   └── vite.config.js
└── README.md
```

## 环境要求

- **操作系统**：Windows 10+ / Linux / macOS
- **JDK**：17 或更高版本
- **Node.js**：18 或更高版本
- **MySQL**：8.0 或更高版本
- **Redis**：6.0 或更高版本

## 快速开始

### 1. 环境准备

```bash
# 确保已安装 JDK 17+、Node.js 18+、MySQL 8.0+、Redis 6.0+
```

### 2. 数据库配置

```sql
-- 创建数据库
CREATE DATABASE fresh_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 导入数据库脚本
-- 执行 fresh-system-project（back-end-code）/src/main/resources/fresh_system.sql
```

### 3. 后端启动

```bash
cd fresh-system-project（back-end-code）

# 使用 Maven 构建
mvn clean package -DskipTests

# 运行项目
java -jar target/fresh-system-project-1.0.0.jar
```

### 4. 前端启动

```bash
cd fresh-system-project（front-end-code）

# 安装依赖
npm install

# 开发模式运行
npm run dev

# 生产构建
npm run build
```

## 访问地址

| 模块 | 地址 |
| :--- | :--- |
| 前端首页 | http://localhost:5173 |
| 后端API | http://localhost:8080 |
| 管理员登录 | http://localhost:5173/#/admin/login |

## 配置说明

### 后端配置

修改 `src/main/resources/application.yaml`：

```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/fresh_system
    username: root
    password: your_password
  redis:
    host: localhost
    port: 6379
```

### 环境变量

| 变量名 | 说明 | 默认值 |
| :--- | :--- | :--- |
| TENCENT_COS_SECRET_ID | 腾讯云COS Secret ID | - |
| TENCENT_COS_SECRET_KEY | 腾讯云COS Secret Key | - |
| TENCENT_COS_BUCKET_NAME | 腾讯云COS存储桶名称 | - |

## API接口

### 用户模块
| 接口 | 方法 | 描述 |
| :--- | :--- | :--- |
| `/api/user/register` | POST | 用户注册 |
| `/api/user/login` | POST | 用户登录 |
| `/api/user/info` | GET | 获取用户信息 |
| `/api/user/logout` | POST | 用户退出 |

### 商品模块
| 接口 | 方法 | 描述 |
| :--- | :--- | :--- |
| `/api/fresh/list` | GET | 获取商品列表 |
| `/api/fresh/{id}` | GET | 获取商品详情 |

### 订单模块
| 接口 | 方法 | 描述 |
| :--- | :--- | :--- |
| `/api/order/create` | POST | 创建订单 |
| `/api/order/list` | GET | 获取订单列表 |
| `/api/order/{id}` | GET | 获取订单详情 |

### 购物车模块
| 接口 | 方法 | 描述 |
| :--- | :--- | :--- |
| `/api/cart/add` | POST | 添加商品到购物车 |
| `/api/cart/list` | GET | 获取购物车列表 |
| `/api/cart/update` | PUT | 更新购物车数量 |
| `/api/cart/delete` | DELETE | 删除购物车商品 |

## 许可证

MIT License

## 联系方式

如有问题或建议，请提交 Issue 或联系开发者。