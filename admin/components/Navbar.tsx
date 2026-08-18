"use client";

import { useEffect, useState } from "react";
import { Activity, LogOut, User } from "lucide-react";
import { getStoredAdminUser, logoutAdmin, AdminUser } from "@/lib/api";
import ThemeToggle from "./ThemeToggle";

export default function Navbar() {
  const [adminUser, setAdminUser] = useState<AdminUser | null>(null);

  useEffect(() => {
    setAdminUser(getStoredAdminUser());
  }, []);

  return (
    <header className="glass-panel border-b border-slate-200 dark:border-slate-800 px-8 py-4 flex items-center justify-between sticky top-0 z-20 transition-colors">
      <div className="flex items-center gap-3">
        <div className="flex items-center gap-2 bg-emerald-500/10 border border-emerald-500/20 px-3 py-1 rounded-full text-emerald-600 dark:text-emerald-400 text-xs font-medium">
          <Activity className="w-3.5 h-3.5 animate-pulse" />
          <span>System Healthy</span>
        </div>
        <span className="text-slate-300 dark:text-slate-700 text-sm">|</span>
        <span className="text-slate-500 dark:text-slate-400 text-xs font-mono">FastAPI Admin Engine</span>
      </div>

      <div className="flex items-center gap-4">
        {/* Light / Dark Mode Toggle */}
        <ThemeToggle />

        {adminUser && (
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2 bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3.5 py-1.5 text-xs text-slate-700 dark:text-slate-300">
              <User className="w-3.5 h-3.5 text-[#f25c40]" />
              <div className="text-left">
                <span className="font-semibold text-slate-900 dark:text-slate-100 block leading-tight">{adminUser.name}</span>
                <span className="text-[10px] text-slate-500 dark:text-slate-400">{adminUser.email}</span>
              </div>
              <span className="ml-1.5 px-2 py-0.5 rounded bg-[#f25c40]/10 dark:bg-[#f25c40]/20 text-[#f25c40] text-[10px] font-bold uppercase border border-[#f25c40]/30">
                {adminUser.role}
              </span>
            </div>

            <button
              onClick={() => logoutAdmin()}
              className="p-2 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-rose-500/10 border border-slate-200 dark:border-slate-700 hover:border-rose-500/40 text-slate-500 dark:text-slate-400 hover:text-rose-600 dark:hover:text-rose-400 transition-colors"
              title="Sign Out"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
