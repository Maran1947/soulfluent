"use client";

import { useEffect } from "react";
import { usePathname, useRouter } from "next/navigation";
import { getStoredAdminUser } from "@/lib/api";

export default function AuthGuard({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();

  useEffect(() => {
    if (pathname === "/login") return;

    const user = getStoredAdminUser();
    if (!user || user.role !== "ADMIN") {
      router.push("/login");
    }
  }, [pathname, router]);

  return <>{children}</>;
}
