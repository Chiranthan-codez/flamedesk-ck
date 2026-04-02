-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: switchback.proxy.rlwy.net    Database: cloud_kitchen
-- ------------------------------------------------------
-- Server version	9.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin_users`
--

DROP TABLE IF EXISTS `admin_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_users` (
  `admin_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`admin_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_users`
--

LOCK TABLES `admin_users` WRITE;
/*!40000 ALTER TABLE `admin_users` DISABLE KEYS */;
INSERT INTO `admin_users` VALUES (1,'admin','$2y$10$examplehashedpassword','Super Admin','admin@cloudkitchen.com','2026-04-02 13:17:58');
/*!40000 ALTER TABLE `admin_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `brands`
--

DROP TABLE IF EXISTS `brands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `brands` (
  `brand_id` int NOT NULL AUTO_INCREMENT,
  `brand_name` varchar(100) NOT NULL,
  `cuisine_type` varchar(50) DEFAULT NULL,
  `logo_url` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`brand_id`),
  CONSTRAINT `chk_brand_status` CHECK ((`status` in (_cp850'active',_cp850'inactive')))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `brands`
--

LOCK TABLES `brands` WRITE;
/*!40000 ALTER TABLE `brands` DISABLE KEYS */;
INSERT INTO `brands` VALUES (1,'Spice Route','Indian',NULL,'active','2026-04-02 13:17:59'),(2,'Burgerburg','American',NULL,'active','2026-04-02 13:17:59'),(3,'Tokyo Bites','Japanese',NULL,'active','2026-04-02 13:17:59'),(4,'Pizza Pronto','Italian',NULL,'active','2026-04-02 13:17:59');
/*!40000 ALTER TABLE `brands` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `address` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Arjun Sharma','9000000001','arjun@email.com','$2a$10$jOezsqkssyJhyALcq.f3duSp6F2x/KUc3jEz8nFFQsB/XQ1JrrgZu','12 MG Road, Bangalore','2026-04-02 13:18:00'),(2,'Priya Nair','9000000002','priya@email.com',NULL,'45 Koramangala, Bangalore','2026-04-02 13:18:00'),(3,'Rahul Mehta','9000000003','rahul@email.com',NULL,'78 Indiranagar, Bangalore','2026-04-02 13:18:00'),(4,'Sneha Patel','9000000004','sneha@email.com',NULL,'23 Whitefield, Bangalore','2026-04-02 13:18:00'),(5,'Vikram Reddy','9000000005','vikram@email.com',NULL,'56 HSR Layout, Bangalore','2026-04-02 13:18:00'),(6,'Anjali Singh','9000000006','anjali@email.com',NULL,'90 Jayanagar, Bangalore','2026-04-02 13:18:00');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_partners`
--

DROP TABLE IF EXISTS `delivery_partners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_partners` (
  `partner_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `vehicle_no` varchar(20) DEFAULT NULL,
  `status` enum('available','on_delivery','offline') DEFAULT 'available',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`partner_id`),
  UNIQUE KEY `phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_partners`
--

LOCK TABLES `delivery_partners` WRITE;
/*!40000 ALTER TABLE `delivery_partners` DISABLE KEYS */;
INSERT INTO `delivery_partners` VALUES (1,'Ravi Kumar','8000000001','KA01AB1234','available','2026-04-02 13:18:01'),(2,'Suresh Babu','8000000002','KA02CD5678','available','2026-04-02 13:18:01'),(3,'Mohan Das','8000000003','KA03EF9012','on_delivery','2026-04-02 13:18:01'),(4,'Kiran Joshi','8000000004','KA04GH3456','offline','2026-04-02 13:18:01');
/*!40000 ALTER TABLE `delivery_partners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_ratings`
--

DROP TABLE IF EXISTS `delivery_ratings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_ratings` (
  `delivery_rating_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `partner_id` int NOT NULL,
  `order_id` int NOT NULL,
  `rating_value` tinyint NOT NULL,
  `feedback` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`delivery_rating_id`),
  UNIQUE KEY `order_id` (`order_id`),
  KEY `fk_dr_customer` (`customer_id`),
  KEY `fk_dr_partner` (`partner_id`),
  CONSTRAINT `fk_dr_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_dr_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `fk_dr_partner` FOREIGN KEY (`partner_id`) REFERENCES `delivery_partners` (`partner_id`),
  CONSTRAINT `chk_delivery_rating` CHECK ((`rating_value` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_ratings`
--

LOCK TABLES `delivery_ratings` WRITE;
/*!40000 ALTER TABLE `delivery_ratings` DISABLE KEYS */;
INSERT INTO `delivery_ratings` VALUES (1,1,1,1,5,'Super fast delivery, very polite!','2026-04-02 13:18:03'),(2,2,2,2,4,'On time and professional.','2026-04-02 13:18:03'),(3,3,1,3,5,'Excellent service!','2026-04-02 13:18:03');
/*!40000 ALTER TABLE `delivery_ratings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_tracking`
--

DROP TABLE IF EXISTS `delivery_tracking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_tracking` (
  `tracking_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `partner_id` int DEFAULT NULL,
  `status` enum('unassigned','assigned','picked_up','delivered') DEFAULT 'unassigned',
  `assigned_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  PRIMARY KEY (`tracking_id`),
  UNIQUE KEY `order_id` (`order_id`),
  KEY `fk_tracking_partner` (`partner_id`),
  CONSTRAINT `fk_tracking_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `fk_tracking_partner` FOREIGN KEY (`partner_id`) REFERENCES `delivery_partners` (`partner_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_tracking`
--

LOCK TABLES `delivery_tracking` WRITE;
/*!40000 ALTER TABLE `delivery_tracking` DISABLE KEYS */;
INSERT INTO `delivery_tracking` VALUES (1,1,1,'delivered','2026-03-20 12:10:00','2026-03-20 12:42:00'),(2,2,2,'delivered','2026-03-21 13:10:00','2026-03-21 13:38:00'),(3,3,1,'delivered','2026-03-22 14:10:00','2026-03-22 14:43:00'),(4,4,3,'picked_up','2026-03-27 11:15:00',NULL),(5,5,NULL,'unassigned',NULL,NULL),(6,6,NULL,'unassigned',NULL,NULL);
/*!40000 ALTER TABLE `delivery_tracking` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ingredients`
--

DROP TABLE IF EXISTS `ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredients` (
  `ing_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `current_stock_qty` decimal(10,2) DEFAULT '0.00',
  `reorder_level` decimal(10,2) DEFAULT '0.00',
  `status` enum('available','low','out_of_stock') DEFAULT 'available',
  PRIMARY KEY (`ing_id`),
  UNIQUE KEY `name` (`name`),
  CONSTRAINT `chk_stock` CHECK ((`current_stock_qty` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredients`
--

LOCK TABLES `ingredients` WRITE;
/*!40000 ALTER TABLE `ingredients` DISABLE KEYS */;
INSERT INTO `ingredients` VALUES (1,'Chicken Breast','kg',25.00,5.00,'available'),(2,'Butter','kg',8.00,2.00,'available'),(3,'Tomato Puree','litre',15.00,3.00,'available'),(4,'Cream','litre',6.00,2.00,'available'),(5,'Black Lentils','kg',12.00,3.00,'available'),(6,'Flour','kg',20.00,5.00,'available'),(7,'Beef Patty','kg',10.00,3.00,'available'),(8,'Cheese','kg',5.00,1.50,'available'),(9,'Ramen Noodles','kg',8.00,2.00,'available'),(10,'Pork Mince','kg',6.00,2.00,'available'),(11,'Mozzarella','kg',7.00,2.00,'available'),(12,'Pasta','kg',10.00,3.00,'available');
/*!40000 ALTER TABLE `ingredients` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `trg_ingredient_before_update` BEFORE UPDATE ON `ingredients` FOR EACH ROW BEGIN
    IF NEW.current_stock_qty != OLD.current_stock_qty THEN
        SET NEW.status = CASE
            WHEN NEW.current_stock_qty = 0 THEN 'out_of_stock'
            WHEN NEW.current_stock_qty <= NEW.reorder_level THEN 'low'
            ELSE 'available'
        END;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `item_ratings`
--

DROP TABLE IF EXISTS `item_ratings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `item_ratings` (
  `rating_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `item_id` int NOT NULL,
  `order_id` int NOT NULL,
  `rating_value` tinyint NOT NULL,
  `review_text` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`rating_id`),
  UNIQUE KEY `uq_item_rating` (`customer_id`,`item_id`,`order_id`),
  KEY `fk_ir_item` (`item_id`),
  KEY `fk_ir_order` (`order_id`),
  CONSTRAINT `fk_ir_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_ir_item` FOREIGN KEY (`item_id`) REFERENCES `menu_items` (`item_id`),
  CONSTRAINT `fk_ir_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `chk_item_rating` CHECK ((`rating_value` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_ratings`
--

LOCK TABLES `item_ratings` WRITE;
/*!40000 ALTER TABLE `item_ratings` DISABLE KEYS */;
INSERT INTO `item_ratings` VALUES (1,1,1,1,5,'Absolutely delicious! Best Butter Chicken ever.','2026-04-02 13:18:03'),(2,1,2,1,4,'Dal Makhani was creamy and flavorful.','2026-04-02 13:18:03'),(3,2,4,2,4,'Great burger, loved the toppings!','2026-04-02 13:18:03'),(4,3,8,3,5,'Perfect crust on the Margherita!','2026-04-02 13:18:03'),(5,3,9,3,3,'Pasta was slightly overcooked but tasty.','2026-04-02 13:18:03');
/*!40000 ALTER TABLE `item_ratings` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `trg_item_rating_before_insert` BEFORE INSERT ON `item_ratings` FOR EACH ROW BEGIN
    DECLARE v_status VARCHAR(30);
    SELECT status INTO v_status FROM orders WHERE order_id = NEW.order_id;
    IF v_status != 'delivered' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot rate: order not yet delivered.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `menu_items`
--

DROP TABLE IF EXISTS `menu_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_items` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `brand_id` int NOT NULL,
  `item_name` varchar(100) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `prep_time` int DEFAULT NULL COMMENT 'in minutes',
  `category` varchar(50) DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT '1',
  `image_url` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`item_id`),
  KEY `fk_menu_brand` (`brand_id`),
  CONSTRAINT `fk_menu_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`brand_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_prep_time` CHECK ((`prep_time` >= 0)),
  CONSTRAINT `chk_price` CHECK ((`price` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_items`
--

LOCK TABLES `menu_items` WRITE;
/*!40000 ALTER TABLE `menu_items` DISABLE KEYS */;
INSERT INTO `menu_items` VALUES (1,1,'Butter Chicken','Creamy tomato-based chicken curry',280.00,20,'Main Course',1,NULL,'2026-04-02 13:17:59'),(2,1,'Dal Makhani','Slow-cooked black lentils with cream',200.00,25,'Main Course',1,NULL,'2026-04-02 13:17:59'),(3,1,'Garlic Naan','Freshly baked garlic flatbread',50.00,10,'Bread',1,NULL,'2026-04-02 13:17:59'),(4,2,'Classic Burger','Beef patty with lettuce and cheese',220.00,15,'Burgers',1,NULL,'2026-04-02 13:17:59'),(5,2,'Loaded Fries','Crispy fries with cheese sauce',150.00,10,'Sides',1,NULL,'2026-04-02 13:17:59'),(6,3,'Chicken Ramen','Rich broth with tender chicken',300.00,20,'Noodles',1,NULL,'2026-04-02 13:17:59'),(7,3,'Gyoza','Pan-fried pork dumplings',180.00,12,'Starters',1,NULL,'2026-04-02 13:17:59'),(8,4,'Margherita Pizza','Classic tomato and mozzarella',350.00,20,'Pizza',1,NULL,'2026-04-02 13:17:59'),(9,4,'Pasta Arrabiata','Spicy tomato pasta',250.00,15,'Pasta',1,NULL,'2026-04-02 13:17:59');
/*!40000 ALTER TABLE `menu_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `order_item_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`order_item_id`),
  KEY `fk_oi_order` (`order_id`),
  KEY `fk_oi_item` (`item_id`),
  CONSTRAINT `fk_oi_item` FOREIGN KEY (`item_id`) REFERENCES `menu_items` (`item_id`),
  CONSTRAINT `fk_oi_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_quantity` CHECK ((`quantity` > 0)),
  CONSTRAINT `chk_subtotal` CHECK ((`subtotal` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (1,1,1,1,280.00),(2,1,3,2,100.00),(3,1,2,1,200.00),(4,2,4,1,220.00),(5,3,8,1,350.00),(6,3,9,1,250.00),(7,3,5,1,150.00),(8,4,6,1,300.00),(9,5,1,1,280.00),(10,5,7,1,180.00),(11,5,3,1,50.00),(12,6,2,1,200.00);
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `trg_order_items_after_update` AFTER UPDATE ON `order_items` FOR EACH ROW BEGIN
    UPDATE orders
    SET total_amount = (
        SELECT IFNULL(SUM(subtotal), 0) FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `status` enum('pending','confirmed','preparing','out_for_delivery','delivered','cancelled') DEFAULT 'pending',
  `order_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `estimated_delivery_time` datetime DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `fk_order_customer` (`customer_id`),
  CONSTRAINT `fk_order_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `chk_total` CHECK ((`total_amount` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,1,530.00,'delivered','2026-03-20 12:00:00','2026-03-20 12:45:00'),(2,2,220.00,'delivered','2026-03-21 13:00:00','2026-03-21 13:40:00'),(3,3,650.00,'delivered','2026-03-22 14:00:00','2026-03-22 14:45:00'),(4,4,300.00,'out_for_delivery','2026-03-27 11:00:00','2026-03-27 11:45:00'),(5,5,480.00,'preparing','2026-03-27 12:30:00','2026-03-27 13:15:00'),(6,6,200.00,'pending','2026-03-27 13:00:00','2026-03-27 13:45:00');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `trg_order_after_insert` AFTER INSERT ON `orders` FOR EACH ROW BEGIN
    INSERT INTO delivery_tracking (order_id, status)
    VALUES (NEW.order_id, 'unassigned');
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `trg_order_status_update` AFTER UPDATE ON `orders` FOR EACH ROW BEGIN
    IF NEW.status = 'delivered' AND OLD.status != 'delivered' THEN
        
        UPDATE ingredients i
        JOIN recipes r ON i.ing_id = r.ing_id
        JOIN order_items oi ON r.item_id = oi.item_id
        SET i.current_stock_qty = i.current_stock_qty - (r.qty_required * oi.quantity)
        WHERE oi.order_id = NEW.order_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `payment_method` enum('cash','card','upi','wallet') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` enum('pending','completed','failed','refunded') DEFAULT 'pending',
  `payment_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `order_id` (`order_id`),
  CONSTRAINT `fk_payment_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,1,'upi',530.00,'completed','2026-04-02 13:18:02'),(2,2,'card',220.00,'completed','2026-04-02 13:18:02'),(3,3,'cash',650.00,'completed','2026-04-02 13:18:02'),(4,4,'upi',300.00,'completed','2026-04-02 13:18:02'),(5,5,'card',480.00,'pending','2026-04-02 13:18:02'),(6,6,'cash',200.00,'pending','2026-04-02 13:18:02');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recipes`
--

DROP TABLE IF EXISTS `recipes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recipes` (
  `recipe_id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `ing_id` int NOT NULL,
  `qty_required` decimal(10,2) NOT NULL,
  PRIMARY KEY (`recipe_id`),
  UNIQUE KEY `uq_recipe` (`item_id`,`ing_id`),
  KEY `fk_recipe_ing` (`ing_id`),
  CONSTRAINT `fk_recipe_ing` FOREIGN KEY (`ing_id`) REFERENCES `ingredients` (`ing_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_recipe_item` FOREIGN KEY (`item_id`) REFERENCES `menu_items` (`item_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_qty` CHECK ((`qty_required` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recipes`
--

LOCK TABLES `recipes` WRITE;
/*!40000 ALTER TABLE `recipes` DISABLE KEYS */;
INSERT INTO `recipes` VALUES (1,1,1,0.30),(2,1,2,0.05),(3,1,3,0.15),(4,1,4,0.10),(5,2,5,0.20),(6,2,2,0.03),(7,2,4,0.05),(8,3,6,0.10),(9,3,2,0.02),(10,4,7,0.20),(11,4,8,0.05),(12,5,6,0.15),(13,5,8,0.04),(14,6,1,0.25),(15,6,9,0.15),(16,7,10,0.20),(17,7,6,0.05),(18,8,11,0.15),(19,8,6,0.20),(20,8,3,0.10),(21,9,12,0.20),(22,9,3,0.12);
/*!40000 ALTER TABLE `recipes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_batches`
--

DROP TABLE IF EXISTS `stock_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_batches` (
  `batch_id` int NOT NULL AUTO_INCREMENT,
  `ing_id` int NOT NULL,
  `supplier_id` int NOT NULL,
  `received_qty` decimal(10,2) NOT NULL,
  `remaining_qty` decimal(10,2) NOT NULL,
  `expiry_date` date NOT NULL,
  `cost_per_unit` decimal(10,2) NOT NULL,
  `received_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`batch_id`),
  KEY `fk_batch_ing` (`ing_id`),
  KEY `fk_batch_supplier` (`supplier_id`),
  CONSTRAINT `fk_batch_ing` FOREIGN KEY (`ing_id`) REFERENCES `ingredients` (`ing_id`),
  CONSTRAINT `fk_batch_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`),
  CONSTRAINT `chk_batch_qty` CHECK ((`received_qty` > 0)),
  CONSTRAINT `chk_cost` CHECK ((`cost_per_unit` > 0)),
  CONSTRAINT `chk_remaining_qty` CHECK ((`remaining_qty` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_batches`
--

LOCK TABLES `stock_batches` WRITE;
/*!40000 ALTER TABLE `stock_batches` DISABLE KEYS */;
INSERT INTO `stock_batches` VALUES (1,1,2,30.00,25.00,'2026-04-10',250.00,'2026-04-02 13:18:00'),(2,2,4,10.00,8.00,'2026-04-15',180.00,'2026-04-02 13:18:00'),(3,3,1,20.00,15.00,'2026-05-01',60.00,'2026-04-02 13:18:00'),(4,4,4,8.00,6.00,'2026-04-12',120.00,'2026-04-02 13:18:00'),(5,5,3,15.00,12.00,'2026-06-01',90.00,'2026-04-02 13:18:00'),(6,6,3,25.00,20.00,'2026-07-01',45.00,'2026-04-02 13:18:00'),(7,7,2,12.00,10.00,'2026-04-08',300.00,'2026-04-02 13:18:00'),(8,8,4,7.00,5.00,'2026-04-20',350.00,'2026-04-02 13:18:00'),(9,11,4,9.00,7.00,'2026-04-18',400.00,'2026-04-02 13:18:00'),(10,12,3,12.00,10.00,'2026-08-01',80.00,'2026-04-02 13:18:00');
/*!40000 ALTER TABLE `stock_batches` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `trg_stock_batch_before_update` BEFORE UPDATE ON `stock_batches` FOR EACH ROW BEGIN
    IF NEW.remaining_qty < 0 THEN
        SET NEW.remaining_qty = 0;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `suppliers` (
  `supplier_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`supplier_id`),
  UNIQUE KEY `phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES (1,'Fresh Farms Ltd','9876543210','supply@freshfarms.com','Industrial Area, Bangalore','2026-04-02 13:18:00'),(2,'Quality Meats Co','9876543211','orders@qualitymeats.com','Meat Market, Bangalore','2026-04-02 13:18:00'),(3,'Grain Masters','9876543212','sales@grainmasters.com','Wholesale Hub, Mysore','2026-04-02 13:18:00'),(4,'Dairy Direct','9876543213','info@dairydirect.com','Dairy Colony, Pune','2026-04-02 13:18:00');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_menu_ratings`
--

DROP TABLE IF EXISTS `vw_menu_ratings`;
/*!50001 DROP VIEW IF EXISTS `vw_menu_ratings`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_menu_ratings` AS SELECT 
 1 AS `item_id`,
 1 AS `brand_name`,
 1 AS `item_name`,
 1 AS `price`,
 1 AS `category`,
 1 AS `avg_rating`,
 1 AS `review_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_order_summary`
--

DROP TABLE IF EXISTS `vw_order_summary`;
/*!50001 DROP VIEW IF EXISTS `vw_order_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_order_summary` AS SELECT 
 1 AS `order_id`,
 1 AS `customer_name`,
 1 AS `phone`,
 1 AS `total_amount`,
 1 AS `status`,
 1 AS `order_time`,
 1 AS `payment_method`,
 1 AS `payment_status`,
 1 AS `delivery_partner`,
 1 AS `delivery_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `wastage_log`
--

DROP TABLE IF EXISTS `wastage_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wastage_log` (
  `wastage_id` int NOT NULL AUTO_INCREMENT,
  `ing_id` int NOT NULL,
  `qty_wasted` decimal(10,2) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `logged_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`wastage_id`),
  KEY `fk_wastage_ing` (`ing_id`),
  CONSTRAINT `fk_wastage_ing` FOREIGN KEY (`ing_id`) REFERENCES `ingredients` (`ing_id`),
  CONSTRAINT `chk_wasted` CHECK ((`qty_wasted` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wastage_log`
--

LOCK TABLES `wastage_log` WRITE;
/*!40000 ALTER TABLE `wastage_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `wastage_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'cloud_kitchen'
--

--
-- Dumping routines for database 'cloud_kitchen'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_brand_revenue` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_brand_revenue`(p_brand_id INT) RETURNS decimal(12,2)
    DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(12,2);
    SELECT IFNULL(SUM(oi.subtotal), 0)
    INTO v_total
    FROM order_items oi
    JOIN orders o    ON oi.order_id = o.order_id
    JOIN menu_items m ON oi.item_id = m.item_id
    WHERE m.brand_id = p_brand_id AND o.status = 'delivered';
    RETURN v_total;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_calc_order_total` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_calc_order_total`(p_order_id INT) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT IFNULL(SUM(subtotal), 0) INTO v_total
    FROM order_items WHERE order_id = p_order_id;
    RETURN v_total;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_customer_order_count` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_customer_order_count`(p_customer_id INT) RETURNS int
    DETERMINISTIC
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM orders
    WHERE customer_id = p_customer_id AND status != 'cancelled';
    RETURN v_count;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_item_avg_rating` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_item_avg_rating`(p_item_id INT) RETURNS decimal(3,2)
    DETERMINISTIC
BEGIN
    DECLARE v_avg DECIMAL(3,2);
    SELECT ROUND(AVG(rating_value), 2) INTO v_avg
    FROM item_ratings WHERE item_id = p_item_id;
    RETURN IFNULL(v_avg, 0.00);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_stock_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_stock_status`(p_ing_id INT) RETURNS varchar(20) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE v_qty   DECIMAL(10,2);
    DECLARE v_level DECIMAL(10,2);
    SELECT current_stock_qty, reorder_level INTO v_qty, v_level
    FROM ingredients WHERE ing_id = p_ing_id;
    IF v_qty = 0 THEN RETURN 'out_of_stock';
    ELSEIF v_qty <= v_level THEN RETURN 'low';
    ELSE RETURN 'available';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_add_order_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_add_order_item`(
    IN p_order_id  INT,
    IN p_item_id   INT,
    IN p_quantity  INT
)
BEGIN
    DECLARE v_price    DECIMAL(10,2);
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_avail    TINYINT;

    SELECT price, is_available INTO v_price, v_avail
    FROM menu_items WHERE item_id = p_item_id;

    IF v_avail = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Item is not available.';
    END IF;

    SET v_subtotal = v_price * p_quantity;

    INSERT INTO order_items (order_id, item_id, quantity, subtotal)
    VALUES (p_order_id, p_item_id, p_quantity, v_subtotal);

    UPDATE orders SET total_amount = total_amount + v_subtotal
    WHERE order_id = p_order_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_assign_delivery` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_assign_delivery`(
    IN p_order_id   INT,
    IN p_partner_id INT,
    OUT p_message   VARCHAR(255)
)
BEGIN
    DECLARE v_partner_status VARCHAR(20);

    SELECT status INTO v_partner_status
    FROM delivery_partners WHERE partner_id = p_partner_id;

    IF v_partner_status != 'available' THEN
        SET p_message = 'Delivery partner is not available.';
    ELSE
        UPDATE delivery_tracking
           SET partner_id = p_partner_id,
               status = 'assigned',
               assigned_at = NOW()
         WHERE order_id = p_order_id;

        UPDATE delivery_partners SET status = 'on_delivery'
        WHERE partner_id = p_partner_id;

        UPDATE orders SET status = 'out_for_delivery'
        WHERE order_id = p_order_id;

        SET p_message = 'Delivery partner assigned successfully.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_brand_revenue_report` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_brand_revenue_report`()
BEGIN
    DECLARE v_done      INT DEFAULT 0;
    DECLARE v_brand_id  INT;
    DECLARE v_brand_name VARCHAR(100);
    DECLARE v_revenue   DECIMAL(12,2);

    DECLARE cur_brands CURSOR FOR
        SELECT brand_id, brand_name FROM brands WHERE status = 'active';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_brand_rev (
        brand_id   INT,
        brand_name VARCHAR(100),
        revenue    DECIMAL(12,2)
    );
    TRUNCATE TABLE tmp_brand_rev;

    OPEN cur_brands;
    brand_loop: LOOP
        FETCH cur_brands INTO v_brand_id, v_brand_name;
        IF v_done = 1 THEN LEAVE brand_loop; END IF;
        SET v_revenue = fn_brand_revenue(v_brand_id);
        INSERT INTO tmp_brand_rev VALUES (v_brand_id, v_brand_name, v_revenue);
    END LOOP;
    CLOSE cur_brands;

    SELECT * FROM tmp_brand_rev ORDER BY revenue DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_complete_delivery` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_complete_delivery`(
    IN p_order_id INT
)
BEGIN
    DECLARE v_partner_id INT;

    SELECT partner_id INTO v_partner_id
    FROM delivery_tracking WHERE order_id = p_order_id;

    UPDATE delivery_tracking
    SET status = 'delivered', delivered_at = NOW()
    WHERE order_id = p_order_id;

    UPDATE orders SET status = 'delivered'
    WHERE order_id = p_order_id;

    UPDATE payments SET status = 'completed'
    WHERE order_id = p_order_id AND status = 'pending';

    IF v_partner_id IS NOT NULL THEN
        UPDATE delivery_partners SET status = 'available'
        WHERE partner_id = v_partner_id;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_low_stock_report` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_low_stock_report`()
BEGIN
    DECLARE v_done        INT DEFAULT 0;
    DECLARE v_ing_id      INT;
    DECLARE v_name        VARCHAR(100);
    DECLARE v_stock       DECIMAL(10,2);
    DECLARE v_reorder     DECIMAL(10,2);
    DECLARE v_unit        VARCHAR(20);

    DECLARE cur_ingredients CURSOR FOR
        SELECT ing_id, name, current_stock_qty, reorder_level, unit
        FROM ingredients
        WHERE current_stock_qty <= reorder_level
        ORDER BY current_stock_qty;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_low_stock (
        ing_id   INT,
        name     VARCHAR(100),
        stock    DECIMAL(10,2),
        reorder  DECIMAL(10,2),
        unit     VARCHAR(20),
        deficit  DECIMAL(10,2)
    );
    TRUNCATE TABLE tmp_low_stock;

    OPEN cur_ingredients;
    read_loop: LOOP
        FETCH cur_ingredients INTO v_ing_id, v_name, v_stock, v_reorder, v_unit;
        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;
        INSERT INTO tmp_low_stock VALUES
            (v_ing_id, v_name, v_stock, v_reorder, v_unit, v_reorder - v_stock);
    END LOOP;
    CLOSE cur_ingredients;

    SELECT * FROM tmp_low_stock ORDER BY deficit DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_place_order` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_place_order`(
    IN  p_customer_id  INT,
    OUT p_order_id     INT,
    OUT p_message      VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error placing order. Transaction rolled back.';
        SET p_order_id = -1;
    END;

    START TRANSACTION;
        INSERT INTO orders (customer_id, total_amount, status)
        VALUES (p_customer_id, 0.00, 'pending');
        SET p_order_id = LAST_INSERT_ID();
        SET p_message = CONCAT('Order #', p_order_id, ' created successfully.');
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_receive_stock` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_receive_stock`(
    IN p_ing_id      INT,
    IN p_supplier_id INT,
    IN p_qty         DECIMAL(10,2),
    IN p_expiry      DATE,
    IN p_cost        DECIMAL(10,2)
)
BEGIN
    INSERT INTO stock_batches
        (ing_id, supplier_id, received_qty, remaining_qty, expiry_date, cost_per_unit)
    VALUES (p_ing_id, p_supplier_id, p_qty, p_qty, p_expiry, p_cost);

    UPDATE ingredients
    SET current_stock_qty = current_stock_qty + p_qty
    WHERE ing_id = p_ing_id;

    
    UPDATE ingredients
    SET status = CASE
        WHEN current_stock_qty = 0 THEN 'out_of_stock'
        WHEN current_stock_qty <= reorder_level THEN 'low'
        ELSE 'available'
    END
    WHERE ing_id = p_ing_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vw_menu_ratings`
--

/*!50001 DROP VIEW IF EXISTS `vw_menu_ratings`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_menu_ratings` AS select `m`.`item_id` AS `item_id`,`b`.`brand_name` AS `brand_name`,`m`.`item_name` AS `item_name`,`m`.`price` AS `price`,`m`.`category` AS `category`,round(avg(`ir`.`rating_value`),1) AS `avg_rating`,count(`ir`.`rating_id`) AS `review_count` from ((`menu_items` `m` join `brands` `b` on((`m`.`brand_id` = `b`.`brand_id`))) left join `item_ratings` `ir` on((`m`.`item_id` = `ir`.`item_id`))) group by `m`.`item_id`,`b`.`brand_name`,`m`.`item_name`,`m`.`price`,`m`.`category` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_order_summary`
--

/*!50001 DROP VIEW IF EXISTS `vw_order_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_order_summary` AS select `o`.`order_id` AS `order_id`,`c`.`name` AS `customer_name`,`c`.`phone` AS `phone`,`o`.`total_amount` AS `total_amount`,`o`.`status` AS `status`,`o`.`order_time` AS `order_time`,`p`.`payment_method` AS `payment_method`,`p`.`status` AS `payment_status`,`dp`.`name` AS `delivery_partner`,`dt`.`status` AS `delivery_status` from ((((`orders` `o` join `customers` `c` on((`o`.`customer_id` = `c`.`customer_id`))) left join `payments` `p` on((`o`.`order_id` = `p`.`order_id`))) left join `delivery_tracking` `dt` on((`o`.`order_id` = `dt`.`order_id`))) left join `delivery_partners` `dp` on((`dt`.`partner_id` = `dp`.`partner_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-02 19:01:09
