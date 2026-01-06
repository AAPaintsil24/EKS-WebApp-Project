const express = require("express");
const cors = require("cors");
const authRoutes = require("./routes/auth");

const app = express();

app.use(cors());
app.use(express.json());
app.use(authRoutes);

/* Only start server if run directly */
if (require.main === module) {
  app.listen(4000, () => {
    console.log("Auth service running on port 4000");
  });
}

module.exports = app;

