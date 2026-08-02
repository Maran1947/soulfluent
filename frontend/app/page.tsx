"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth";
import { api } from "@/lib/api";
import {
  Sparkles,
  ArrowRight,
  Globe,
  Lightbulb,
  Briefcase,
  GraduationCap,
  MessageSquare,
  Mic,
  CheckCircle2,
  Sliders,
  Clock,
  Gauge,
  Users,
  Search,
  Zap,
} from "lucide-react";

const CATEGORY_CONFIG: Record<
  string,
  { label: string; icon: any; desc: string; count: string }
> = {
  current_affairs: {
    label: "Current Affairs",
    icon: Globe,
    desc: "Geopolitics, technology & economic trends",
    count: "12 topics",
  },
  abstract: {
    label: "Abstract Topics",
    icon: Lightbulb,
    desc: "Philosophy, ethics & societal dilemmas",
    count: "10 topics",
  },
  case_based: {
    label: "Case Studies",
    icon: Briefcase,
    desc: "Corporate strategy & business decisions",
    count: "8 topics",
  },
  mba_specific: {
    label: "MBA & GD Prep",
    icon: GraduationCap,
    desc: "B-school admissions & leadership prompts",
    count: "15 topics",
  },
  ielts_aligned: {
    label: "IELTS Speaking",
    icon: MessageSquare,
    desc: "Part 3 discussion topics & formal English",
    count: "10 topics",
  },
};

const DIFFICULTIES: { key: "beginner" | "intermediate" | "advanced"; label: string; desc: string }[] = [
  { key: "beginner", label: "Beginner", desc: "Gentle pace & supportive tone" },
  { key: "intermediate", label: "Intermediate", desc: "Realistic GD debate rhythm" },
  { key: "advanced", label: "Advanced", desc: "High pressure & sharp rebuttals" },
];

const DURATIONS = [5, 10, 15, 20];

