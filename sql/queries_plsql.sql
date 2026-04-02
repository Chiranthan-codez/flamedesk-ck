-- ============================================================
-- CLOUD KITCHEN MANAGEMENT SYSTEM
-- SQL Queries + PL/SQL: Procedures, Functions, Triggers, Cursors
-- ============================================================
USE cloud_kitchen;

-- ============================================================
-- SECTION A: BASIC QUERIES (10)
-- ============================================================

-- Q1: List all active menu items with brand name
SELECT m.item_id, b.brand_name, m.item_name, m.price, m.category, m.prep_time
FROM menu_items m
JOIN brands b ON m.brand_id = b.brand_id
WHERE m.is_available = 1
ORDER BY b.brand_name, m.category;

-- Q2: All orders with customer name and status
SELECT o.order_id, c.name AS customer_name, c.phone,
       o.total_amount, o.status, o.order_time
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_time DESC;

-- Q3: Ingredients below reorder level
SELECT ing_id, name, unit, current_stock_qty, reorder_level
FROM ingredients
WHERE current_stock_qty <= reorder_level;

-- Q4: All delivery partners and their current status
SELECT partner_id, name, phone, vehicle_no, status
FROM delivery_partners
ORDER BY status;

-- Q5: Payments by method
SELECT payment_method, COUNT(*) AS total_transactions,
       SUM(amount) AS total_amount
FROM payments
WHERE status = 'completed'
GROUP BY payment_method;

-- Q6: Pending orders (not delivered/cancelled)
SELECT o.order_id, c.name, o.total_amount, o.status, o.order_time
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
WHERE o.status NOT IN ('delivered','cancelled');

-- Q7: Stock batches expiring within 30 days
SELECT sb.batch_id, i.name AS ingredient, sb.remaining_qty,
       sb.expiry_date, s.name AS supplier,
       DATEDIFF(sb.expiry_date, CURDATE()) AS days_left
FROM stock_batches sb
JOIN ingredients i ON sb.ing_id = i.ing_id
JOIN suppliers s ON sb.supplier_id = s.supplier_id
WHERE sb.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  AND sb.remaining_qty > 0
ORDER BY days_left;

-- Q8: Items ordered in a specific order
SELECT oi.order_id, m.item_name, oi.quantity, oi.subtotal
FROM order_items oi JOIN menu_items m ON oi.item_id = m.item_id
WHERE oi.order_id = 1;

-- Q9: Brands with their item count
SELECT b.brand_name, COUNT(m.item_id) AS item_count
FROM brands b LEFT JOIN menu_items m ON b.brand_id = m.brand_id
GROUP BY b.brand_id, b.brand_name;

-- Q10: All customer ratings with item and customer info
SELECT ir.rating_id, c.name AS customer, m.item_name,
       ir.rating_value, ir.review_text, ir.created_at
FROM item_ratings ir
JOIN customers c  ON ir.customer_id = c.customer_id
JOIN menu_items m ON ir.item_id = m.item_id
ORDER BY ir.created_at DESC;


-- ============================================================
-- SECTION B: COMPLEX QUERIES (10)
-- ============================================================

-- CQ1: Top 5 highest rated menu items (avg rating, total reviews)
SELECT m.item_id, m.item_name, b.brand_name,
       ROUND(AVG(ir.rating_value), 2)  AS avg_rating,
       COUNT(ir.rating_id)             AS total_reviews,
       m.price
FROM menu_items m
JOIN brands b ON m.brand_id = b.brand_id
LEFT JOIN item_ratings ir ON m.item_id = ir.item_id
GROUP BY m.item_id, m.item_name, b.brand_name, m.price
HAVING COUNT(ir.rating_id) > 0
ORDER BY avg_rating DESC, total_reviews DESC
LIMIT 5;

-- CQ2: Revenue per brand (last 30 days)
SELECT b.brand_name,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(oi.subtotal)           AS total_revenue
FROM brands b
JOIN menu_items m  ON b.brand_id = m.brand_id
JOIN order_items oi ON m.item_id = oi.item_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'delivered'
  AND o.order_time >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY b.brand_id, b.brand_name
ORDER BY total_revenue DESC;

-- CQ3: Best delivery partners (avg delivery rating + orders completed)
SELECT dp.partner_id, dp.name, dp.vehicle_no,
       COUNT(dt.tracking_id)         AS deliveries_done,
       ROUND(AVG(dr.rating_value),2) AS avg_rating
FROM delivery_partners dp
LEFT JOIN delivery_tracking dt ON dp.partner_id = dt.partner_id AND dt.status = 'delivered'
LEFT JOIN delivery_ratings dr  ON dp.partner_id = dr.partner_id
GROUP BY dp.partner_id, dp.name, dp.vehicle_no
ORDER BY avg_rating DESC, deliveries_done DESC;

-- CQ4: Customers who ordered more than once with total spend
SELECT c.customer_id, c.name, c.phone,
       COUNT(o.order_id) AS order_count,
       SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status != 'cancelled'
