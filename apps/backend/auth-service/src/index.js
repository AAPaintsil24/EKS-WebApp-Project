const express = require("express");
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Example login route
app.post("/login", (req, res) => {
  const { username, password } = req.body;

  // Dummy auth logic
  if (username === "admin" && password === "password") {
    return res.json({ success: true, token: "fake-jwt-token" });
  } else {
    return res.status(401).json({ success: false, message: "Invalid credentials" });
  }
});

// Example registration route
app.post("/register", (req, res) => {
  const { username, password } = req.body;

  // Dummy logic
  return res.json({ success: true, message: `User ${username} registered.` });
});

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "auth-service is running" });
});

app.listen(port, () => {
  console.log(`Auth-service listening at http://localhost:${port}`);
});
