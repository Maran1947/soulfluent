"use client";

import { usePathname } from "next/navigation";
import AmbientBackground from "./AmbientBackground";
import AppHeader from "./AppHeader";
import BottomNav from "./BottomNav";

const NO_CHROME_PREFIXES = ["/login", "/register", "/session"];

export default function AppChrome({ children }: { children: React.ReactNode }) {
  const pathname = usePathname() || "/";
  const hideChrome = NO_CHROME_PREFIXES.some((p) => pathname.startsWith(p));

  return (
    <div className="min-h-screen">
      <AmbientBackground />
      <div className="max-w-md mx-auto min-h-screen px-5 relative">
        {!hideChrome && <AppHeader />}
        <main className={hideChrome ? "" : "pb-28"}>{children}</main>
        {!hideChrome && <BottomNav />}
      </div>
    </div>
  );
}
