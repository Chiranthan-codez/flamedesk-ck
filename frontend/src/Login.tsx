import React, { useState } from 'react';
import './Login.css';

const API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:3001/api';

const Login: React.FC = () => {
  const [username, setUsername] = useState('admin');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await fetch(`${API_BASE}/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password }),
      });
      const result = await response.json();

      if (!response.ok || !result.success || !result.token) {
        throw new Error(result.error || 'Invalid credentials');
      }

      sessionStorage.setItem('ck_auth', '1');
      sessionStorage.setItem('ck_user', result.username || username);
      sessionStorage.setItem('ck_token', result.token);
      sessionStorage.setItem('ck_role', result.role || 'admin');
      sessionStorage.setItem('ck_display_name', result.display_name || result.username || username);
      if (result.customer_id) {
        sessionStorage.setItem('ck_customer_id', String(result.customer_id));
      } else {
        sessionStorage.removeItem('ck_customer_id');
      }
      window.location.href = result.role === 'customer' ? '/customer' : '/dashboard';
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Login failed';
      setError(message);
      setLoading(false);
      document.getElementById('loginCard')?.classList.add('shake');
      setTimeout(() => {
        document.getElementById('loginCard')?.classList.remove('shake');
      }, 500);
    }
  };

  const togglePassword = () => {
    const pwdInput = document.getElementById('password') as HTMLInputElement;
    pwdInput.type = pwdInput.type === 'password' ? 'text' : 'password';
  };

  return (
    <div className="login-bg">
      <div className="noise"></div>
      <div className="orb orb-1"></div>
      <div className="orb orb-2"></div>
      <div className="orb orb-3"></div>

      <div className="login-container">
        <div className="brand-mark">
          <div className="flame-icon">
            <svg viewBox="0 0 40 50" fill="none">
              <path d="M20 2C20 2 32 14 32 26C32 33.18 26.63 39 20 39C13.37 39 8 33.18 8 26C8 14 20 2 20 2Z" fill="url(#f1)"/>
              <path d="M20 18C20 18 26 24 26 30C26 33.31 23.31 36 20 36C16.69 36 14 33.31 14 30C14 24 20 18 20 18Z" fill="url(#f2)"/>
              <defs>
                <linearGradient id="f1" x1="20" y1="2" x2="20" y2="39" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#FF6B35"/><stop offset="1" stopColor="#F7C59F"/>
                </linearGradient>
                <linearGradient id="f2" x1="20" y1="18" x2="20" y2="36" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#FFE66D"/><stop offset="1" stopColor="#FF6B35"/>
                </linearGradient>
              </defs>
            </svg>
          </div>
          <div className="brand-text">
            <h1>FlameDesk</h1>
            <span>Cloud Kitchen OS</span>
          </div>
        </div>

        <div className="login-card" id="loginCard">
          <div className="card-header">
            <h2>Welcome back</h2>
            <p>Sign in to your kitchen command center</p>
          </div>

          <form id="loginForm" onSubmit={handleSubmit}>
            <div className="field-group">
              <label>Username</label>
              <div className="input-wrap">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
                </svg>
                <input
                  type="text"
                  id="username"
                  placeholder="admin"
                  autoComplete="username"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                />
              </div>
            </div>

            <div className="field-group">
              <label>Password</label>
              <div className="input-wrap">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/>
                </svg>
                <input
                  type="password"
                  id="password"
                  placeholder="••••••••"
                  autoComplete="current-password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                />
                <button type="button" className="eye-btn" onClick={togglePassword}>
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                  </svg>
                </button>
              </div>
            </div>

            

            <button type="submit" className={`login-btn ${loading ? 'loading' : ''}`}>
              <span>{loading ? 'Launching…' : 'Access Dashboard'}</span>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M5 12h14M12 5l7 7-7 7"/>
              </svg>
            </button>

            <div className="error-msg">{error}</div>
          </form>
        </div>

        <div className="login-footer">FlameDesk v1.0 · Cloud Kitchen Management System</div>
      </div>
    </div>
  );
};

export default Login;
