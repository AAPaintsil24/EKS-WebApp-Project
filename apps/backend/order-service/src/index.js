const express = require("express");
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Example route to create an order
app.post("/orders", (req, res) => {
  const { item, quantity } = req.body;

  // Dummy logic
  return res.json({ success: true, message: `Order for ${quantity} x ${item} created.` });
});

// Example route to list orders
app.get("/orders", (req, res) => {
  // Dummy data
  const orders = [
    { id: 1, item: "Laptop", quantity: 2 },
    { id: 2, item: "Phone", quantity: 1 }
  ];

  res.json({ success: true, orders });
});

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "order-service is running" });
});

app.listen(port, () => {
  console.log(`Order-service listening at http://localhost:${port}`);
});
