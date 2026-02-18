// src/db.js
const { Pool } = require("pg");

const pool = new Pool({
  host: process.env.DB_HOST,     // placeholder
  port: process.env.DB_PORT,     // placeholder
  user: process.env.DB_USER,     // placeholder
  password: process.env.DB_PASSWORD, // placeholder
  database: process.env.DB_NAME  // placeholder
});

// Export the pool so you can call pool.query(...)
module.exports = pool;
