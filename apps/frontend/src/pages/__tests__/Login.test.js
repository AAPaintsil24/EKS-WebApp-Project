import { render, screen } from "@testing-library/react";
import Login from "../Login";

test("renders login form", () => {
  render(<Login />);
  expect(screen.getByText("Login")).toBeInTheDocument();
});
