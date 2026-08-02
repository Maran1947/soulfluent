"use client";

import React from "react";
import { Sun, Moon } from "lucide-react";
import { useTheme } from "@/lib/theme";

type Props = {
  themeMode?: "dark" | "light";
  onToggle?: (e?: React.MouseEvent) => void;
  className?: string;
};

export default function ThemeToggle({
  themeMode: propThemeMode,
  onToggle: propOnToggle,
  className = "",
}: Props) {
  const globalTheme = useTheme();

  const currentTheme = propThemeMode ?? globalTheme.theme;
  const isLight = currentTheme === "light";

  const handleSwitch = (e?: React.MouseEvent) => {
    if (propOnToggle) {
      propOnToggle(e);
    } else {
      globalTheme.toggleTheme(e);
    }
  };

  return (
    <button
      type="button"
      onClick={(e) => handleSwitch(e)}
      aria-label={`Switch to ${isLight ? "Dark" : "Light"} mode`}
      title={`Switch to ${isLight ? "Dark" : "Light"} mode`}
      className={`w-8 h-8 rounded-xl flex items-center justify-center border border-slate-200/90 dark:border-rose-900/40 bg-white/90 dark:bg-[#131722] text-slate-700 dark:text-slate-300 hover:text-slate-900 dark:hover:text-white hover:bg-slate-100 dark:hover:bg-[#1c2232] hover:border-[#F25C40]/40 transition-all shadow-xs cursor-pointer ${className}`}
    >
      {isLight ? (
        <Moon size={15} className="text-slate-700 transition-transform duration-300 hover:-rotate-12" />
      ) : (
        <Sun size={15} className="text-amber-400 transition-transform duration-300 hover:rotate-45" />
      )}
    </button>
  );
}
