"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { LayoutDashboard, MessageSquareText, Mic, Trophy, Eye, ShieldAlert } from "lucide-react";
import BrandLogo from "@/components/BrandLogo";

export default function Sidebar() {
  const pathname = usePathname();

  const navItems = [
    { name: "Overview & Signups", href: "/", icon: LayoutDashboard },
    { name: "User Sessions & Cost", href: "/sessions", icon: MessageSquareText },
    { name: "Daily Speak & Cost", href: "/daily-speak", icon: Mic },
    { name: "Streak Leaderboard", href: "/leaderboard", icon: Trophy },
  ];

  return (
    <aside className="w-64 glass-panel flex flex-col min-h-screen border-r border-slate-200 dark:border-slate-800 p-4 sticky top-0 transition-colors">
      <div className="flex flex-col gap-2 px-3 py-4 mb-6 border-b border-slate-200 dark:border-slate-800">
        <BrandLogo size="md" />
        <div className="flex items-center gap-1.5 mt-1">
          <Eye className="w-3 h-3 text-[#f25c40]" />
          <span className="text-[10px] font-bold tracking-wider uppercase text-[#f25c40]">
            Admin Portal (Read Only)
          </span>
        </div>
      </div>

      <nav className="flex-1 space-y-1.5">
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-3.5 py-2.5 rounded-xl font-medium text-sm transition-all duration-200 ${
                isActive
                  ? "bg-[#f25c40]/10 dark:bg-[#f25c40]/20 text-[#f25c40] dark:text-rose-200 border border-[#f25c40]/30 shadow-sm"
                  : "text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800/60"
              }`}
            >
              <Icon className={`w-4 h-4 ${isActive ? "text-[#f25c40]" : "text-slate-400"}`} />
              <span>{item.name}</span>
            </Link>
          );
        })}
      </nav>

      <div className="mt-auto pt-4 border-t border-slate-200 dark:border-slate-800">
        <div className="glass-card rounded-xl p-3.5 border border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-900/60 text-xs text-slate-500 dark:text-slate-400">
          <div className="flex items-center gap-2 font-semibold text-[#f25c40] mb-1">
            <ShieldAlert className="w-4 h-4 text-[#f25c40]" />
            <span>Strict Read-Only Mode</span>
          </div>
          <p className="text-[11px] leading-relaxed text-slate-500 dark:text-slate-400">
            This dashboard enforces read-only access. Mutations & write operations are disabled.
          </p>
        </div>
      </div>
    </aside>
  );
}
