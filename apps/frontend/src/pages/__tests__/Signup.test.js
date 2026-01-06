import { render, screen } from "@testing-library/react";
import Signup from "../Signup";

test("renders Signup page", () => {
  render(<Signup setPage={() => {}} />);

  expect(screen.getByText(/sign up/i)).toBeInTheDocument();
  expect(screen.getByPlaceholderText(/username/i)).toBeInTheDocument();
  expect(screen.getByPlaceholderText(/email/i)).toBeInTheDocument();
  expect(screen.getByPlaceholderText(/password/i)).toBeInTheDocument();
});
