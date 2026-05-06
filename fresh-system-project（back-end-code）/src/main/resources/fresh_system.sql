/*
 Navicat Premium Dump SQL

 Source Server         : 关山月
 Source Server Type    : MySQL
 Source Server Version : 80035 (8.0.35)
 Source Host           : localhost:3306
 Source Schema         : fresh_system

 Target Server Type    : MySQL
 Target Server Version : 80035 (8.0.35)
 File Encoding         : 65001

 Date: 21/12/2024 14:53:25
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for address
-- ----------------------------
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键ID',
  `address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货地址',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建日期',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新日期',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `address`(`address` ASC) USING BTREE COMMENT '唯一索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '收货地址表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of address
-- ----------------------------
INSERT INTO `address` VALUES ('056adf7119cb62ebc9e085cdb53c510e', '湖北省孝感市孝南区湖工校园社区', '2024-12-08 05:39:16', '2024-12-08 05:39:16', b'0');
INSERT INTO `address` VALUES ('7976f7407513b99947e66f6312606d98', '河南省鹿邑县高集乡大河口行政村朱桥', '2024-12-08 05:38:02', '2024-12-08 05:38:02', b'0');
INSERT INTO `address` VALUES ('eeaad45ed2fd7319753802f026d014a4', '河南省郑州市杨庄社区', '2024-12-08 05:39:54', '2024-12-08 05:39:54', b'0');

-- ----------------------------
-- Table structure for cart
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart`  (
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '普通用户ID',
  `fresh_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '生鲜ID',
  `count` int NULL DEFAULT NULL COMMENT '购买数量',
  `purchase_time` datetime NULL DEFAULT NULL COMMENT '购买日期',
  `version` int NULL DEFAULT 1 COMMENT '版本号（乐观锁）',
  PRIMARY KEY (`user_id`, `fresh_id`) USING BTREE,
  INDEX `cart_ibfk_2`(`fresh_id` ASC) USING BTREE,
  CONSTRAINT `cart_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `cart_ibfk_2` FOREIGN KEY (`fresh_id`) REFERENCES `fresh` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户与生鲜产生的购物车关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cart
-- ----------------------------

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类ID',
  `category_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类名称',
  `user_id` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '管理者ID（外键）',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建日期',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新日期',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态)\r\ntip: 此项目实际没必要添加此逻辑删除字段',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_category_name`(`category_name` ASC) USING BTREE,
  INDEX `category_ibfk_1`(`user_id` ASC) USING BTREE,
  CONSTRAINT `category_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '生鲜分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES ('1a4d36c946b076331b3fba16635edd72', '水果', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 03:00:59', '2024-12-08 03:00:59', b'0');
INSERT INTO `category` VALUES ('5b9c1b78fd7ee97e1d887b34f95fe650', '奶制品', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 03:00:41', '2024-12-08 03:00:41', b'0');
INSERT INTO `category` VALUES ('5fd08e5a8dc826eba80c4f6ea3f6ebb3', '海鲜', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 03:00:16', '2024-12-08 03:00:16', b'0');
INSERT INTO `category` VALUES ('91cae657eae503f56770cb93cfb3d26f', '肉类', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 02:59:35', '2024-12-08 02:59:35', b'0');
INSERT INTO `category` VALUES ('bb80ab822241f4ccfce864a90d24245e', '蔬菜', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 03:00:49', '2024-12-08 03:00:49', b'0');
INSERT INTO `category` VALUES ('cb7e2fc1c4bc9651633674bcf5ca3d47', '蛋类', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 03:00:30', '2024-12-08 03:00:30', b'0');
INSERT INTO `category` VALUES ('d8ea8eb44a1686b9fcac18ec3d2d0851', '谷物', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 03:01:08', '2024-12-08 03:01:08', b'0');
INSERT INTO `category` VALUES ('f0bce8470ff256fd7c1f20e5d5665178', '鱼类', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 02:59:59', '2024-12-08 02:59:59', b'1');

-- ----------------------------
-- Table structure for communication
-- ----------------------------
DROP TABLE IF EXISTS `communication`;
CREATE TABLE `communication`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '交流ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '动态内容',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '普通用户ID（外键）',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建日期',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新日期',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `communication_ibfk_1`(`user_id` ASC) USING BTREE,
  CONSTRAINT `communication_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '社区交流评论表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of communication
-- ----------------------------
INSERT INTO `communication` VALUES ('0c508abedd03c4ebc10fc41df4cc7d3a', '那是必须滴！', '954568305d4e14daa275deee255c58b4', '2024-12-08 02:48:21', '2024-12-08 02:48:21', b'0');
INSERT INTO `communication` VALUES ('126a56f698e032bc81be6312ec354ff7', 'Hello! Everyone. 刚上线的社区生鲜配送系统基本上还能用，但一些功能还需要升级，另外希望临近春节了，希望能把猪肉价给打下来。哈哈！', '954568305d4e14daa275deee255c58b4', '2024-12-08 02:44:24', '2024-12-08 02:44:43', b'0');
INSERT INTO `communication` VALUES ('6c06940abeb8440401c868474388c55a', '2024年已结束，2025年现已开启，希望咱们老百姓的日子越过越红火，湖工未来发展的越来越好，老师同学们都是各有所长，都是生活中不可或缺的主角，加油吧，吾辈青年，加油吧，我的湖工！加油吧，中国，ლ(′◉❥◉｀ლ)', '954568305d4e14daa275deee255c58b4', '2024-12-08 02:47:34', '2024-12-08 02:47:34', b'0');
INSERT INTO `communication` VALUES ('c8c9eb8a7c3ec0d282438ee2f62b2f7e', '不忘初心，以人为本，在胖东来超市展现的淋漓尽致哈！', '75217db29973d45941678881458225b5', '2024-12-08 06:49:58', '2024-12-08 06:49:58', b'0');

-- ----------------------------
-- Table structure for fresh
-- ----------------------------
DROP TABLE IF EXISTS `fresh`;
CREATE TABLE `fresh`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '生鲜商品ID',
  `fresh_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生鲜名称',
  `feature` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '特色',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '描述',
  `picture_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生鲜图片URL',
  `prices` decimal(10, 2) NULL DEFAULT NULL COMMENT '原价',
  `promotion_price` decimal(10, 2) UNSIGNED ZEROFILL NULL DEFAULT NULL COMMENT '促销价格',
  `repertory` int(10) UNSIGNED ZEROFILL NULL DEFAULT 0000000000 COMMENT '库存',
  `sum_repertory` int(10) UNSIGNED ZEROFILL NULL DEFAULT 0000000000 COMMENT '总库存',
  `is_recommend` bit(1) NULL DEFAULT b'0' COMMENT '是否推荐（0不推荐，1推荐）',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '管理员ID（外键）',
  `category_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类ID（外键）',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建日期',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新日期',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态)',
  `version` int UNSIGNED NULL DEFAULT 1 COMMENT '版本号（乐观锁）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fresh_ibfk_1`(`user_id` ASC) USING BTREE,
  INDEX `fresh_ibfk_2`(`category_id` ASC) USING BTREE,
  CONSTRAINT `fresh_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fresh_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '生鲜商品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fresh
-- ----------------------------
INSERT INTO `fresh` VALUES ('36f08003523f119358cbe2f831da9103', '新鲜有机苹果', '有机种植、无农药残留', '每一颗苹果都是最天然、最健康的。', 'http://localhost:8080/file/download/freshPictures/_multimodal_image_684232087U310030azyj9_b6200082-b39b-40f6-aacf-9f6f7bcbcaea.jpg', 15.00, 00000000.00, 0000000299, 0000000300, b'1', 'b5bd70d4c671a963263fd3b0ef726afa', '1a4d36c946b076331b3fba16635edd72', '2024-12-08 03:55:48', '2024-12-08 09:16:36', b'0', 3);
INSERT INTO `fresh` VALUES ('6d760c49fa72ff11be65bb1f5124a931', '有机糙米', '无农药残留、天然健康', '糙米富含膳食纤维、维生素B群和矿物质，有助于消化和维持身体健康', 'http://localhost:8080/file/download/freshPictures/_multimodal_image_684232087U996003mmupz_2cdcdf4c-229d-49b0-8842-cace8a31a01c.jpg', 15.00, 00000012.00, 0000000499, 0000000500, b'1', 'b5bd70d4c671a963263fd3b0ef726afa', 'd8ea8eb44a1686b9fcac18ec3d2d0851', '2024-12-08 03:51:33', '2024-12-08 09:16:36', b'0', 5);
INSERT INTO `fresh` VALUES ('8341b911dfff5765d97a0d99e6fb2299', '新鲜有机鸡蛋', '鸡蛋大而高蛋白', '鸡蛋富含蛋白质、维生素D和胆固醇，有助于增强免疫力和提供能量。', 'http://localhost:8080/file/download/freshPictures/_multimodal_image_684232087U6878152edi0_fcae3c51-1546-4c45-9502-70ec54a830a2.jpg', 10.00, 00000008.90, 0000000296, 0000000300, b'1', 'b5bd70d4c671a963263fd3b0ef726afa', 'cb7e2fc1c4bc9651633674bcf5ca3d47', '2024-12-08 04:03:31', '2024-12-15 05:35:46', b'0', 4);
INSERT INTO `fresh` VALUES ('bf6be093c30479c4f37e2a4ec75e46be', '新鲜有机牛奶', '高钙牛奶、天然健康', '我们的有机牛奶来自有机农场，确保每一瓶牛奶都是最天然、最健康的。', 'http://localhost:8080/file/download/freshPictures/_multimodal_image_684232087U4361950co4n_8d91e405-4f9b-4dfb-904d-40b4c659fb90.jpg', 20.00, 00000000.00, 0000000200, 0000000200, b'0', 'b5bd70d4c671a963263fd3b0ef726afa', '5b9c1b78fd7ee97e1d887b34f95fe650', '2024-12-08 03:59:32', '2024-12-08 03:59:32', b'0', 1);
INSERT INTO `fresh` VALUES ('c0754693271b9204f87f362f1bf911bd', '新鲜优质番茄', '富含维生素和膳食纤维', '蔬菜经过专业采摘和检疫，保证其品质和安全。', 'http://localhost:8080/file/download/freshPictures/_multimodal_image_684232087U110324k8r7h_a3d70da9-0255-4da9-bfe6-5d4aba64c0e2.jpg', 25.00, 00000020.00, 0000000198, 0000000200, b'1', 'b5bd70d4c671a963263fd3b0ef726afa', 'bb80ab822241f4ccfce864a90d24245e', '2024-12-08 03:41:58', '2024-12-08 09:16:36', b'0', 3);
INSERT INTO `fresh` VALUES ('c71355454d02a0ff8b8ae17798558cc3', '新鲜三文鱼', '富含Omega-3脂肪酸', '新鲜三文鱼，源自中国深海，肉质鲜美，营养丰富，适合生食或烹饪。', 'http://localhost:8080/file/download/freshPictures/_multimodal_image_684232087U917995bz941_0c71c1a0-a9d3-42fb-a971-a68223c0aefe.jpg', 150.00, 00000120.00, 0000000096, 0000000100, b'0', 'b5bd70d4c671a963263fd3b0ef726afa', '5fd08e5a8dc826eba80c4f6ea3f6ebb3', '2024-12-08 04:07:16', '2024-12-15 05:35:46', b'0', 5);
INSERT INTO `fresh` VALUES ('eb0f925d94d95715ddfc2c7999e65e4a', '新鲜优质猪肉', '新鲜屠宰冷链运输', '每一块猪肉都新鲜、健康、无激素。', 'http://localhost:8080/file/download/freshPictures/OfficeAI20241208-030336_0_e9e94a03-5ede-4db1-aa0b-c90a7d1f4c80.png', 90.00, 00000070.00, 0000000296, 0000000300, b'1', 'b5bd70d4c671a963263fd3b0ef726afa', '91cae657eae503f56770cb93cfb3d26f', '2024-12-08 03:07:47', '2024-12-15 05:35:46', b'0', 10);

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '内容',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT ' 管理员用户ID（外键）',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建日期',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新日期',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态)',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `notice_ibfk_1`(`user_id` ASC) USING BTREE,
  CONSTRAINT `notice_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '公告资讯表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES ('63f21c9a3fc240512a9175e63a598a55', '社区生鲜系统促销活动通知', '亲爱的社区居民：\n\n为了感谢大家对我们社区生鲜系统的支持，我们特别推出了一系列促销活动，让您享受更多实惠！活动详情如下：\n\n1.\n限时折扣：\n即日起至本月底，所有生鲜产品享受8折优惠。\n每天上午10点至中午12点，特定商品享受额外5折优惠，先到先得。\n2.\n满减优惠：\n单笔订单满100元，立减10元。\n单笔订单满200元，立减30元。\n活动细则：\n\n以上活动不可叠加使用，最终解释权归社区生鲜系统所有。\n如有任何疑问，请联系我们的客服团队，我们将竭诚为您服务。\n感谢大家的支持与信任，祝您购物愉快！', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 02:24:35', '2024-12-08 02:24:35', b'0');
INSERT INTO `notice` VALUES ('77c932ce9d1aa5ead07546b0d31f2fd2', '春节线上店面升级暨生鲜大甩卖活动通知', '春节将至，为了给您带来更好的购物体验，我们的社区生鲜系统进行了全面的线上店面升级！同时，为了感谢大家一直以来的支持，我们特别推出春节生鲜大甩卖活动，让您以超值价格购买到新鲜的生鲜产品。具体活动详情如下：\n\n1.\n店面升级亮点：\n更简洁直观的界面设计，让您轻松找到所需商品。\n新增多种便捷支付方式，提升您的购物体验。\n优化配送系统，确保您的订单更快送达。\n2.\n生鲜大甩卖活动：\n全场折扣： 即日起至春节，所有生鲜产品享受最低5折优惠。\n限时秒杀： 每天下午3点至5点，特定商品限量秒杀，超值抢购。\n满额赠礼： 单笔订单满200元，即赠送精美春节礼包一份。\n会员专享： 会员用户享受折上折优惠，并可参与积分翻倍活动。\n3.\n春节特别活动：\n年货大礼包： 推出多款春节年货大礼包，内含多种精选生鲜产品，适合家庭团圆享用。\n幸运抽奖： 每笔订单均可参与春节幸运抽奖，奖品包括免费生鲜礼包、购物券和春节红包等。\n4.\n配送服务：\n我们提供春节期间的定时配送服务，确保您的年货按时送达。\n所有配送均采用无接触配送，保障您的安全。\n感谢大家的支持与信任，祝您和您的家人春节快乐，万事如意！\n\n社区生鲜系统团队', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 02:27:24', '2024-12-08 02:27:24', b'0');
INSERT INTO `notice` VALUES ('84f834d98d324b004f527d2d8c9ddcf6', '社区生鲜系统上线通知', '亲爱的社区居民：\n\n为了更好地服务大家，我们很高兴地宣布，我们的社区生鲜系统现已正式上线！通过这个系统，您可以方便地在线选购新鲜的生鲜产品，享受快捷的配送服务。以下是一些主要功能和使用指南：\n\n1.\n注册与登录：\n首次使用请先注册账号，然后登录系统。\n已注册用户可直接登录。\n2.\n选购商品：\n浏览我们的生鲜产品目录，选择您需要的商品。\n所有商品均为每日新鲜采购，保证品质。\n3.\n下单与支付：\n将选好的商品加入购物车，确认订单。\n支持多种支付方式，包括微信支付、支付宝和银行卡支付。\n4.\n配送服务：\n我们提供每日定时配送服务，您可以选择适合的时间段。\n所有配送均采用无接触配送，确保您的安全。\n5.\n售后服务：\n如有任何问题或不满意的地方，请随时联系我们的客服团队。\n我们承诺提供优质的售后服务，确保您的购物体验。\n感谢大家的支持与信任，祝您购物愉快！\n\n社区生鲜系统团队', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 02:22:00', '2024-12-08 02:22:00', b'0');

-- ----------------------------
-- Table structure for order
-- ----------------------------
DROP TABLE IF EXISTS `order`;
CREATE TABLE `order`  (
  `order_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号',
  `status` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '待发货' COMMENT '发货状态（待发货、待收货、已完成）',
  `sum_prices` decimal(10, 2) NULL DEFAULT NULL COMMENT '总价',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '普通用户ID（外键）',
  `shipping_address_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货地址ID（外键）',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建日期',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态)',
  `version` int NULL DEFAULT 1 COMMENT '版本号（乐观锁）',
  PRIMARY KEY (`order_number`) USING BTREE,
  INDEX `order_ibfk_1`(`user_id` ASC) USING BTREE,
  INDEX `order_ibfk_2`(`shipping_address_id` ASC) USING BTREE,
  CONSTRAINT `order_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `order_ibfk_2` FOREIGN KEY (`shipping_address_id`) REFERENCES `address` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order
-- ----------------------------
INSERT INTO `order` VALUES ('413af618e8bd4db5b21d60f559892922', '已完成', 75.90, '75217db29973d45941678881458225b5', '056adf7119cb62ebc9e085cdb53c510e', '2024-12-08 09:16:36', b'1', 1);
INSERT INTO `order` VALUES ('49153c936a93413880c8a757d9e97023', '已完成', 147.00, '75217db29973d45941678881458225b5', '056adf7119cb62ebc9e085cdb53c510e', '2024-12-08 09:04:38', b'1', 1);
INSERT INTO `order` VALUES ('6a0b13f3c1b6402aa7a3bfe9f633fcdf', '已完成', 140.00, '75217db29973d45941678881458225b5', '056adf7119cb62ebc9e085cdb53c510e', '2024-12-08 06:44:48', b'1', 1);
INSERT INTO `order` VALUES ('6e3603f470ed4ea5bf27dd8351783c4c', '已完成', 12.00, '75217db29973d45941678881458225b5', '056adf7119cb62ebc9e085cdb53c510e', '2024-12-08 07:20:23', b'1', 1);
INSERT INTO `order` VALUES ('715b336d443c4f3b80398ab34d798a88', '已完成', 120.00, '75217db29973d45941678881458225b5', '056adf7119cb62ebc9e085cdb53c510e', '2024-12-08 07:00:30', b'1', 1);
INSERT INTO `order` VALUES ('719f6d30615b4c629ecd2a74a85a5b34', '已完成', 58.90, '75217db29973d45941678881458225b5', '056adf7119cb62ebc9e085cdb53c510e', '2024-12-08 07:28:18', b'1', 1);
INSERT INTO `order` VALUES ('75100fb98ffc469bb8ab5477feed4777', '已完成', 397.80, '75217db29973d45941678881458225b5', '056adf7119cb62ebc9e085cdb53c510e', '2024-12-12 11:08:01', b'1', 1);
INSERT INTO `order` VALUES ('7733dc1867bc43f48761b96fcdfb5ee5', '待发货', 388.90, '75217db29973d45941678881458225b5', '056adf7119cb62ebc9e085cdb53c510e', '2024-12-15 05:35:46', b'0', 1);

-- ----------------------------
-- Table structure for order_detail
-- ----------------------------
DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE `order_detail`  (
  `order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号ID',
  `fresh_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '生鲜ID',
  `count` int NULL DEFAULT NULL COMMENT '购买数量',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态）',
  `version` int NULL DEFAULT 1 COMMENT '版本号（乐观锁）',
  PRIMARY KEY (`order_id`, `fresh_id`) USING BTREE,
  INDEX `order_detail_ibfk_2`(`fresh_id` ASC) USING BTREE,
  CONSTRAINT `order_detail_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `order` (`order_number`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `order_detail_ibfk_2` FOREIGN KEY (`fresh_id`) REFERENCES `fresh` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单与生鲜生成的订单详情表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_detail
-- ----------------------------
INSERT INTO `order_detail` VALUES ('413af618e8bd4db5b21d60f559892922', '36f08003523f119358cbe2f831da9103', 1, '2024-12-08 09:16:35', b'0', 1);
INSERT INTO `order_detail` VALUES ('413af618e8bd4db5b21d60f559892922', '6d760c49fa72ff11be65bb1f5124a931', 1, '2024-12-08 09:16:35', b'0', 1);
INSERT INTO `order_detail` VALUES ('413af618e8bd4db5b21d60f559892922', '8341b911dfff5765d97a0d99e6fb2299', 1, '2024-12-08 09:16:35', b'0', 1);
INSERT INTO `order_detail` VALUES ('413af618e8bd4db5b21d60f559892922', 'c0754693271b9204f87f362f1bf911bd', 2, '2024-12-08 09:16:35', b'0', 1);
INSERT INTO `order_detail` VALUES ('49153c936a93413880c8a757d9e97023', '36f08003523f119358cbe2f831da9103', 1, '2024-12-08 09:04:37', b'0', 1);
INSERT INTO `order_detail` VALUES ('49153c936a93413880c8a757d9e97023', '6d760c49fa72ff11be65bb1f5124a931', 1, '2024-12-08 09:04:37', b'0', 1);
INSERT INTO `order_detail` VALUES ('49153c936a93413880c8a757d9e97023', 'c71355454d02a0ff8b8ae17798558cc3', 1, '2024-12-08 09:04:37', b'0', 1);
INSERT INTO `order_detail` VALUES ('6a0b13f3c1b6402aa7a3bfe9f633fcdf', '36f08003523f119358cbe2f831da9103', 2, '2024-12-08 06:44:48', b'0', 1);
INSERT INTO `order_detail` VALUES ('6a0b13f3c1b6402aa7a3bfe9f633fcdf', 'c0754693271b9204f87f362f1bf911bd', 2, '2024-12-08 06:44:48', b'0', 1);
INSERT INTO `order_detail` VALUES ('6a0b13f3c1b6402aa7a3bfe9f633fcdf', 'eb0f925d94d95715ddfc2c7999e65e4a', 1, '2024-12-08 06:44:48', b'0', 1);
INSERT INTO `order_detail` VALUES ('6e3603f470ed4ea5bf27dd8351783c4c', '6d760c49fa72ff11be65bb1f5124a931', 1, '2024-12-08 07:20:23', b'0', 1);
INSERT INTO `order_detail` VALUES ('715b336d443c4f3b80398ab34d798a88', 'c71355454d02a0ff8b8ae17798558cc3', 1, '2024-12-08 07:00:30', b'0', 1);
INSERT INTO `order_detail` VALUES ('719f6d30615b4c629ecd2a74a85a5b34', '36f08003523f119358cbe2f831da9103', 2, '2024-12-08 07:28:18', b'0', 1);
INSERT INTO `order_detail` VALUES ('719f6d30615b4c629ecd2a74a85a5b34', '8341b911dfff5765d97a0d99e6fb2299', 1, '2024-12-08 07:28:18', b'0', 1);
INSERT INTO `order_detail` VALUES ('719f6d30615b4c629ecd2a74a85a5b34', 'c0754693271b9204f87f362f1bf911bd', 1, '2024-12-08 07:28:18', b'0', 1);
INSERT INTO `order_detail` VALUES ('75100fb98ffc469bb8ab5477feed4777', '8341b911dfff5765d97a0d99e6fb2299', 2, '2024-12-12 11:08:00', b'0', 1);
INSERT INTO `order_detail` VALUES ('75100fb98ffc469bb8ab5477feed4777', 'c71355454d02a0ff8b8ae17798558cc3', 2, '2024-12-12 11:08:00', b'0', 1);
INSERT INTO `order_detail` VALUES ('75100fb98ffc469bb8ab5477feed4777', 'eb0f925d94d95715ddfc2c7999e65e4a', 2, '2024-12-12 11:08:00', b'0', 1);
INSERT INTO `order_detail` VALUES ('7733dc1867bc43f48761b96fcdfb5ee5', '8341b911dfff5765d97a0d99e6fb2299', 1, '2024-12-15 05:35:46', b'0', 1);
INSERT INTO `order_detail` VALUES ('7733dc1867bc43f48761b96fcdfb5ee5', 'c71355454d02a0ff8b8ae17798558cc3', 2, '2024-12-15 05:35:46', b'0', 1);
INSERT INTO `order_detail` VALUES ('7733dc1867bc43f48761b96fcdfb5ee5', 'eb0f925d94d95715ddfc2c7999e65e4a', 2, '2024-12-15 05:35:46', b'0', 1);

-- ----------------------------
-- Table structure for slideshow
-- ----------------------------
DROP TABLE IF EXISTS `slideshow`;
CREATE TABLE `slideshow`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '轮播图ID',
  `picture_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图片URL',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '管理员ID（外键）',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建日期',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新日期',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `slideshow_ibfk_1`(`user_id` ASC) USING BTREE,
  CONSTRAINT `slideshow_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '轮播图地址存放表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of slideshow
-- ----------------------------
INSERT INTO `slideshow` VALUES ('0971833d06f7f6a2b612005ea7958688', 'http://localhost:8080/file/download/slidePictures/2h70j-kmkrm_1dae7253-7d50-487e-a3d8-734db1c01203.gif', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 05:31:33', '2024-12-08 05:31:33', b'1');
INSERT INTO `slideshow` VALUES ('2cdba7f373691deaef47c7ddd546227c', 'http://localhost:8080/file/download/slidePictures/pexels-kindelmedia-8351608_049a03ae-12d0-4fc3-8d72-80e8f8bdd204.jpg', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 06:09:33', '2024-12-08 06:09:33', b'0');
INSERT INTO `slideshow` VALUES ('9cc03b5782bd984c9383b2b812d08c15', 'http://localhost:8080/file/download/slidePictures/pexels-minan1398-1093837_95497483-b5ca-44f7-b284-2a97e7a4cee5.jpg', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 06:05:51', '2024-12-08 06:05:51', b'0');
INSERT INTO `slideshow` VALUES ('a7242f71134817ebeafed04c818bf7ac', 'http://localhost:8080/file/download/slidePictures/2h70j-kmkrm_d4262287-41da-40fb-8e0d-326ac0df4144.gif', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 05:34:26', '2024-12-08 05:34:26', b'1');
INSERT INTO `slideshow` VALUES ('afc9e98fc0e523f2be8bb9a70220ea2e', 'http://localhost:8080/file/download/slidePictures/dd87u-dl7xs_a9257398-0083-443e-af64-e07c793e43ca.gif', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 06:11:26', '2024-12-08 06:11:26', b'0');
INSERT INTO `slideshow` VALUES ('d8d0bddb90bfbcbc91db81475ffb3796', 'http://localhost:8080/file/download/slidePictures/4e9rs-neg3l_28159550-4785-4dfc-afaf-aed1fd64647a.gif', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 06:05:16', '2024-12-08 06:05:16', b'0');
INSERT INTO `slideshow` VALUES ('f223fddaf2efa08fb43a91de80295b6b', 'http://localhost:8080/file/download/slidePictures/2h70j-kmkrm_524d10df-7220-4247-a310-2d2414cbc7d2.gif', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 05:34:46', '2024-12-08 05:54:50', b'0');
INSERT INTO `slideshow` VALUES ('f875a8d184903db3dccaf3c3d276eeaa', 'http://localhost:8080/file/download/slidePictures/pexels-angel-ayala-321556-28976231_9ae2a28e-e0f0-4773-93f9-3cd65ed44a88.jpg', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 06:06:07', '2024-12-08 06:06:07', b'0');
INSERT INTO `slideshow` VALUES ('fe0aa5ade18db4101b2bd647ab9ce372', 'http://localhost:8080/file/download/slidePictures/pexels-greta-hoffman-9705830_6918913f-1676-44cc-8de3-a958e4af5aa5.jpg', 'b5bd70d4c671a963263fd3b0ef726afa', '2024-12-08 05:53:28', '2024-12-08 05:53:28', b'0');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键',
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '密码',
  `nick_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像地址',
  `role` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色（普通用户、管理员）',
  `birthday` date NULL DEFAULT NULL COMMENT '出生日期',
  `account` decimal(10, 2) UNSIGNED NULL DEFAULT 0.00 COMMENT '账户余额',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint UNSIGNED NULL DEFAULT 0 COMMENT '逻辑删除字段(0代表未被删除状态，1代表已删除状态)',
  `version` int UNSIGNED NULL DEFAULT 1 COMMENT '乐观锁（每修改一次版本号++1）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `id`(`id` ASC) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('75217db29973d45941678881458225b5', '悠然', '22bb5f9976c7d9176f293ec74f55f87b', '悠然见南山', '1637847669@qq.com', '17613270756', 'http://localhost:8080/file/download/avatars/IMG_20140608_152227_973e9939-dab5-42fb-a7ff-1932ca38e9c8.jpg', '普通用户', '2024-12-07', 181.50, '2024-12-08 06:20:16', '2024-12-15 05:35:27', 0, 16);
INSERT INTO `user` VALUES ('954568305d4e14daa275deee255c58b4', 'Orion.Guan', '22bb5f9976c7d9176f293ec74f55f87b', '山月润无声', 'orion.guan@lianwei.com.cn', '18066234881', 'http://localhost:8080/file/download/avatars/OfficeAI20241208-025600_0_9e2a53f7-896e-45ee-b4a8-a9bc9caf52e0.png', '普通用户', '2001-08-26', 100.00, '2024-12-08 02:32:12', '2024-12-08 02:50:18', 0, 3);
INSERT INTO `user` VALUES ('b5bd70d4c671a963263fd3b0ef726afa', '关山月', '22bb5f9976c7d9176f293ec74f55f87b', '山月润无声', 'orion.guan@lianwei.com.cn', '18066234881', 'http://localhost:8080/file/download/avatars/OfficeAI20241208-025717_0_c74d7d95-f827-42e8-9a7d-b7b4f11f94fa.png', '管理员', '2000-08-27', 0.00, '2024-12-08 02:14:33', '2024-12-08 03:29:29', 0, 3);

-- ----------------------------
-- Table structure for user_address
-- ----------------------------
DROP TABLE IF EXISTS `user_address`;
CREATE TABLE `user_address`  (
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '普通用户ID',
  `shipping_address_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收货地址ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建日期',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新日期',
  `is_deleted` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除字段（0未删除状态、1已删除状态)',
  PRIMARY KEY (`user_id`, `shipping_address_id`) USING BTREE,
  INDEX `user_address_ibfk_2`(`shipping_address_id` ASC) USING BTREE,
  CONSTRAINT `user_address_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `user_address_ibfk_2` FOREIGN KEY (`shipping_address_id`) REFERENCES `address` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户与收货地址产生的关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_address
-- ----------------------------
INSERT INTO `user_address` VALUES ('75217db29973d45941678881458225b5', '056adf7119cb62ebc9e085cdb53c510e', '2024-12-08 06:43:25', '2024-12-08 06:43:25', b'0');
INSERT INTO `user_address` VALUES ('75217db29973d45941678881458225b5', '7976f7407513b99947e66f6312606d98', '2024-12-08 06:43:05', '2024-12-08 06:43:05', b'0');
INSERT INTO `user_address` VALUES ('75217db29973d45941678881458225b5', 'eeaad45ed2fd7319753802f026d014a4', '2024-12-08 06:43:49', '2024-12-08 06:43:49', b'0');

SET FOREIGN_KEY_CHECKS = 1;
