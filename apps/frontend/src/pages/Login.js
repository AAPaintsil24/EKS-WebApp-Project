import { useState } from "react";

export default function Login({ setUser, setPage }) {
  const [form, setForm] = useState({ email: "", password: "" });

  const submit = async () => {
    const res = await fetch("http://localhost:4000/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(form)
    });
    const data = await res.json();
    setUser(data);
    setPage("welcome");
  };

  return (
    <>
      <h2>Sign In</h2>
      <input placeholder="Email" onChange={e => setForm({ ...form, email: e.target.value })} />
      <input type="password" placeholder="Password" onChange={e => setForm({ ...form, password: e.target.value })} />
      <button onClick={submit}>Login</button>
    </>
  );
}
