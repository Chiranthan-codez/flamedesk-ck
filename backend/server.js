// ============================================================
// FlameDesk — Node.js Backend (replaces PHP)
// Express + MySQL2
// ============================================================
require('dotenv').config();
const express  = require('express');
const cors     = require('cors');
const bcrypt   = require('bcryptjs');
const jwt      = require('jsonwebtoken');
const { pool, testDatabaseConnection } = require('./db');
const { OAuth2Client } = require('google-auth-library');

const googleClient = new OAuth2Client(
  (process.env.GOOGLE_CLIENT_ID || 'YOUR_GOOGLE_CLIENT_ID').trim(),
  (process.env.GOOGLE_CLIENT_SECRET || 'YOUR_GOOGLE_CLIENT_SECRET').trim(),
  (process.env.GOOGLE_CALLBACK_URL || 'http://localhost:3002/api/auth/google/callback').trim()
);

const app  = express();
const PORT = process.env.PORT || 3002;
const JWT_SECRET = process.env.JWT_SECRET || 'flamedesk-secret-key';
const ALLOWED_ORIGINS = (process.env.CORS_ORIGINS || 'http://localhost:3000,http://localhost:5173,http://127.0.0.1:5173,http://localhost:5500')
  .split(',')
  .map(origin => origin.trim())
  .filter(Boolean);

function isAllowedOrigin(origin) {
  if (!origin) return true;
  if (ALLOWED_ORIGINS.includes(origin)) return true;

  // Allow local dev servers on any loopback port.
  return /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);
}

// ── MIDDLEWARE ────────────────────────────────────────────────
app.use(cors({
  origin(origin, callback) {
    if (isAllowedOrigin(origin)) {
      callback(null, true);
      return;
    }
    callback(new Error(`CORS blocked for origin: ${origin}`));
  },
  credentials: true
}));
app.use(express.json());
// ── ROOT ROUTE (for browser test) ─────────────────────────────
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: "🔥 FlameDesk API is running",
    version: "2.0.0"
  });
});
// ── AUTH MIDDLEWARE ───────────────────────────────────────────
function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ success: false, error: 'Unauthorized' });
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch {
    return res.status(401).json({ success: false, error: 'Invalid token' });
  }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ success: false, error: 'Forbidden' });
    }
    next();
  };
}

const adminOnly = requireRole('admin');
const customerOnly = requireRole('customer');

