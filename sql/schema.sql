-- ============================================================
-- CLOUD KITCHEN MANAGEMENT SYSTEM
-- Complete Database Schema
-- Author: Final Year Project
-- ============================================================

CREATE DATABASE IF NOT EXISTS cloud_kitchen;
USE cloud_kitchen;

-- ============================================================
-- DROP TABLES (clean slate)
-- ============================================================
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS delivery_ratings;
DROP TABLE IF EXISTS item_ratings;
DROP TABLE IF EXISTS wastage_log;
DROP TABLE IF EXISTS stock_batches;
DROP TABLE IF EXISTS recipes;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS delivery_tracking;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS delivery_partners;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS ingredients;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS brands;
DROP TABLE IF EXISTS admin_users;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- TABLE 1: ADMIN_USERS
-- ============================================================
CREATE TABLE admin_users (
    admin_id      INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(100),
    email         VARCHAR(100) UNIQUE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 2: BRANDS
-- ============================================================
CREATE TABLE brands (
    brand_id     INT AUTO_INCREMENT PRIMARY KEY,
    brand_name   VARCHAR(100) NOT NULL,
    cuisine_type VARCHAR(50),
    logo_url     VARCHAR(255),
    status       ENUM('active','inactive') DEFAULT 'active',
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_brand_status CHECK (status IN ('active','inactive'))
);

-- ============================================================
-- TABLE 3: MENU_ITEMS
-- ============================================================
CREATE TABLE menu_items (
    item_id      INT AUTO_INCREMENT PRIMARY KEY,
    brand_id     INT NOT NULL,
    item_name    VARCHAR(100) NOT NULL,
    description  TEXT,
    price        DECIMAL(10,2) NOT NULL,
    prep_time    INT COMMENT 'in minutes',
    category     VARCHAR(50),
    is_available TINYINT(1) DEFAULT 1,
    image_url    VARCHAR(255),
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_menu_brand FOREIGN KEY (brand_id) REFERENCES brands(brand_id) ON DELETE CASCADE,
    CONSTRAINT chk_price CHECK (price > 0),
    CONSTRAINT chk_prep_time CHECK (prep_time >= 0)
);

-- ============================================================
-- TABLE 4: INGREDIENTS
-- ============================================================
CREATE TABLE ingredients (
    ing_id            INT AUTO_INCREMENT PRIMARY KEY,
    name              VARCHAR(100) NOT NULL UNIQUE,
    unit              VARCHAR(20) NOT NULL,
    current_stock_qty DECIMAL(10,2) DEFAULT 0,
    reorder_level     DECIMAL(10,2) DEFAULT 0,
    status            ENUM('available','low','out_of_stock') DEFAULT 'available',
    CONSTRAINT chk_stock CHECK (current_stock_qty >= 0)
);

-- ============================================================
-- TABLE 5: RECIPES (M:N between Menu_Items & Ingredients)
-- ============================================================
CREATE TABLE recipes (
    recipe_id    INT AUTO_INCREMENT PRIMARY KEY,
    item_id      INT NOT NULL,
    ing_id       INT NOT NULL,
    qty_required DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_recipe_item FOREIGN KEY (item_id) REFERENCES menu_items(item_id) ON DELETE CASCADE,
    CONSTRAINT fk_recipe_ing  FOREIGN KEY (ing_id)  REFERENCES ingredients(ing_id) ON DELETE CASCADE,
    CONSTRAINT uq_recipe UNIQUE (item_id, ing_id),
    CONSTRAINT chk_qty CHECK (qty_required > 0)
);

-- ============================================================
-- TABLE 6: SUPPLIERS
-- ============================================================
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    phone       VARCHAR(15) NOT NULL UNIQUE,
    email       VARCHAR(100),
    address     TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 7: STOCK_BATCHES
-- ============================================================
CREATE TABLE stock_batches (
    batch_id       INT AUTO_INCREMENT PRIMARY KEY,
    ing_id         INT NOT NULL,
    supplier_id    INT NOT NULL,
    received_qty   DECIMAL(10,2) NOT NULL,
    remaining_qty  DECIMAL(10,2) NOT NULL,
    expiry_date    DATE NOT NULL,
    cost_per_unit  DECIMAL(10,2) NOT NULL,
    received_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_batch_ing      FOREIGN KEY (ing_id)      REFERENCES ingredients(ing_id),
    CONSTRAINT fk_batch_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT chk_batch_qty     CHECK (received_qty > 0),
    CONSTRAINT chk_remaining_qty CHECK (remaining_qty >= 0),
    CONSTRAINT chk_cost          CHECK (cost_per_unit > 0)
);

-- ============================================================
-- TABLE 8: CUSTOMERS
-- ============================================================
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    phone       VARCHAR(15)  NOT NULL UNIQUE,
    email       VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255),
    address     TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 9: DELIVERY_PARTNERS
