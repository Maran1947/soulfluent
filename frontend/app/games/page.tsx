"use client";

import { Gamepad2, Flame, RefreshCw, Trophy, Sparkles } from "lucide-react";
import Link from "next/link";

const GAMES = [
  {
    title: "Rapid Rebuttal",
    description: "Respond to Meera's controversial points in under 15 seconds to test quick thinking.",
    tags: ["Speed", "Spontaneity"],
    icon: Flame,
    color: "bg-amber-50 text-amber-600",
  },
  {
    title: "Word Swap Blitz",
    description: "Replace repetitive basic vocabulary words with advanced alternatives on the fly.",
    tags: ["Vocabulary", "Precision"],
    icon: RefreshCw,
    color: "bg-indigo-50 text-indigo-600",
  },
  {
    title: "Argument Defense Arena",
    description: "Defend a random stance against both Riya and Meera without losing logical composure.",
    tags: ["Debate", "Logic"],
    icon: Trophy,
    color: "bg-emerald-50 text-emerald-600",
  },
];

export default function GamesPage() {
  return (
    <div className="py-4">
      <div className="mb-8">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-amber-50 border border-amber-200/60 text-amber-800 text-xs font-semibold mb-3">
          <Gamepad2 size={14} /> Practice Drills & Games
        </div>
        <h1 className="font-display text-3xl sm:text-4xl text-ink font-semibold tracking-tight mb-2">
          Fluency Micro-Games
        </h1>
        <p className="text-slate-600 text-sm sm:text-base max-w-2xl">
          Fast-paced drills designed to improve response speed, vocabulary power, and poise under pressure.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        {GAMES.map((g) => {
          const Icon = g.icon;
          return (
            <div key={g.title} className="card p-6 flex flex-col justify-between hover:shadow-card-hover transition-all duration-200">
              <div>
                <div className="flex items-center justify-between gap-2 mb-4">
                  <div className={`w-10 h-10 rounded-2xl flex items-center justify-center ${g.color}`}>
                    <Icon size={20} />
                  </div>
                  <div className="flex gap-1">
                    {g.tags.map((t) => (
                      <span key={t} className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-slate-100 text-slate-600">
                        {t}
                      </span>
                    ))}
                  </div>
                </div>
                <h3 className="font-semibold text-slate-900 text-lg mb-2">{g.title}</h3>
                <p className="text-xs text-slate-600 leading-relaxed mb-4">{g.description}</p>
              </div>
              <button disabled className="btn-secondary w-full text-xs opacity-80 cursor-not-allowed">
                Coming Soon
              </button>
            </div>
          );
        })}
      </div>

      <div className="card p-8 bg-gradient-to-r from-amber-500/10 via-indigo-500/5 to-emerald-500/10 border-amber-100 flex flex-col sm:flex-row items-center justify-between gap-6">
        <div>
          <h2 className="font-display font-semibold text-slate-900 text-xl mb-1 flex items-center gap-2">
            <Sparkles size={18} className="text-amber-600" /> Ready for full conversation practice?
          </h2>
          <p className="text-xs sm:text-sm text-slate-600">
            Combine vocabulary and arguments in an authentic AI Group Discussion session.
          </p>
        </div>
        <Link href="/" className="btn-primary shrink-0 shadow-md">
          Start Group Discussion →
        </Link>
      </div>
    </div>
  );
}