async function placeOrderForCustomer(customerId, items) {
  if (!customerId) {
    throw new Error('customer_id is required');
  }
  if (!Array.isArray(items) || !items.length) {
    throw new Error('At least one item is required');
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const [[customer]] = await connection.query(
      'SELECT customer_id FROM customers WHERE customer_id = ?',
      [customerId]
    );
    if (!customer) {
      throw new Error('Customer not found');
    }

    const [orderInsert] = await connection.query(
      'INSERT INTO orders (customer_id, total_amount, status) VALUES (?, 0, ?)',
      [customerId, 'pending']
    );
    const orderId = orderInsert.insertId;

    let totalAmount = 0;
    let maxPrepTime = 0;
    for (const rawItem of items) {
      const itemId = Number(rawItem.item_id);
      const quantity = Number(rawItem.quantity);
      if (!itemId || !quantity || quantity < 1) {
        throw new Error('Invalid order item payload');
      }

      const [[menuItem]] = await connection.query(
        'SELECT price, is_available, prep_time FROM menu_items WHERE item_id = ?',
        [itemId]
      );
      if (!menuItem) throw new Error(`Menu item not found: ${itemId}`);
      if (!menuItem.is_available) throw new Error(`Menu item unavailable: ${itemId}`);

      const subtotal = Number(menuItem.price) * quantity;
      totalAmount += subtotal;
      maxPrepTime = Math.max(maxPrepTime, Number(menuItem.prep_time) || 0);

      await connection.query(
        'INSERT INTO order_items (order_id, item_id, quantity, subtotal) VALUES (?,?,?,?)',
        [orderId, itemId, quantity, subtotal]
      );
    }

    const estimateMinutes = Math.max(45, Math.min(180, maxPrepTime + 20));
    await connection.query(
      `UPDATE orders
       SET total_amount = ?,
           estimated_delivery_time = DATE_ADD(order_time, INTERVAL ${estimateMinutes} MINUTE)
       WHERE order_id = ?`,
      [totalAmount, orderId]
    );

    await connection.commit();
    return { orderId };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

async function markOrderPaymentCompleted(orderId, paymentMethod) {
  if (!orderId) {
    throw new Error('Invalid order id');
  }

  const allowedMethods = new Set(['cash', 'card', 'upi', 'wallet']);
  const normalizedMethod = allowedMethods.has(paymentMethod) ? paymentMethod : 'cash';
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const [[order]] = await connection.query(
      'SELECT order_id, total_amount FROM orders WHERE order_id = ?',
      [orderId]
    );
    if (!order) {
      throw new Error('Order not found');
    }

    const [paymentRows] = await connection.query(
      'SELECT payment_id, payment_method, status FROM payments WHERE order_id = ?',
      [orderId]
    );

    if (paymentRows.length) {
      const payment = paymentRows[0];
      if (payment.status === 'completed') {
        await connection.rollback();
        return { alreadyCompleted: true };
      }

      await connection.query(
        `UPDATE payments
         SET status = 'completed',
             payment_method = ?,
             payment_time = NOW()
         WHERE order_id = ?`,
        [normalizedMethod, orderId]
      );
    } else {
      await connection.query(
        `INSERT INTO payments (order_id, payment_method, amount, status, payment_time)
         VALUES (?, ?, ?, 'completed', NOW())`,
        [orderId, normalizedMethod, order.total_amount]
      );
    }

    await connection.commit();
    return { alreadyCompleted: false };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

async function syncDeliveryStateForOrder(connection, orderId, nextStatus) {
  const [[order]] = await connection.query(
    'SELECT order_id, total_amount FROM orders WHERE order_id = ?',
    [orderId]
  );
  if (!order) {
    throw new Error('Order not found');
  }

  const [[tracking]] = await connection.query(
    'SELECT tracking_id, partner_id, status FROM delivery_tracking WHERE order_id = ?',
    [orderId]
  );

  if (nextStatus === 'out_for_delivery') {
    if (tracking?.tracking_id) {
      await connection.query(
        `UPDATE delivery_tracking
         SET status = 'picked_up', delivered_at = NULL
         WHERE order_id = ?`,
        [orderId]
      );
    }

    if (tracking?.partner_id) {
      await connection.query(
        `UPDATE delivery_partners
         SET status = 'on_delivery'
         WHERE partner_id = ?`,
        [tracking.partner_id]
      );
    }

    return;
  }

  if (nextStatus !== 'delivered') {
    return;
  }

  if (tracking?.tracking_id) {
    await connection.query(
      `UPDATE delivery_tracking
       SET status = 'delivered', delivered_at = NOW()
       WHERE order_id = ?`,
      [orderId]
    );
  } else {
    await connection.query(
      `INSERT INTO delivery_tracking (order_id, status, delivered_at)
       VALUES (?, 'delivered', NOW())`,
      [orderId]
    );
  }

  const [paymentRows] = await connection.query(
    'SELECT payment_id, status FROM payments WHERE order_id = ?',
    [orderId]
  );

  if (paymentRows.length) {
    await connection.query(
      `UPDATE payments
       SET status = 'completed',
           payment_time = COALESCE(payment_time, NOW())
       WHERE order_id = ?
         AND status != 'completed'`,
      [orderId]
    );
  } else {
    await connection.query(
      `INSERT INTO payments (order_id, payment_method, amount, status, payment_time)
       VALUES (?, 'cash', ?, 'completed', NOW())`,
      [orderId, order.total_amount]
    );
  }

  const partnerId = tracking?.partner_id || null;
  if (!partnerId) {
    return;
  }

  const [[activeAssignments]] = await connection.query(
    `SELECT COUNT(*) AS active_count
     FROM delivery_tracking
     WHERE partner_id = ?
       AND order_id != ?
       AND status IN ('assigned', 'picked_up')`,
    [partnerId, orderId]
  );

  await connection.query(
    `UPDATE delivery_partners
     SET status = ?
     WHERE partner_id = ?`,
    [activeAssignments.active_count > 0 ? 'on_delivery' : 'available', partnerId]
  );
}

// ── AUTH ──────────────────────────────────────────────────────
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    const [adminRows] = await pool.query('SELECT * FROM admin_users WHERE username = ?', [username]);
    if (adminRows.length) {
      const admin = adminRows[0];
      const ok = await bcrypt.compare(password, admin.password_hash);
      if (!ok) return res.json({ success: false, error: 'Invalid credentials' });
      const token = jwt.sign(
        { id: admin.admin_id, username: admin.username, role: 'admin' },
        JWT_SECRET,
        { expiresIn: '8h' }
      );
      return res.json({
        success: true,
        token,
        username: admin.username,
        role: 'admin',
        display_name: admin.full_name || admin.username
      });
    }

    const [customerRows] = await pool.query(
      'SELECT * FROM customers WHERE email = ? OR phone = ?',
      [username, username]
    );
    if (!customerRows.length) return res.json({ success: false, error: 'Invalid credentials' });

    const customer = customerRows[0];
    if (!customer.password_hash) return res.json({ success: false, error: 'Customer login is not enabled for this account' });

    const ok = await bcrypt.compare(password, customer.password_hash);
    if (!ok) return res.json({ success: false, error: 'Invalid credentials' });

    const token = jwt.sign(
      {
        id: customer.customer_id,
        customer_id: customer.customer_id,
        username: customer.email || customer.phone,
        role: 'customer'
      },
      JWT_SECRET,
      { expiresIn: '8h' }
    );
    return res.json({
      success: true,
      token,
      username: customer.email || customer.phone,
      role: 'customer',
      customer_id: customer.customer_id,
      display_name: customer.name
    });
  } catch (e) {
    res.json({ success: false, error: e.message });
  }
});