GROUP BY c.customer_id, c.name, c.phone
HAVING COUNT(o.order_id) > 1
ORDER BY total_spent DESC;

-- CQ5: Ingredients used most (qty consumed via recipes * orders)
SELECT i.name AS ingredient, i.unit,
       SUM(r.qty_required * oi.quantity) AS total_consumed
FROM ingredients i
JOIN recipes r       ON i.ing_id = r.ing_id
JOIN order_items oi  ON r.item_id = oi.item_id
JOIN orders o        ON oi.order_id = o.order_id
WHERE o.status = 'delivered'
GROUP BY i.ing_id, i.name, i.unit
ORDER BY total_consumed DESC;

-- CQ6: Most popular items (by quantity ordered)
SELECT m.item_id, m.item_name, b.brand_name, m.category,
       SUM(oi.quantity) AS total_qty_ordered,
       SUM(oi.subtotal) AS revenue_generated
FROM menu_items m
JOIN brands b       ON m.brand_id = b.brand_id
JOIN order_items oi ON m.item_id = oi.item_id
JOIN orders o       ON oi.order_id = o.order_id
WHERE o.status != 'cancelled'
GROUP BY m.item_id, m.item_name, b.brand_name, m.category
ORDER BY total_qty_ordered DESC
LIMIT 10;

-- CQ7: Avg delivery time per partner (in minutes)
SELECT dp.name AS partner_name,
       COUNT(dt.tracking_id) AS deliveries,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, dt.assigned_at, dt.delivered_at)), 1) AS avg_delivery_min
FROM delivery_partners dp
JOIN delivery_tracking dt ON dp.partner_id = dt.partner_id
WHERE dt.status = 'delivered'
  AND dt.assigned_at IS NOT NULL AND dt.delivered_at IS NOT NULL
GROUP BY dp.partner_id, dp.name
ORDER BY avg_delivery_min;

-- CQ8: Daily revenue for the last 7 days
SELECT DATE(o.order_time) AS order_date,
       COUNT(o.order_id)  AS orders_count,
       SUM(o.total_amount) AS daily_revenue
FROM orders o
WHERE o.status = 'delivered'
  AND o.order_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE(o.order_time)
ORDER BY order_date DESC;

-- CQ9: Customers who rated below 3 (dissatisfied)
SELECT c.name, c.phone, m.item_name, ir.rating_value, ir.review_text
FROM item_ratings ir
JOIN customers c  ON ir.customer_id = c.customer_id
JOIN menu_items m ON ir.item_id = m.item_id
WHERE ir.rating_value < 3
ORDER BY ir.rating_value;

-- CQ10: Correlated subquery - items never ordered
SELECT m.item_id, m.item_name, b.brand_name, m.price
FROM menu_items m
JOIN brands b ON m.brand_id = b.brand_id
WHERE m.item_id NOT IN (
    SELECT DISTINCT item_id FROM order_items
);


-- ============================================================
-- SECTION C: VIEWS
-- ============================================================

-- View 1: Order Summary
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT o.order_id, c.name AS customer_name, c.phone,
       o.total_amount, o.status, o.order_time,
       p.payment_method, p.status AS payment_status,
       dp.name AS delivery_partner, dt.status AS delivery_status
FROM orders o
JOIN customers c         ON o.customer_id = c.customer_id
LEFT JOIN payments p     ON o.order_id = p.order_id
LEFT JOIN delivery_tracking dt ON o.order_id = dt.order_id
LEFT JOIN delivery_partners dp ON dt.partner_id = dp.partner_id;

-- View 2: Menu with ratings
CREATE OR REPLACE VIEW vw_menu_ratings AS
SELECT m.item_id, b.brand_name, m.item_name, m.price, m.category,
       ROUND(AVG(ir.rating_value),1) AS avg_rating,
       COUNT(ir.rating_id)           AS review_count
FROM menu_items m
JOIN brands b ON m.brand_id = b.brand_id
LEFT JOIN item_ratings ir ON m.item_id = ir.item_id
GROUP BY m.item_id, b.brand_name, m.item_name, m.price, m.category;


-- ============================================================
-- SECTION D: STORED PROCEDURES
-- ============================================================

DELIMITER $$

