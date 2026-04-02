-- ============================================================
-- SAMPLE DATA - CLOUD KITCHEN MANAGEMENT SYSTEM
-- ============================================================
USE cloud_kitchen;

-- Admin
INSERT INTO admin_users (username, password_hash, full_name, email) VALUES
('admin', '$2y$10$examplehashedpassword', 'Super Admin', 'admin@cloudkitchen.com');

-- Brands
INSERT INTO brands (brand_name, cuisine_type, status) VALUES
('Spice Route', 'Indian', 'active'),
('Burgerburg', 'American', 'active'),
('Tokyo Bites', 'Japanese', 'active'),
('Pizza Pronto', 'Italian', 'active');

-- Menu Items
INSERT INTO menu_items (brand_id, item_name, description, price, prep_time, category) VALUES
(1, 'Butter Chicken', 'Creamy tomato-based chicken curry', 280.00, 20, 'Main Course'),
(1, 'Dal Makhani', 'Slow-cooked black lentils with cream', 200.00, 25, 'Main Course'),
(1, 'Garlic Naan', 'Freshly baked garlic flatbread', 50.00, 10, 'Bread'),
(2, 'Classic Burger', 'Beef patty with lettuce and cheese', 220.00, 15, 'Burgers'),
(2, 'Loaded Fries', 'Crispy fries with cheese sauce', 150.00, 10, 'Sides'),
(3, 'Chicken Ramen', 'Rich broth with tender chicken', 300.00, 20, 'Noodles'),
(3, 'Gyoza', 'Pan-fried pork dumplings', 180.00, 12, 'Starters'),
(4, 'Margherita Pizza', 'Classic tomato and mozzarella', 350.00, 20, 'Pizza'),
(4, 'Pasta Arrabiata', 'Spicy tomato pasta', 250.00, 15, 'Pasta');

-- Ingredients
INSERT INTO ingredients (name, unit, current_stock_qty, reorder_level, status) VALUES
('Chicken Breast', 'kg', 25.00, 5.00, 'available'),
('Butter', 'kg', 8.00, 2.00, 'available'),
('Tomato Puree', 'litre', 15.00, 3.00, 'available'),
('Cream', 'litre', 6.00, 2.00, 'available'),
('Black Lentils', 'kg', 12.00, 3.00, 'available'),
('Flour', 'kg', 20.00, 5.00, 'available'),
('Beef Patty', 'kg', 10.00, 3.00, 'available'),
('Cheese', 'kg', 5.00, 1.50, 'available'),
('Ramen Noodles', 'kg', 8.00, 2.00, 'available'),
('Pork Mince', 'kg', 6.00, 2.00, 'available'),
('Mozzarella', 'kg', 7.00, 2.00, 'available'),
('Pasta', 'kg', 10.00, 3.00, 'available');

-- Recipes
INSERT INTO recipes (item_id, ing_id, qty_required) VALUES
(1, 1, 0.30), (1, 2, 0.05), (1, 3, 0.15), (1, 4, 0.10),
(2, 5, 0.20), (2, 2, 0.03), (2, 4, 0.05),
(3, 6, 0.10), (3, 2, 0.02),
(4, 7, 0.20), (4, 8, 0.05),
(5, 6, 0.15), (5, 8, 0.04),
(6, 1, 0.25), (6, 9, 0.15),
(7, 10, 0.20), (7, 6, 0.05),
(8, 11, 0.15), (8, 6, 0.20), (8, 3, 0.10),
(9, 12, 0.20), (9, 3, 0.12);

-- Suppliers
INSERT INTO suppliers (name, phone, email, address) VALUES
('Fresh Farms Ltd',    '9876543210', 'supply@freshfarms.com', 'Industrial Area, Bangalore'),
('Quality Meats Co',   '9876543211', 'orders@qualitymeats.com', 'Meat Market, Bangalore'),
('Grain Masters',      '9876543212', 'sales@grainmasters.com', 'Wholesale Hub, Mysore'),
('Dairy Direct',       '9876543213', 'info@dairydirect.com', 'Dairy Colony, Pune');

-- Stock Batches
INSERT INTO stock_batches (ing_id, supplier_id, received_qty, remaining_qty, expiry_date, cost_per_unit) VALUES
(1, 2, 30.00, 25.00, '2026-04-10', 250.00),
(2, 4, 10.00, 8.00,  '2026-04-15', 180.00),
(3, 1, 20.00, 15.00, '2026-05-01', 60.00),
(4, 4, 8.00,  6.00,  '2026-04-12', 120.00),
(5, 3, 15.00, 12.00, '2026-06-01', 90.00),
(6, 3, 25.00, 20.00, '2026-07-01', 45.00),
(7, 2, 12.00, 10.00, '2026-04-08', 300.00),
(8, 4, 7.00,  5.00,  '2026-04-20', 350.00),
(11,4, 9.00,  7.00,  '2026-04-18', 400.00),
(12,3, 12.00, 10.00, '2026-08-01', 80.00);

