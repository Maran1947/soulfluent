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
    <div className="min-h-screen flex flex-col justify-center max-w-sm mx-auto px-5 py-12">
      <Wordmark tagline="A calm space to practice spoken English." />
      <form onSubmit={handleSubmit} className="card p-6 space-y-4 motion-safe:animate-rise">
        <div>
          <label className="block text-sm font-medium mb-1.5">Name</label>
          <input
            type="text"
            required
            autoComplete="name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="input"
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1.5">Email</label>
          <input
            type="email"
            required
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="input"
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1.5">Password</label>
          <input
            type="password"
            required
            minLength={8}
            autoComplete="new-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="input"
          />
          <p className="text-xs text-ink-soft/70 mt-1">At least 8 characters</p>
        </div>
        {error && (
          <p className="text-sm text-rose-500 bg-rose-50 rounded-xl px-3 py-2">{error}</p>
        )}
        <button type="submit" disabled={submitting} className="btn-primary w-full">
          {submitting ? "Creating account…" : "Sign up"}
        </button>
      </form>
      <p className="text-center text-sm text-ink-soft mt-5">
        Already have an account?{" "}
        <Link href="/login" className="text-lavender-deep font-medium">
          Log in
        </Link>
      </p>
    </div>
  );
}
