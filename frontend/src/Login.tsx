import React, { useState, useEffect } from 'react';
import './Login.css';

declare global {
  interface Window {
    google: any;
  }
}


const API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:3002/api';

const Login: React.FC = () => {
  const [isRegister, setIsRegister] = useState(false);
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [address, setAddress] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    // Check for standard OAuth tokens in URL
    const urlParams = new URLSearchParams(window.location.search);
    const token = urlParams.get('ck_token');
    const err = urlParams.get('error');

    if (err) {
      setError(decodeURIComponent(err));
      window.history.replaceState({}, document.title, window.location.pathname);
    } else if (token) {
      sessionStorage.setItem('ck_auth', '1');
      sessionStorage.setItem('ck_user', urlParams.get('ck_username') || '');
      sessionStorage.setItem('ck_token', token);
      sessionStorage.setItem('ck_role', urlParams.get('ck_role') || 'customer');
      sessionStorage.setItem('ck_display_name', urlParams.get('ck_display_name') || '');
      
      const customerId = urlParams.get('ck_customer_id');
      if (customerId && customerId !== 'undefined') {
        sessionStorage.setItem('ck_customer_id', customerId);
      }
      
      // Clean url and redirect
      window.location.href = urlParams.get('ck_role') === 'customer' ? '/customer' : '/dashboard.html';
    }
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      if (isRegister) {
        // Register
        const response = await fetch(`${API_BASE}/register`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name, phone, email, password, address }),
        });
        const result = await response.json();

        if (!response.ok || !result.success) {
          throw new Error(result.error || 'Registration failed');
        }

        setError('Registration successful! Please login.');
        setIsRegister(false);
        setLoading(false);
        return;
      }

      // Login
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
      window.location.href = result.role === 'customer' ? '/customer' : '/dashboard.html';
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Action failed';
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
          
          <div className="brand-text">
            <h1>TasteTrail</h1>
            <span>Cloud Kitchen OS</span>
          </div>
        </div>

        <div className="login-card" id="loginCard">
          <div className="card-header">
            <h2>{isRegister ? 'Create Account' : 'Welcome back'}</h2>
            <p>{isRegister ? 'Join TasteTrail as a customer' : 'Sign in to your account'}</p>
          </div>

          <form id="loginForm" onSubmit={handleSubmit}>
            {isRegister && (
              <>
                <div className="field-group">
                  <label>Full Name</label>
                  <div className="input-wrap">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
                    </svg>
                    <input
                      type="text"
                      placeholder="ex - Austin"
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      required
                    />
                  </div>
                </div>

                <div className="field-group">
                  <label>Phone</label>
                  <div className="input-wrap">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45 12.84 12.84 0 002.81.7A2 2 0 0122 16.92z"/>
                    </svg>
                    <input
                      type="tel"
                      placeholder="+91 9876543210"
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      required
                    />
                  </div>
                </div>

                <div className="field-group">
                  <label>Email</label>
                  <div className="input-wrap">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/>
                    </svg>
                    <input
                      type="email"
                      placeholder="john@example.com"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      required
                    />
                  </div>
                </div>

                <div className="field-group">
                  <label>Address</label>
                  <div className="input-wrap">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/>
                    </svg>
                    <input
                      type="text"
                      placeholder="Your address"
                      value={address}
                      onChange={(e) => setAddress(e.target.value)}
                    />
                  </div>
                </div>
              </>
            )}

            {!isRegister && (
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
            )}

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
                  required
                />
                <button type="button" className="eye-btn" onClick={togglePassword}>
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                  </svg>
                </button>
              </div>
            </div>

            

            <button type="submit" className={`login-btn ${loading ? 'loading' : ''}`}>
              <span>{loading ? 'Processing…' : (isRegister ? 'Create Account' : 'Access Dashboard')}</span>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M5 12h14M12 5l7 7-7 7"/>
              </svg>
            </button>

            <div className="error-msg">{error}</div>
          </form>

          <div style={{ display: 'flex', justifyContent: 'center', marginTop: '1rem', marginBottom: '1rem', width: '100%' }}>
            <a href={`${API_BASE.replace('/api', '')}/api/auth/google`} className="google-auth-btn">
              <svg viewBox="0 0 24 24" width="20" height="20" xmlns="http://www.w3.org/2000/svg">
                <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
                <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
              </svg>
              <span>Continue with Google</span>
            </a>
          </div>

          <div className="toggle-link">
            <button type="button" onClick={() => { setIsRegister(!isRegister); setError(''); }}>
              {isRegister ? 'Already have an account? Login' : 'New customer? Create account'}
            </button>
          </div>
        </div>

        <div className="login-footer">TasteTrail v1.0 · Cloud Kitchen Management System</div>
      </div>
    </div>
  );
};

export default Login;
