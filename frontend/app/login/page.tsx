"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth";
import Wordmark from "@/components/Wordmark";

export default function LoginPage() {
  const { login } = useAuth();
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    setError("");
    try {
      await login(email, password);
      router.push("/");
    } catch (err: any) {
      setError(err.message || "Login failed");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="min-h-screen flex flex-col justify-center max-w-md mx-auto px-4 py-12">
      <Wordmark tagline="Welcome back — ready for another practice conversation?" />
      <form onSubmit={handleSubmit} className="card p-8 space-y-5 motion-safe:animate-rise shadow-xl border-slate-200/80">
        <div>
          <label className="block text-xs font-semibold uppercase tracking-wider text-slate-500 mb-2">Email Address</label>
          <input
            type="email"
            required
            autoComplete="email"
            placeholder="you@example.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="input"
          />
        </div>
        <div>
          <label className="block text-xs font-semibold uppercase tracking-wider text-slate-500 mb-2">Password</label>
          <input
            type="password"
            required
            autoComplete="current-password"
            placeholder="••••••••"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="input"
          />
        </div>
        {error && (
          <p className="text-xs font-medium text-rose-600 bg-rose-50 border border-rose-200/80 rounded-xl px-3.5 py-2.5">{error}</p>
        )}
        <button type="submit" disabled={submitting} className="btn-primary w-full py-3.5 shadow-md">
          {submitting ? "Logging in…" : "Log in to SoulFluent →"}
        </button>
      </form>
      <p className="text-center text-sm text-slate-600 mt-6">
        No account yet?{" "}
        <Link href="/register" className="text-indigo-600 font-semibold hover:underline">
          Sign up for free
        </Link>
      </p>
    </div>
  );
}
