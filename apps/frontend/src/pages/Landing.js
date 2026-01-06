export default function Landing({ setPage }) {
  return (
    <div style={{ textAlign: "center", marginTop: 100 }}>
      <h1 style={{ fontSize: 48 }}>AlbertDevOps</h1>
      <button onClick={() => setPage("login")}>Sign In</button>
      <button onClick={() => setPage("signup")}>Sign Up</button>
    </div>
  );
}
