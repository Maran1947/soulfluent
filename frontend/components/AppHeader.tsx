"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { History, LogOut, MessagesSquare, BookOpen, Gamepad2 } from "lucide-react";
import { useAuth } from "@/lib/auth";

function greeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return "Good morning";
  if (hour < 18) return "Good afternoon";
  return "Good evening";
}

const NAV_ITEMS = [
  { href: "/", label: "Practice", icon: MessagesSquare, match: (p: string) => p === "/" || p.startsWith("/session") || p.startsWith("/history") },
  { href: "/learn", label: "Learn", icon: BookOpen, match: (p: string) => p.startsWith("/learn") },
  { href: "/games", label: "Games", icon: Gamepad2, match: (p: string) => p.startsWith("/games") },
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

  if (!user) return null;

  const initial = user.name.charAt(0).toUpperCase();

  return (
    <header className="py-5 mb-4 flex items-center justify-between border-b border-slate-200/60">
      {/* Brand logo & Greeting */}
      <div className="flex items-center gap-6">
        <Link href="/" className="flex items-center gap-2 group">
          <span className="relative flex h-3 w-3 items-center justify-center">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-lavender opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-lavender"></span>
          </span>
          <span className="font-display italic text-2xl text-ink tracking-tight font-semibold group-hover:text-lavender transition-colors">
            SoulFluent
          </span>
        </Link>

        <div className="hidden sm:block pl-4 border-l border-slate-200 text-xs text-slate-500">
          <p>{greeting()}, <span className="font-semibold text-slate-700">{user.name.split(" ")[0]}</span></p>
        </div>
      </div>

      {/* Desktop Navigation Links */}
      <nav className="hidden md:flex items-center gap-1 bg-white/80 border border-slate-200/80 rounded-full p-1.5 shadow-sm backdrop-blur-md">
        {NAV_ITEMS.map((tab) => {
          const active = tab.match(pathname || "/");
          const Icon = tab.icon;
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={`flex items-center gap-2 px-4 py-1.5 rounded-full text-xs font-semibold transition-all duration-200 ${
                active
                  ? "bg-slate-900 text-white shadow-sm"
                  : "text-slate-600 hover:text-slate-900 hover:bg-slate-100/70"
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
        <div className="sm:hidden text-right">
          <p className="text-[11px] text-slate-500">{greeting()}</p>
          <p className="text-xs font-semibold text-slate-800">{user.name.split(" ")[0]}</p>
        </div>

        <div className="relative" ref={menuRef}>
          <button
            onClick={() => setOpen((v) => !v)}
            aria-label="Account menu"
            aria-expanded={open}
            className={`w-9 h-9 rounded-full bg-slate-900 text-white flex items-center justify-center
              font-display text-sm font-semibold shadow-sm transition-all duration-200
              ${open ? "ring-2 ring-lavender ring-offset-2" : "hover:bg-slate-800"}`}
          >
            {initial}
          </button>

          {open && (
            <div
              className="absolute right-0 mt-2 w-52 card p-2 z-50 motion-safe:animate-rise origin-top-right shadow-xl"
              role="menu"
            >
              <div className="px-3 py-2 mb-1.5 border-b border-slate-100">
                <p className="text-xs font-semibold text-slate-900 truncate">{user.name}</p>
                <p className="text-[11px] text-slate-500 truncate">{user.email}</p>
              </div>
              <Link
                href="/history"
                onClick={() => setOpen(false)}
                className="flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium text-slate-700 hover:bg-slate-100 hover:text-slate-900 transition-colors"
                role="menuitem"
              >
                <History size={15} className="text-lavender" />
                Session History
              </Link>
              <button
                onClick={() => {
                  setOpen(false);
                  logout();
                  router.push("/login");
                }}
                className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium text-slate-700 hover:bg-rose-50 hover:text-rose-600 transition-colors"
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