app.get('/api/auth/google', (req, res) => {
  const url = googleClient.generateAuthUrl({
    access_type: 'offline',
    scope: ['email', 'profile'],
  });
  res.redirect(url);
});

app.get('/api/auth/google/callback', async (req, res) => {
  const code = req.query.code;
  const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:5173';
  try {
    const { tokens } = await googleClient.getToken(code);
    const ticket = await googleClient.verifyIdToken({
      idToken: tokens.id_token,
      audience: process.env.GOOGLE_CLIENT_ID || 'YOUR_GOOGLE_CLIENT_ID'
    });
    const payload = ticket.getPayload();
    if (!payload || !payload.email) throw new Error('Invalid Google token');

    const email = payload.email;
    const name = payload.name || 'Google User';

    const [customerRows] = await pool.query('SELECT * FROM customers WHERE email = ?', [email]);
    let customer;

    if (customerRows.length) {
      customer = customerRows[0];
    } else {
      const [result] = await pool.query(
        'INSERT INTO customers (name, email) VALUES (?, ?)',
        [name, email]
      );
      customer = { customer_id: result.insertId, name, email };
    }

    const token = jwt.sign(
      {
        id: customer.customer_id,
        customer_id: customer.customer_id,
        username: customer.email,
        role: 'customer'
      },
      JWT_SECRET,
      { expiresIn: '8h' }
    );

    res.redirect(`${frontendUrl}/?ck_token=${token}&ck_username=${encodeURIComponent(customer.email)}&ck_role=customer&ck_customer_id=${customer.customer_id}&ck_display_name=${encodeURIComponent(customer.name)}`);
  } catch (e) {
    res.redirect(`${frontendUrl}/?error=${encodeURIComponent(e.message)}`);
  }
});

app.post('/api/register', async (req, res) => {
  const { name, phone, email, password, address } = req.body;
  try {
    if (!name || !phone || !email || !password) {
      return res.json({ success: false, error: 'All fields are required' });
    }

    // Check if email or phone already exists
    const [existing] = await pool.query('SELECT * FROM customers WHERE email = ? OR phone = ?', [email, phone]);
    if (existing.length) {
      return res.json({ success: false, error: 'Email or phone already registered' });
    }

    // Hash password
    const password_hash = await bcrypt.hash(password, 10);

    // Insert new customer
    const [result] = await pool.query(
      'INSERT INTO customers (name, phone, email, password_hash, address) VALUES (?, ?, ?, ?, ?)',
      [name, phone, email, password_hash, address || '']
    );

    res.json({ success: true, message: 'Registration successful', customer_id: result.insertId });
  } catch (e) {
    res.json({ success: false, error: e.message });
  }
});

