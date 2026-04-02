import React, { useState, useEffect } from 'react';
import './Dashboard.css';

const Dashboard: React.FC = () => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [currentPage, setCurrentPage] = useState('dashboard');
  const [time, setTime] = useState('');

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setTime(now.toLocaleTimeString());
    };
    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  const toggleSidebar = () => {
    setSidebarOpen(!sidebarOpen);
  };

  const showPage = (page: string) => {
    setCurrentPage(page);
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

  return (
    <div className="app">
      {/* SIDEBAR */}
      <aside className={`sidebar ${sidebarOpen ? 'open' : ''}`}>
        <div className="sidebar-brand">
          <div className="flame-icon">
            <svg viewBox="0 0 40 50" fill="none">
              <path d="M20 2C20 2 32 14 32 26C32 33.18 26.63 39 20 39C13.37 39 8 33.18 8 26C8 14 20 2 20 2Z" fill="url(#sf1)"/>
              <path d="M20 18C20 18 26 24 26 30C26 33.31 23.31 36 20 36C16.69 36 14 33.31 14 30C14 24 20 18 20 18Z" fill="url(#sf2)"/>
              <defs>
                <linearGradient id="sf1" x1="20" y1="2" x2="20" y2="39" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#FF6B35"/><stop offset="1" stopColor="#F7C59F"/>
                </linearGradient>
                <linearGradient id="sf2" x1="20" y1="18" x2="20" y2="36" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#FFE66D"/><stop offset="1" stopColor="#FF6B35"/>
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
          <a className={`nav-item ${currentPage === 'dashboard' ? 'active' : ''}`} onClick={() => showPage('dashboard')}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
              <rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>
            </svg>
            Dashboard
          </a>
          <a className={`nav-item ${currentPage === 'orders' ? 'active' : ''}`} onClick={() => showPage('orders')}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
              <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2"/><rect x="9" y="3" width="6" height="4" rx="1"/><path d="M9 12h6M9 16h4"/>
            </svg>
            Orders
            <span className="nav-badge">0</span>
          </a>
          <a className={`nav-item ${currentPage === 'menu' ? 'active' : ''}`} onClick={() => showPage('menu')}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
              <path d="M12 2a9 9 0 018.66 6.57 9 9 0 01-3.72 10.07A9 9 0 013.06 15.5 9 9 0 013.34 8.57 9 9 0 0112 2z"/><path d="M12 8v4l3 3"/>
            </svg>
            Menu
          </a>
          <a className={`nav-item ${currentPage === 'brands' ? 'active' : ''}`} onClick={() => showPage('brands')}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
              <path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"/>
            </svg>
            Brands
          </a>
          <div className="nav-section">OPERATIONS</div>
          <a className={`nav-item ${currentPage === 'customers' ? 'active' : ''}`} onClick={() => showPage('customers')}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
              <circle cx="9" cy="7" r="4"/><path d="M3 21v-2a4 4 0 014-4h4a4 4 0 014 4v2"/><circle cx="19" cy="7" r="2"/><path d="M22 21v-1a3 3 0 00-3-3h-1"/>
            </svg>
            Customers
          </a>
          <a className={`nav-item ${currentPage === 'delivery' ? 'active' : ''}`} onClick={() => showPage('delivery')}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
              <rect x="1" y="3" width="15" height="13" rx="1"/><path d="M16 8h4l3 3v5h-7V8z"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/>
            </svg>
            Delivery
          </a>
          <a className={`nav-item ${currentPage === 'inventory' ? 'active' : ''}`} onClick={() => showPage('inventory')}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
              <path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/>
            </svg>
            Inventory
          </a>
          <div className="nav-section">INSIGHTS</div>
          <a className={`nav-item ${currentPage === 'ratings' ? 'active' : ''}`} onClick={() => showPage('ratings')}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
              <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
            </svg>
            Ratings
          </a>
          <a className={`nav-item ${currentPage === 'reports' ? 'active' : ''}`} onClick={() => showPage('reports')}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
              <line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/>
            </svg>
            Reports
          </a>
          <a className={`nav-item ${currentPage === 'ai' ? 'active' : ''}`} onClick={() => showPage('ai')}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
              <path d="M12 2a2 2 0 012 2v2a2 2 0 01-2 2 2 2 0 01-2-2V4a2 2 0 012-2z"/><path d="M12 16a2 2 0 012 2v2a2 2 0 01-4 0v-2a2 2 0 012-2z"/><path d="M4.93 4.93a2 2 0 012.83 0L9.17 6.34a2 2 0 010 2.83 2 2 0 01-2.83 0L4.93 7.76a2 2 0 010-2.83z"/><path d="M14.83 14.83a2 2 0 012.83 0l1.41 1.41a2 2 0 01-2.83 2.83l-1.41-1.41a2 2 0 010-2.83z"/><path d="M2 12a2 2 0 012-2h2a2 2 0 010 4H4a2 2 0 01-2-2z"/><path d="M16 12a2 2 0 012-2h2a2 2 0 010 4h-2a2 2 0 01-2-2z"/>
            </svg>
            AI Insights
            <span className="nav-badge" style={{background: 'var(--gold)', color: '#111'}}>✦</span>
          </a>
        </nav>

        <div className="sidebar-user">
          <div className="user-avatar">A</div>
          <div className="user-info">
            <div className="user-name">Admin</div>
            <div className="user-role">Super Admin</div>
          </div>
          <button className="logout-btn" onClick={logout} title="Logout">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>
            </svg>
          </button>
        </div>
      </aside>

      {/* MAIN */}
      <main className="main-content">
        {/* TOPBAR */}
        <header className="topbar">
          <div className="topbar-left">
            <button className="menu-toggle" onClick={toggleSidebar}>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/>
              </svg>
            </button>
            <div className="page-title">Dashboard</div>
          </div>
          <div className="topbar-right">
            <div className="time-display">{time}</div>
            <div className="status-pill">
              <span className="pulse"></span> Live
            </div>
          </div>
        </header>

        {/* DASHBOARD PAGE */}
        <div className="page active">
          <div className="page-header">
            <div>
              <h2>Good morning, Admin 👋</h2>
              <p>Here's what's happening in your kitchen today</p>
            </div>
          </div>

          <div className="stat-grid">
            <div className="stat-card flame">
              <div className="stat-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2"/>
                  <rect x="9" y="3" width="6" height="4" rx="1"/>
                </svg>
              </div>
              <div>
                <div className="stat-val">24</div>
                <div className="stat-label">Total Orders</div>
              </div>
            </div>
            <div className="stat-card amber">
              <div className="stat-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
                </svg>
              </div>
              <div>
                <div className="stat-val">3</div>
                <div className="stat-label">Pending</div>
              </div>
            </div>
            <div className="stat-card green">
              <div className="stat-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <polyline points="20 6 9 17 4 12"/>
                </svg>
              </div>
              <div>
                <div className="stat-val">18</div>
                <div className="stat-label">Delivered Today</div>
              </div>
            </div>
            <div className="stat-card gold">
              <div className="stat-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/>
                </svg>
              </div>
              <div>
                <div className="stat-val">$1,247</div>
                <div className="stat-label">Revenue Today</div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
