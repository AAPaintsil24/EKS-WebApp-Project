const request = require("supertest");
const fs = require("fs");
const path = require("path");
const app = require("../src/server");
const db = require("../src/db");

beforeAll(async () => {
  const sql = fs.readFileSync(
    path.join(__dirname, "../sql/init.sql"),
    "utf8"
  );
  await db.query(sql);
});

describe("Auth API – Integration", () => {
  test("Signup inserts user into database", async () => {
    const res = await request(app)
      .post("/signup")
      .send({
        username: "integration_user",
        email: "integration@test.com",
        password: "password123",
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.username).toBe("integration_user");
  });
});

afterAll(async () => {
  await db.end();
});
