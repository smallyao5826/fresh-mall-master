/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80032
 Source Host           : localhost:3306
 Source Schema         : fresh_system

 Target Server Type    : MySQL
 Target Server Version : 80032
 File Encoding         : 65001

 Date: 04/04/2025 18:08:03
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for address
-- ----------------------------
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address`  (
  `id` int(0) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` int(0) NOT NULL COMMENT '所属用户ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收货人姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系电话',
  `province` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '省份',
  `city` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '城市',
  `district` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '区县',
  `detailed_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '详细地址',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建日期',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新日期',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态）',
  `is_default` tinyint(1) NULL DEFAULT 0 COMMENT '是否默认地址（0否，1是）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `address_ibfk_1`(`user_id`) USING BTREE,
  CONSTRAINT `address_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '收货地址表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of address
-- ----------------------------
INSERT INTO `address` VALUES (1, 1, '陈尧', '15260883342', '福建省', '莆田市', '城厢区', '莆田学院', '2025-04-01 21:33:37', '2025-04-01 21:33:37', b'0', 1);

-- ----------------------------
-- Table structure for after_sales
-- ----------------------------
DROP TABLE IF EXISTS `after_sales`;
CREATE TABLE `after_sales`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `order_id` int(0) NOT NULL COMMENT '关联订单ID',
  `user_id` int(0) NOT NULL COMMENT '用户ID',
  `service_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '售后类型（退款/退货退款/换货）',
  `apply_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '申请原因',
  `status` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '待审核' COMMENT '状态（待处理/已通过/已拒绝）',
  `process_result` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处理结果',
  `process_comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处理备注',
  `apply_time` datetime(0) NOT NULL COMMENT '申请时间',
  `process_time` datetime(0) NULL DEFAULT NULL COMMENT '处理时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '生鲜订单售后表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of after_sales
-- ----------------------------
INSERT INTO `after_sales` VALUES (1, 13, 1, '退款', '123131231去24124124214', '已处理', '已通过', '好', '2025-04-03 16:41:13', '2025-04-03 22:08:50');

-- ----------------------------
-- Table structure for cart
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart`  (
  `user_id` int(0) NOT NULL COMMENT '普通用户ID',
  `fresh_id` int(0) NOT NULL,
  `count` int(0) NULL DEFAULT NULL COMMENT '购买数量',
  `version` int(0) NULL DEFAULT 1 COMMENT '版本号（乐观锁）',
  PRIMARY KEY (`user_id`, `fresh_id`) USING BTREE,
  INDEX `cart_ibfk_2`(`fresh_id`) USING BTREE,
  CONSTRAINT `cart_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_cart_fresh` FOREIGN KEY (`fresh_id`) REFERENCES `fresh` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户与生鲜产生的购物车关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cart
-- ----------------------------

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` int(0) NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `category_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类名称',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建日期',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新日期',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态)\r\n',
  UNIQUE INDEX `uk_category_name`(`category_name`) USING BTREE,
  INDEX `id`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '生鲜分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, '蔬菜', '2024-12-08 03:00:59', '2024-12-08 03:00:59', b'0');
INSERT INTO `category` VALUES (2, '水果', '2024-12-08 03:00:41', '2024-12-08 03:00:41', b'0');
INSERT INTO `category` VALUES (3, '肉类', '2024-12-08 03:00:49', '2024-12-08 03:00:49', b'0');
INSERT INTO `category` VALUES (4, '海鲜', '2024-12-08 03:01:08', '2024-12-08 03:01:08', b'0');
INSERT INTO `category` VALUES (5, '冻品', '2025-03-29 20:47:42', '2025-03-29 20:47:46', b'0');
INSERT INTO `category` VALUES (6, '杂粮', '2025-03-29 20:47:42', '2025-03-29 20:47:46', b'0');
INSERT INTO `category` VALUES (7, '油类', '2025-03-29 20:47:42', '2025-03-29 20:47:46', b'0');
INSERT INTO `category` VALUES (8, '坚果', '2025-03-29 20:47:42', '2025-03-29 20:47:46', b'0');

-- ----------------------------
-- Table structure for fresh
-- ----------------------------
DROP TABLE IF EXISTS `fresh`;
CREATE TABLE `fresh`  (
  `id` int(0) NOT NULL AUTO_INCREMENT COMMENT '生鲜商品ID',
  `fresh_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '生鲜名称',
  `feature` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '特色',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '描述',
  `specification` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品规格',
  `picture_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生鲜图片URL',
  `prices` decimal(10, 2) NOT NULL,
  `promotion_price` decimal(10, 2) NULL DEFAULT NULL,
  `repertory` int(0) UNSIGNED NULL DEFAULT 100,
  `sum_repertory` int(0) UNSIGNED NULL DEFAULT 100,
  `is_recommend` bit(1) NULL DEFAULT b'0' COMMENT '是否推荐（0不推荐，1推荐）',
  `category_id` int(0) NULL DEFAULT NULL,
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建日期',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新日期',
  `is_deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '逻辑删除',
  `version` int(0) UNSIGNED NULL DEFAULT 1 COMMENT '版本号（乐观锁）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fresh_ibfk_2`(`category_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1156 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '生鲜商品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fresh
-- ----------------------------
INSERT INTO `fresh` VALUES (1001, '上海青', '新鲜,绿叶', '上海青，叶片肥厚脆嫩，适合清炒或煮汤', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E4%B8%8A%E6%B5%B7%E9%9D%92.jpg', 5.50, 4.80, 47, 959, b'1', 1, '2025-03-29 20:11:20', '2025-04-01 01:09:13', b'0', 11);
INSERT INTO `fresh` VALUES (1002, '丝瓜', '清热,美容', '丝瓜口感清甜，适合丝瓜炒蛋或丝瓜汤', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E4%B8%9D%E7%93%9C.jpg', 6.80, NULL, 64, 650, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 2);
INSERT INTO `fresh` VALUES (1003, '土豆', '粉糯,饱腹', '黄心土豆，适合炖煮或制作土豆泥', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E5%9C%9F%E8%B1%86.jpg', 3.20, 2.90, 73, 850, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 13);
INSERT INTO `fresh` VALUES (1004, '圣女果', '甜脆,维C', '迷你番茄，酸甜多汁，适合沙拉生食', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E5%9C%A3%E5%A5%B3%E6%9E%9C.jpg', 9.90, 8.80, 26, 380, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 13);
INSERT INTO `fresh` VALUES (1005, '塔菜', '脆嫩,清香', '塔菜口感独特，适合清炒或涮火锅', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E5%A1%94%E8%8F%9C.jpg', 7.60, NULL, 41, 420, b'0', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 2);
INSERT INTO `fresh` VALUES (1006, '天津白', '爽脆,耐煮', '天津白菜帮薄叶厚，适合炖煮或腌制', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E5%A4%A9%E6%B4%A5%E7%99%BD.jpg', 4.50, 3.90, 57, 570, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1007, '娃娃菜', '鲜甜,迷你', '迷你型大白菜，适合蒜蓉娃娃菜', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E5%A8%83%E5%A8%83%E8%8F%9C.jpg', 6.20, 5.50, 52, 630, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 12);
INSERT INTO `fresh` VALUES (1008, '子姜', '辛辣,去腥', '嫩姜适合腌制，可做寿司姜片', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E5%AD%90%E5%A7%9C.jpg', 8.80, NULL, 28, 350, b'0', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 8);
INSERT INTO `fresh` VALUES (1009, '樱桃萝卜', '脆甜,红皮', '樱桃萝卜色泽鲜艳，适合凉拌摆盘', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E6%A8%B1%E6%A1%83%E8%90%9D%E5%8D%9C.jpg', 4.90, NULL, 71, 780, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 8);
INSERT INTO `fresh` VALUES (1010, '油菜', '鲜嫩,快熟', '小油菜质地柔嫩，适合蚝油油菜', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E6%B2%B9%E8%8F%9C.jpg', 3.80, 3.20, 81, 920, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 12);
INSERT INTO `fresh` VALUES (1011, '洋葱', '辛香,紫皮', '紫皮洋葱，适合炒制或沙拉调味', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E6%B4%8B%E8%91%B1.jpg', 2.90, NULL, 108, 1080, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1012, '玉米粒', '甜糯,速冻', '速冻甜玉米粒，方便烹饪配菜', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E7%8E%89%E7%B1%B3%E7%B2%92.jpg', 12.80, 11.90, 45, 450, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1014, '甜豆角', '无筋,清甜', '无筋豆角色泽翠绿，适合干煸', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E7%94%9C%E8%B1%86%E8%A7%92.jpg', 7.20, 6.50, 53, 530, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1015, '生花生', '带壳,鲜香', '新鲜带壳花生，适合盐水煮制', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E7%94%9F%E8%8A%B1%E7%94%9F.jpg', 6.50, NULL, 72, 720, b'0', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1016, '生菜', '脆生,球状', '球生菜叶片爽脆，适合沙拉汉堡', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E7%94%9F%E8%8F%9C.jpg', 4.20, 3.80, 95, 950, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1017, '笋', '冬笋,鲜嫩', '冬笋肉质细嫩，适合油焖或炖汤', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E7%AC%8B.jpg', 15.80, 14.90, 28, 280, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1018, '紫玉米', '花青素,糯', '紫玉米富含花青素，蒸煮食用', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E7%B4%AB%E7%8E%89%E7%B1%B3.jpg', 9.90, 8.80, 37, 370, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1019, '玉米', '杂粮,养生', '玉米颗粒饱满，适合煮粥甜品', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E7%8E%89%E7%B1%B3.jpg', 9.80, NULL, 42, 420, b'0', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1020, '紫薯', '低脂,甜糯', '紫薯富含膳食纤维，蒸烤皆宜', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E7%B4%AB%E8%96%AF.jpg', 6.80, 5.90, 68, 680, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1021, '芋头', '荔浦,粉糯', '荔浦芋头芋香浓郁，适合蒸煮甜品', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E8%8A%8B%E5%A4%B4.jpg', 7.50, 6.80, 58, 580, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1022, '芋子', '小芋艿,滑', '小芋艿口感滑糯，适合红烧葱油', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E8%8A%8B%E5%AD%90.jpg', 5.90, NULL, 47, 470, b'0', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1023, '茼蒿', '药香,涮锅', '茼蒿独特香气，适合火锅烫食', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E8%8C%BC%E8%92%BF.jpg', 8.20, 7.50, 39, 390, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1024, '莴笋', '青翠,削皮', '莴笋去皮后脆嫩，适合清炒凉拌', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E8%8E%B4%E7%AC%8B.jpg', 5.50, 4.90, 64, 640, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1025, '蒜笋', '嫩茎,香脆', '蒜苗嫩茎，适合炒腊肉或回锅肉', '500g', '	https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E8%92%9C%E8%96%B9.jpg', 7.80, NULL, 52, 520, b'0', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1026, '蒜粒', '独蒜,调味', '独头蒜味道浓郁，适合调味爆香', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E8%92%9C%E7%B2%92.jpg', 3.20, NULL, 112, 1120, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1027, '蒜苔', '脆嫩,时令', '新鲜蒜苔，适合蒜苔炒肉或腌制', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E8%92%9C%E8%8B%94.jpg', 9.50, 8.80, 43, 430, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1028, '蒜苗', '青蒜,提味', '青蒜苗去腥提鲜，适合炒回锅肉', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E8%92%9C%E8%8B%97.jpg', 4.80, NULL, 77, 770, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1029, '西兰花', '抗癌,紧实', '西兰花紧实新鲜，适合白灼蒜蓉', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E8%A5%BF%E5%85%B0%E8%8A%B1.jpg', 8.80, 7.90, 54, 540, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1030, '西红柿', '沙瓤,多汁', '沙瓤西红柿，适合糖拌或炒蛋', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E8%A5%BF%E7%BA%A2%E6%9F%BF.jpg', 4.50, 3.90, 89, 890, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1031, '西芹', '爽脆,西餐', '西芹茎干粗壮，适合榨汁或沙拉', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E8%A5%BF%E8%8A%B9.jpg', 5.20, 4.50, 61, 610, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1032, '豌豆', '甜豆,配菜', '甜豌豆颗粒饱满，适合炒饭配菜', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E8%B1%8C%E8%B1%86.jpg', 6.80, NULL, 46, 460, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1033, '长豆角', '豇豆,炖煮', '长豇豆适合干煸或制作酸豆角', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E9%95%BF%E8%B1%86%E8%A7%92.jpg', 5.90, 5.20, 66, 660, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1034, '紫甘蓝', '紫色,沙拉', '紫甘蓝富含花青素，适合凉拌沙拉', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/vegetable/%E7%B4%AB%E7%94%98%E8%93%9D.jpg', 7.20, 6.50, 34, 340, b'1', 1, '2025-03-29 20:11:20', '2025-03-29 20:11:20', b'0', 1);
INSERT INTO `fresh` VALUES (1035, '冬枣', '脆甜,维C', '冬枣皮薄肉脆，含丰富维生素C', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E5%86%AC%E6%9E%A3.jpg', 12.80, 11.90, 88, 880, b'1', 2, '2025-03-29 20:33:22', '2025-03-29 20:33:22', b'0', 1);
INSERT INTO `fresh` VALUES (1036, '凤梨', '去刺,甜心', '台湾金钻凤梨，免挖眼不塞牙', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E5%87%A4%E6%A2%A8.jpg', 15.90, 14.50, 65, 650, b'1', 2, '2025-03-29 20:33:22', '2025-03-29 20:33:22', b'0', 1);
INSERT INTO `fresh` VALUES (1037, '小米蕉', '迷你,软糯', '海南小米蕉果肉细腻，甜度高', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E5%B0%8F%E7%B1%B3%E8%95%89.jpg', 9.90, 8.80, 92, 920, b'1', 2, '2025-03-29 20:33:22', '2025-03-29 20:33:22', b'0', 1);
INSERT INTO `fresh` VALUES (1038, '山楂', '开胃,果丹皮', '铁山楂果肉厚实，适合制作糖葫芦', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E5%B1%B1%E6%A5%82.jpg', 6.50, 5.90, 115, 1150, b'0', 2, '2025-03-29 20:33:23', '2025-03-29 20:33:23', b'0', 1);
INSERT INTO `fresh` VALUES (1039, '帝皇蕉', '帝王蕉,甜', '泰国产帝王蕉，果皮薄甜度高', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E5%B8%9D%E7%9A%87%E8%95%89.jpg', 19.90, NULL, 45, 450, b'1', 2, '2025-03-29 20:33:23', '2025-03-29 20:33:23', b'0', 1);
INSERT INTO `fresh` VALUES (1040, '早酥梨', '酥脆,多汁', '早酥梨皮薄核小，汁水充盈', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E6%97%A9%E9%85%A5%E6%A2%A8.png', 7.80, 6.90, 78, 780, b'1', 2, '2025-03-29 20:33:24', '2025-03-29 20:33:24', b'0', 1);
INSERT INTO `fresh` VALUES (1041, '木瓜', '青皮,丰胸', '海南青木瓜，适合炖煮甜品', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E6%9C%A8%E7%93%9C.jpg', 8.50, 7.20, 62, 620, b'0', 2, '2025-03-29 20:33:24', '2025-03-29 20:33:24', b'0', 1);
INSERT INTO `fresh` VALUES (1042, '李子', '红心,脆甜', '脆红李酸甜适中，果肉鲜红', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E6%9D%8E%E5%AD%90.jpg', 6.90, 5.90, 85, 850, b'1', 2, '2025-03-29 20:33:25', '2025-03-29 20:33:25', b'0', 1);
INSERT INTO `fresh` VALUES (1043, '柑橘', '蜜桔,无籽', '温州蜜柑皮薄无籽，果肉细腻', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E6%9F%91%E6%A9%98.jpg', 5.20, 4.50, 105, 1050, b'1', 2, '2025-03-29 20:33:25', '2025-03-29 20:33:25', b'0', 1);
INSERT INTO `fresh` VALUES (1044, '梨', '雪梨,润肺', '河北雪梨果肉洁白，润肺止咳', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E6%A2%A8.jpg', 6.80, 5.90, 95, 950, b'1', 2, '2025-03-29 20:33:26', '2025-03-29 20:33:26', b'0', 1);
INSERT INTO `fresh` VALUES (1045, '椰子', '老椰,椰青', '海南老椰椰汁清甜，椰肉香浓', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E6%A4%B0%E5%AD%90.jpg', 12.80, 11.90, 38, 380, b'1', 2, '2025-03-29 20:33:27', '2025-03-29 20:33:27', b'0', 1);
INSERT INTO `fresh` VALUES (1046, '椰青', '现开,鲜甜', '泰国椰青现砍发货，汁水充沛', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E6%A4%B0%E9%9D%92.jpg', 9.90, 8.80, 42, 420, b'1', 2, '2025-03-29 20:33:27', '2025-03-29 20:33:27', b'0', 1);
INSERT INTO `fresh` VALUES (1047, '榴莲', '金枕,爆肉', '泰国金枕榴莲，果肉饱满香甜', '1.5-2kg', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E6%A6%B4%E8%8E%B2.jpg', 129.00, 119.00, 22, 220, b'1', 2, '2025-03-29 20:33:28', '2025-03-29 20:33:28', b'0', 1);
INSERT INTO `fresh` VALUES (1048, '樱桃', '车厘子,智利', '智利进口车厘子，果径32mm+', '250g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E6%A8%B1%E6%A1%83.jpg', 89.90, 79.90, 35, 350, b'1', 2, '2025-03-29 20:33:28', '2025-03-29 20:33:28', b'0', 1);
INSERT INTO `fresh` VALUES (1049, '橙子', '脐橙,甜橙', '赣南脐橙果肉细腻，汁水充沛', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E6%A9%99%E5%AD%90.jpg', 7.90, 6.90, 88, 880, b'1', 2, '2025-03-29 20:33:29', '2025-03-29 20:33:29', b'0', 1);
INSERT INTO `fresh` VALUES (1050, '油桃', '黄油桃,脆', '新疆黄油桃，果肉金黄脆甜', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E6%B2%B9%E6%A1%83.jpg', 12.80, 11.90, 58, 580, b'1', 2, '2025-03-29 20:33:29', '2025-03-29 20:33:29', b'0', 1);
INSERT INTO `fresh` VALUES (1051, '牛奶大青枣', '奶香,脆', '台湾牛奶枣，带有淡淡奶香味', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E7%89%9B%E5%A5%B6%E5%A4%A7%E9%9D%92%E6%9E%A3.jpg', 15.90, 14.50, 45, 450, b'1', 2, '2025-03-29 20:33:29', '2025-03-29 20:33:29', b'0', 1);
INSERT INTO `fresh` VALUES (1052, '猕猴桃', '翠香,甜心', '陕西翠香猕猴桃，果肉翡翠绿', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E7%8C%95%E7%8C%B4%E6%A1%83.jpg', 8.80, 7.90, 68, 680, b'1', 2, '2025-03-29 20:33:30', '2025-03-29 20:33:30', b'0', 1);
INSERT INTO `fresh` VALUES (1053, '甘蔗', '黑皮,现砍', '广西黑皮甘蔗，现砍发货保鲜', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E7%94%98%E8%94%97.jpg', 6.50, 5.90, 75, 750, b'0', 2, '2025-03-29 20:33:31', '2025-03-29 20:33:31', b'0', 1);
INSERT INTO `fresh` VALUES (1054, '白心火龙果', '越南,清甜', '越南白心火龙果，果肉爽滑', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E7%99%BD%E5%BF%83%E7%81%AB%E9%BE%99%E6%9E%9C.jpg', 7.90, 6.90, 62, 620, b'1', 2, '2025-03-29 20:33:31', '2025-03-29 20:33:31', b'0', 1);
INSERT INTO `fresh` VALUES (1055, '百香果', '紫皮,酸甜', '广西紫皮百香果，香气浓郁', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E7%99%BE%E9%A6%99%E6%9E%9C.jpg', 9.90, 8.80, 55, 550, b'1', 2, '2025-03-29 20:33:32', '2025-03-29 20:33:32', b'0', 1);
INSERT INTO `fresh` VALUES (1056, '红布林', '美国,黑布林', '进口红布李，果肉深红色泽', '4粒', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E7%BA%A2%E5%B8%83%E6%9E%97.jpg', 16.80, 15.90, 38, 380, b'1', 2, '2025-03-29 20:33:32', '2025-03-29 20:33:32', b'0', 1);
INSERT INTO `fresh` VALUES (1057, '红心火龙果', '自营,花青素', '自营红心火龙果，富含花青素', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E7%BA%A2%E5%BF%83%E7%81%AB%E9%BE%99%E6%9E%9C.jpg', 12.80, 11.90, 52, 520, b'1', 2, '2025-03-29 20:33:32', '2025-03-29 20:33:32', b'0', 1);
INSERT INTO `fresh` VALUES (1058, '红提', '无籽,脆甜', '美国红提葡萄，无籽即食', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E7%BA%A2%E6%8F%90.jpg', 19.90, 18.90, 45, 450, b'1', 2, '2025-03-29 20:33:33', '2025-03-29 20:33:33', b'0', 1);
INSERT INTO `fresh` VALUES (1059, '绿宝甜瓜', '网纹,蜜瓜', '山东绿宝甜瓜，果肉翡翠绿', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E7%BB%BF%E5%AE%9D%E7%94%9C%E7%93%9C.jpg', 8.80, 7.90, 65, 650, b'1', 2, '2025-03-29 20:33:33', '2025-03-29 20:33:33', b'0', 1);
INSERT INTO `fresh` VALUES (1060, '绿心猕猴桃', '徐香,多汁', '徐香猕猴桃，果肉翠绿多汁', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E7%BB%BF%E5%BF%83%E7%8C%95%E7%8C%B4%E6%A1%83.jpg', 9.90, 8.80, 58, 580, b'1', 2, '2025-03-29 20:33:34', '2025-03-29 20:33:34', b'0', 1);
INSERT INTO `fresh` VALUES (1061, '羊角蜜瓜', '脆甜,爆汁', '山东羊角蜜，瓜肉脆嫩多汁', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E7%BE%8A%E8%A7%92%E8%9C%9C%E7%93%9C.jpg', 7.50, 6.90, 72, 720, b'1', 2, '2025-03-29 20:33:34', '2025-03-29 20:33:34', b'0', 1);
INSERT INTO `fresh` VALUES (1062, '芒果', '大台农,香甜', '海南大台农芒果，果肉细腻', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E8%8A%92%E6%9E%9C.jpg', 10.90, 9.90, 68, 680, b'1', 2, '2025-03-29 20:33:34', '2025-03-29 20:33:34', b'0', 1);
INSERT INTO `fresh` VALUES (1063, '芭乐', '红心,软糯', '台湾红心芭乐，果肉粉红色', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E8%8A%AD%E4%B9%90.jpg', 8.80, 7.90, 52, 520, b'1', 2, '2025-03-29 20:33:34', '2025-03-29 20:33:34', b'0', 1);
INSERT INTO `fresh` VALUES (1064, '苹果', '红富士,脆甜', '烟台红富士，冰糖心苹果', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E8%8B%B9%E6%9E%9C.jpg', 6.90, 5.90, 95, 950, b'1', 2, '2025-03-29 20:33:36', '2025-03-29 20:33:36', b'0', 1);
INSERT INTO `fresh` VALUES (1065, '草莓', '丹东,牛奶', '丹东牛奶草莓，果香浓郁', '250g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E8%8D%89%E8%8E%93.jpg', 25.90, 23.90, 38, 380, b'1', 2, '2025-03-29 20:33:36', '2025-03-29 20:33:36', b'0', 1);
INSERT INTO `fresh` VALUES (1066, '菠萝', '金钻,不涩', '海南金钻菠萝，免泡盐水', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/fruit/%E8%8F%A0%E8%90%9D.jpg', 5.90, 4.90, 85, 850, b'1', 2, '2025-03-29 20:33:36', '2025-03-29 20:33:36', b'0', 1);
INSERT INTO `fresh` VALUES (1067, '五花肉', '三层肥瘦', '精选肥瘦相间五花肉', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E4%BA%94%E8%8A%B1%E8%82%89.jpg', 32.80, 29.90, 150, 300, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1068, '培根肉', '烟熏风味', '美式烟熏培根片', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E5%9F%B9%E6%A0%B9%E8%82%89.jpg', 25.50, NULL, 200, 500, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1069, '小鸡胸肉', '低脂高蛋白', '健身鸡胸肉250g装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E5%B0%8F%E9%B8%A1%E8%83%B8%E8%82%89.jpg', 18.90, 16.90, 300, 600, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1070, '新鲜生鸡', '现杀现发', '散养土鸡1.5kg/只', '1.5kg', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E6%96%B0%E9%B2%9C%E7%94%9F%E9%B8%A1.jpg', 68.00, NULL, 80, 150, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1071, '牛排', '澳洲谷饲', '西冷牛排200g装', '200g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%89%9B%E6%8E%92.jpg', 89.90, 79.90, 120, 200, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1072, '牛眼肉牛排', '雪花纹理', 'M3级眼肉牛排', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%89%9B%E7%9C%BC%E8%82%89%E7%89%9B%E6%8E%92.jpg', 128.00, 115.00, 90, 150, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1073, '牛肉块', '炖煮专用', '牛腩切块500g装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%89%9B%E8%82%89%E5%9D%97..jpg', 45.00, NULL, 180, 300, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1074, '牛肉馅', '肥瘦2:8', '手工现绞牛肉馅', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%89%9B%E8%82%89%E9%A6%85.jpg', 38.00, 34.90, 200, 400, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1075, '牛腩肉', '筋膜分明', '红烧牛腩专用', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%89%9B%E8%85%A9%E8%82%89.jpg', 62.00, 58.00, 150, 250, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1076, '牛舌', '厚切精品', '日式烧肉牛舌片', '200g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%89%9B%E8%88%8C.jpg', 95.00, NULL, 60, 100, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1077, '猪排骨', '肋排中段', '精选猪肋排500g', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%8C%AA%E6%8E%92%E9%AA%A8.jpg', 35.80, NULL, 200, 400, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1078, '猪肉', '前腿肉', '新鲜前腿肉1kg装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%8C%AA%E8%82%89.jpg', 28.50, NULL, 300, 600, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1079, '猪肉皮', '胶原蛋白', '炸猪皮原料', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%8C%AA%E8%82%89%E7%9A%AE.jpg', 12.80, 9.90, 150, 300, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1080, '猪肚', '处理干净', '爆炒猪肚原料', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%8C%AA%E8%82%9A.jpg', 42.00, NULL, 100, 200, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1081, '猪肝', '鲜嫩不腥', '补铁猪肝300g', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%8C%AA%E8%82%9D.jpg', 18.00, NULL, 120, 250, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1082, '猪脚', '前蹄筋多', '卤猪脚原料', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%8C%AA%E8%84%9A.jpg', 28.00, 25.90, 150, 300, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1083, '猪蹄', '后蹄肉厚', '美容养颜猪蹄', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%8C%AA%E8%B9%84.jpg', 32.00, NULL, 120, 200, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1084, '琵琶腿', '奥尔良风味', '鸡腿烤制专用', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%90%B5%E7%90%B6%E8%85%BF.jpg', 22.90, 19.90, 250, 500, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1085, '童子鸡', '整鸡烹制', '500g童子鸡', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%AB%A5%E5%AD%90%E9%B8%A1.jpg', 38.00, NULL, 80, 150, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1086, '羊后腿', '草原散养', '涮羊肉原料', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%BE%8A%E5%90%8E%E8%85%BF.jpg', 78.00, 72.00, 90, 180, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1087, '羊排', '法式切段', '烤羊排原料', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%BE%8A%E6%8E%92.jpg', 95.00, 88.00, 70, 150, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1088, '羊排骨', '红焖专用', '带肉羊排骨', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%BE%8A%E6%8E%92%E9%AA%A8.jpg', 65.00, NULL, 100, 200, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1089, '羊肉', '后腿肉片', '涮火锅薄切', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%BE%8A%E8%82%89.jpg', 68.00, NULL, 150, 300, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1090, '羊腿肉', '新疆风味', '串烤羊肉块', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E7%BE%8A%E8%85%BF%E8%82%89.jpg', 72.00, 68.00, 110, 220, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1091, '鸡中翅', '可乐鸡翅', '家庭装10只', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E9%B8%A1%E4%B8%AD%E7%BF%85.jpg', 39.90, 35.90, 180, 350, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1092, '鸡大腿', '去骨留皮', '照烧鸡腿饭原料', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E9%B8%A1%E5%A4%A7%E8%85%BF.jpg', 26.00, NULL, 200, 400, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1093, '鸡爪', '虎皮原料', '卤鸡爪专用', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E9%B8%A1%E7%88%AA.jpg', 24.90, 21.90, 150, 300, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1094, '鸡翅根', '奥尔良腌料', '烤箱即食', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E9%B8%A1%E7%BF%85%E6%A0%B9.jpg', 20.00, 17.90, 220, 450, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1095, '鸡胗', '爆炒脆嫩', '清洗处理干净', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E9%B8%A1%E8%83%97.jpg', 32.00, NULL, 120, 250, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1096, '鸡胸肉', '健身优选', '真空分装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E9%B8%A1%E8%83%B8%E8%82%89.jpg', 16.90, 14.90, 350, 700, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1097, '鸡腿肉', '去皮去骨', '健身餐食材', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E9%B8%A1%E8%85%BF%E8%82%89.jpg', 28.00, NULL, 180, 350, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1098, '鸡蛋', '土鸡蛋', '30枚礼盒装', '30枚', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E9%B8%A1%E8%9B%8B.jpg', 32.90, 29.90, 500, 1000, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1099, '鸭爪', '卤味原料', '筋道有嚼劲', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E9%B8%AD%E7%88%AA.jpg', 28.00, NULL, 100, 200, b'0', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1100, '鹌鹑蛋', '火锅搭档', '即食卤蛋30枚', '30枚', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E9%B9%8C%E9%B9%91%E8%9B%8B.jpg', 15.90, 12.90, 300, 600, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1101, '黑土猪肉', '生态养殖', '散养黑猪肉', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/meat/%E9%BB%91%E5%9C%9F%E7%8C%AA%E8%82%89.jpg', 49.90, 45.90, 120, 250, b'1', 3, '2025-03-30 18:00:41', '2025-03-30 18:00:41', b'0', 1);
INSERT INTO `fresh` VALUES (1102, '三文鱼', '挪威进口', '刺身级三文鱼中段500g', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E4%B8%89%E6%96%87%E9%B1%BC.jpg', 98.00, 88.00, 80, 150, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1103, '三牙鱼', '南海野生', '清蒸佳品400-500g/条', '400-500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E4%B8%89%E7%89%99%E9%B1%BC.jpg', 45.00, NULL, 120, 250, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1104, '厄瓜多尔白虾', '盐冻大虾', '30-40规格1kg装', '30-40只', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E5%8E%84%E7%93%9C%E5%A4%9A%E5%B0%94%E7%99%BD%E8%99%BE.jpg', 89.00, 79.00, 150, 300, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1105, '基围虾', '活冻技术', '鲜活急冻20-30只/盒', '20-30只', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E5%9F%BA%E5%9B%B4%E8%99%BE.jpg', 75.00, 68.00, 200, 400, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1106, '墨鱼', '深海捕捞', '500g/只 带墨囊', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E5%A2%A8%E9%B1%BC.jpg', 38.00, NULL, 90, 180, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1107, '墨鱼仔', '弹嫩爽口', '3-5cm规格 500g装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E5%A2%A8%E9%B1%BC%E4%BB%94.jpg', 42.00, 36.00, 150, 300, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1108, '多宝鱼', '鲜活宰杀', '600-800g/条 清蒸专用', '600-800g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E5%A4%9A%E5%AE%9D%E9%B1%BC.jpg', 58.00, NULL, 70, 150, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1109, '多春鱼', '籽粒饱满', '冷冻装 250g/袋', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E5%A4%9A%E6%98%A5%E9%B1%BC.jpg', 28.00, 24.90, 200, 400, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1110, '大虾', '船冻锁鲜', '20-30只/kg 大规格', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E5%A4%A7%E8%99%BE.jpg', 65.00, NULL, 180, 350, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1111, '大黄鱼', '东海野生', '400-500g/条 红烧佳品', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E5%A4%A7%E9%BB%84%E9%B1%BC.jpg', 45.00, 39.90, 100, 200, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1112, '小黄鱼', '家常必备', '150-200g/条 10条装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E5%B0%8F%E9%BB%84%E9%B1%BC.jpg', 32.00, NULL, 250, 500, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1113, '帝王蟹', '阿拉斯加', '鲜活帝王蟹1.5-2kg/只', '1.5-2kg', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E5%B8%9D%E7%8E%8B%E8%9F%B9%20.jpg', 598.00, 558.00, 30, 50, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1114, '扇贝', '蒜蓉粉丝', '大号扇贝肉 500g装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E6%89%87%E8%B4%9D.jpg', 49.00, 42.90, 120, 250, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1115, '新鲜虾滑', '火锅搭档', '95%虾肉含量 200g', '200g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E6%96%B0%E9%B2%9C%E8%99%BE%E6%BB%91.jpg', 29.90, 25.90, 300, 600, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1116, '新鲜鲍鱼', '六头鲍', '鲜活鲍鱼 6只装', '6只', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E6%96%B0%E9%B2%9C%E9%B2%8D%E9%B1%BC.jpg', 88.00, NULL, 60, 120, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1117, '梭子蟹', '舟山直发', '肥美带膏 300-400g/只', '300-400g/只', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E6%A2%AD%E5%AD%90%E8%9F%B9.jpg', 78.00, 69.00, 90, 180, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1118, '毛蛤', '胶东特色', '鲜活毛蛤 1kg装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E6%AF%9B%E8%9B%A4.jpg', 28.00, NULL, 150, 300, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1119, '活鲍鱼', '八头鲍', '鲜活到货 8只/盒', '8只', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E6%B4%BB%E9%B2%8D%E9%B1%BC.jpg', 65.00, 58.00, 80, 160, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1120, '海螺', '大海馈赠', '200-300g/只 5只装', '200-300g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E6%B5%B7%E8%9E%BA.jpg', 55.00, NULL, 100, 200, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1121, '海鲳鱼', '清蒸首选', '300-400g/条 2条装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E6%B5%B7%E9%B2%B3%E9%B1%BC.jpg', 42.00, 36.90, 120, 250, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1122, '深海鲽鱼', '无刺厚切', '500g/袋 烧烤食材', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E6%B7%B1%E6%B5%B7%E9%B2%BD%E9%B1%BC.jpg', 38.00, NULL, 150, 300, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1123, '牛蛙', '现杀现发', '400-500g/只 2只装', '400-500g/只', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E7%89%9B%E8%9B%99.jpg', 35.00, 29.90, 90, 180, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1124, '牡蛎', '乳山直供', '生蚝肉 500g装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E7%89%A1%E8%9B%8E.jpg', 32.00, NULL, 200, 400, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1125, '生蚝', '蒜蓉烤蚝', '大号生蚝6只装', '6只', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E7%94%9F%E8%9A%9D.jpg', 49.90, 42.90, 150, 300, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1126, '皮皮虾', '带膏母虾', '200-250g/只 8只装', '200-250g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E7%9A%AE%E7%9A%AE%E8%99%BE.jpg', 85.00, 75.00, 60, 120, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1127, '石斑鱼', '深海养殖', '500-600g/条 清蒸专用', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E7%9F%B3%E6%96%91%E9%B1%BC.jpg', 78.00, NULL, 70, 150, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1128, '秋刀鱼', '日式烤物', '300g/袋 5条装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E7%A7%8B%E5%88%80%E9%B1%BC.jpg', 28.00, 24.90, 180, 350, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1129, '章鱼', '韩式料理', '300-400g/只 即食章鱼', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E7%AB%A0%E9%B1%BC.jpg', 45.00, NULL, 100, 200, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1130, '虾滑', '手工捶打', '90%虾肉含量 150g', '150g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E8%99%BE%E6%BB%91.jpg', 22.90, 19.90, 250, 500, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1131, '裙带菜', '凉拌佳品', '盐渍裙带菜 500g', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E8%A3%99%E5%B8%A6%E8%8F%9C.jpg', 15.90, NULL, 300, 600, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1132, '金昌鱼', '香煎首选', '400-500g/条 2条装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E9%87%91%E6%98%8C%E9%B1%BC.jpg', 38.00, 32.90, 120, 250, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1133, '金鲳鱼', '南海捕捞', '600-700g/条 红烧佳品', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E9%87%91%E9%B2%B3%E9%B1%BC.jpg', 48.00, NULL, 90, 180, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1134, '青花鱼', '日式盐烤', '300-400g/条 4条装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E9%9D%92%E8%8A%B1%E9%B1%BC.jpg', 42.00, 36.00, 150, 300, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1135, '青蛤', '吐沙干净', '500g/袋 炒制佳品', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E9%9D%92%E8%9B%A4.jpg', 24.90, NULL, 200, 400, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1136, '面包蟹', '膏满黄肥', '800-1000g/只', '800-1000g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E9%9D%A2%E5%8C%85%E8%9F%B9.jpg', 128.00, 108.00, 40, 80, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1137, '马鲛鱼', '海南直发', '500-600g/段 香煎专用', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E9%A9%AC%E9%B2%9B%E9%B1%BC.jpg', 55.00, NULL, 100, 200, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1138, '鲈鱼', '鲜活现杀', '600-700g/条 清蒸首选', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E9%B2%88%E9%B1%BC.jpg', 36.00, 31.90, 150, 300, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1139, '鲤鱼', '红烧佳品', '800-1000g/条', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E9%B2%A4%E9%B1%BC.jpg', 28.00, NULL, 120, 250, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1140, '鲫鱼', '煲汤专用', '300-400g/条 2条装', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E9%B2%AB%E9%B1%BC.jpg', 24.90, 21.90, 180, 350, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1141, '鳕鱼', '宝宝辅食', '去皮去刺 200g装', '200g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E9%B3%95%E9%B1%BC.jpg', 39.90, 34.90, 200, 400, b'1', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1142, '鳗鱼段', '日式蒲烧', '200g/袋 即食装', '200g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/seafood/%E9%B3%97%E9%B1%BC%E6%AE%B5.jpg', 45.00, NULL, 150, 300, b'0', 4, '2025-03-30 18:11:49', '2025-03-30 18:11:49', b'0', 1);
INSERT INTO `fresh` VALUES (1143, '墨鱼丸', '弹牙墨鱼粒', '含真实墨鱼颗粒 火锅搭档', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/frozen/%E5%A2%A8%E9%B1%BC%E4%B8%B8.jpg', 22.90, 19.90, 300, 600, b'1', 5, '2025-03-30 18:44:49', '2025-03-30 18:44:49', b'0', 1);
INSERT INTO `fresh` VALUES (1144, '撒尿牛肉丸', '爆汁小心烫', '潮汕传统工艺 肉汁饱满', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/frozen/%E6%92%92%E5%B0%BF%E7%89%9B%E8%82%89%E4%B8%B8.jpg', 28.00, 24.90, 450, 900, b'1', 5, '2025-03-30 18:44:49', '2025-03-30 18:44:49', b'0', 1);
INSERT INTO `fresh` VALUES (1145, '燕肉饺', '薄皮大馅', '闽南特色 猪肉马蹄馅', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/frozen/%E7%87%95%E8%82%89%E9%A5%BA.jpg', 18.80, NULL, 380, 800, b'0', 5, '2025-03-30 18:44:49', '2025-03-30 18:44:49', b'0', 1);
INSERT INTO `fresh` VALUES (1146, '牛肉丸', '手打Q弹', '潮汕牛后腿肉制作', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/frozen/%E7%89%9B%E8%82%89%E4%B8%B8.jpg', 34.90, 31.90, 280, 600, b'1', 5, '2025-03-30 18:44:49', '2025-03-30 18:44:49', b'0', 1);
INSERT INTO `fresh` VALUES (1147, '牛肉卷', '涮锅必备', '肥牛卷200g/盒', '200g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/frozen/%E7%89%9B%E8%82%89%E5%8D%B7.jpg', 29.90, 26.90, 500, 1000, b'1', 5, '2025-03-30 18:44:49', '2025-03-30 18:44:49', b'0', 1);
INSERT INTO `fresh` VALUES (1148, '虾丸', '鲜虾含量≥60%', '含完整虾仁颗粒', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/frozen/%E8%99%BE%E4%B8%B8.jpg', 24.90, NULL, 320, 700, b'0', 5, '2025-03-30 18:44:49', '2025-03-30 18:44:49', b'0', 1);
INSERT INTO `fresh` VALUES (1149, '蛋饺', '金黄蛋皮', '猪肉玉米馅 20只装', '20只', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/frozen/%E8%9B%8B%E9%A5%BA.jpg', 16.90, 14.90, 400, 850, b'1', 5, '2025-03-30 18:44:49', '2025-03-30 18:44:49', b'0', 1);
INSERT INTO `fresh` VALUES (1150, '蟹肉棒', '模拟蟹腿', '日式风味 可撕条', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/frozen/%E8%9F%B9%E8%82%89%E6%A3%92.jpg', 12.90, 9.90, 600, 1200, b'1', 5, '2025-03-30 18:44:49', '2025-03-30 18:44:49', b'0', 1);
INSERT INTO `fresh` VALUES (1151, '香肠', '台式风味', '含酒香 爆汁脆皮肠', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/frozen/%E9%A6%99%E8%82%A0.jpg', 21.90, NULL, 260, 550, b'0', 5, '2025-03-30 18:44:49', '2025-03-30 18:44:49', b'0', 1);
INSERT INTO `fresh` VALUES (1152, '鱼皮脆', '嘎吱爽脆', '油炸鱼皮 火锅伴侣', '500g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/frozen/%E9%B1%BC%E7%9A%AE%E8%84%86.jpg', 14.90, 12.90, 180, 400, b'0', 5, '2025-03-30 18:44:49', '2025-03-30 18:44:49', b'0', 1);
INSERT INTO `fresh` VALUES (1153, '鱼籽福袋', '日式关东煮', '鱼籽爆浆 豆皮包裹', '6个', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/frozen/%E9%B1%BC%E7%B1%BD%E7%A6%8F%E8%A2%8B.jpg', 32.90, 29.90, 220, 450, b'1', 5, '2025-03-30 18:44:49', '2025-03-30 18:44:49', b'0', 1);
INSERT INTO `fresh` VALUES (1154, '鱼豆腐', '嫩滑不碎', '含35%鱼肉 烧烤食材', '300g', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/frozen/%E9%B1%BC%E8%B1%86%E8%85%90.jpg', 16.90, 13.90, 480, 1000, b'0', 5, '2025-03-30 18:44:49', '2025-03-30 20:51:16', b'0', 2);
INSERT INTO `fresh` VALUES (1155, '测试', '测试', '测试', '测试', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com//fresh/images/055077e9-5ebd-4ee9-bf98-21201e44c5c3_IMG_0176.JPG', 100.00, 0.00, 100, 100, b'0', 1, '2025-03-31 19:30:27', '2025-03-31 19:43:55', b'1', 2);

-- ----------------------------
-- Table structure for logistics
-- ----------------------------
DROP TABLE IF EXISTS `logistics`;
CREATE TABLE `logistics`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `order_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '关联订单号',
  `company` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物流公司',
  `type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物流类型',
  `tracking_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物流单号',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '物流状态',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_number`(`order_number`) USING BTREE,
  CONSTRAINT `fk_logistics_order` FOREIGN KEY (`order_number`) REFERENCES `order` (`order_number`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 33 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of logistics
-- ----------------------------
INSERT INTO `logistics` VALUES (1, '20250402185441128301', '顺丰物流', 'cold', '123456789', '已发货', '2025-04-02 21:33:11', NULL);
INSERT INTO `logistics` VALUES (9, '20250402205916415447', '京东物流', 'normal', '12345', '已发货', '2025-04-02 22:58:07', NULL);
INSERT INTO `logistics` VALUES (10, '20250402232908198834', '京东物流', 'cold', '128491840918', 'delivered', '2025-04-02 23:29:26', '2025-04-02 23:30:36');
INSERT INTO `logistics` VALUES (14, '20250402235959480238', '顺丰物流', 'cold', '2134215432', 'delivered', '2025-04-03 00:00:11', '2025-04-03 00:01:38');
INSERT INTO `logistics` VALUES (31, '20250403000422302803', '顺丰物流', 'cold', '12312414134', '已发货', '2025-04-03 00:04:30', NULL);
INSERT INTO `logistics` VALUES (32, '20250403003047590486', '京东物流', 'normal', '12314241241', '已发货', '2025-04-03 00:30:55', NULL);

-- ----------------------------
-- Table structure for logistics_history
-- ----------------------------
DROP TABLE IF EXISTS `logistics_history`;
CREATE TABLE `logistics_history`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `logistics_id` int(0) NOT NULL COMMENT '关联物流主表ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态记录',
  `temperature` decimal(5, 2) NULL DEFAULT NULL COMMENT '冷链温度记录',
  `event_time` datetime(0) NOT NULL COMMENT '事件时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_history_logistics`(`logistics_id`) USING BTREE,
  CONSTRAINT `fk_history_logistics` FOREIGN KEY (`logistics_id`) REFERENCES `logistics` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物流历史记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of logistics_history
-- ----------------------------
INSERT INTO `logistics_history` VALUES (1, 10, 'shipping', 4.50, '2025-04-02 23:29:26');
INSERT INTO `logistics_history` VALUES (2, 10, 'shipping', 3.60, '2025-04-02 23:29:52');
INSERT INTO `logistics_history` VALUES (3, 10, 'in_transit', 4.30, '2025-04-02 23:30:04');
INSERT INTO `logistics_history` VALUES (4, 10, 'delivering', 4.00, '2025-04-02 23:30:19');
INSERT INTO `logistics_history` VALUES (5, 10, 'delivered', 3.00, '2025-04-02 23:30:36');
INSERT INTO `logistics_history` VALUES (6, 14, 'shipping', 4.50, '2025-04-03 00:00:11');
INSERT INTO `logistics_history` VALUES (7, 14, 'shipping', 5.00, '2025-04-03 00:00:45');
INSERT INTO `logistics_history` VALUES (8, 14, 'in_transit', 3.40, '2025-04-03 00:01:09');
INSERT INTO `logistics_history` VALUES (9, 14, 'delivering', 3.90, '2025-04-03 00:01:25');
INSERT INTO `logistics_history` VALUES (10, 14, 'delivered', 3.90, '2025-04-03 00:01:38');
INSERT INTO `logistics_history` VALUES (11, 31, '已发货', 4.50, '2025-04-03 00:04:30');
INSERT INTO `logistics_history` VALUES (12, 31, '运输中', 3.00, '2025-04-03 00:08:25');
INSERT INTO `logistics_history` VALUES (13, 32, '已发货', NULL, '2025-04-03 00:30:55');

-- ----------------------------
-- Table structure for order
-- ----------------------------
DROP TABLE IF EXISTS `order`;
CREATE TABLE `order`  (
  `order_id` int(0) NOT NULL AUTO_INCREMENT COMMENT '订单id',
  `order_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单号',
  `status` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '待发货' COMMENT '发货状态（待发货、待收货、已完成）',
  `sum_prices` decimal(10, 2) NULL DEFAULT NULL COMMENT '总价',
  `shipping_fee` decimal(10, 2) NOT NULL COMMENT '运费金额',
  `user_id` int(0) NOT NULL COMMENT '普通用户ID（外键）',
  `address_id` int(0) NULL DEFAULT NULL COMMENT '收货地址ID（外键）',
  `payment_method` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '支付方式',
  `payment_time` datetime(0) NULL DEFAULT NULL COMMENT '付款时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单备注',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态)',
  `version` int(0) NULL DEFAULT 1 COMMENT '版本号（乐观锁）',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建日期',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '最后更新时间',
  PRIMARY KEY (`order_id`) USING BTREE,
  INDEX `order_ibfk_1`(`user_id`) USING BTREE,
  INDEX `order_ibfk_2`(`address_id`) USING BTREE,
  INDEX `order_number`(`order_number`) USING BTREE,
  CONSTRAINT `order_address_fk` FOREIGN KEY (`address_id`) REFERENCES `address` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `order_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order
-- ----------------------------
INSERT INTO `order` VALUES (8, '20250402185441128301', '已完成', 797.60, 20.00, 1, 1, '微信支付', NULL, '', b'0', 1, '2025-04-02 18:54:42', '2025-04-03 15:43:31');
INSERT INTO `order` VALUES (9, '20250402205916415447', '已完成', 24.80, 20.00, 1, 1, '微信支付', NULL, '', b'0', 1, '2025-04-02 20:59:17', '2025-04-03 15:43:32');
INSERT INTO `order` VALUES (10, '20250402232908198834', '已完成', 27.60, 20.00, 1, 1, '微信支付', NULL, '', b'0', 1, '2025-04-02 23:29:09', '2025-04-03 15:43:32');
INSERT INTO `order` VALUES (11, '20250402235959480238', '已完成', 25.50, 20.00, 1, 1, '微信支付', NULL, '', b'0', 1, '2025-04-03 00:00:00', '2025-04-03 15:43:32');
INSERT INTO `order` VALUES (12, '20250403000422302803', '已完成', 26.80, 20.00, 1, 1, '微信支付', NULL, '', b'0', 1, '2025-04-03 00:04:23', '2025-04-03 15:43:32');
INSERT INTO `order` VALUES (13, '20250403003047590486', '已完成', 28.70, 20.00, 1, 1, '微信支付', NULL, '', b'0', 1, '2025-04-03 00:30:48', '2025-04-03 15:43:32');
INSERT INTO `order` VALUES (14, '20250404175218728429', '待发货', 29.90, 20.00, 1, 1, '支付宝', NULL, '', b'0', 1, '2025-04-04 17:52:18', '2025-04-04 17:52:18');
INSERT INTO `order` VALUES (15, '20250404175714205772', '待发货', 24.80, 20.00, 1, 1, '支付宝', NULL, '', b'0', 1, '2025-04-04 17:57:15', '2025-04-04 17:57:15');
INSERT INTO `order` VALUES (16, '20250404175726604739', '待发货', 24.80, 20.00, 1, 1, '微信支付', NULL, '', b'0', 1, '2025-04-04 17:57:27', '2025-04-04 17:57:27');
INSERT INTO `order` VALUES (17, '20250404175732643502', '待发货', 24.80, 20.00, 1, 1, '支付宝', NULL, '', b'0', 1, '2025-04-04 17:57:33', '2025-04-04 17:57:33');

-- ----------------------------
-- Table structure for order_detail
-- ----------------------------
DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE `order_detail`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `order_id` int(0) NOT NULL COMMENT '订单编号ID',
  `fresh_id` int(0) NOT NULL,
  `count` int(0) NULL DEFAULT NULL COMMENT '购买数量',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态）',
  `version` int(0) NULL DEFAULT 1 COMMENT '版本号（乐观锁）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `order_detail_ibfk_2`(`fresh_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 38 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单与生鲜生成的订单详情表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_detail
-- ----------------------------
INSERT INTO `order_detail` VALUES (21, 6, 1001, 1, '2025-04-02 15:26:56', b'0', 1);
INSERT INTO `order_detail` VALUES (22, 6, 1002, 4, '2025-04-02 15:26:56', b'0', 1);
INSERT INTO `order_detail` VALUES (23, 6, 1035, 1, '2025-04-02 15:26:56', b'0', 1);
INSERT INTO `order_detail` VALUES (24, 6, 1067, 1, '2025-04-02 15:26:56', b'0', 1);
INSERT INTO `order_detail` VALUES (25, 7, 1001, 1, '2025-04-02 15:40:20', b'0', 1);
INSERT INTO `order_detail` VALUES (26, 8, 1067, 1, '2025-04-02 18:54:42', b'0', 1);
INSERT INTO `order_detail` VALUES (27, 8, 1070, 1, '2025-04-02 18:54:42', b'0', 1);
INSERT INTO `order_detail` VALUES (28, 8, 1071, 1, '2025-04-02 18:54:42', b'0', 1);
INSERT INTO `order_detail` VALUES (29, 8, 1072, 1, '2025-04-02 18:54:42', b'0', 1);
INSERT INTO `order_detail` VALUES (30, 8, 1082, 1, '2025-04-02 18:54:42', b'0', 1);
INSERT INTO `order_detail` VALUES (31, 8, 1123, 1, '2025-04-02 18:54:42', b'0', 1);
INSERT INTO `order_detail` VALUES (32, 8, 1125, 10, '2025-04-02 18:54:42', b'0', 1);
INSERT INTO `order_detail` VALUES (33, 9, 1001, 1, '2025-04-02 20:59:17', b'0', 1);
INSERT INTO `order_detail` VALUES (34, 10, 1005, 1, '2025-04-02 23:29:09', b'0', 1);
INSERT INTO `order_detail` VALUES (35, 11, 1007, 1, '2025-04-03 00:00:00', b'0', 1);
INSERT INTO `order_detail` VALUES (36, 12, 1002, 1, '2025-04-03 00:04:23', b'0', 1);
INSERT INTO `order_detail` VALUES (37, 13, 1003, 3, '2025-04-03 00:30:48', b'0', 1);
INSERT INTO `order_detail` VALUES (38, 14, 1150, 1, '2025-04-04 17:52:19', b'0', 1);
INSERT INTO `order_detail` VALUES (39, 15, 1001, 1, '2025-04-04 17:57:15', b'0', 1);
INSERT INTO `order_detail` VALUES (40, 16, 1001, 1, '2025-04-04 17:57:27', b'0', 1);
INSERT INTO `order_detail` VALUES (41, 17, 1001, 1, '2025-04-04 17:57:33', b'0', 1);

-- ----------------------------
-- Table structure for recommend_config
-- ----------------------------
DROP TABLE IF EXISTS `recommend_config`;
CREATE TABLE `recommend_config`  (
  `param_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '参数名称',
  `param_value` decimal(10, 2) NOT NULL COMMENT '参数值',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '参数说明',
  `create_time` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  PRIMARY KEY (`param_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of recommend_config
-- ----------------------------
INSERT INTO `recommend_config` VALUES ('cf_weight', 0.65, '协同过滤算法权重（0-1）', '2025-04-04 00:19:56', '2025-04-04 01:50:28');
INSERT INTO `recommend_config` VALUES ('content_weight', 0.30, '内容推荐权重（0-1）', '2025-04-04 00:19:56', '2025-04-04 00:19:56');
INSERT INTO `recommend_config` VALUES ('min_similarity', 0.20, '最低相似度阈值', '2025-04-04 00:19:56', '2025-04-04 00:19:56');
INSERT INTO `recommend_config` VALUES ('random_factor', 0.10, '随机扰动因子（0-0.2）', '2025-04-04 00:19:56', '2025-04-04 00:19:56');

-- ----------------------------
-- Table structure for slideshow
-- ----------------------------
DROP TABLE IF EXISTS `slideshow`;
CREATE TABLE `slideshow`  (
  `id` int(0) NOT NULL AUTO_INCREMENT COMMENT '轮播图ID',
  `picture_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图片URL',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建日期',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新日期',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '轮播图地址存放表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of slideshow
-- ----------------------------
INSERT INTO `slideshow` VALUES (1, 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/slide/1.jpg', '2025-04-03 14:20:16', '2025-04-03 14:20:19', b'0');
INSERT INTO `slideshow` VALUES (2, '	https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/slide/2.jpg', '2025-03-01 00:24:37', '2025-03-01 00:24:37', b'0');
INSERT INTO `slideshow` VALUES (3, '	https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/fresh/slide/3.jpg', '2025-03-01 00:24:08', '2025-03-01 00:24:08', b'0');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '密码',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像地址',
  `role` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色（普通用户、管理员）',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint(0) UNSIGNED NULL DEFAULT 0 COMMENT '逻辑删除字段(0代表未被删除状态，1代表已删除状态)',
  `version` int(0) UNSIGNED NULL DEFAULT 1 COMMENT '乐观锁（每修改一次版本号++1）',
  `last_login_time` datetime(0) NULL DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', '1810811793@qq.com', '15260883342', 'https://mall-1347087724.cos.ap-guangzhou.myqcloud.com/avatar/0875de28-2a7a-418d-bd1a-40d3d4d76d39_IMG_0308.JPG', '管理员', '2025-02-28 17:32:23', '2025-04-01 17:42:45', 0, 2, '2025-04-04 16:21:27', '0:0:0:0:0:0:0:1');

SET FOREIGN_KEY_CHECKS = 1;
