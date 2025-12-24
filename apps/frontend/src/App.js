import React from "react";

function App() {
  const authUrl = "http://auth-service:3000";    // replace with your auth-service URL
  const orderUrl = "http://order-service:3000";  // replace with your order-service URL

  return (
    <div style={{ textAlign: "center", marginTop: "100px", fontFamily: "Arial" }}>
      <h1>Welcome to DevOps Albert Inc.</h1>
      <div style={{ marginTop: "50px" }}>
        <button 
          style={{ marginRight: "20px", padding: "10px 20px", fontSize: "16px" }}
          onClick={() => window.location.href = authUrl}
        >
          Auth Service
        </button>
        <button 
          style={{ padding: "10px 20px", fontSize: "16px" }}
          onClick={() => window.location.href = orderUrl}
        >
          Order Service
        </button>
      </div>
    </div>
  );
}

export default App;
