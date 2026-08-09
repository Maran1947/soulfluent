"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { History, LogOut, MessagesSquare, BookOpen, Gamepad2 } from "lucide-react";
import { useAuth } from "@/lib/auth";
import ThemeToggle from "@/components/ThemeToggle";

function greeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return "Good morning";
  if (hour < 18) return "Good afternoon";
  return "Good evening";
}

const NAV_ITEMS = [
  { href: "/", label: "Practice", icon: MessagesSquare, match: (p: string) => p === "/" || p.startsWith("/session") },
  { href: "/history", label: "History", icon: History, match: (p: string) => p.startsWith("/history") },
];

export default function AppHeader() {
  const { user, logout } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    function onClickOutside(e: MouseEvent) {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) setOpen(false);
    }
    function onEscape(e: KeyboardEvent) {
      if (e.key === "Escape") setOpen(false);
    }
    document.addEventListener("mousedown", onClickOutside);
    document.addEventListener("keydown", onEscape);
    return () => {
      document.removeEventListener("mousedown", onClickOutside);
      document.removeEventListener("keydown", onEscape);
    };
  }, []);

  if (!user) {
    return (
      <header className="py-5 mb-4 flex items-center justify-between border-b border-slate-200/60 dark:border-rose-900/40 transition-colors">
        <Link href="/" className="flex items-center gap-2.5 group">
          <div className="w-8 h-8 bg-gradient-to-br from-[#FA5A3A] to-[#F25C40] rounded-xl flex items-center justify-center gap-[2px] shadow-sm shadow-[#F25C40]/20 shrink-0">
            <span className="w-[2px] h-2.5 bg-white rounded-full"></span>
            <span className="w-[2px] h-4 bg-white rounded-full"></span>
            <span className="w-[2px] h-5 bg-white rounded-full"></span>
            <span className="w-[2px] h-3 bg-white rounded-full"></span>
          </div>
          <span className="text-xl font-bold tracking-tight">
            <span className="text-slate-900 dark:text-white">Fluent</span>
            <span className="text-[#F25C40]">Soul</span>
          </span>
        </Link>

        <div className="flex items-center gap-3">
          <ThemeToggle />
          <Link
            href="/login"
            className="px-4 py-2 rounded-xl text-xs font-bold text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 transition-all"
          >
            Sign In
          </Link>
          <Link
            href="/register"
            className="px-4 py-2 rounded-xl text-xs font-extrabold bg-[#F25C40] text-white shadow-xs hover:bg-[#FA5A3A] transition-all"
          >
            Get Started
          </Link>
        </div>
      </header>
    );
  }

  const initial = user.name.charAt(0).toUpperCase();

  return (
    <header className="py-5 mb-4 flex items-center justify-between border-b border-slate-200/60 dark:border-rose-900/40 transition-colors">
      {/* Brand logo */}
      <div className="flex items-center gap-6">
        <Link href="/" className="flex items-center gap-2.5 group">
          <div className="w-8 h-8 bg-gradient-to-br from-[#FA5A3A] to-[#F25C40] rounded-xl flex items-center justify-center gap-[2px] shadow-sm shadow-[#F25C40]/20 shrink-0">
            <span className="w-[2px] h-2.5 bg-white rounded-full"></span>
            <span className="w-[2px] h-4 bg-white rounded-full"></span>
            <span className="w-[2px] h-5 bg-white rounded-full"></span>
            <span className="w-[2px] h-3 bg-white rounded-full"></span>
          </div>
          <span className="text-xl font-bold tracking-tight">
            <span className="text-slate-900 dark:text-white">Fluent</span>
            <span className="text-[#F25C40]">Soul</span>
          </span>
        </Link>
      </div>

      {/* Desktop Navigation Links */}
      <nav className="hidden md:flex items-center gap-1 bg-white/80 dark:bg-[#181d29]/90 border border-slate-200/80 dark:border-rose-900/40 rounded-full p-1.5 shadow-sm backdrop-blur-md">
        {NAV_ITEMS.map((tab) => {
          const active = tab.match(pathname || "/");
          const Icon = tab.icon;
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={`flex items-center gap-2 px-4 py-1.5 rounded-full text-xs font-semibold transition-all duration-200 ${
                active
                  ? "bg-[#F25C40] text-white shadow-sm"
                  : "text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white hover:bg-[#faf5f3] dark:hover:bg-[#202737]"
              }`}
            >
              <Icon size={14} strokeWidth={active ? 2.2 : 1.8} />
              <span>{tab.label}</span>
            </Link>
          );
        })}
      </nav>

      {/* Profile & User Menu */}
      <div className="flex items-center gap-3">
        <div className="relative" ref={menuRef}>
          <button
            onClick={() => setOpen((v) => !v)}
            aria-label="Account menu"
            aria-expanded={open}
            className={`w-9 h-9 rounded-full bg-slate-900 dark:bg-indigo-600 text-white flex items-center justify-center
              font-display text-sm font-semibold shadow-sm transition-all duration-200
              ${open ? "ring-2 ring-lavender ring-offset-2 dark:ring-offset-slate-950" : "hover:bg-slate-800 dark:hover:bg-indigo-700"}`}
          >
            {initial}
          </button>

          {open && (
            <div
              className="absolute right-0 mt-2 w-56 card p-2 z-50 motion-safe:animate-rise origin-top-right shadow-xl"
              role="menu"
            >
              <div className="px-3 py-2 mb-1.5 border-b border-slate-100 dark:border-slate-800">
                <p className="text-xs font-semibold text-slate-900 dark:text-slate-100 truncate">{user.name}</p>
                <p className="text-[11px] text-slate-500 dark:text-slate-400 truncate">{user.email}</p>
              </div>
              <Link
                href="/history"
                onClick={() => setOpen(false)}
                className="flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 hover:text-slate-900 dark:hover:text-white transition-colors"
                role="menuitem"
              >
                <History size={15} className="text-[#F25C40]" />
                Session History
              </Link>
              <div className="px-3 py-2 my-1 flex items-center justify-between border-t border-b border-slate-100 dark:border-slate-800/80">
                <span className="text-xs font-medium text-slate-700 dark:text-slate-300">Theme</span>
                <ThemeToggle />
              </div>
              <button
                onClick={() => {
                  setOpen(false);
                  logout();
                  router.push("/login");
                }}
                className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium text-slate-700 dark:text-slate-300 hover:bg-rose-50 dark:hover:bg-rose-950/40 hover:text-rose-600 dark:hover:text-rose-400 transition-colors"
                role="menuitem"
              >
                <LogOut size={15} />
                Log out
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
