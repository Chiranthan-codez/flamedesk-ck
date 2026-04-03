# 🔥 FlameDesk v2.0 — Enhanced Cloud Kitchen OS

## What's New in v2.0

### 🎨 UI Enhancements
- **Kanban Board** for orders — drag cards between status columns
- **Global Search** — instant search across orders, menu, customers from the topbar
- **Notification Panel** — real-time alerts for pending orders, low stock, etc.
- **Animated stat counters** — numbers count up on load
- **Line/Bar chart toggle** on the revenue chart
- **Order Status Donut Chart** on the dashboard
- **Stock level progress bars** in inventory
- **Interactive star ratings** display
- **Drag-and-drop** order status updates in Kanban view
- **CSV Export** from reports page

### 🤖 AI Insights Page (New!)
- Powered by Claude (Anthropic) API
- Auto-generates 3 smart insights from your kitchen data
- Ask any question in natural language ("What's selling best?")
- Kitchen Health Score with per-metric breakdown
- Suggested action cards with quick navigation

### 🔧 Backend: PHP → Node.js + MySQL
- Express.js REST API with JWT authentication
- mysql2 connection pooling
- bcryptjs password hashing
- All original SQL stored procedures preserved (`sp_place_order`, `sp_assign_delivery`, etc.)

---

## Setup Instructions

### Backend (Node.js)

```bash
cd backend
npm install
# Set environment variables (or edit directly):
DB_HOST=localhost DB_USER=root DB_PASS= DB_NAME=cloud_kitchen node server.js
```

The API runs on **http://localhost:3002**

### Database
Use the original SQL files (unchanged):
1. Import `sql/schema.sql`
2. Import `sql/sample_data.sql`
3. Import `sql/queries_plsql.sql`

Then update the admin password to bcrypt hash:
```sql
UPDATE admin_users SET password_hash = '$2a$10$...' WHERE username = 'admin';
-- Generate hash: node -e "const b=require('bcryptjs');console.log(b.hashSync('admin123',10))"
```

### Frontend
Open `frontend/index.html` in your browser.

**Demo mode** (no backend needed): The app runs with mock data by default (`IS_DEMO = true` in dashboard.html).

To connect to the real backend:
1. Set `IS_DEMO = false` in `frontend/dashboard.html`
2. Make sure the backend is running on port 3002

### AI Features
The AI Insights page calls the Anthropic API directly from the browser.
To enable it, you need an Anthropic API key. Update the fetch call in dashboard.html:
```js
headers: {
  'Content-Type': 'application/json',
  'x-api-key': 'YOUR_API_KEY',
  'anthropic-version': '2023-06-01',
  'anthropic-dangerous-direct-browser-access': 'true'
}
```

---

## API Endpoints (Node.js)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/login | Admin login → JWT token |
| GET | /api/dashboard/stats | Dashboard KPIs |
| GET | /api/dashboard/revenue-chart | 7-day revenue |
| GET | /api/orders | All orders |
| POST | /api/orders | Place new order |
| PATCH | /api/orders/:id/status | Update order status |
| GET | /api/menu | Menu items |
| POST | /api/menu | Add menu item |
| PATCH | /api/menu/:id | Toggle availability |
| GET | /api/brands | All brands |
| POST | /api/brands | Add brand |
| GET | /api/customers | All customers |
| POST | /api/customers | Add customer |
| GET | /api/delivery | Delivery partners |
| POST | /api/delivery/assign | Assign delivery |
| GET | /api/inventory | Stock levels |
| PATCH | /api/inventory/:id | Restock item |
| GET | /api/ratings | All ratings |
| GET | /api/reports/top-items | Top sellers |
| GET | /api/reports/brand-revenue | Revenue by brand |

---

## File Structure

```
FlameDesk/
├── backend/
│   ├── server.js        ← Express + MySQL2 API (replaces PHP)
│   └── package.json
├── frontend/
│   ├── index.html       ← Login page
│   └── dashboard.html   ← Full interactive dashboard
└── sql/                 ← Original SQL files (unchanged)
    ├── schema.sql
    ├── sample_data.sql
    └── queries_plsql.sql
```

*FlameDesk v2.0 — Node.js + MySQL + AI*
