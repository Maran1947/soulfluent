"use client";

import { Mic, MicOff } from "lucide-react";

const PERSONA_CONFIG: Record<
  string,
  { avatarBg: string; ringColor: string; accentBg: string; role: string }
> = {
  riya: { avatarBg: "bg-emerald-600", ringColor: "ring-emerald-500", accentBg: "bg-emerald-500", role: "AI Moderator" },
  meera: { avatarBg: "bg-amber-600", ringColor: "ring-amber-500", accentBg: "bg-amber-500", role: "AI Challenger" },
  user: { avatarBg: "bg-indigo-600", ringColor: "ring-indigo-500", accentBg: "bg-indigo-500", role: "You" },
};

const FALLBACK_CONFIG = { avatarBg: "bg-slate-700", ringColor: "ring-slate-500", accentBg: "bg-slate-500", role: "Participant" };

export default function ParticipantCard({
  name,
  isSpeaking,
  isUser = false,
  themeMode = "dark",
}: {
  name: string;
  isSpeaking: boolean;
  isUser?: boolean;
  themeMode?: "dark" | "light";
}) {
  const key = isUser ? "user" : name.toLowerCase();
  const config = PERSONA_CONFIG[key] || FALLBACK_CONFIG;
  const initial = name.charAt(0).toUpperCase();

  const isLight = themeMode === "light";

  return (
    <div
      className={`relative overflow-hidden rounded-2xl border transition-all duration-300 aspect-[4/3] sm:aspect-video flex flex-col items-center justify-center ${
        isLight
          ? isSpeaking
            ? "bg-emerald-50/60 border-emerald-500 ring-2 ring-emerald-500/80 shadow-[0_0_20px_rgba(16,185,129,0.25)]"
            : "bg-slate-100/80 border-slate-200/90 hover:border-slate-300 shadow-sm"
          : isSpeaking
          ? "bg-slate-900 border-emerald-500 ring-2 ring-emerald-500/80 shadow-[0_0_25px_rgba(16,185,129,0.3)]"
          : "bg-slate-900 border-slate-800/80 hover:border-slate-700"
      }`}
    >
      {/* Background subtle mesh glow */}
      <div className={`absolute inset-0 opacity-10 bg-gradient-to-br ${isLight ? "from-indigo-100 via-transparent to-slate-200" : "from-white via-transparent to-black"}`} />

      {/* Main Center Avatar */}
      <div className="relative flex flex-col items-center justify-center z-10">
        <div
          className={`relative w-16 h-16 sm:w-20 sm:h-20 rounded-full ${config.avatarBg} text-white flex items-center justify-center text-2xl font-bold font-display shadow-lg transition-transform duration-300 ${
            isSpeaking ? "scale-105" : ""
          }`}
        >
          {initial}
          {isSpeaking && (
            <span className={`absolute -inset-2 rounded-full border-2 ${config.ringColor} opacity-75 animate-ping`} />
          )}
        </div>
      </div>

      {/* Google Meet Bottom Overlay Tag */}
      <div className="absolute bottom-3 left-3 right-3 flex items-center justify-between z-20 pointer-events-none">
        <div className={`flex items-center gap-2 px-3 py-1.5 rounded-xl backdrop-blur-md border shadow-sm ${
          isLight
            ? "bg-white/90 border-slate-200 text-slate-800"
            : "bg-slate-950/80 border-slate-800/80 text-white"
        }`}>
          <div className="flex items-center gap-1.5">
            {isSpeaking ? (
              <div className="flex items-end gap-[2px] h-3.5" aria-label="Speaking">
                {[0, 1, 2].map((i) => (
                  <span
                    key={i}
                    className="w-[3px] rounded-full bg-emerald-500 motion-safe:animate-wave"
                    style={{ height: "100%", animationDelay: `${i * 0.15}s` }}
                  />
                ))}
              </div>
            ) : (
              <MicOff size={13} className={isLight ? "text-slate-400" : "text-slate-400"} />
            )}
            <span className={`text-xs font-semibold ${isLight ? "text-slate-900" : "text-slate-100"}`}>{name}</span>
          </div>
          <span className={`text-[10px] font-medium hidden sm:inline ${isLight ? "text-slate-500" : "text-slate-400"}`}>({config.role})</span>
        </div>
      </div>
    </div>
  );
}
