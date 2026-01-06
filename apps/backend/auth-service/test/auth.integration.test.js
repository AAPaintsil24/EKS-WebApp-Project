const request = require("supertest");
const app = require("../src/server");

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
