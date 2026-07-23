"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { BookOpen, MessagesSquare, Gamepad2 } from "lucide-react";

const TABS = [
  {
    href: "/learn",
    label: "Learn",
    icon: BookOpen,
    match: (p: string) => p.startsWith("/learn"),
    activeBg: "bg-sage-soft",
    activeText: "text-sage-deep",
  },
  {
    href: "/",
    label: "Practice",
    icon: MessagesSquare,
    match: (p: string) => p === "/" || p.startsWith("/session") || p.startsWith("/history"),
    activeBg: "bg-lavender-soft",
    activeText: "text-lavender-deep",
  },
  {
    href: "/games",
    label: "Games",
    icon: Gamepad2,
    match: (p: string) => p.startsWith("/games"),
    activeBg: "bg-apricot-soft",
    activeText: "text-apricot-deep",
  },
];

export default function BottomNav() {
  const pathname = usePathname();

  return (
    <nav className="fixed bottom-4 inset-x-0 z-50 flex justify-center px-4">
      <div className="flex items-center gap-1 bg-white/70 backdrop-blur-xl border border-white/60 rounded-full shadow-[0_10px_35px_-10px_rgba(111,107,199,0.35)] px-2 py-2">
        {TABS.map((tab) => {
          const active = tab.match(pathname || "/");
          const Icon = tab.icon;
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={`flex flex-col items-center justify-center gap-0.5 rounded-full px-5 py-2 transition-all duration-300 ${
                active ? `${tab.activeBg} ${tab.activeText}` : "text-ink-soft hover:text-ink"
              }`}
            >
              <Icon
                size={20}
                strokeWidth={active ? 2.4 : 2}
                className={`transition-transform duration-300 ${active ? "scale-110" : ""}`}
              />
              <span className="text-[11px] font-medium">{tab.label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
