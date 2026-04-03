import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './Login';
import CustomerPortal from './CustomerPortal';
import './App.css';

function App() {
  // Check if user is authenticated
  const isAuthenticated = sessionStorage.getItem('ck_auth') === '1';
  const role = sessionStorage.getItem('ck_role');
  const homePath = role === 'customer' ? '/customer' : '/dashboard.html';
  const loginElement = isAuthenticated ? <Navigate to={homePath} replace /> : <Login />;
  const dashboardElement = isAuthenticated && role === 'admin' ? <Navigate to="/dashboard.html" replace /> : <Navigate to={isAuthenticated ? homePath : "/"} replace />;
  const customerElement = isAuthenticated && role === 'customer' ? <CustomerPortal /> : <Navigate to={isAuthenticated ? homePath : "/"} replace />;

  return (
    <Router>
      <div className="App">
        <Routes>
          <Route path="/" element={loginElement} />
          <Route path="/index.html" element={<Navigate to="/" replace />} />
          <Route path="/dashboard" element={dashboardElement} />
          <Route path="/dashboard.html" element={dashboardElement} />
          <Route path="/customer" element={customerElement} />
          <Route path="*" element={<Navigate to={isAuthenticated ? homePath : "/"} replace />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
