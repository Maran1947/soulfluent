"use client";

import { useState } from "react";
import Link from "next/link";
import {
  Sparkles,
  ArrowRight,
  Mic,
  Volume2,
  Users,
  Swords,
  Zap,
  BarChart3,
  CheckCircle2,
  Play,
  Pause,
  ShieldCheck,
  Globe,
  Award,
} from "lucide-react";

const DEMO_VOICES = [
  {
    key: "riya",
    name: "Riya",
    flag: "🇮🇳",
    origin: "Indian Accent",
    role: "Empathetic Peacemaker",
    traits: ["Encouraging", "Bridging", "Warm"],
    sampleText: "That's a great point! However, have we considered the economic impact on smaller businesses?",
    color: "from-amber-500 to-[#F25C40]",
  },
  {
    key: "rohan",
    name: "Rohan",
    flag: "🇮🇳",
    origin: "Indian Accent",
    role: "Structured Strategist",
    traits: ["Structured", "Methodical", "Logical"],
    sampleText: "Let's break this down into three key pillars: scalability, cost efficiency, and long-term sustainability.",
    color: "from-[#F25C40] to-rose-600",
  },
  {
    key: "emily",
    name: "Emily",
    flag: "🇺🇸",
    origin: "US Accent",
    role: "Sharp Orator",
    traits: ["Eloquent", "Persuasive", "Sharp"],
    sampleText: "I respect your perspective, but statistical evidence strongly points toward a different conclusion.",
    color: "from-indigo-500 to-purple-600",
  },
  {
    key: "alex",
    name: "Alex",
    flag: "🇺🇸",
    origin: "US Accent",
    role: "Analytical Contrarian",
    traits: ["Analytical", "Contrarian", "Challenging"],
    sampleText: "What if the fundamental premise itself is flawed? Let's challenge that core assumption.",
    color: "from-cyan-500 to-blue-600",
  },
];

