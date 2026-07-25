"use client";

import { BookOpen, Mic, Sparkles, Target, Zap } from "lucide-react";
import Link from "next/link";

const MODULES = [
  {
    title: "Opening Statements",
    description: "Learn how to frame a strong 30-second opener that sets the tone for the discussion.",
    level: "Beginner",
    icon: Mic,
    color: "bg-indigo-50 text-indigo-600",
  },
  {
    title: "Handling Interruptions",
    description: "Politely re-claim your turn when interrupted without sounding aggressive.",
    level: "Intermediate",
    icon: Zap,
    color: "bg-emerald-50 text-emerald-600",
  },
  {
    title: "Constructive Disagreement",
    description: "Phrases and tactics to counter-argue while maintaining professional rapport.",
    level: "Advanced",
    icon: Target,
    color: "bg-amber-50 text-amber-600",
  },
];

export default function LearnPage() {
  return (
    <div className="py-4">
      <div className="mb-8">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-50 border border-emerald-200/60 text-emerald-800 text-xs font-semibold mb-3">
          <BookOpen size={14} /> Learning Modules
        </div>
        <h1 className="font-display text-3xl sm:text-4xl text-ink font-semibold tracking-tight mb-2">
          Fluency & GD Skills
        </h1>
        <p className="text-slate-600 text-sm sm:text-base max-w-2xl">
          Interactive micro-lessons to sharpen your vocabulary, turn-taking, and argument structure.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        {MODULES.map((m) => {
          const Icon = m.icon;
          return (
            <div key={m.title} className="card p-6 flex flex-col justify-between hover:shadow-card-hover transition-all duration-200">
              <div>
                <div className="flex items-center justify-between gap-2 mb-4">
                  <div className={`w-10 h-10 rounded-2xl flex items-center justify-center ${m.color}`}>
                    <Icon size={20} />
                  </div>
                  <span className="text-[11px] font-semibold px-2.5 py-0.5 rounded-full bg-slate-100 text-slate-700">
                    {m.level}
                  </span>
                </div>
                <h3 className="font-semibold text-slate-900 text-lg mb-2">{m.title}</h3>
                <p className="text-xs text-slate-600 leading-relaxed mb-4">{m.description}</p>
              </div>
              <button disabled className="btn-secondary w-full text-xs opacity-80 cursor-not-allowed">
                Coming Soon
              </button>
            </div>
          );
        })}
      </div>

      <div className="card p-8 bg-gradient-to-r from-emerald-500/10 via-indigo-500/5 to-amber-500/10 border-indigo-100 flex flex-col sm:flex-row items-center justify-between gap-6">
        <div>
          <h2 className="font-display font-semibold text-slate-900 text-xl mb-1 flex items-center gap-2">
            <Sparkles size={18} className="text-emerald-600" /> Learn faster through real conversation
          </h2>
          <p className="text-xs sm:text-sm text-slate-600">
            The fastest way to build speaking confidence is live practice with AI personas.
          </p>
        </div>
        <Link href="/" className="btn-primary shrink-0 shadow-md">
          Start Practice Session →
        </Link>
      </div>
    </div>
  );
}