// ── CUSTOMER PORTAL ───────────────────────────────────────────
app.get('/api/customer/menu', authMiddleware, customerOnly, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT m.item_id, m.item_name, m.description, m.price, m.prep_time, m.category,
             m.is_available, m.image_url, b.brand_name,
             ROUND(AVG(r.rating_value),1) AS avg_rating,
             COUNT(r.rating_id) AS rating_count
      FROM menu_items m
      JOIN brands b ON m.brand_id = b.brand_id
      LEFT JOIN item_ratings r ON m.item_id = r.item_id
      WHERE m.is_available = 1
      GROUP BY m.item_id
      ORDER BY b.brand_name, m.item_name`);
    res.json({ success: true, data: rows });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

app.get('/api/customer/orders', authMiddleware, customerOnly, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT o.order_id, o.customer_id, o.total_amount, o.status, o.order_time,
             o.estimated_delivery_time, p.payment_method, p.status AS payment_status,
             CASE
               WHEN o.status = 'delivered' THEN 'delivered'
               ELSE dt.status
             END AS delivery_status,
             dp.name AS delivery_partner
      FROM orders o
      LEFT JOIN payments p ON o.order_id = p.order_id
      LEFT JOIN delivery_tracking dt ON o.order_id = dt.order_id
      LEFT JOIN delivery_partners dp ON dt.partner_id = dp.partner_id
      WHERE o.customer_id = ?
      ORDER BY o.order_time DESC`,
      [req.user.customer_id]
    );

    const orderIds = rows.map(order => order.order_id);
    let itemsByOrderId = {};
    let ratingsByOrderId = {};

    if (orderIds.length) {
      const [itemRows] = await pool.query(`
        SELECT oi.order_id, oi.item_id, oi.quantity, oi.subtotal, m.item_name
        FROM order_items oi
        JOIN menu_items m ON oi.item_id = m.item_id
        WHERE oi.order_id IN (${orderIds.map(() => '?').join(',')})
        ORDER BY oi.order_item_id`,
        orderIds
      );
      itemsByOrderId = itemRows.reduce((acc, item) => {
        if (!acc[item.order_id]) acc[item.order_id] = [];
        acc[item.order_id].push(item);
        return acc;
      }, {});

      const [ratingRows] = await pool.query(`
        SELECT order_id, item_id, rating_value, review_text
        FROM item_ratings
        WHERE customer_id = ?
          AND order_id IN (${orderIds.map(() => '?').join(',')})`,
        [req.user.customer_id, ...orderIds]
      );
      ratingsByOrderId = ratingRows.reduce((acc, rating) => {
        if (!acc[rating.order_id]) acc[rating.order_id] = [];
        acc[rating.order_id].push(rating);
        return acc;
      }, {});
    }

    res.json({
      success: true,
      data: rows.map(order => ({
        ...order,
        items: itemsByOrderId[order.order_id] || [],
        ratings: ratingsByOrderId[order.order_id] || []
      }))
    });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

app.post('/api/customer/orders', authMiddleware, customerOnly, async (req, res) => {
  try {
    const result = await placeOrderForCustomer(req.user.customer_id, req.body.items);
    res.json({ success: true, message: 'Order placed successfully', order_id: result.orderId });
  } catch (e) {
    const status = ['customer_id is required', 'At least one item is required', 'Customer not found'].includes(e.message) ? 400 : 500;
    res.status(status).json({ success: false, error: e.message });
  }
});

app.patch('/api/customer/orders/:id/payment', authMiddleware, customerOnly, async (req, res) => {
  const orderId = Number(req.params.id);
  try {
    const [[order]] = await pool.query(
      'SELECT order_id FROM orders WHERE order_id = ? AND customer_id = ?',
      [orderId, req.user.customer_id]
    );
    if (!order) {
      return res.status(404).json({ success: false, error: 'Order not found' });
    }

    const result = await markOrderPaymentCompleted(orderId, req.body?.payment_method);
    res.json({
      success: true,
      message: result.alreadyCompleted ? 'Payment already completed' : 'Payment marked as completed'
    });
  } catch (e) {
    const status = e.message === 'Invalid order id' ? 400 : e.message === 'Order not found' ? 404 : 500;
    res.status(status).json({ success: false, error: e.message });
  }
});

app.post('/api/customer/orders/:id/ratings', authMiddleware, customerOnly, async (req, res) => {
  const orderId = Number(req.params.id);
  const ratings = Array.isArray(req.body?.ratings) ? req.body.ratings : [];

  if (!orderId) {
    return res.status(400).json({ success: false, error: 'Invalid order id' });
  }
  if (!ratings.length) {
    return res.status(400).json({ success: false, error: 'At least one rating is required' });
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const [[order]] = await connection.query(
      'SELECT order_id, status FROM orders WHERE order_id = ? AND customer_id = ?',
      [orderId, req.user.customer_id]
    );
    if (!order) {
      await connection.rollback();
      return res.status(404).json({ success: false, error: 'Order not found' });
    }
    if (order.status !== 'delivered') {
      await connection.rollback();
      return res.status(400).json({ success: false, error: 'Only delivered orders can be rated' });
    }

    const [orderItems] = await connection.query(
      'SELECT item_id FROM order_items WHERE order_id = ?',
      [orderId]
    );
    const validItemIds = new Set(orderItems.map(item => item.item_id));

    for (const rawRating of ratings) {
      const itemId = Number(rawRating.item_id);
      const ratingValue = Number(rawRating.rating_value);
      const reviewText = rawRating.review_text || null;

      if (!validItemIds.has(itemId)) {
        throw new Error(`Item ${itemId} does not belong to this order`);
      }
      if (!Number.isInteger(ratingValue) || ratingValue < 1 || ratingValue > 5) {
        throw new Error(`Invalid rating value for item ${itemId}`);
      }

      await connection.query(
        `INSERT INTO item_ratings (customer_id, item_id, order_id, rating_value, review_text)
         VALUES (?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE rating_value = VALUES(rating_value), review_text = VALUES(review_text)`,
        [req.user.customer_id, itemId, orderId, ratingValue, reviewText]
      );
    }

    await connection.commit();
    res.json({ success: true, message: 'Ratings submitted successfully' });
  } catch (e) {
    await connection.rollback();
    res.status(500).json({ success: false, error: e.message });
  } finally {
    connection.release();
  }
});