export default function HomePage() {
  const { user, loading } = useAuth();
  const router = useRouter();

  const [categories, setCategories] = useState<Record<string, string[]>>({});
  const [category, setCategory] = useState<string>("");
  const [topic, setTopic] = useState<string>("");
  const [customTopic, setCustomTopic] = useState<string>("");
  const [difficulty, setDifficulty] = useState<"beginner" | "intermediate" | "advanced">(
    "intermediate"
  );
  const [duration, setDuration] = useState(10);
  const [creating, setCreating] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!loading && !user) router.push("/login");
  }, [loading, user, router]);

  useEffect(() => {
    api.getTopics().then((res) => setCategories(res.categories));
  }, []);

  async function handleStart() {
    setCreating(true);
    setError("");
    try {
      const selectedTopic = customTopic.trim() || topic || undefined;
      const session = await api.createSession({
        topic: selectedTopic,
        category: category || "general",
        difficulty,
        duration_minutes: duration,
      });
      router.push(`/session/${session.id}`);
    } catch (e: any) {
      setError(e.message || "Could not start session");
      setCreating(false);
    }
  }

  function applyPreset(cat: string, top: string, diff: "beginner" | "intermediate" | "advanced", dur: number) {
    setCategory(cat);
    setTopic(top);
    setDifficulty(diff);
    setDuration(dur);
    setCustomTopic("");
  }

  if (loading || !user) return null;

  const currentCategoryTopics = category ? categories[category] || [] : [];
  const activeTopicDisplay = customTopic.trim() || topic || "Random Topic";

  return (
    <div className="py-6 space-y-8">
      {/* Top Banner Header */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div className="space-y-2">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#FDEEE9] dark:bg-rose-950/60 border border-[#FCE3DC] dark:border-rose-800/60 text-[#F25C40] dark:text-rose-300 text-xs font-semibold">
            <Sparkles size={13} /> AI Group Discussion Studio
          </div>
          <h1 className="font-display text-3xl sm:text-4xl text-slate-900 dark:text-slate-100 font-bold tracking-tight">
            Start a Practice Discussion
          </h1>
          <p className="text-slate-600 dark:text-slate-400 text-sm sm:text-base max-w-2xl leading-relaxed">
            Practice speaking naturally with intelligent AI personas who challenge your points, moderate discussions, and sharpen your fluency.
          </p>
        </div>

        {/* Quick Presets Bar */}
        <div className="flex flex-wrap gap-2 shrink-0">
          <button
            onClick={() => {
              setCategory("");
              setTopic("");
              setCustomTopic("");
            }}
            className="chip text-xs flex items-center gap-1.5 hover:border-[#F25C40]"
          >
            <Zap size={13} className="text-[#F25C40]" /> Surprise Me
          </button>
          <button
            onClick={() => applyPreset("mba_specific", "Is AI a threat to human jobs?", "intermediate", 10)}
            className="chip text-xs hover:border-[#F25C40]"
          >
            🎓 MBA 10m GD
          </button>
          <button
            onClick={() => applyPreset("ielts_aligned", "Should public transport be free?", "beginner", 5)}
            className="chip text-xs hover:border-[#F25C40]"
          >
            🗣️ IELTS 5m Warmup
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        {/* Left Column: GD Setup Studio (7 cols on lg) */}
        <div className="lg:col-span-7 space-y-6">
          <div className="card p-6 sm:p-7 space-y-7 border-[#FCE3DC] dark:border-rose-900/30">
            {/* Step 1: Select Category */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <label className="eyebrow flex items-center gap-1.5">
                  <Sliders size={13} className="text-[#F25C40]" /> 1. Select Discussion Category
                </label>
                {category && (
                  <button
                    onClick={() => {
                      setCategory("");
                      setTopic("");
                      setCustomTopic("");
                    }}
                    className="text-xs text-[#F25C40] font-semibold hover:underline"
                  >
                    Clear selection
                  </button>
                )}
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                {Object.keys(CATEGORY_CONFIG).map((key) => {
                  const item = CATEGORY_CONFIG[key];
                  const Icon = item.icon;
                  const selected = category === key;
                  return (
                    <button
                      key={key}
                      onClick={() => {
                        setCategory(key);
                        setTopic("");
                        setCustomTopic("");
                      }}
                      className={`p-3.5 rounded-xl border text-left transition-all duration-200 flex items-start gap-3 select-none ${
                        selected
                          ? "border-[#F25C40] bg-[#FDEEE9]/80 dark:bg-rose-950/70 text-slate-900 dark:text-slate-100 shadow-xs ring-1 ring-[#F25C40]"
                          : "border-slate-200/90 dark:border-slate-800 bg-white dark:bg-[#181d29]/60 hover:border-[#F25C40]/40 hover:bg-[#faf5f3] dark:hover:bg-[#202737] text-slate-700 dark:text-slate-300"
                      }`}
                    >
                      <div className={`w-9 h-9 rounded-xl flex items-center justify-center shrink-0 ${
                        selected
                          ? "bg-[#F25C40] text-white"
                          : "bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300"
                      }`}>
                        <Icon size={18} />
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center justify-between">
                          <p className="text-xs font-bold text-slate-900 dark:text-slate-100">{item.label}</p>
                          <span className="text-[10px] text-slate-400 font-medium">{item.count}</span>
                        </div>
                        <p className="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5 leading-tight truncate">
                          {item.desc}
                        </p>
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Step 2: Select Topic or Enter Custom */}
            {category && (
              <div className="motion-safe:animate-rise space-y-3 pt-2 border-t border-slate-100 dark:border-slate-800">
                <div className="flex items-center justify-between">
                  <label className="eyebrow">2. Pick a Topic or Enter Custom Prompt</label>
                  <span className="text-[11px] text-slate-400 font-medium">{currentCategoryTopics.length} curated topics</span>
                </div>

                <div className="space-y-2 max-h-52 overflow-y-auto pr-1 scroll-thin">
                  {currentCategoryTopics.map((t) => {
                    const isSelected = topic === t && !customTopic;
                    return (
                      <button
                        key={t}
                        onClick={() => {
                          setTopic(t);
                          setCustomTopic("");
                        }}
                        className={`w-full text-left px-4 py-3 rounded-xl text-xs sm:text-sm border font-medium transition-all duration-200 flex items-center justify-between gap-3 ${
                          isSelected
                            ? "border-[#F25C40] dark:border-rose-500 bg-[#FDEEE9]/80 dark:bg-rose-950/70 text-[#F25C40] dark:text-rose-200 font-semibold shadow-xs"
                            : "border-slate-200/90 dark:border-slate-800 bg-white dark:bg-[#181d29]/60 hover:border-[#F25C40]/40 hover:bg-[#faf5f3] dark:hover:bg-[#202737] text-slate-700 dark:text-slate-300"
                        }`}
                      >
                        <span className="line-clamp-1">{t}</span>
                        {isSelected && <CheckCircle2 size={16} className="text-[#F25C40] dark:text-rose-400 shrink-0" />}
                      </button>
                    );
                  })}
                </div>

                {/* Custom Topic Input */}
                <div className="pt-2">
                  <div className="relative">
                    <Search size={15} className="text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                    <input
                      type="text"
                      placeholder="Or type a custom topic (e.g. Work-from-home vs Office)"
                      value={customTopic}
                      onChange={(e) => {
                        setCustomTopic(e.target.value);
                        if (e.target.value) setTopic("");
                      }}
                      className="input pl-10 text-xs"
                    />
                  </div>
                </div>
              </div>
            )}

            {/* Step 3: Difficulty & Duration Controls */}
            <div className="pt-2 border-t border-slate-100 dark:border-slate-800 space-y-6">
              <div>
                <label className="eyebrow flex items-center gap-1.5 mb-3">
                  <Gauge size={13} className="text-[#F25C40]" /> 3. Difficulty Level
                </label>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-2.5">
                  {DIFFICULTIES.map((d) => {
                    const active = difficulty === d.key;
                    return (
                      <button
                        key={d.key}
                        onClick={() => setDifficulty(d.key)}
                        className={`p-3 rounded-xl border text-left transition-all duration-200 select-none ${
                          active
                            ? "border-[#F25C40] dark:border-rose-500 bg-[#F25C40] text-white shadow-xs"
                            : "border-slate-200/90 dark:border-slate-800 bg-white dark:bg-[#181d29]/60 hover:border-slate-300 dark:hover:border-slate-700 text-slate-700 dark:text-slate-300"
                        }`}
                      >
                        <p className="text-xs font-bold">{d.label}</p>
                        <p className={`text-[11px] mt-0.5 leading-tight ${active ? "text-rose-100" : "text-slate-500 dark:text-slate-400"}`}>
                          {d.desc}
                        </p>
                      </button>
                    );
                  })}
                </div>
              </div>

              <div>
                <label className="eyebrow flex items-center gap-1.5 mb-3">
                  <Clock size={13} className="text-[#F25C40]" /> 4. Target Duration
                </label>
                <div className="grid grid-cols-4 gap-2">
                  {DURATIONS.map((d) => (
                    <button
                      key={d}
                      onClick={() => setDuration(d)}
                      className={`chip py-2.5 text-center font-semibold tabular-nums ${
                        duration === d ? "chip-active" : ""
                      }`}
                    >
                      {d} mins
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {error && (
              <p className="text-xs font-medium text-rose-600 dark:text-rose-400 bg-rose-50 dark:bg-rose-950/50 border border-rose-200 dark:border-rose-800 rounded-xl px-4 py-3">
                {error}
              </p>
            )}

            {/* Launch Button */}
            <button
              onClick={handleStart}
              disabled={creating}
              className="btn-primary w-full py-4 text-sm font-semibold flex items-center justify-center gap-2 shadow-md shadow-[#F25C40]/25 bg-[#F25C40] hover:bg-[#E04B30] text-white rounded-xl"
            >
              <span>{creating ? "Preparing GD Room…" : `Launch Discussion Room (${duration}m)`}</span>
              {!creating && <ArrowRight size={16} />}
            </button>
          </div>
        </div>

        {/* Right Column: Discussion Partners Showcase & Guide (5 cols on lg) */}
        <div className="lg:col-span-5 space-y-6">
          {/* Discussion Partners Card */}
          <div className="card p-6 border-[#FCE3DC] dark:border-rose-900/30">
            <div className="flex items-center justify-between mb-4">
              <h2 className="eyebrow flex items-center gap-1.5">
                <Users size={13} className="text-[#F25C40]" /> Your AI Discussion Partners
              </h2>
              <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-emerald-100 dark:bg-emerald-950 text-emerald-800 dark:text-emerald-300">
                Live Turn-Taking
              </span>
            </div>

            <div className="space-y-4">
              {/* Riya Persona Tile */}
              <div className="card-flat p-4 border-slate-200/80 dark:border-slate-800 hover:border-[#F25C40]/30 transition-colors">
                <div className="flex items-start gap-3.5">
                  <div className="w-11 h-11 rounded-2xl bg-emerald-600 text-white flex items-center justify-center font-bold text-base shrink-0 shadow-xs">
                    R
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="text-sm font-bold text-slate-900 dark:text-slate-100">Riya</p>
                      <span className="px-2 py-0.5 rounded-md bg-emerald-100 dark:bg-emerald-950 text-emerald-800 dark:text-emerald-300 text-[10px] font-semibold border border-emerald-200 dark:border-emerald-800/60">
                        AI Moderator
                      </span>
                    </div>
                    <p className="text-xs text-slate-600 dark:text-slate-400 mt-1 leading-relaxed">
                      Summarizes key arguments, bridges opposing views, and ensures everyone gets a fair chance to present ideas.
                    </p>
                    <div className="flex items-center gap-1.5 mt-2.5 text-[10px] font-medium text-slate-500 dark:text-slate-400">
                      <span className="px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-800">Empathetic</span>
                      <span>•</span>
                      <span className="px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-800">Structured</span>
                      <span>•</span>
                      <span className="px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-800">Encouraging</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Meera Persona Tile */}
              <div className="card-flat p-4 border-slate-200/80 dark:border-slate-800 hover:border-[#F25C40]/30 transition-colors">
                <div className="flex items-start gap-3.5">
                  <div className="w-11 h-11 rounded-2xl bg-amber-600 text-white flex items-center justify-center font-bold text-base shrink-0 shadow-xs">
                    M
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="text-sm font-bold text-slate-900 dark:text-slate-100">Meera</p>
                      <span className="px-2 py-0.5 rounded-md bg-amber-100 dark:bg-amber-950 text-amber-800 dark:text-amber-300 text-[10px] font-semibold border border-amber-200 dark:border-amber-800/60">
                        AI Challenger
                      </span>
                    </div>
                    <p className="text-xs text-slate-600 dark:text-slate-400 mt-1 leading-relaxed">
                      Challenges assumptions, presents sharp counter-points, and tests your ability to defend arguments under pressure.
                    </p>
                    <div className="flex items-center gap-1.5 mt-2.5 text-[10px] font-medium text-slate-500 dark:text-slate-400">
                      <span className="px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-800">Analytical</span>
                      <span>•</span>
                      <span className="px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-800">Contrarian</span>
                      <span>•</span>
                      <span className="px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-800">Sharp</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* How GD Sessions Work Card */}
          <div className="card p-6 border-[#FCE3DC] dark:border-rose-900/30 bg-[#FAF5F3]/60 dark:bg-[#181d29]/40">
            <h3 className="font-semibold text-slate-900 dark:text-slate-100 text-sm mb-3 flex items-center gap-2">
              <Mic size={16} className="text-[#F25C40] dark:text-rose-400" /> How GD Sessions Work
            </h3>
            <ul className="space-y-3 text-xs text-slate-600 dark:text-slate-400">
              <li className="flex items-start gap-2.5">
                <span className="w-5 h-5 rounded-full bg-[#FDEEE9] dark:bg-rose-950 text-[#F25C40] dark:text-rose-300 font-bold flex items-center justify-center text-[10px] shrink-0">1</span>
                <span className="leading-snug">Hold <kbd className="px-1.5 py-0.5 bg-white dark:bg-slate-800 rounded border text-[10px] font-mono shadow-xs">Space</kbd> or click the microphone to speak your thoughts in natural English.</span>
              </li>
              <li className="flex items-start gap-2.5">
                <span className="w-5 h-5 rounded-full bg-[#FDEEE9] dark:bg-rose-950 text-[#F25C40] dark:text-rose-300 font-bold flex items-center justify-center text-[10px] shrink-0">2</span>
                <span className="leading-snug">Riya & Meera listen and take turns responding via realistic voice audio synthesis.</span>
              </li>
              <li className="flex items-start gap-2.5">
                <span className="w-5 h-5 rounded-full bg-[#FDEEE9] dark:bg-rose-950 text-[#F25C40] dark:text-rose-300 font-bold flex items-center justify-center text-[10px] shrink-0">3</span>
                <span className="leading-snug">Get an instant AI report detailing your Fluency, Filler Words, and Argument Structure upon exit.</span>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
