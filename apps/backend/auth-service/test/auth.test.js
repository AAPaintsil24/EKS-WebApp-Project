const request = require("supertest");
const app = require("../src/server");

describe("Auth API", () => {
  test("Signup works", async () => {
    const res = await request(app)
      .post("/signup")
      .send({
        username: "albert",
        email: "albert@test.com",
        password: "password123"
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.username).toBe("albert");
  });
});