export default function LandingPage() {
  const [activeVoice, setActiveVoice] = useState<string | null>("riya");
  const [isPlaying, setIsPlaying] = useState(false);

  function toggleVoiceSample(key: string) {
    if (activeVoice === key) {
      setIsPlaying(!isPlaying);
    } else {
      setActiveVoice(key);
      setIsPlaying(true);
    }
  }

  const selectedVoice = DEMO_VOICES.find((v) => v.key === activeVoice) || DEMO_VOICES[0];

  return (
    <div className="max-w-6xl mx-auto space-y-20 py-8 px-4 sm:px-6">
      
      {/* 1. HERO SECTION (HIGH VISUAL IMPACT, MINIMAL TEXT) */}
      <div className="relative pt-6 pb-12 flex flex-col items-center text-center space-y-8">
        
        {/* Floating Background Glow Orbs */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-gradient-to-tr from-[#F25C40]/20 to-purple-500/20 rounded-full blur-3xl -z-10 pointer-events-none" />

        {/* Floating Partner Avatar Badges (3D Float Animation effect) */}
        <div className="hidden lg:block absolute top-4 left-6 bg-white/80 dark:bg-[#181d29]/90 backdrop-blur-xl border border-slate-200/80 dark:border-rose-900/40 p-3 rounded-2xl shadow-lg animate-bounce duration-[4000ms]">
          <div className="flex items-center gap-2 text-xs font-bold">
            <span className="text-base">🇮🇳</span>
            <span>Riya</span>
            <span className="px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-500 text-[10px]">Warm</span>
          </div>
        </div>

        <div className="hidden lg:block absolute top-12 right-6 bg-white/80 dark:bg-[#181d29]/90 backdrop-blur-xl border border-slate-200/80 dark:border-rose-900/40 p-3 rounded-2xl shadow-lg animate-bounce duration-[5000ms]">
          <div className="flex items-center gap-2 text-xs font-bold">
            <span className="text-base">🇺🇸</span>
            <span>Alex</span>
            <span className="px-2 py-0.5 rounded-full bg-cyan-500/10 text-cyan-500 text-[10px]">Contrarian</span>
          </div>
        </div>

        {/* Hero Eyebrow Badge */}
        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-gradient-to-r from-[#FA5A3A]/10 via-[#F25C40]/15 to-purple-500/10 border border-[#F25C40]/30 text-[#F25C40] text-xs font-extrabold shadow-xs">
          <Sparkles size={14} className="animate-spin duration-3000" />
          <span>Real-Time AI Voice Speech Gym</span>
        </div>

        {/* Main Punchy Headline */}
        <h1 className="text-4xl sm:text-6xl md:text-7xl font-extrabold tracking-tight text-slate-900 dark:text-white max-w-4xl leading-[1.1]">
          Speak English. <br />
          <span className="bg-gradient-to-r from-[#FA5A3A] via-[#F25C40] to-purple-600 bg-clip-text text-transparent">
            Fluently & Confidently.
          </span>
        </h1>

        {/* Short Subtitle */}
        <p className="text-base sm:text-lg text-slate-600 dark:text-slate-300 max-w-2xl leading-relaxed font-medium">
          Master Group Discussions & 1:1 Debates with real-time AI voice partners. Get instant WPM, filler word & vocabulary analysis.
        </p>

        {/* Hero Action CTAs */}
        <div className="flex flex-wrap items-center justify-center gap-4 pt-2">
          <Link
            href="/register"
            className="px-8 py-4 bg-gradient-to-r from-[#FA5A3A] to-[#F25C40] text-white text-sm font-extrabold rounded-2xl shadow-xl shadow-[#F25C40]/30 hover:shadow-2xl hover:shadow-[#F25C40]/40 hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center gap-2.5"
          >
            <span>Start Practicing Free</span>
            <ArrowRight size={18} />
          </Link>
          <Link
            href="/login"
            className="px-6 py-4 bg-white/80 dark:bg-[#181d29]/90 border border-slate-200 dark:border-slate-800 text-slate-800 dark:text-slate-200 text-sm font-bold rounded-2xl shadow-sm hover:bg-slate-100 transition-all flex items-center gap-2"
          >
            <span>Sign In</span>
          </Link>
        </div>

        {/* LIVE AUDIO WAVEFORM VISUALIZER PREVIEW */}
        <div className="w-full max-w-3xl pt-8">
          <div className="bg-white/80 dark:bg-[#181d29]/90 backdrop-blur-xl border border-slate-200/80 dark:border-rose-900/40 rounded-3xl p-6 sm:p-8 shadow-xl space-y-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-3 h-3 rounded-full bg-emerald-500 animate-ping" />
                <span className="text-xs font-extrabold text-slate-900 dark:text-white uppercase tracking-wider">
                  Live AI Conversation Room
                </span>
              </div>
              <span className="px-3 py-1 rounded-full bg-[#F25C40]/10 text-[#F25C40] text-xs font-bold">
                128 WPM · Optimal Pace
              </span>
            </div>

            {/* Equalizer Sound Wave Simulation */}
            <div className="flex items-center justify-center gap-1.5 h-16 px-4 py-2 bg-slate-50 dark:bg-slate-900/60 rounded-2xl border border-slate-200/60 dark:border-slate-800">
              {[40, 75, 100, 60, 30, 85, 95, 50, 70, 100, 45, 80, 65, 90, 40, 85, 100, 55, 30, 70, 95, 60, 40].map(
                (h, i) => (
                  <span
                    key={i}
                    className="w-1.5 bg-gradient-to-t from-[#FA5A3A] to-[#F25C40] rounded-full animate-wave"
                    style={{
                      height: `${h}%`,
                      animationDelay: `${(i % 5) * 0.15}s`,
                    }}
                  />
                )
              )}
            </div>

            <div className="flex items-center justify-between text-xs text-slate-500 dark:text-slate-400 pt-1">
              <span className="flex items-center gap-1.5">
                <Mic size={14} className="text-[#F25C40]" /> Hold Space or click mic to speak
              </span>
              <span className="flex items-center gap-1.5 font-bold text-slate-800 dark:text-slate-200">
                <Volume2 size={14} className="text-emerald-500" /> Real-time TTS synthesis
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* 2. INTERACTIVE AI VOICE SOUNDBOARD */}
      <div className="space-y-8">
        <div className="text-center space-y-2">
          <div className="inline-flex items-center gap-1.5 px-3.5 py-1 rounded-full bg-[#F25C40]/10 text-[#F25C40] text-xs font-bold">
            <Globe size={14} />
            <span>4 Distinct AI Voice Partners</span>
          </div>
          <h2 className="text-2xl sm:text-4xl font-extrabold text-slate-900 dark:text-white tracking-tight">
            Meet Your AI Practice Partners
          </h2>
          <p className="text-xs sm:text-sm text-slate-500 dark:text-slate-400 max-w-xl mx-auto">
            Choose from Indian and US accents with distinct speaking personalities and debate styles
          </p>
        </div>

        {/* 4 Voice Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {DEMO_VOICES.map((v) => {
            const active = activeVoice === v.key;
            return (
              <div
                key={v.key}
                onClick={() => toggleVoiceSample(v.key)}
                className={`cursor-pointer p-5 rounded-3xl border transition-all duration-300 space-y-4 flex flex-col justify-between ${
                  active
                    ? "bg-white dark:bg-[#181d29] border-[#F25C40] ring-2 ring-[#F25C40]/80 shadow-xl"
                    : "bg-white/60 dark:bg-[#181d29]/60 border-slate-200/80 dark:border-slate-800 hover:border-slate-300"
                }`}
              >
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className={`w-10 h-10 rounded-2xl bg-gradient-to-br ${v.color} text-white flex items-center justify-center font-bold text-sm shadow-md`}>
                        {v.name.charAt(0)}
                      </div>
                      <div>
                        <div className="flex items-center gap-1.5">
                          <span className="text-sm font-extrabold text-slate-900 dark:text-white">{v.name}</span>
                          <span className="text-sm">{v.flag}</span>
                        </div>
                        <span className="text-[10px] text-slate-400 font-semibold">{v.origin}</span>
                      </div>
                    </div>

                    <button
                      type="button"
                      className={`w-8 h-8 rounded-full flex items-center justify-center transition-all ${
                        active && isPlaying ? "bg-[#F25C40] text-white" : "bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300"
                      }`}
                    >
                      {active && isPlaying ? <Pause size={14} /> : <Play size={14} className="ml-0.5" />}
                    </button>
                  </div>

                  <p className="text-xs font-bold text-[#F25C40]">{v.role}</p>

                  {/* Sample Text */}
                  <p className="text-xs text-slate-600 dark:text-slate-400 italic bg-slate-50 dark:bg-slate-900/50 p-2.5 rounded-xl border border-slate-200/50 dark:border-slate-800/80 leading-relaxed">
                    "{v.sampleText}"
                  </p>
                </div>

                {/* Trait Pills */}
                <div className="flex flex-wrap items-center gap-1.5 pt-2">
                  {v.traits.map((t, idx) => (
                    <span key={idx} className="px-2 py-0.5 rounded-md bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400 text-[10px] font-semibold">
                      {t}
                    </span>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* 3. PRACTICE MODES SHOWCASE (GD VS 1:1 DEBATE) */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-stretch">
        
        {/* GD Mode Card */}
        <div className="bg-gradient-to-br from-white via-white to-amber-500/5 dark:from-[#181d29] dark:via-[#181d29] dark:to-amber-500/10 border border-slate-200/80 dark:border-rose-900/40 rounded-3xl p-8 shadow-sm flex flex-col justify-between space-y-6">
          <div className="space-y-4">
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-[#FA5A3A] to-[#F25C40] text-white flex items-center justify-center font-bold shadow-md shadow-[#F25C40]/25">
              <Users size={24} />
            </div>
            <div>
              <span className="text-xs font-bold tracking-wider text-[#F25C40] uppercase">
                Multi-Persona Room
              </span>
              <h3 className="text-2xl font-extrabold text-slate-900 dark:text-white mt-1">
                Group Discussion
              </h3>
              <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400 mt-2 leading-relaxed">
                Practice group dynamics, natural turn-taking, and active listening with AI peers and a virtual moderator.
              </p>
            </div>
          </div>

          <ul className="space-y-2.5 text-xs text-slate-700 dark:text-slate-300">
            <li className="flex items-center gap-2 font-semibold">
              <CheckCircle2 size={16} className="text-[#F25C40] shrink-0" />
              <span>Multi-speaker AI turn management</span>
            </li>
            <li className="flex items-center gap-2 font-semibold">
              <CheckCircle2 size={16} className="text-[#F25C40] shrink-0" />
              <span>Curated MBA, Case Study & IELTS topics</span>
            </li>
            <li className="flex items-center gap-2 font-semibold">
              <CheckCircle2 size={16} className="text-[#F25C40] shrink-0" />
              <span>Instant group dynamics report upon exit</span>
            </li>
          </ul>
        </div>

        {/* 1:1 Debate Card */}
        <div className="bg-gradient-to-br from-white via-white to-purple-500/5 dark:from-[#181d29] dark:via-[#181d29] dark:to-purple-500/10 border border-slate-200/80 dark:border-rose-900/40 rounded-3xl p-8 shadow-sm flex flex-col justify-between space-y-6">
          <div className="space-y-4">
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-indigo-500 to-purple-600 text-white flex items-center justify-center font-bold shadow-md shadow-indigo-500/25">
              <Swords size={24} />
            </div>
            <div>
              <span className="text-xs font-bold tracking-wider text-indigo-500 uppercase">
                Direct Challenge
              </span>
              <h3 className="text-2xl font-extrabold text-slate-900 dark:text-white mt-1">
                1:1 Debate Mode
              </h3>
              <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400 mt-2 leading-relaxed">
                Debate 1:1 against a sharp AI opponent. Defend your logic, formulate rebuttals, and overcome high-pressure arguments.
              </p>
            </div>
          </div>

          <ul className="space-y-2.5 text-xs text-slate-700 dark:text-slate-300">
            <li className="flex items-center gap-2 font-semibold">
              <CheckCircle2 size={16} className="text-indigo-500 shrink-0" />
              <span>Custom natural language debate prompts</span>
            </li>
            <li className="flex items-center gap-2 font-semibold">
              <CheckCircle2 size={16} className="text-indigo-500 shrink-0" />
              <span>Argument defense & rebuttal scoring</span>
            </li>
            <li className="flex items-center gap-2 font-semibold">
              <CheckCircle2 size={16} className="text-indigo-500 shrink-0" />
              <span>Vocabulary upgrade & phrase swap suggestions</span>
            </li>
          </ul>
        </div>
      </div>

      {/* 4. VISUAL STATS & ANALYTICS PREVIEW */}
      <div className="bg-white/80 dark:bg-[#181d29]/90 backdrop-blur-xl border border-slate-200/80 dark:border-rose-900/40 rounded-3xl p-8 shadow-sm space-y-8">
        <div className="text-center space-y-2">
          <span className="text-xs font-bold tracking-wider text-[#F25C40] uppercase">
            Data-Driven Speech Analytics
          </span>
          <h2 className="text-2xl sm:text-3xl font-extrabold text-slate-900 dark:text-white">
            Track Every Aspect of Your Speaking
          </h2>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
          <div className="p-4 bg-slate-50 dark:bg-slate-900/50 rounded-2xl border border-slate-200/60 dark:border-slate-800 space-y-1">
            <p className="text-3xl font-extrabold text-[#F25C40]">135 WPM</p>
            <p className="text-xs text-slate-500 dark:text-slate-400 font-semibold">Optimal Speech Pace</p>
          </div>
          <div className="p-4 bg-slate-50 dark:bg-slate-900/50 rounded-2xl border border-slate-200/60 dark:border-slate-800 space-y-1">
            <p className="text-3xl font-extrabold text-emerald-500">0 Filler</p>
            <p className="text-xs text-slate-500 dark:text-slate-400 font-semibold">Clean Delivery</p>
          </div>
          <div className="p-4 bg-slate-50 dark:bg-slate-900/50 rounded-2xl border border-slate-200/60 dark:border-slate-800 space-y-1">
            <p className="text-3xl font-extrabold text-indigo-500">92% Score</p>
            <p className="text-xs text-slate-500 dark:text-slate-400 font-semibold">Vocabulary Richness</p>
          </div>
          <div className="p-4 bg-slate-50 dark:bg-slate-900/50 rounded-2xl border border-slate-200/60 dark:border-slate-800 space-y-1">
            <p className="text-3xl font-extrabold text-purple-500">Instant</p>
            <p className="text-xs text-slate-500 dark:text-slate-400 font-semibold">AI Feedback Report</p>
          </div>
        </div>
      </div>

      {/* 5. BOTTOM HERO CTA BANNER */}
      <div className="bg-gradient-to-r from-[#FA5A3A] to-[#F25C40] text-white rounded-3xl p-8 sm:p-12 shadow-2xl flex flex-col md:flex-row items-center justify-between gap-6 text-center md:text-left">
        <div className="space-y-2 max-w-xl">
          <h2 className="text-2xl sm:text-4xl font-extrabold tracking-tight">
            Ready to Speak Confidently?
          </h2>
          <p className="text-xs sm:text-sm opacity-90 leading-relaxed font-medium">
            Join FluentSoul today and practice live conversations with intelligent AI voice partners.
          </p>
        </div>

        <Link
          href="/register"
          className="px-8 py-4 bg-white text-slate-900 text-sm font-extrabold rounded-2xl shadow-lg hover:bg-slate-100 hover:scale-[1.02] active:scale-[0.98] transition-all shrink-0"
        >
          Start Practicing Now →
        </Link>
      </div>
    </div>
  );
}
