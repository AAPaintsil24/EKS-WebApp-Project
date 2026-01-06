const express = require("express");
const cors = require("cors");
const authRoutes = require("./routes/auth");

const app = express();
app.use(cors());
app.use(express.json());
app.use(authRoutes);

if (require.main === module) {
  app.listen(4000, () => console.log("Auth service running"));
}

module.exports = app;

