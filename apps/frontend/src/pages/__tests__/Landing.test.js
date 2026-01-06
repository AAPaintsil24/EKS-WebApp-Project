import { render, screen } from "@testing-library/react";
import Landing from "../Landing";

test("renders AlbertDevOps title", () => {
  render(<Landing setPage={() => {}} />);
  expect(screen.getByText("AlbertDevOps")).toBeInTheDocument();
});
