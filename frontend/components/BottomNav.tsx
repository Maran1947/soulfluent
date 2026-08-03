"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { History, MessagesSquare } from "lucide-react";

const TABS = [
  {
    href: "/",
    label: "Practice",
    icon: MessagesSquare,
    match: (p: string) => p === "/" || p.startsWith("/session"),
  },
  {
    href: "/history",
    label: "History",
    icon: History,
    match: (p: string) => p.startsWith("/history"),
  },
];

export default function BottomNav() {
  const pathname = usePathname();

  return (
    <nav className="fixed bottom-4 inset-x-0 z-50 flex justify-center px-4 md:hidden">
      <div className="flex items-center gap-1 bg-white/90 dark:bg-[#181d29]/95 backdrop-blur-xl border border-slate-200 dark:border-rose-900/40 rounded-full shadow-lg px-2 py-1.5">
        {TABS.map((tab) => {
          const active = tab.match(pathname || "/");
          const Icon = tab.icon;
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={`flex flex-col items-center justify-center gap-0.5 rounded-full px-6 py-2 transition-all duration-200 ${
                active
                  ? "bg-[#F25C40] text-white font-semibold shadow-xs"
                  : "text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200"
              }`}
            >
              <Icon
                size={18}
                strokeWidth={active ? 2.4 : 1.8}
                className="transition-transform duration-200"
              />
              <span className="text-[11px] font-medium">{tab.label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
