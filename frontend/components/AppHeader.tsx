"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { History, LogOut } from "lucide-react";
import { useAuth } from "@/lib/auth";

function greeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return "Good morning";
  if (hour < 18) return "Good afternoon";
  return "Good evening";
}

export default function AppHeader() {
  const { user, logout } = useAuth();
  const router = useRouter();
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
    <header className="pt-6 pb-2 px-1 flex items-center justify-between">
      <div>
        <p className="text-xs text-ink-soft">{greeting()}</p>
        <h1 className="font-display text-2xl text-ink">{user.name.split(" ")[0]}</h1>
      </div>

      <div className="relative" ref={menuRef}>
        <button
          onClick={() => setOpen((v) => !v)}
          aria-label="Account menu"
          aria-expanded={open}
          className={`w-9 h-9 rounded-full bg-lavender text-white flex items-center justify-center
            font-display text-sm font-semibold border-2 transition
            ${open ? "border-lavender-deep" : "border-white/60"}`}
        >
          {initial}
        </button>

        {open && (
          <div
            className="absolute right-0 mt-2 w-48 card p-1.5 z-50 motion-safe:animate-rise origin-top-right"
            role="menu"
          >
            <div className="px-3 py-2 mb-1 border-b border-ink/5">
              <p className="text-sm font-medium truncate">{user.name}</p>
              <p className="text-xs text-ink-soft truncate">{user.email}</p>
            </div>
            <Link
              href="/history"
              onClick={() => setOpen(false)}
              className="flex items-center gap-2.5 px-3 py-2 rounded-xl text-sm text-ink hover:bg-lavender-soft transition"
              role="menuitem"
            >
              <History size={16} className="text-lavender-deep" />
              History
            </Link>
            <button
              onClick={() => {
                setOpen(false);
                logout();
                router.push("/login");
              }}
              className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-sm text-ink hover:bg-rose-50 hover:text-rose-600 transition"
              role="menuitem"
            >
              <LogOut size={16} />
              Log out
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