-- ============================================================
CREATE TABLE delivery_partners (
    partner_id  INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    phone       VARCHAR(15)  NOT NULL UNIQUE,
    vehicle_no  VARCHAR(20),
    status      ENUM('available','on_delivery','offline') DEFAULT 'available',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 10: ORDERS
-- ============================================================
CREATE TABLE orders (
    order_id                INT AUTO_INCREMENT PRIMARY KEY,
    customer_id             INT NOT NULL,
    total_amount            DECIMAL(10,2) NOT NULL DEFAULT 0,
    status                  ENUM('pending','confirmed','preparing','out_for_delivery','delivered','cancelled') DEFAULT 'pending',
    order_time              DATETIME DEFAULT CURRENT_TIMESTAMP,
    estimated_delivery_time DATETIME,
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT chk_total CHECK (total_amount >= 0)
);

-- ============================================================
-- TABLE 11: ORDER_ITEMS (M:N between Orders & Menu_Items)
-- ============================================================
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id      INT NOT NULL,
    item_id       INT NOT NULL,
    quantity      INT NOT NULL,
    subtotal      DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_oi_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_oi_item  FOREIGN KEY (item_id)  REFERENCES menu_items(item_id),
    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT chk_subtotal CHECK (subtotal >= 0)
);

-- ============================================================
-- TABLE 12: PAYMENTS
-- ============================================================
CREATE TABLE payments (
    payment_id     INT AUTO_INCREMENT PRIMARY KEY,
    order_id       INT NOT NULL UNIQUE,
    payment_method ENUM('cash','card','upi','wallet') NOT NULL,
    amount         DECIMAL(10,2) NOT NULL,
    status         ENUM('pending','completed','failed','refunded') DEFAULT 'pending',
    payment_time   DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ============================================================
-- TABLE 13: DELIVERY_TRACKING
-- ============================================================
CREATE TABLE delivery_tracking (
    tracking_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id    INT NOT NULL UNIQUE,
    partner_id  INT,
    status      ENUM('unassigned','assigned','picked_up','delivered') DEFAULT 'unassigned',
    assigned_at DATETIME,
    delivered_at DATETIME,
    CONSTRAINT fk_tracking_order   FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    CONSTRAINT fk_tracking_partner FOREIGN KEY (partner_id) REFERENCES delivery_partners(partner_id)
);

-- ============================================================
-- TABLE 14: WASTAGE_LOG
-- ============================================================
CREATE TABLE wastage_log (
    wastage_id   INT AUTO_INCREMENT PRIMARY KEY,
    ing_id       INT NOT NULL,
    qty_wasted   DECIMAL(10,2) NOT NULL,
    reason       VARCHAR(255),
    logged_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_wastage_ing FOREIGN KEY (ing_id) REFERENCES ingredients(ing_id),
    CONSTRAINT chk_wasted CHECK (qty_wasted > 0)
);

-- ============================================================
-- TABLE 15: ITEM_RATINGS
-- ============================================================
CREATE TABLE item_ratings (
    rating_id    INT AUTO_INCREMENT PRIMARY KEY,
    customer_id  INT NOT NULL,
    item_id      INT NOT NULL,
    order_id     INT NOT NULL,
    rating_value TINYINT NOT NULL,
    review_text  TEXT,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ir_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_ir_item     FOREIGN KEY (item_id)     REFERENCES menu_items(item_id),
    CONSTRAINT fk_ir_order    FOREIGN KEY (order_id)    REFERENCES orders(order_id),
    CONSTRAINT chk_item_rating CHECK (rating_value BETWEEN 1 AND 5),
    CONSTRAINT uq_item_rating UNIQUE (customer_id, item_id, order_id)
);

-- ============================================================
-- TABLE 16: DELIVERY_RATINGS
-- ============================================================
CREATE TABLE delivery_ratings (
    delivery_rating_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id        INT NOT NULL,
    partner_id         INT NOT NULL,
    order_id           INT NOT NULL UNIQUE,
    rating_value       TINYINT NOT NULL,
    feedback           TEXT,
    created_at         DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_dr_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_dr_partner  FOREIGN KEY (partner_id)  REFERENCES delivery_partners(partner_id),
    CONSTRAINT fk_dr_order    FOREIGN KEY (order_id)    REFERENCES orders(order_id),
    CONSTRAINT chk_delivery_rating CHECK (rating_value BETWEEN 1 AND 5)
);
