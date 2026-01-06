import { useState } from "react";
import Landing from "./pages/Landing";
import Login from "./pages/Login";
import Signup from "./pages/Signup";
import Welcome from "./pages/Welcome";

export default function App() {
  const [page, setPage] = useState("landing");
  const [user, setUser] = useState(null);

  if (page === "welcome") return <Welcome user={user} />;

  return (
    <>
      {page === "landing" && <Landing setPage={setPage} />}
      {page === "login" && <Login setUser={setUser} setPage={setPage} />}
      {page === "signup" && <Signup setUser={setUser} setPage={setPage} />}
    </>
  );
}

