# Community Fresh Delivery System

## Project Introduction

Community Fresh Delivery System is an online fresh produce shopping platform based on a separated front-end and back-end architecture. It aims to provide convenient fresh produce purchasing services for community residents. The system integrates core functions such as product browsing, shopping cart management, order processing, payment settlement, and logistics tracking.

## Technology Stack

### Back-end Technology
| Technology | Version | Description |
| :--- | :--- | :--- |
| Java | 17 | Programming Language |
| Spring Boot | 3.x | Back-end Framework |
| MyBatis-Plus | 3.x | ORM Framework |
| MySQL | 8.0 | Relational Database |
| Redis | 6.x | Cache Database |
| JWT | - | Authentication |

### Front-end Technology
| Technology | Version | Description |
| :--- | :--- | :--- |
| Node.js | 18+ | Runtime Environment |
| Vue | 3.x | Front-end Framework |
| Vite | 5.x | Build Tool |
| Element Plus | 2.x | UI Component Library |
| Pinia | 2.x | State Management |
| Axios | - | HTTP Client |

## Function Modules

### User-side Features
- **Product Browsing**: Browse product categories, product lists, product details
- **Shopping Cart**: Add products to cart, modify quantity, delete products
- **Order Management**: Create orders, view order list, order details
- **Payment Settlement**: Online payment support, view payment results
- **Shipping Address**: Manage shipping addresses (add, modify, delete)
- **Personal Center**: View user information, change password

### Admin-side Features
- **Product Management**: CRUD operations for products, inventory management
- **Category Management**: CRUD operations for categories
- **Order Management**: View order list, manage order status
- **User Management**: View user information, manage user status
- **After-sales Management**: Handle after-sales applications, update status
- **Logistics Management**: Enter logistics information, track logistics
- **Slideshow Management**: CRUD operations for slideshows
- **Recommendation Configuration**: Configure product recommendation rules
- **Login Log**: View admin login records

## Project Structure

```
fresh-mall-master/
├── fresh-system-project（back-end-code）/    # Back-end Code
│   ├── src/main/java/com/orion/
│   │   ├── controller/           # REST API Controllers
│   │   ├── service/              # Business Logic Layer
│   │   ├── mapper/               # Data Access Layer
│   │   ├── pojo/                 # Entity Classes
│   │   ├── config/               # Configuration Classes
│   │   ├── interceptors/         # Interceptors
│   │   ├── exceptions/           # Exception Handling
│   │   └── utils/                # Utility Classes
│   ├── src/main/resources/
│   │   ├── mapper/               # MyBatis Mapper Files
│   │   ├── application.yaml      # Application Configuration
│   │   └── fresh_system.sql      # Database Script
│   └── pom.xml                   # Maven Configuration
├── fresh-system-project（front-end-code）/   # Front-end Code
│   ├── src/
│   │   ├── views/                # Page Components
│   │   ├── api/                  # API Interfaces
│   │   ├── stores/               # Pinia State Management
│   │   ├── routers/              # Router Configuration
│   │   ├── utils/                # Utility Functions
│   │   └── assets/               # Static Resources
│   ├── index.html
│   ├── package.json
│   └── vite.config.js
└── README.md
```

## Environment Requirements

- **Operating System**: Windows 10+ / Linux / macOS
- **JDK**: 17 or higher
- **Node.js**: 18 or higher
- **MySQL**: 8.0 or higher
- **Redis**: 6.0 or higher

## Quick Start

### 1. Environment Preparation

```bash
# Ensure JDK 17+, Node.js 18+, MySQL 8.0+, Redis 6.0+ are installed
```

### 2. Database Configuration

```sql
-- Create database
CREATE DATABASE fresh_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Import database script
-- Execute fresh-system-project（back-end-code）/src/main/resources/fresh_system.sql
```

### 3. Start Back-end

```bash
cd fresh-system-project（back-end-code）

# Build with Maven
mvn clean package -DskipTests

# Run the project
java -jar target/fresh-system-project-1.0.0.jar
```

### 4. Start Front-end

```bash
cd fresh-system-project（front-end-code）

# Install dependencies
npm install

# Run in development mode
npm run dev

# Build for production
npm run build
```

## Access Addresses

| Module | Address |
| :--- | :--- |
| Front-end Home | http://localhost:5173 |
| Back-end API | http://localhost:8080 |
| Admin Login | http://localhost:5173/#/admin/login |

## Configuration

### Back-end Configuration

Modify `src/main/resources/application.yaml`:

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

### Environment Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| TENCENT_COS_SECRET_ID | Tencent Cloud COS Secret ID | - |
| TENCENT_COS_SECRET_KEY | Tencent Cloud COS Secret Key | - |
| TENCENT_COS_BUCKET_NAME | Tencent Cloud COS Bucket Name | - |

## API Interfaces

### User Module
| Interface | Method | Description |
| :--- | :--- | :--- |
| `/api/user/register` | POST | User registration |
| `/api/user/login` | POST | User login |
| `/api/user/info` | GET | Get user info |
| `/api/user/logout` | POST | User logout |

### Product Module
| Interface | Method | Description |
| :--- | :--- | :--- |
| `/api/fresh/list` | GET | Get product list |
| `/api/fresh/{id}` | GET | Get product detail |

### Order Module
| Interface | Method | Description |
| :--- | :--- | :--- |
| `/api/order/create` | POST | Create order |
| `/api/order/list` | GET | Get order list |
| `/api/order/{id}` | GET | Get order detail |

### Cart Module
| Interface | Method | Description |
| :--- | :--- | :--- |
| `/api/cart/add` | POST | Add product to cart |
| `/api/cart/list` | GET | Get cart list |
| `/api/cart/update` | PUT | Update cart quantity |
| `/api/cart/delete` | DELETE | Delete cart item |

## License

MIT License

## Contact

For questions or suggestions, please submit an Issue or contact the developer.