-- Customers
INSERT INTO customers (name, phone, email, address) VALUES
('Arjun Sharma',    '9000000001', 'arjun@email.com',   '12 MG Road, Bangalore'),
('Priya Nair',      '9000000002', 'priya@email.com',   '45 Koramangala, Bangalore'),
('Rahul Mehta',     '9000000003', 'rahul@email.com',   '78 Indiranagar, Bangalore'),
('Sneha Patel',     '9000000004', 'sneha@email.com',   '23 Whitefield, Bangalore'),
('Vikram Reddy',    '9000000005', 'vikram@email.com',  '56 HSR Layout, Bangalore'),
('Anjali Singh',    '9000000006', 'anjali@email.com',  '90 Jayanagar, Bangalore');

UPDATE customers
SET password_hash = '$2a$10$jOezsqkssyJhyALcq.f3duSp6F2x/KUc3jEz8nFFQsB/XQ1JrrgZu'
WHERE email = 'arjun@email.com';

-- Delivery Partners
INSERT INTO delivery_partners (name, phone, vehicle_no, status) VALUES
('Ravi Kumar',   '8000000001', 'KA01AB1234', 'available'),
('Suresh Babu',  '8000000002', 'KA02CD5678', 'available'),
('Mohan Das',    '8000000003', 'KA03EF9012', 'on_delivery'),
('Kiran Joshi',  '8000000004', 'KA04GH3456', 'offline');

-- Orders
INSERT INTO orders (customer_id, total_amount, status, order_time, estimated_delivery_time) VALUES
(1, 530.00, 'delivered',          '2026-03-20 12:00:00', '2026-03-20 12:45:00'),
(2, 220.00, 'delivered',          '2026-03-21 13:00:00', '2026-03-21 13:40:00'),
(3, 650.00, 'delivered',          '2026-03-22 14:00:00', '2026-03-22 14:45:00'),
(4, 300.00, 'out_for_delivery',   '2026-03-27 11:00:00', '2026-03-27 11:45:00'),
(5, 480.00, 'preparing',          '2026-03-27 12:30:00', '2026-03-27 13:15:00'),
(6, 200.00, 'pending',            '2026-03-27 13:00:00', '2026-03-27 13:45:00');

-- Order Items
INSERT INTO order_items (order_id, item_id, quantity, subtotal) VALUES
(1, 1, 1, 280.00), (1, 3, 2, 100.00), (1, 2, 1, 200.00),  -- Order 1: Butter Chicken, Naan, Dal Makhani
(2, 4, 1, 220.00),                                          -- Order 2: Classic Burger
(3, 8, 1, 350.00), (3, 9, 1, 250.00), (3, 5, 1, 150.00),  -- Order 3: Pizza, Pasta, Fries
(4, 6, 1, 300.00),                                          -- Order 4: Ramen
(5, 1, 1, 280.00), (5, 7, 1, 180.00), (5, 3, 1, 50.00),   -- Order 5
(6, 2, 1, 200.00);                                          -- Order 6

-- Payments
INSERT INTO payments (order_id, payment_method, amount, status) VALUES
(1, 'upi',  530.00, 'completed'),
(2, 'card', 220.00, 'completed'),
(3, 'cash', 650.00, 'completed'),
(4, 'upi',  300.00, 'completed'),
(5, 'card', 480.00, 'pending'),
(6, 'cash', 200.00, 'pending');

-- Delivery Tracking
INSERT INTO delivery_tracking (order_id, partner_id, status, assigned_at, delivered_at) VALUES
(1, 1, 'delivered',  '2026-03-20 12:10:00', '2026-03-20 12:42:00'),
(2, 2, 'delivered',  '2026-03-21 13:10:00', '2026-03-21 13:38:00'),
(3, 1, 'delivered',  '2026-03-22 14:10:00', '2026-03-22 14:43:00'),
(4, 3, 'picked_up',  '2026-03-27 11:15:00', NULL),
(5, NULL, 'unassigned', NULL, NULL),
(6, NULL, 'unassigned', NULL, NULL);

-- Item Ratings
INSERT INTO item_ratings (customer_id, item_id, order_id, rating_value, review_text) VALUES
(1, 1, 1, 5, 'Absolutely delicious! Best Butter Chicken ever.'),
(1, 2, 1, 4, 'Dal Makhani was creamy and flavorful.'),
(2, 4, 2, 4, 'Great burger, loved the toppings!'),
(3, 8, 3, 5, 'Perfect crust on the Margherita!'),
(3, 9, 3, 3, 'Pasta was slightly overcooked but tasty.');

-- Delivery Ratings
INSERT INTO delivery_ratings (customer_id, partner_id, order_id, rating_value, feedback) VALUES
(1, 1, 1, 5, 'Super fast delivery, very polite!'),
(2, 2, 2, 4, 'On time and professional.'),
(3, 1, 3, 5, 'Excellent service!');
