"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth";
import Wordmark from "@/components/Wordmark";

export default function RegisterPage() {
  const { register } = useAuth();
  const router = useRouter();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    setError("");
    try {
      await register(email, password, name);
      router.push("/");
    } catch (err: any) {
      setError(err.message || "Registration failed");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="min-h-screen flex flex-col justify-center max-w-md mx-auto px-4 py-12">
      <Wordmark tagline="A calm space to practice spoken English, one conversation at a time." />
      <form onSubmit={handleSubmit} className="card p-8 space-y-5 motion-safe:animate-rise shadow-xl border-slate-200/80">
        <div>
          <label className="block text-xs font-semibold uppercase tracking-wider text-slate-500 mb-2">Full Name</label>
          <input
            type="text"
            required
            autoComplete="name"
            placeholder="Alex Smith"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="input"
          />
        </div>
        <div>
          <label className="block text-xs font-semibold uppercase tracking-wider text-slate-500 mb-2">Email Address</label>
          <input
            type="email"
            required
            autoComplete="email"
            placeholder="alex@example.com"
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
            minLength={8}
            autoComplete="new-password"
            placeholder="••••••••"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="input"
          />
          <p className="text-[11px] text-slate-400 mt-1 font-medium">Must be at least 8 characters</p>
        </div>
        {error && (
          <p className="text-xs font-medium text-rose-600 bg-rose-50 border border-rose-200/80 rounded-xl px-3.5 py-2.5">{error}</p>
        )}
        <button type="submit" disabled={submitting} className="btn-primary w-full py-3.5 shadow-md">
          {submitting ? "Creating account…" : "Create Account →"}
        </button>
      </form>
      <p className="text-center text-sm text-slate-600 mt-6">
        Already have an account?{" "}
        <Link href="/login" className="text-indigo-600 font-semibold hover:underline">
          Log in
        </Link>
      </p>
    </div>
  );
}
