"use client";

import { useState } from "react";
import { Sun, Moon, Droplets } from "lucide-react";

type Props = {
  themeMode: "dark" | "light";
  onToggle: () => void;
};

export default function ThemeToggle({ themeMode, onToggle }: Props) {
  const [ripple, setRipple] = useState(false);
  const isLight = themeMode === "light";

  function handleClick() {
    setRipple(true);
    onToggle();
    setTimeout(() => setRipple(false), 750);
  }

  return (
    <button
      onClick={handleClick}
      aria-label={`Switch to ${isLight ? "Dark" : "Light"} Mode`}
      title={`Switch to ${isLight ? "Dark" : "Light"} Mode`}
      className={`relative overflow-hidden group flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold border transition-all duration-300 shadow-sm select-none ${
        isLight
          ? "bg-gradient-to-r from-sky-400 via-indigo-500 to-cyan-400 text-white border-sky-300/80 shadow-sky-500/20 animate-liquid-flow"
          : "bg-gradient-to-r from-indigo-950 via-slate-900 to-blue-950 text-amber-300 border-slate-700/80 shadow-slate-950/40 animate-liquid-flow"
      }`}
    >
      {/* Liquid Water Wave Ripple Overlay */}
      {ripple && (
        <span
          className={`absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-6 h-6 rounded-full animate-liquid-ripple pointer-events-none ${
            isLight ? "bg-amber-300/60" : "bg-sky-400/60"
          }`}
        />
      )}

      <div className="relative z-10 flex items-center gap-1.5">
        <span className="transition-transform duration-500 ease-out transform group-hover:rotate-180 group-hover:scale-110 flex items-center">
          {isLight ? <Sun size={15} className="text-amber-200 fill-amber-200/40" /> : <Moon size={15} className="text-indigo-300 fill-indigo-300/30" />}
        </span>
        <span className="tracking-tight text-xs font-semibold">
          {isLight ? "Light Mode" : "Dark Mode"}
        </span>
        <Droplets size={12} className="opacity-60 animate-pulse" />
      </div>
    </button>
  );
}
