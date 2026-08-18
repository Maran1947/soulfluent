import type { Metadata } from "next";
import "./globals.css";
import AdminLayoutShell from "@/components/AdminLayoutShell";
import { ThemeProvider } from "@/components/ThemeProvider";

export const metadata: Metadata = {
  title: "FluentSoul Admin (Read-Only)",
  description: "Read-Only Admin Dashboard for FluentSoul platform analytics, session costs, daily speak, signups, and streak leaderboard.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark" suppressHydrationWarning>
      <body className="bg-[#f8fafc] dark:bg-[#0f172a] text-slate-900 dark:text-slate-100 antialiased min-h-screen transition-colors">
        <ThemeProvider>
          <AdminLayoutShell>{children}</AdminLayoutShell>
        </ThemeProvider>
      </body>
    </html>
  );
}
