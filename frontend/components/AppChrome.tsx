"use client";

import { usePathname } from "next/navigation";
import AmbientBackground from "./AmbientBackground";
import AppHeader from "./AppHeader";
import BottomNav from "./BottomNav";

const NO_CHROME_PREFIXES = ["/login", "/register"];

export default function AppChrome({ children }: { children: React.ReactNode }) {
  const pathname = usePathname() || "/";
  
  // Hide chrome ONLY for auth pages and live meeting room (NOT for /session/[id]/report)
  const isReportPage = pathname.includes("/report");
  const isLiveSessionRoom = pathname.startsWith("/session") && !isReportPage;
  const hideChrome = NO_CHROME_PREFIXES.some((p) => pathname.startsWith(p)) || isLiveSessionRoom;

  if (hideChrome) {
    return (
      <div className="min-h-screen text-ink selection:bg-lavender/20 flex flex-col">
        <main className="w-full flex-1 flex flex-col">{children}</main>
      </div>
    );
  }

  return (
    <div className="min-h-screen text-ink selection:bg-lavender/20">
      <AmbientBackground />
      <div className="w-full max-w-7xl mx-auto min-h-screen px-4 sm:px-6 lg:px-8 relative flex flex-col">
        <AppHeader />
        <main className="flex-1 pb-24 md:pb-12">{children}</main>
        <BottomNav />
      </div>
    </div>
  );
}
