import React, { useCallback, useEffect, useMemo, useState } from 'react';
import './Dashboard.css';

const API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:3001/api';

type DashboardStats = {
  total_orders: number;
  pending_orders: number;
  delivered_today: number;
  revenue_today: number;
  low_stock: number;
  active_brands: number;
  total_customers: number;
  available_riders: number;
};

type Order = {
  order_id: number;
  customer_name: string;
  phone: string;
  total_amount: number;
  status: string;
  order_time: string;
  payment_method: string | null;
  payment_status: string | null;
  delivery_partner: string | null;
  delivery_status: string | null;
};

type MenuItem = {
  item_id: number;
  item_name: string;
  brand_name: string;
  category: string | null;
  price: number;
  prep_time: number;
  is_available: number;
  avg_rating: number | null;
  rating_count: number;
};

type Brand = {
  brand_id: number;
  brand_name: string;
  cuisine_type: string | null;
  status: string;
  item_count: number;
};

type Customer = {
  customer_id: number;
  name: string;
  phone: string;
  email: string | null;
  order_count: number;
  total_spent: number;
};

type DeliveryPartner = {
  partner_id: number;
  name: string;
  phone: string;
  vehicle_no: string;
  status: string;
  total_deliveries: number;
};

type InventoryItem = {
  ing_id: number;
  name: string;
  unit: string;
  current_stock_qty: number;
  reorder_level: number;
  status: string;
};

type Rating = {
  rating_id: number;
  customer_name: string;
  item_name: string;
  brand_name: string;
  rating_value: number;
  review_text: string | null;
  created_at: string;
};

type TopItem = {
  item_name: string;
  brand_name: string;
  qty_sold: number;
  revenue: number;
  rating: number | null;
};

type BrandRevenue = {
  brand_id: number;
  brand_name: string;
  revenue: number;
};

type PageKey = 'dashboard' | 'orders' | 'menu' | 'brands' | 'customers' | 'delivery' | 'inventory' | 'ratings' | 'reports' | 'ai';

type ApiResponse<T> = {
  success: boolean;
  data?: T;
  error?: string;
};

const pageTitles: Record<PageKey, string> = {
  dashboard: 'Dashboard',
  orders: 'Orders',
  menu: 'Menu',
  brands: 'Brands',
  customers: 'Customers',
  delivery: 'Delivery',
  inventory: 'Inventory',
  ratings: 'Ratings',
  reports: 'Reports',
  ai: 'AI Insights'
};

function formatCurrency(value: number) {
  return new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(Number(value || 0));
}

