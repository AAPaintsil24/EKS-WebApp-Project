const express = require("express");
const bcrypt = require("bcrypt");
const db = require("../db");

const router = express.Router();

router.post("/signup", async (req, res) => {
  const { username, email, password } = req.body;
  const hash = await bcrypt.hash(password, 10);

  const result = await db.query(
    "INSERT INTO users (username, email, password) VALUES ($1,$2,$3) RETURNING username",
    [username, email, hash]
  );

  res.json(result.rows[0]);
});

router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  const user = await db.query("SELECT * FROM users WHERE email=$1", [email]);
  if (!user.rows.length) return res.status(401).end();

  const valid = await bcrypt.compare(password, user.rows[0].password);
  if (!valid) return res.status(401).end();

  res.json({ username: user.rows[0].username });
});

module.exports = router;