// ── DASHBOARD STATS ───────────────────────────────────────────
app.get('/api/dashboard/stats', authMiddleware, adminOnly, async (req, res) => {
  try {
    const [[stats]] = await pool.query(`
      SELECT
        COUNT(*) AS total_orders,
        SUM(status = 'pending') AS pending_orders,
        SUM(status = 'delivered' AND DATE(order_time) = CURDATE()) AS delivered_today,
        COALESCE(SUM(CASE WHEN DATE(order_time)=CURDATE() AND status='delivered' THEN total_amount END),0) AS revenue_today,
        (SELECT COUNT(*) FROM ingredients WHERE current_stock_qty <= reorder_level) AS low_stock,
        (SELECT COUNT(*) FROM brands WHERE status='active') AS active_brands,
        (SELECT COUNT(*) FROM customers) AS total_customers,
        (SELECT COUNT(*)
         FROM delivery_partners dp
         WHERE dp.status != 'offline'
           AND NOT EXISTS (
             SELECT 1
             FROM delivery_tracking dt
             JOIN orders o ON o.order_id = dt.order_id
             WHERE dt.partner_id = dp.partner_id
               AND dt.status IN ('assigned','picked_up')
               AND o.status != 'delivered'
           )) AS available_riders
      FROM orders`);
    res.json({ success: true, data: stats });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

app.get('/api/dashboard/revenue-chart', authMiddleware, adminOnly, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT DATE(order_time) AS day, COALESCE(SUM(total_amount),0) AS revenue
      FROM orders WHERE order_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND status='delivered'
      GROUP BY DATE(order_time) ORDER BY day ASC`);
    res.json({ success: true, data: rows });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

// ── ORDERS ────────────────────────────────────────────────────
app.get('/api/orders', authMiddleware, adminOnly, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT o.*, c.name AS customer_name, c.phone,
             p.payment_method, p.status AS payment_status,
             dp.name AS delivery_partner,
             CASE
               WHEN o.status = 'delivered' THEN 'delivered'
               ELSE dt.status
             END AS delivery_status
      FROM orders o
      JOIN customers c ON o.customer_id = c.customer_id
      LEFT JOIN payments p ON o.order_id = p.order_id
      LEFT JOIN delivery_tracking dt ON o.order_id = dt.order_id
      LEFT JOIN delivery_partners dp ON dt.partner_id = dp.partner_id
      ORDER BY o.order_time DESC`);
    res.json({ success: true, data: rows });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

app.post('/api/orders', authMiddleware, adminOnly, async (req, res) => {
  try {
    const result = await placeOrderForCustomer(Number(req.body.customer_id), req.body.items);
    res.json({ success: true, message: 'Order placed successfully', order_id: result.orderId });
  } catch (e) {
    const status = ['customer_id is required', 'At least one item is required', 'Customer not found'].includes(e.message) ? 400 : 500;
    res.status(status).json({ success: false, error: e.message });
  }
});

app.patch('/api/orders/:id/status', authMiddleware, adminOnly, async (req, res) => {
  const { status } = req.body;
  const orderId = Number(req.params.id);

  if (!orderId) {
    return res.status(400).json({ success: false, error: 'Invalid order id' });
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const [[order]] = await connection.query(
      'SELECT order_id, status FROM orders WHERE order_id = ?',
      [orderId]
    );
    if (!order) {
      await connection.rollback();
      return res.status(404).json({ success: false, error: 'Order not found' });
    }

    await connection.query(
      'UPDATE orders SET status = ? WHERE order_id = ?',
      [status, orderId]
    );

    await syncDeliveryStateForOrder(connection, orderId, status);

    await connection.commit();
    res.json({ success: true, message: 'Status updated' });
  } catch (e) {
    await connection.rollback();
    res.status(500).json({ success: false, error: e.message });
  } finally {
    connection.release();
  }
});

app.patch('/api/orders/:id/payment', authMiddleware, adminOnly, async (req, res) => {
  try {
    const result = await markOrderPaymentCompleted(Number(req.params.id), req.body?.payment_method);
    res.json({
      success: true,
      message: result.alreadyCompleted ? 'Payment already completed' : 'Payment marked as completed'
    });
  } catch (e) {
    const status = e.message === 'Invalid order id' ? 400 : e.message === 'Order not found' ? 404 : 500;
    res.status(status).json({ success: false, error: e.message });
  }
});

// ── MENU ──────────────────────────────────────────────────────
app.get('/api/menu', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT m.*, b.brand_name,
             ROUND(AVG(r.rating_value),1) AS avg_rating,
             COUNT(r.rating_id) AS rating_count
      FROM menu_items m
      JOIN brands b ON m.brand_id = b.brand_id
      LEFT JOIN item_ratings r ON m.item_id = r.item_id
      GROUP BY m.item_id ORDER BY b.brand_name, m.item_name`);
    res.json({ success: true, data: rows });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

app.post('/api/menu', authMiddleware, adminOnly, async (req, res) => {
  const { brand_id, item_name, price, category, prep_time } = req.body;
  try {
    await pool.query('INSERT INTO menu_items (brand_id,item_name,price,category,prep_time) VALUES (?,?,?,?,?)',
      [brand_id, item_name, price, category, prep_time]);
    res.json({ success: true, message: 'Item added' });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

app.patch('/api/menu/:id', authMiddleware, adminOnly, async (req, res) => {
  const { is_available } = req.body;
  try {
    await pool.query('UPDATE menu_items SET is_available=? WHERE item_id=?', [is_available, req.params.id]);
    res.json({ success: true, message: 'Menu item updated' });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

// ── BRANDS ────────────────────────────────────────────────────
app.get('/api/brands', authMiddleware, adminOnly, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT b.*, COUNT(m.item_id) AS item_count
      FROM brands b LEFT JOIN menu_items m ON b.brand_id = m.brand_id
      GROUP BY b.brand_id ORDER BY b.brand_name`);
    res.json({ success: true, data: rows });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

app.post('/api/brands', authMiddleware, adminOnly, async (req, res) => {
  const { brand_name, cuisine_type } = req.body;
  try {
    await pool.query('INSERT INTO brands (brand_name, cuisine_type) VALUES (?,?)', [brand_name, cuisine_type]);
    res.json({ success: true, message: 'Brand created' });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

// ── CUSTOMERS ─────────────────────────────────────────────────
app.get('/api/customers', authMiddleware, adminOnly, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT c.*, COUNT(o.order_id) AS order_count,
             COALESCE(SUM(o.total_amount),0) AS total_spent
      FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
      GROUP BY c.customer_id ORDER BY total_spent DESC`);
    res.json({ success: true, data: rows });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

app.post('/api/customers', authMiddleware, adminOnly, async (req, res) => {
  const { name, phone, email, address } = req.body;
  try {
    await pool.query('INSERT INTO customers (name,phone,email,address) VALUES (?,?,?,?)',
      [name, phone, email, address]);
    res.json({ success: true, message: 'Customer added' });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

// ── DELIVERY ──────────────────────────────────────────────────
app.get('/api/delivery', authMiddleware, adminOnly, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT dp.partner_id,
             dp.name,
             dp.phone,
             dp.vehicle_no,
             dp.created_at,
             CASE
               WHEN dp.status = 'offline' THEN 'offline'
               WHEN SUM(CASE
                 WHEN dt.status IN ('assigned','picked_up') AND COALESCE(o.status, '') != 'delivered' THEN 1
                 ELSE 0
               END) > 0 THEN 'on_delivery'
               ELSE 'available'
             END AS status,
             SUM(CASE
               WHEN dt.status = 'delivered' OR o.status = 'delivered' THEN 1
               ELSE 0
             END) AS total_deliveries
      FROM delivery_partners dp
      LEFT JOIN delivery_tracking dt ON dp.partner_id = dt.partner_id
      LEFT JOIN orders o ON o.order_id = dt.order_id
      GROUP BY dp.partner_id, dp.name, dp.phone, dp.vehicle_no, dp.created_at, dp.status
      ORDER BY
        CASE
          WHEN dp.status = 'offline' THEN 3
          WHEN SUM(CASE
            WHEN dt.status IN ('assigned','picked_up') AND COALESCE(o.status, '') != 'delivered' THEN 1
            ELSE 0
          END) > 0 THEN 2
          ELSE 1
        END,
        dp.name`);
    res.json({ success: true, data: rows });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

app.post('/api/delivery/assign', authMiddleware, adminOnly, async (req, res) => {
  const orderId = Number(req.body.order_id);
  const partnerId = Number(req.body.partner_id);

  if (!orderId || !partnerId) {
    return res.status(400).json({ success: false, error: 'order_id and partner_id are required' });
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const [[order]] = await connection.query(
      'SELECT order_id, status FROM orders WHERE order_id = ?',
      [orderId]
    );
    if (!order) {
      await connection.rollback();
      return res.status(404).json({ success: false, error: 'Order not found' });
    }
    if (!['confirmed', 'preparing'].includes(order.status)) {
      await connection.rollback();
      return res.status(400).json({ success: false, error: `Order is ${order.status}; only confirmed/preparing can be assigned` });
    }

    const [[partner]] = await connection.query(
      'SELECT partner_id, status FROM delivery_partners WHERE partner_id = ?',
      [partnerId]
    );
    if (!partner) {
      await connection.rollback();
      return res.status(404).json({ success: false, error: 'Delivery partner not found' });
    }
    if (partner.status !== 'available') {
      await connection.rollback();
      return res.status(400).json({ success: false, error: 'Delivery partner is not available' });
    }

    const [[tracking]] = await connection.query(
      'SELECT tracking_id, status FROM delivery_tracking WHERE order_id = ?',
      [orderId]
    );
    if (!tracking) {
      await connection.query(
        'INSERT INTO delivery_tracking (order_id, status) VALUES (?, ?)',
        [orderId, 'unassigned']
      );
    } else if (['assigned', 'picked_up', 'delivered'].includes(tracking.status)) {
      await connection.rollback();
      return res.status(400).json({ success: false, error: `Order already has delivery status: ${tracking.status}` });
    }

    await connection.query(
      `UPDATE delivery_tracking
       SET partner_id = ?, status = 'assigned', assigned_at = NOW()
       WHERE order_id = ?`,
      [partnerId, orderId]
    );
    await connection.query(
      `UPDATE delivery_partners
       SET status = 'on_delivery'
       WHERE partner_id = ?`,
      [partnerId]
    );
    await connection.query(
      `UPDATE orders
       SET status = 'out_for_delivery'
       WHERE order_id = ?`,
      [orderId]
    );

    await connection.commit();
    res.json({ success: true, message: 'Delivery assigned successfully' });
  } catch (e) {
    await connection.rollback();
    res.status(500).json({ success: false, error: e.message });
  } finally {
    connection.release();
  }
});

// ── INVENTORY ─────────────────────────────────────────────────
app.get('/api/inventory', authMiddleware, adminOnly, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT i.*,
        CASE WHEN current_stock_qty = 0 THEN 'out_of_stock'
             WHEN current_stock_qty <= reorder_level THEN 'low'
             ELSE 'available' END AS status
      FROM ingredients i ORDER BY status ASC, name ASC`);
    res.json({ success: true, data: rows });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

app.patch('/api/inventory/:id', authMiddleware, adminOnly, async (req, res) => {
  const { qty } = req.body;
  try {
    await pool.query('UPDATE ingredients SET current_stock_qty = current_stock_qty + ? WHERE ing_id = ?',
      [qty, req.params.id]);
    res.json({ success: true, message: 'Stock updated' });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

// ── RATINGS ───────────────────────────────────────────────────
app.get('/api/ratings', authMiddleware, adminOnly, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT r.*, c.name AS customer_name, m.item_name, b.brand_name
      FROM item_ratings r
      JOIN customers c ON r.customer_id = c.customer_id
      JOIN menu_items m ON r.item_id = m.item_id
      JOIN brands b ON m.brand_id = b.brand_id
      ORDER BY r.created_at DESC`);
    res.json({ success: true, data: rows });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

// ── REPORTS ───────────────────────────────────────────────────
app.get('/api/reports/top-items', authMiddleware, adminOnly, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT m.item_name, b.brand_name,
             SUM(oi.quantity) AS qty_sold,
             SUM(oi.subtotal) AS revenue,
             ROUND(AVG(r.rating_value),1) AS rating
      FROM order_items oi
      JOIN menu_items m ON oi.item_id = m.item_id
      JOIN brands b ON m.brand_id = b.brand_id
      JOIN orders o ON oi.order_id = o.order_id
      LEFT JOIN item_ratings r ON m.item_id = r.item_id
      WHERE o.status = 'delivered'
      GROUP BY m.item_id ORDER BY qty_sold DESC LIMIT 10`);
    res.json({ success: true, data: rows });
  } catch (e) { res.json({ success: false, error: e.message }); }
});

app.get('/api/reports/brand-revenue', authMiddleware, adminOnly, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT b.brand_id, b.brand_name,
             COALESCE(SUM(oi.subtotal),0) AS revenue
      FROM brands b
      LEFT JOIN menu_items m ON b.brand_id = m.brand_id
      LEFT JOIN order_items oi ON m.item_id = oi.item_id
      LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status='delivered'
      GROUP BY b.brand_id ORDER BY revenue DESC`);
    res.json({ success: true, data: rows });
  } catch (e) { res.json({ success: false, error: e.message }); }
});
app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({
      status: 'OK',
      database: 'connected',
      uptime: process.uptime(),
      timestamp: Date.now()
    });
  } catch {
    res.status(500).json({
      status: 'ERROR',
      database: 'disconnected',
      uptime: process.uptime(),
      timestamp: Date.now()
    });
  }
});

