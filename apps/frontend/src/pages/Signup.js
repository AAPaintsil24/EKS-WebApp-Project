import { useState } from "react";

export default function Signup({ setUser, setPage }) {
  const [form, setForm] = useState({ username: "", email: "", password: "" });

  const submit = async () => {
    const res = await fetch("http://localhost:4000/signup", {
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
      <h2>Sign Up</h2>
      <input placeholder="Username" onChange={e => setForm({ ...form, username: e.target.value })} />
      <input placeholder="Email" onChange={e => setForm({ ...form, email: e.target.value })} />
      <input type="password" placeholder="Password" onChange={e => setForm({ ...form, password: e.target.value })} />
      <button onClick={submit}>Create Account</button>
    </>
  );
}
