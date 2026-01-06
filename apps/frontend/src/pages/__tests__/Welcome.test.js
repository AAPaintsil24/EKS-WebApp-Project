import { render, screen } from "@testing-library/react";
import Welcome from "../Welcome";

test("renders welcome message with username", () => {
  render(<Welcome username="Albert" />);

  expect(screen.getByText("Welcome, Albert")).toBeInTheDocument();
});