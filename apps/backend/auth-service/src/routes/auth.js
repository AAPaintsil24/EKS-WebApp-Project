const express = require("express");
const bcrypt = require("bcrypt");
const pool = require("../db"); // <--- use pool, not db

const router = express.Router();

router.post("/signup", async (req, res) => {
  const { username, email, password } = req.body;
  const hash = await bcrypt.hash(password, 10);

  try {
    const result = await pool.query(
      "INSERT INTO users (username, email, password) VALUES ($1,$2,$3) RETURNING username",
      [username, email, hash]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error creating user");
  }
});

router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const result = await pool.query("SELECT * FROM users WHERE email=$1", [email]);
    if (!result.rows.length) return res.status(401).end();

    const valid = await bcrypt.compare(password, result.rows[0].password);
    if (!valid) return res.status(401).end();

    res.json({ username: result.rows[0].username });
  } catch (err) {
    console.error(err);
    res.status(500).send("Error logging in");
  }
});

module.exports = router;

