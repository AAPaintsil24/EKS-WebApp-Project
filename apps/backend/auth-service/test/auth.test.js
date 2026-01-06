// test/auth.test.js
const request = require("supertest");
const express = require("express");
const authRoutes = require("../src/routes/auth");

jest.mock("../src/db", () => ({
  query: jest.fn((text, params) => {
    if (text.startsWith("INSERT INTO users")) {
      return Promise.resolve({ rows: [{ username: params[0] }] });
    }
    if (text.startsWith("SELECT * FROM users")) {
      return Promise.resolve({
        rows: [{ username: "albert", email: params[0], password: "hashedpassword" }],
      });
    }
  }),
}));

const app = express();
app.use(express.json());
app.use(authRoutes);

describe("Auth API", () => {
  test("Signup works", async () => {
    const res = await request(app).post("/signup").send({
      username: "albert",
      email: "albert@example.com",
      password: "secret",
    });
    expect(res.statusCode).toBe(200);
    expect(res.body.username).toBe("albert");
  });
});