-- PROCEDURE 1: Place a new order
CREATE PROCEDURE sp_place_order(
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
END$$

-- PROCEDURE 2: Add item to order + update total
CREATE PROCEDURE sp_add_order_item(
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
END$$

-- PROCEDURE 3: Assign delivery partner to order
CREATE PROCEDURE sp_assign_delivery(
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
END$$

-- PROCEDURE 4: Update stock when batch received
CREATE PROCEDURE sp_receive_stock(
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

    -- Update status
    UPDATE ingredients
    SET status = CASE
        WHEN current_stock_qty = 0 THEN 'out_of_stock'
        WHEN current_stock_qty <= reorder_level THEN 'low'
        ELSE 'available'
    END
    WHERE ing_id = p_ing_id;
END$$

-- PROCEDURE 5: Complete order delivery
CREATE PROCEDURE sp_complete_delivery(
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
END$$


-- ============================================================
-- SECTION E: FUNCTIONS
-- ============================================================

-- FUNCTION 1: Calculate average item rating
CREATE FUNCTION fn_item_avg_rating(p_item_id INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
BEGIN
    DECLARE v_avg DECIMAL(3,2);
    SELECT ROUND(AVG(rating_value), 2) INTO v_avg
    FROM item_ratings WHERE item_id = p_item_id;
    RETURN IFNULL(v_avg, 0.00);
END$$

-- FUNCTION 2: Get total revenue for a brand
CREATE FUNCTION fn_brand_revenue(p_brand_id INT)
RETURNS DECIMAL(12,2)
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
END$$

-- FUNCTION 3: Check if ingredient is low/out of stock
CREATE FUNCTION fn_stock_status(p_ing_id INT)
RETURNS VARCHAR(20)
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
END$$

-- FUNCTION 4: Count orders by customer
CREATE FUNCTION fn_customer_order_count(p_customer_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM orders
    WHERE customer_id = p_customer_id AND status != 'cancelled';
    RETURN v_count;
END$$

-- FUNCTION 5: Get order total from items (recalculate)
CREATE FUNCTION fn_calc_order_total(p_order_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT IFNULL(SUM(subtotal), 0) INTO v_total
    FROM order_items WHERE order_id = p_order_id;
    RETURN v_total;
END$$


-- ============================================================
-- SECTION F: TRIGGERS
-- ============================================================

-- TRIGGER 1: Auto-create delivery tracking when order is placed
CREATE TRIGGER trg_order_after_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO delivery_tracking (order_id, status)
    VALUES (NEW.order_id, 'unassigned');
END$$

-- TRIGGER 2: Update ingredient stock when order is delivered
CREATE TRIGGER trg_order_status_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'delivered' AND OLD.status != 'delivered' THEN
        -- Reduce stock for all ingredients used in this order
        UPDATE ingredients i
        JOIN recipes r ON i.ing_id = r.ing_id
        JOIN order_items oi ON r.item_id = oi.item_id
        SET i.current_stock_qty = i.current_stock_qty - (r.qty_required * oi.quantity)
        WHERE oi.order_id = NEW.order_id;
    END IF;
END$$

-- TRIGGER 3: Keep ingredient status in sync without updating the same table again
CREATE TRIGGER trg_ingredient_before_update
BEFORE UPDATE ON ingredients
FOR EACH ROW
BEGIN
    IF NEW.current_stock_qty != OLD.current_stock_qty THEN
        SET NEW.status = CASE
            WHEN NEW.current_stock_qty = 0 THEN 'out_of_stock'
            WHEN NEW.current_stock_qty <= NEW.reorder_level THEN 'low'
            ELSE 'available'
        END;
    END IF;
END$$

-- TRIGGER 4: Prevent rating if order not delivered
CREATE TRIGGER trg_item_rating_before_insert
BEFORE INSERT ON item_ratings
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(30);
    SELECT status INTO v_status FROM orders WHERE order_id = NEW.order_id;
    IF v_status != 'delivered' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot rate: order not yet delivered.';
    END IF;
END$$

-- TRIGGER 5: Auto-update order total when item subtotal changes
CREATE TRIGGER trg_order_items_after_update
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total_amount = (
        SELECT IFNULL(SUM(subtotal), 0) FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END$$

-- TRIGGER 6: Log wastage when stock goes negative (safety catch)
CREATE TRIGGER trg_stock_batch_before_update
BEFORE UPDATE ON stock_batches
FOR EACH ROW
BEGIN
    IF NEW.remaining_qty < 0 THEN
        SET NEW.remaining_qty = 0;
    END IF;
END$$


-- ============================================================
-- SECTION G: CURSOR EXAMPLE
-- ============================================================

-- CURSOR 1: Generate low stock report
CREATE PROCEDURE sp_low_stock_report()
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

    -- Create temp result table
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
END$$

-- CURSOR 2: Calculate total revenue per brand using cursor
CREATE PROCEDURE sp_brand_revenue_report()
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
END$$

DELIMITER ;

-- ============================================================
-- SAMPLE PROCEDURE/FUNCTION CALLS
-- ============================================================

-- Call sp_place_order
-- CALL sp_place_order(1, @oid, @msg);
-- SELECT @oid AS order_id, @msg AS message;

-- Call sp_add_order_item
-- CALL sp_add_order_item(@oid, 1, 2);
-- CALL sp_add_order_item(@oid, 3, 1);

-- Call functions
-- SELECT fn_item_avg_rating(1);
-- SELECT fn_brand_revenue(1);
-- SELECT fn_stock_status(1);
-- SELECT fn_customer_order_count(1);

-- Call cursor procedures
-- CALL sp_low_stock_report();
-- CALL sp_brand_revenue_report();

-- Use view
-- SELECT * FROM vw_order_summary;
-- SELECT * FROM vw_menu_ratings;