app.get('/api/debug/db-check', authMiddleware, adminOnly, async (req, res) => {
  try {
    const checks = {};

    const [[ping]] = await pool.query('SELECT 1 AS ok');
    checks.connection = { ok: ping.ok === 1 };

    const [tableRows] = await pool.query(
      `SELECT table_name
       FROM information_schema.tables
       WHERE table_schema = DATABASE()
         AND table_name IN (
           'admin_users','orders','order_items','payments','delivery_tracking',
           'delivery_partners','customers','menu_items','brands','ingredients'
         )`
    );
    const foundTables = new Set(tableRows.map(t => t.table_name));
    const requiredTables = [
      'admin_users', 'orders', 'order_items', 'payments', 'delivery_tracking',
      'delivery_partners', 'customers', 'menu_items', 'brands', 'ingredients'
    ];
    checks.tables = {
      ok: requiredTables.every(t => foundTables.has(t)),
      missing: requiredTables.filter(t => !foundTables.has(t))
    };

    const [[ordersCount]] = await pool.query('SELECT COUNT(*) AS c FROM orders');
    const [[orderItemsCount]] = await pool.query('SELECT COUNT(*) AS c FROM order_items');
    const [[paymentsCount]] = await pool.query('SELECT COUNT(*) AS c FROM payments');
    const [[trackingCount]] = await pool.query('SELECT COUNT(*) AS c FROM delivery_tracking');
    const [[customersCount]] = await pool.query('SELECT COUNT(*) AS c FROM customers');
    const [[menuCount]] = await pool.query('SELECT COUNT(*) AS c FROM menu_items');
    const [[partnersCount]] = await pool.query('SELECT COUNT(*) AS c FROM delivery_partners');
    checks.counts = {
      orders: ordersCount.c,
      order_items: orderItemsCount.c,
      payments: paymentsCount.c,
      delivery_tracking: trackingCount.c,
      customers: customersCount.c,
      menu_items: menuCount.c,
      delivery_partners: partnersCount.c
    };

    const [[orphanOrderItems]] = await pool.query(`
      SELECT COUNT(*) AS c
      FROM order_items oi
      LEFT JOIN orders o ON oi.order_id = o.order_id
      WHERE o.order_id IS NULL`);
    const [[orphanPayments]] = await pool.query(`
      SELECT COUNT(*) AS c
      FROM payments p
      LEFT JOIN orders o ON p.order_id = o.order_id
      WHERE o.order_id IS NULL`);
    const [[orphanTracking]] = await pool.query(`
      SELECT COUNT(*) AS c
      FROM delivery_tracking dt
      LEFT JOIN orders o ON dt.order_id = o.order_id
      WHERE o.order_id IS NULL`);
    const [[invalidPartnerRefs]] = await pool.query(`
      SELECT COUNT(*) AS c
      FROM delivery_tracking dt
      LEFT JOIN delivery_partners dp ON dt.partner_id = dp.partner_id
      WHERE dt.partner_id IS NOT NULL AND dp.partner_id IS NULL`);

    checks.relationships = {
      order_items_without_orders: orphanOrderItems.c,
      payments_without_orders: orphanPayments.c,
      tracking_without_orders: orphanTracking.c,
      tracking_with_missing_partner: invalidPartnerRefs.c
    };

    const ok =
      checks.connection.ok &&
      checks.tables.ok &&
      checks.relationships.order_items_without_orders === 0 &&
      checks.relationships.payments_without_orders === 0 &&
      checks.relationships.tracking_without_orders === 0 &&
      checks.relationships.tracking_with_missing_partner === 0;

    res.json({
      success: true,
      status: ok ? 'OK' : 'WARN',
      checked_at: new Date().toISOString(),
      checks
    });
  } catch (e) {
    res.status(500).json({ success: false, status: 'ERROR', error: e.message });
  }
});
// ── GLOBAL ERROR HANDLER ─────────────────────────────────────
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({
    success: false,
    error: "Internal Server Error"
  });
});
async function startServer() {
  try {
    await testDatabaseConnection();
    console.log('✅ Database connected');
    const server = app.listen(PORT, () => console.log(`🔥 FlameDesk API running on port ${PORT}`));

    server.on('error', (error) => {
      if (error.code === 'EADDRINUSE') {
        console.error(`❌ Port ${PORT} is already in use.`);
        console.error(`   Stop the other server or run this one with a different port.`);
        console.error(`   PowerShell example: $env:PORT=3002; npm run dev`);
        process.exit(1);
      }

      console.error('❌ Failed to start server:', error.message);
      process.exit(1);
    });
  } catch (error) {
    console.error('❌ Failed to connect to MySQL:', error.message);
    process.exit(1);
  }
}

startServer();
