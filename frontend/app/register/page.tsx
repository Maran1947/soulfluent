"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth";
import Wordmark from "@/components/Wordmark";
import ThemeToggle from "@/components/ThemeToggle";
import { User, Mail, Lock, Eye, EyeOff, ArrowRight } from "lucide-react";

export default function RegisterPage() {
  const { register } = useAuth();
  const router = useRouter();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
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
    <div className="min-h-screen flex flex-col justify-center items-center px-4 py-12 relative">
      <div className="fixed top-6 right-6 z-50">
        <ThemeToggle />
      </div>

      <div className="w-full max-w-5xl grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
        {/* Left Side: Brand Wordmark & Tagline (5 cols on lg) */}
        <div className="lg:col-span-5 hidden lg:block space-y-4">
          <Wordmark tagline="Speak English with Confidence. Every day, a little better." />
        </div>

        {/* Right Side: Recreated Registration Form Card (7 cols on lg) */}
        <div className="lg:col-span-7 w-full max-w-md mx-auto">
          {/* Mobile Wordmark fallback */}
          <div className="lg:hidden mb-6 flex justify-center">
            <Wordmark tagline="Speak English with Confidence." />
          </div>

          <div className="card p-8 sm:p-9 shadow-xl border-[#fce3dc] dark:border-rose-900/30">
            {/* Top Form Icon Badge */}
            <div className="w-14 h-14 bg-[#FDEEE9] dark:bg-rose-950/40 rounded-2xl flex items-center justify-center gap-1 mx-auto mb-4">
              <span className="w-1 h-4 bg-[#F25C40] rounded-full"></span>
              <span className="w-1 h-6 bg-[#F25C40] rounded-full"></span>
              <span className="w-1 h-7 bg-[#F25C40] rounded-full"></span>
              <span className="w-1 h-5 bg-[#F25C40] rounded-full"></span>
              <span className="w-1 h-3 bg-[#F25C40] rounded-full"></span>
            </div>

            <h1 className="text-2xl font-bold text-slate-900 dark:text-slate-100 text-center tracking-tight">
              Create your account
            </h1>
            <p className="text-xs sm:text-sm text-slate-500 dark:text-slate-400 text-center mb-6 mt-1">
              Start your free fluency journey today
            </p>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                  Full Name
                </label>
                <div className="relative">
                  <User
                    size={18}
                    className="text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2"
                  />
                  <input
                    type="text"
                    required
                    placeholder="Alex Smith"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="input pl-10"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                  Email Address
                </label>
                <div className="relative">
                  <Mail
                    size={18}
                    className="text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2"
                  />
                  <input
                    type="email"
                    required
                    autoComplete="email"
                    placeholder="you@example.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="input pl-10"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                  Password
                </label>
                <div className="relative">
                  <Lock
                    size={18}
                    className="text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2"
                  />
                  <input
                    type={showPassword ? "text" : "password"}
                    required
                    minLength={8}
                    autoComplete="new-password"
                    placeholder="Must be at least 8 characters"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="input pl-10 pr-10"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 transition-colors"
                  >
                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>

              {error && (
                <p className="text-xs font-medium text-rose-600 dark:text-rose-400 bg-rose-50 dark:bg-rose-950/50 border border-rose-200/80 dark:border-rose-800/80 rounded-xl px-3.5 py-2.5">
                  {error}
                </p>
              )}

              <button
                type="submit"
                disabled={submitting}
                className="btn-primary w-full py-3.5 text-sm font-semibold flex items-center justify-center gap-2 shadow-md shadow-[#F25C40]/20 bg-[#F25C40] hover:bg-[#E04B30] text-white rounded-xl"
              >
                <span>{submitting ? "Creating account…" : "Create Account"}</span>
                {!submitting && <ArrowRight size={16} />}
              </button>
            </form>

            {/* Social Divider */}
            <div className="relative my-6 text-center text-xs text-slate-400">
              <span className="bg-white dark:bg-[#181d29] px-3 z-10 relative">
                or continue with
              </span>
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-slate-200 dark:border-slate-800"></div>
              </div>
            </div>

            {/* Single Full-Width Google Login Button */}
            <button className="btn-secondary w-full py-3 px-4 text-sm font-semibold flex items-center justify-center gap-2.5 border-slate-200 dark:border-slate-800">
              <svg className="w-4 h-4 shrink-0" viewBox="0 0 24 24">
                <path
                  fill="#4285F4"
                  d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                />
                <path
                  fill="#34A853"
                  d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                />
                <path
                  fill="#FBBC05"
                  d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
                />
                <path
                  fill="#EA4335"
                  d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
                />
              </svg>
              <span>Continue with Google</span>
            </button>

            <p className="text-center text-xs sm:text-sm text-slate-500 dark:text-slate-400 mt-6">
              Already have an account?{" "}
              <Link href="/login" className="text-[#F25C40] font-semibold hover:underline">
                Log in
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
