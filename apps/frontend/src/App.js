import React, { useState } from 'react';
import './App.css';

function App() {
  const [authData, setAuthData] = useState({ username: '', password: '' });
  const [orderData, setOrderData] = useState({ user_id: '', item: '', quantity: 1 });
  const [message, setMessage] = useState('');

  const authServiceUrl = process.env.REACT_APP_AUTH_URL || 'http://localhost:3000';
  const orderServiceUrl = process.env.REACT_APP_ORDER_URL || 'http://localhost:3001';

  const handleAuthSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await fetch(`${authServiceUrl}/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(authData)
      });
      const result = await response.json();
      setMessage(result.success ? `User ${authData.username} registered!` : `Error: ${result.message}`);
    } catch (error) {
      setMessage('Failed to connect to auth service');
    }
  };

  const handleOrderSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await fetch(`${orderServiceUrl}/orders`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(orderData)
      });
      const result = await response.json();
      setMessage(result.success ? `Order for ${orderData.item} created!` : `Error: ${result.message}`);
    } catch (error) {
      setMessage('Failed to connect to order service');
    }
  };

  return (
    <div className="App">
      <h1>DevOps Portfolio Project</h1>
      
      <div className="service-section">
        <h2>Auth Service</h2>
        <form onSubmit={handleAuthSubmit}>
          <input type="text" placeholder="Username" value={authData.username}
            onChange={(e) => setAuthData({...authData, username: e.target.value})} />
          <input type="password" placeholder="Password" value={authData.password}
            onChange={(e) => setAuthData({...authData, password: e.target.value})} />
          <button type="submit">Register User</button>
        </form>
      </div>

      <div className="service-section">
        <h2>Order Service</h2>
        <form onSubmit={handleOrderSubmit}>
          <input type="number" placeholder="User ID" value={orderData.user_id}
            onChange={(e) => setOrderData({...orderData, user_id: e.target.value})} />
          <input type="text" placeholder="Item" value={orderData.item}
            onChange={(e) => setOrderData({...orderData, item: e.target.value})} />
          <input type="number" placeholder="Quantity" value={orderData.quantity}
            onChange={(e) => setOrderData({...orderData, quantity: e.target.value})} />
          <button type="submit">Create Order</button>
        </form>
      </div>

      <div className="service-section">
        <h2>Service Health</h2>
        <div className="health-buttons">
          <button onClick={async () => {
            const response = await fetch(`${authServiceUrl}/health`);
            const data = await response.json();
            setMessage(`Auth Service: ${data.status} (DB: ${data.database})`);
          }}>Check Auth Health</button>
          
          <button onClick={async () => {
            const response = await fetch(`${orderServiceUrl}/health`);
            const data = await response.json();
            setMessage(`Order Service: ${data.status} (DB: ${data.database})`);
          }}>Check Order Health</button>
        </div>
      </div>

      {message && <div className="message">{message}</div>}
    </div>
  );
}

export default App;