function formatDateTime(value: string) {
  return new Date(value).toLocaleString('en-IN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
}

function labelize(value: string | null | undefined, fallback = 'n/a') {
  if (!value) return fallback;
  return value.replaceAll('_', ' ');
}

function DashboardTable({
  columns,
  rows,
  emptyMessage
}: {
  columns: string[];
  rows: React.ReactNode[][];
  emptyMessage: string;
}) {
  if (!rows.length) {
    return <div className="stat-card"><div className="stat-label">{emptyMessage}</div></div>;
  }

  return (
    <div style={{ overflowX: 'auto' }}>
      <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.92rem' }}>
        <thead>
          <tr>
            {columns.map(column => (
              <th
                key={column}
                style={{
                  textAlign: 'left',
                  padding: '12px 10px',
                  color: 'var(--muted)',
                  fontWeight: 600,
                  borderBottom: '1px solid var(--border)'
                }}
              >
                {column}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, index) => (
            <tr key={index}>
              {row.map((cell, cellIndex) => (
                <td
                  key={`${index}-${cellIndex}`}
                  style={{
                    padding: '12px 10px',
                    borderBottom: '1px solid var(--border)',
                    color: 'var(--text)',
                    verticalAlign: 'top'
                  }}
                >
                  {cell}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

const Dashboard: React.FC = () => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [currentPage, setCurrentPage] = useState<PageKey>('dashboard');
  const [time, setTime] = useState('');
  const [loadingPage, setLoadingPage] = useState(false);
  const [error, setError] = useState('');
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [orders, setOrders] = useState<Order[]>([]);
  const [menuItems, setMenuItems] = useState<MenuItem[]>([]);
  const [brands, setBrands] = useState<Brand[]>([]);
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [deliveryPartners, setDeliveryPartners] = useState<DeliveryPartner[]>([]);
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [ratings, setRatings] = useState<Rating[]>([]);
  const [topItems, setTopItems] = useState<TopItem[]>([]);
  const [brandRevenue, setBrandRevenue] = useState<BrandRevenue[]>([]);

  const token = sessionStorage.getItem('ck_token') || '';

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setTime(now.toLocaleTimeString());
    };
    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  const api = useCallback(async <T,>(path: string): Promise<T> => {
    const response = await fetch(`${API_BASE}${path}`, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`
      }
    });
    const result = await response.json();
    if (!response.ok || result.success === false) {
      throw new Error(result.error || 'Request failed');
    }
    return result as T;
  }, [token]);

  const loadPageData = useCallback(async (page: PageKey) => {
    setLoadingPage(true);
    setError('');
    try {
      if (page === 'dashboard') {
        const result = await api<ApiResponse<DashboardStats>>('/dashboard/stats');
        setStats(result.data || null);
      } else if (page === 'orders') {
        const result = await api<ApiResponse<Order[]>>('/orders');
        setOrders(result.data || []);
      } else if (page === 'menu') {
        const result = await api<ApiResponse<MenuItem[]>>('/menu');
        setMenuItems(result.data || []);
      } else if (page === 'brands') {
        const result = await api<ApiResponse<Brand[]>>('/brands');
        setBrands(result.data || []);
      } else if (page === 'customers') {
        const result = await api<ApiResponse<Customer[]>>('/customers');
        setCustomers(result.data || []);
      } else if (page === 'delivery') {
        const result = await api<ApiResponse<DeliveryPartner[]>>('/delivery');
        setDeliveryPartners(result.data || []);
      } else if (page === 'inventory') {
        const result = await api<ApiResponse<InventoryItem[]>>('/inventory');
        setInventory(result.data || []);
      } else if (page === 'ratings') {
        const result = await api<ApiResponse<Rating[]>>('/ratings');
        setRatings(result.data || []);
      } else if (page === 'reports') {
        const [itemsResult, brandResult] = await Promise.all([
          api<ApiResponse<TopItem[]>>('/reports/top-items'),
          api<ApiResponse<BrandRevenue[]>>('/reports/brand-revenue')
        ]);
        setTopItems(itemsResult.data || []);
        setBrandRevenue(brandResult.data || []);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load page');
    } finally {
      setLoadingPage(false);
    }
  }, [api]);

  useEffect(() => {
    void loadPageData(currentPage);
  }, [currentPage, loadPageData]);

  const toggleSidebar = () => {
    setSidebarOpen(!sidebarOpen);
  };

  const showPage = (page: PageKey) => {
    setCurrentPage(page);
    setSidebarOpen(false);
  };

  const logout = () => {
    sessionStorage.removeItem('ck_auth');
    sessionStorage.removeItem('ck_user');
    sessionStorage.removeItem('ck_token');
    sessionStorage.removeItem('ck_role');
    sessionStorage.removeItem('ck_customer_id');
    sessionStorage.removeItem('ck_display_name');
    window.location.href = '/';
  };

  const activePendingOrders = useMemo(() => orders.filter(order => order.status === 'pending').length, [orders]);

  function renderPageContent() {
    if (loadingPage) {
      return <div className="stat-card"><div className="stat-label">Loading {pageTitles[currentPage].toLowerCase()}…</div></div>;
    }

    if (error) {
      return <div className="stat-card"><div className="stat-label" style={{ color: 'var(--red)' }}>{error}</div></div>;
    }

    if (currentPage === 'dashboard') {
      return (
        <>
          <div className="page-header">
            <div>
              <h2>Good morning, Admin</h2>
              <p>Here&apos;s what&apos;s happening in your kitchen today</p>
            </div>
          </div>

          <div className="stat-grid">
            <div className="stat-card flame">
              <div className="stat-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2"/><rect x="9" y="3" width="6" height="4" rx="1"/></svg></div>
              <div><div className="stat-val">{stats?.total_orders ?? 0}</div><div className="stat-label">Total Orders</div></div>
            </div>
            <div className="stat-card amber">
              <div className="stat-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
              <div><div className="stat-val">{stats?.pending_orders ?? 0}</div><div className="stat-label">Pending</div></div>
            </div>
            <div className="stat-card green">
              <div className="stat-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="20 6 9 17 4 12"/></svg></div>
              <div><div className="stat-val">{stats?.delivered_today ?? 0}</div><div className="stat-label">Delivered Today</div></div>
            </div>
            <div className="stat-card gold">
              <div className="stat-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg></div>
              <div><div className="stat-val">{formatCurrency(stats?.revenue_today ?? 0)}</div><div className="stat-label">Revenue Today</div></div>
            </div>
          </div>

          <div className="stat-grid">
            <div className="stat-card"><div><div className="stat-val">{stats?.low_stock ?? 0}</div><div className="stat-label">Low Stock Items</div></div></div>
            <div className="stat-card"><div><div className="stat-val">{stats?.active_brands ?? 0}</div><div className="stat-label">Active Brands</div></div></div>
            <div className="stat-card"><div><div className="stat-val">{stats?.total_customers ?? 0}</div><div className="stat-label">Customers</div></div></div>
            <div className="stat-card"><div><div className="stat-val">{stats?.available_riders ?? 0}</div><div className="stat-label">Available Riders</div></div></div>
          </div>
        </>
      );
    }

    if (currentPage === 'orders') {
      return (
        <>
          <div className="page-header">
            <div>
              <h2>Orders</h2>
              <p>{orders.length} orders loaded, {activePendingOrders} currently pending.</p>
            </div>
          </div>
          <DashboardTable
            columns={['Order', 'Customer', 'Status', 'Payment', 'Delivery', 'Total', 'Placed']}
            rows={orders.map(order => [
              `#${order.order_id}`,
              <div key={order.order_id}><strong>{order.customer_name}</strong><div style={{ color: 'var(--muted)' }}>{order.phone}</div></div>,
              labelize(order.status),
              `${labelize(order.payment_status, 'pending')} / ${order.payment_method ? order.payment_method.toUpperCase() : 'N/A'}`,
              `${labelize(order.delivery_status, 'unassigned')} / ${order.delivery_partner || 'No rider'}`,
              formatCurrency(order.total_amount),
              formatDateTime(order.order_time)
            ])}
            emptyMessage="No orders available."
          />
        </>
      );
    }

    if (currentPage === 'menu') {
      return (
        <>
          <div className="page-header"><div><h2>Menu</h2><p>All menu items across brands.</p></div></div>
          <DashboardTable
            columns={['Item', 'Brand', 'Category', 'Price', 'Prep', 'Status', 'Rating']}
            rows={menuItems.map(item => [
              item.item_name,
              item.brand_name,
              item.category || 'N/A',
              formatCurrency(item.price),
              `${item.prep_time} min`,
              item.is_available ? 'available' : 'unavailable',
              item.avg_rating ? `${item.avg_rating}/5 (${item.rating_count})` : 'No ratings'
            ])}
            emptyMessage="No menu items available."
          />
        </>
      );
    }

    if (currentPage === 'brands') {
      return (
        <>
          <div className="page-header"><div><h2>Brands</h2><p>Track brand catalog and status.</p></div></div>
          <DashboardTable
            columns={['Brand', 'Cuisine', 'Status', 'Items']}
            rows={brands.map(brand => [brand.brand_name, brand.cuisine_type || 'N/A', labelize(brand.status), brand.item_count])}
            emptyMessage="No brands available."
          />
        </>
      );
    }

    if (currentPage === 'customers') {
      return (
        <>
          <div className="page-header"><div><h2>Customers</h2><p>Customer base sorted by total spend.</p></div></div>
          <DashboardTable
            columns={['Customer', 'Contact', 'Orders', 'Spent']}
            rows={customers.map(customer => [
              customer.name,
              <div key={customer.customer_id}><div>{customer.phone}</div><div style={{ color: 'var(--muted)' }}>{customer.email || 'No email'}</div></div>,
              customer.order_count,
              formatCurrency(customer.total_spent)
            ])}
            emptyMessage="No customers available."
          />
        </>
      );
    }

    if (currentPage === 'delivery') {
      return (
        <>
          <div className="page-header"><div><h2>Delivery</h2><p>Partner availability and completed deliveries.</p></div></div>
          <DashboardTable
            columns={['Partner', 'Phone', 'Vehicle', 'Status', 'Deliveries']}
            rows={deliveryPartners.map(partner => [partner.name, partner.phone, partner.vehicle_no, labelize(partner.status), partner.total_deliveries])}
            emptyMessage="No delivery partners available."
          />
        </>
      );
    }

    if (currentPage === 'inventory') {
      return (
        <>
          <div className="page-header"><div><h2>Inventory</h2><p>Ingredient stock status and reorder thresholds.</p></div></div>
          <DashboardTable
            columns={['Ingredient', 'Stock', 'Unit', 'Reorder Level', 'Status']}
            rows={inventory.map(item => [item.name, item.current_stock_qty, item.unit, item.reorder_level, labelize(item.status)])}
            emptyMessage="No inventory records available."
          />
        </>
      );
    }

    if (currentPage === 'ratings') {
      return (
        <>
          <div className="page-header"><div><h2>Ratings</h2><p>Latest customer feedback on menu items.</p></div></div>
          <DashboardTable
            columns={['Customer', 'Item', 'Brand', 'Rating', 'Review', 'Date']}
            rows={ratings.map(rating => [
              rating.customer_name,
              rating.item_name,
              rating.brand_name,
              `${rating.rating_value}/5`,
              rating.review_text || 'No review',
              formatDateTime(rating.created_at)
            ])}
            emptyMessage="No ratings available."
          />
        </>
      );
    }

    if (currentPage === 'reports') {
      return (
        <>
          <div className="page-header"><div><h2>Reports</h2><p>Top-selling items and brand revenue snapshot.</p></div></div>
          <div className="stat-grid" style={{ marginBottom: '20px' }}>
            {brandRevenue.slice(0, 4).map(brand => (
              <div className="stat-card gold" key={brand.brand_id}>
                <div>
                  <div className="stat-val">{formatCurrency(brand.revenue)}</div>
                  <div className="stat-label">{brand.brand_name}</div>
                </div>
              </div>
            ))}
          </div>
          <DashboardTable
            columns={['Item', 'Brand', 'Qty Sold', 'Revenue', 'Rating']}
            rows={topItems.map(item => [
              item.item_name,
              item.brand_name,
              item.qty_sold,
              formatCurrency(item.revenue),
              item.rating ? `${item.rating}/5` : 'No ratings'
            ])}
            emptyMessage="No report data available."
          />
        </>
      );
    }

    return (
      <>
        <div className="page-header"><div><h2>AI Insights</h2><p>The admin navigation is now working. This page can be expanded later with your AI analysis workflow.</p></div></div>
        <div className="stat-grid">
          <div className="stat-card">
            <div>
              <div className="stat-val">Ready</div>
              <div className="stat-label">Use this section for future insights and recommendations.</div>
            </div>
          </div>
        </div>
      </>
    );
  }

  const navItem = (page: PageKey, label: string, icon: React.ReactNode, badge?: React.ReactNode) => (
    <button type="button" className={`nav-item ${currentPage === page ? 'active' : ''}`} onClick={() => showPage(page)}>
      {icon}
      {label}
      {badge ? <span className="nav-badge">{badge}</span> : null}
    </button>
  );

  return (
    <div className="app">
      <aside className={`sidebar ${sidebarOpen ? 'open' : ''}`}>
        <div className="sidebar-brand">
          <div className="flame-icon">
            <svg viewBox="0 0 40 50" fill="none">
              <path d="M20 2C20 2 32 14 32 26C32 33.18 26.63 39 20 39C13.37 39 8 33.18 8 26C8 14 20 2 20 2Z" fill="url(#sf1)" />
              <path d="M20 18C20 18 26 24 26 30C26 33.31 23.31 36 20 36C16.69 36 14 33.31 14 30C14 24 20 18 20 18Z" fill="url(#sf2)" />
              <defs>
                <linearGradient id="sf1" x1="20" y1="2" x2="20" y2="39" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#FF6B35" /><stop offset="1" stopColor="#F7C59F" />
                </linearGradient>
                <linearGradient id="sf2" x1="20" y1="18" x2="20" y2="36" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#FFE66D" /><stop offset="1" stopColor="#FF6B35" />
                </linearGradient>
              </defs>
            </svg>
          </div>
          <div>
            <div className="brand-name">FlameDesk</div>
            <div className="brand-sub">Kitchen OS v2</div>
          </div>
        </div>

        <nav className="sidebar-nav">
          <div className="nav-section">MAIN</div>
          {navItem('dashboard', 'Dashboard', <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><rect x="3" y="3" width="7" height="7" rx="1" /><rect x="14" y="3" width="7" height="7" rx="1" /><rect x="3" y="14" width="7" height="7" rx="1" /><rect x="14" y="14" width="7" height="7" rx="1" /></svg>)}
          {navItem('orders', 'Orders', <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2" /><rect x="9" y="3" width="6" height="4" rx="1" /><path d="M9 12h6M9 16h4" /></svg>, activePendingOrders)}
          {navItem('menu', 'Menu', <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><path d="M12 2a9 9 0 018.66 6.57 9 9 0 01-3.72 10.07A9 9 0 013.06 15.5 9 9 0 013.34 8.57 9 9 0 0112 2z" /><path d="M12 8v4l3 3" /></svg>)}
          {navItem('brands', 'Brands', <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z" /></svg>)}
          <div className="nav-section">OPERATIONS</div>
          {navItem('customers', 'Customers', <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><circle cx="9" cy="7" r="4" /><path d="M3 21v-2a4 4 0 014-4h4a4 4 0 014 4v2" /><circle cx="19" cy="7" r="2" /><path d="M22 21v-1a3 3 0 00-3-3h-1" /></svg>)}
          {navItem('delivery', 'Delivery', <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><rect x="1" y="3" width="15" height="13" rx="1" /><path d="M16 8h4l3 3v5h-7V8z" /><circle cx="5.5" cy="18.5" r="2.5" /><circle cx="18.5" cy="18.5" r="2.5" /></svg>)}
          {navItem('inventory', 'Inventory', <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z" /><polyline points="3.27 6.96 12 12.01 20.73 6.96" /><line x1="12" y1="22.08" x2="12" y2="12" /></svg>)}
          <div className="nav-section">INSIGHTS</div>
          {navItem('ratings', 'Ratings', <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" /></svg>)}
          {navItem('reports', 'Reports', <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><line x1="18" y1="20" x2="18" y2="10" /><line x1="12" y1="20" x2="12" y2="4" /><line x1="6" y1="20" x2="6" y2="14" /></svg>)}
          {navItem('ai', 'AI Insights', <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><path d="M12 2a2 2 0 012 2v2a2 2 0 01-2 2 2 2 0 01-2-2V4a2 2 0 012-2z" /><path d="M12 16a2 2 0 012 2v2a2 2 0 01-4 0v-2a2 2 0 012-2z" /><path d="M4.93 4.93a2 2 0 012.83 0L9.17 6.34a2 2 0 010 2.83 2 2 0 01-2.83 0L4.93 7.76a2 2 0 010-2.83z" /><path d="M14.83 14.83a2 2 0 012.83 0l1.41 1.41a2 2 0 01-2.83 2.83l-1.41-1.41a2 2 0 010-2.83z" /><path d="M2 12a2 2 0 012-2h2a2 2 0 010 4H4a2 2 0 01-2-2z" /><path d="M16 12a2 2 0 012-2h2a2 2 0 010 4h-2a2 2 0 01-2-2z" /></svg>, '✦')}
        </nav>

        <div className="sidebar-user">
          <div className="user-avatar">A</div>
          <div className="user-info">
            <div className="user-name">Admin</div>
            <div className="user-role">Super Admin</div>
          </div>
          <button className="logout-btn" onClick={logout} title="Logout">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4" /><polyline points="16 17 21 12 16 7" /><line x1="21" y1="12" x2="9" y2="12" />
            </svg>
          </button>
        </div>
      </aside>

      <main className="main-content">
        <header className="topbar">
          <div className="topbar-left">
            <button className="menu-toggle" onClick={toggleSidebar}>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <line x1="3" y1="6" x2="21" y2="6" /><line x1="3" y1="12" x2="21" y2="12" /><line x1="3" y1="18" x2="21" y2="18" />
              </svg>
            </button>
            <div className="page-title">{pageTitles[currentPage]}</div>
          </div>
          <div className="topbar-right">
            <div className="time-display">{time}</div>
            <div className="status-pill"><span className="pulse"></span> Live</div>
          </div>
        </header>

        <div className="page active">
          {renderPageContent()}
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
