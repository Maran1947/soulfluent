"use client";

import { usePathname } from "next/navigation";
import AmbientBackground from "./AmbientBackground";
import AppHeader from "./AppHeader";
import BottomNav from "./BottomNav";

const NO_CHROME_PREFIXES = ["/login", "/register"];

export default function AppChrome({ children }: { children: React.ReactNode }) {
  const pathname = usePathname() || "/";

  // Hide header & bottom nav for auth pages and live meeting room
  const isReportPage = pathname.includes("/report");
  const isLiveSessionRoom = pathname.startsWith("/session") && !isReportPage;
  const hideHeaderNav = NO_CHROME_PREFIXES.some((p) => pathname.startsWith(p)) || isLiveSessionRoom;

  if (hideHeaderNav) {
    return (
      <div className="min-h-screen text-slate-900 dark:text-slate-100 flex flex-col relative">
        <AmbientBackground />
        <main className="w-full flex-1 flex flex-col relative z-10">{children}</main>
      </div>
    );
  }

  return (
    <div className="min-h-screen text-slate-900 dark:text-slate-100 relative">
      <AmbientBackground />
      <div className="w-full max-w-5xl mx-auto min-h-screen px-4 sm:px-6 relative flex flex-col z-10">
        <AppHeader />
        <main className="flex-1 flex flex-col items-center justify-center pb-12">{children}</main>
        <BottomNav />
      </div>
    </div>
  );
}
