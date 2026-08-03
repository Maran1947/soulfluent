"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth";
import { api } from "@/lib/api";
import {
  Sparkles,
  ArrowRight,
  ArrowLeft,
  Globe,
  Lightbulb,
  Briefcase,
  GraduationCap,
  MessageSquare,
  Users,
  Swords,
  Clock,
  PenTool,
  Library,
  ChevronDown,
  Check,
  Zap,
  UserCheck,
} from "lucide-react";

const CATEGORIES: { key: string; label: string; icon: any; desc: string }[] = [
  { key: "current_affairs", label: "Current Affairs", icon: Globe, desc: "Geopolitics & tech trends" },
  { key: "abstract", label: "Abstract Topics", icon: Lightbulb, desc: "Philosophy & dilemmas" },
  { key: "case_based", label: "Case Studies", icon: Briefcase, desc: "Business strategy" },
  { key: "mba_specific", label: "MBA & GD Prep", icon: GraduationCap, desc: "B-school prompts" },
  { key: "ielts_aligned", label: "IELTS Speaking", icon: MessageSquare, desc: "Formal & Part 3 English" },
];

const DIFFICULTIES: { key: "beginner" | "intermediate" | "advanced"; label: string; desc: string }[] = [
  { key: "beginner", label: "Beginner", desc: "Gentle pace & supportive tone" },
  { key: "intermediate", label: "Intermediate", desc: "Realistic debate rhythm" },
  { key: "advanced", label: "Advanced", desc: "High pressure & sharp rebuttals" },
];

const DURATIONS = [10, 20];

export type VoicePartner = {
  key: string;
  name: string;
  gender: "female" | "male";
  origin: "indian" | "us";
  flag: string;
  title: string;
  accent: string;
  style: string;
};

const VOICE_PARTNERS: VoicePartner[] = [
  {
    key: "riya",
    name: "Riya",
    gender: "female",
    origin: "indian",
    flag: "🇮🇳",
    title: "Empathetic Peacemaker",
    accent: "Indian Accent",
    style: "Warm, articulate, bridging",
  },
  {
    key: "rohan",
    name: "Rohan",
    gender: "male",
    origin: "indian",
    flag: "🇮🇳",
    title: "Structured Strategist",
    accent: "Indian Accent",
    style: "Clear, methodical, framework-driven",
  },
  {
    key: "emily",
    name: "Emily",
    gender: "female",
    origin: "us",
    flag: "🇺🇸",
    title: "Sharp Orator",
    accent: "US Accent",
    style: "Dynamic, confident, eloquent",
  },
  {
    key: "alex",
    name: "Alex",
    gender: "male",
    origin: "us",
    flag: "🇺🇸",
    title: "Analytical Contrarian",
    accent: "US Accent",
    style: "Direct, provocative, analytical",
  },
];

/* Custom Styled Single Dropdown Component */
function CustomSelect({
  options,
  value,
  onChange,
  placeholder = "Select option...",
}: {
  options: { value: string; label: string; sublabel?: string }[];
  value: string;
  onChange: (val: string) => void;
  placeholder?: string;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (ref.current && !ref.current.contains(event.target as Node)) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const selectedOption = options.find((o) => o.value === value);

  return (
    <div ref={ref} className="relative w-full">
      <button
        type="button"
        onClick={() => setOpen(!open)}
        className="w-full bg-white dark:bg-[#111622] border border-slate-200 dark:border-slate-800 rounded-xl px-4 py-3.5 text-xs text-left font-semibold text-slate-800 dark:text-slate-200 shadow-2xs hover:border-[#F25C40]/60 transition-all flex items-center justify-between gap-3 group"
      >
        <span className="truncate">
          {selectedOption ? selectedOption.label : placeholder}
        </span>
        <ChevronDown
          size={16}
          className={`text-slate-400 group-hover:text-[#F25C40] shrink-0 transition-transform duration-200 ${
            open ? "rotate-180 text-[#F25C40]" : ""
          }`}
        />
      </button>

      {open && (
        <div className="absolute left-0 right-0 top-full mt-1.5 z-50 bg-white dark:bg-[#181d29] border border-slate-200 dark:border-slate-800 rounded-xl shadow-xl max-h-64 overflow-y-auto p-1.5 space-y-1 backdrop-blur-xl">
          {options.map((opt) => {
            const isSelected = opt.value === value;
            return (
              <button
                key={opt.value}
                type="button"
                onClick={() => {
                  onChange(opt.value);
                  setOpen(false);
                }}
                className={`w-full text-left px-3.5 py-2.5 rounded-lg text-xs font-medium transition-all flex items-center justify-between gap-2 ${
                  isSelected
                    ? "bg-[#F25C40]/10 text-[#F25C40] font-bold"
                    : "text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800/80"
                }`}
              >
                <div className="min-w-0 pr-2">
                  <p className="truncate">{opt.label}</p>
                  {opt.sublabel && (
                    <p className="text-[10px] text-slate-400 font-normal truncate">
                      {opt.sublabel}
                    </p>
                  )}
                </div>
                {isSelected && <Check size={14} className="text-[#F25C40] shrink-0" />}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}

export default function HomePage() {
  const { user, loading } = useAuth();
  const router = useRouter();

  // Wizard Step State: 1 | 2 | 3 | 4
  const [step, setStep] = useState<number>(1);

  // Step 1: Mode Selection ("gd" | "debate")
  const [mode, setMode] = useState<"gd" | "debate">("gd");

  // Step 2: Topic Selection
  const [topicSource, setTopicSource] = useState<"library" | "custom">("library");
  const [categories, setCategories] = useState<Record<string, string[]>>({});
  const [category, setCategory] = useState<string>("current_affairs");
  const [topic, setTopic] = useState<string>("");
  const [customPrompt, setCustomPrompt] = useState<string>("");

  // Step 3: AI Voice Selection
  const [debateOpponent, setDebateOpponent] = useState<string>("alex");
  const [gdPartners, setGdPartners] = useState<string[]>(["riya", "alex"]);

  // Step 4: Difficulty & Duration
  const [difficulty, setDifficulty] = useState<"beginner" | "intermediate" | "advanced">("intermediate");
  const [duration, setDuration] = useState<number>(10);

  const [creating, setCreating] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!loading && !user) router.push("/login");
  }, [loading, user, router]);

  useEffect(() => {
    api.getTopics().then((res) => {
      setCategories(res.categories);
      if (res.categories["current_affairs"] && res.categories["current_affairs"].length > 0) {
        setTopic(res.categories["current_affairs"][0]);
      }
    });
  }, []);

  function toggleGdPartner(key: string) {
    if (gdPartners.includes(key)) {
      if (gdPartners.length > 1) {
        setGdPartners(gdPartners.filter((k) => k !== key));
      }
    } else {
      setGdPartners([...gdPartners, key]);
    }
  }

  async function handleStart() {
    setCreating(true);
    setError("");
    try {
      const finalTopic =
        topicSource === "custom"
          ? customPrompt.trim()
          : topic || (category ? categories[category]?.[0] : undefined);

      if (!finalTopic) {
        setError("Please enter or select a discussion topic.");
        setCreating(false);
        return;
      }

      const activePartners = mode === "debate" ? [debateOpponent] : gdPartners;

      const session = await api.createSession({
        mode,
        topic: finalTopic,
        category: topicSource === "custom" ? "custom" : category || "general",
        difficulty,
        duration_minutes: duration,
        persona_keys: activePartners,
      });

      router.push(`/session/${session.id}`);
    } catch (e: any) {
      setError(e.message || "Could not start session");
      setCreating(false);
    }
  }

  if (loading || !user) return null;

  const currentTopics = category ? categories[category] || [] : [];
  const topicOptions = currentTopics.map((t) => ({ value: t, label: t }));

  const opponentOptions = VOICE_PARTNERS.map((p) => ({
    value: p.key,
    label: `${p.flag} ${p.name} (${p.accent}) — ${p.title}`,
    sublabel: p.style,
  }));

  const selectedOpponentObj = VOICE_PARTNERS.find((p) => p.key === debateOpponent) || VOICE_PARTNERS[3];

  const STEP_TITLES = [
    { num: 1, title: "Practice Mode" },
    { num: 2, title: "Topic / Prompt" },
    { num: 3, title: "AI Voice Partners" },
    { num: 4, title: "Setup & Launch" },
  ];

  return (
    <div className="w-full max-w-2xl mx-auto my-auto py-2 space-y-5">
      {/* Step Progress Tracker */}
        <div className="bg-white/80 dark:bg-[#181d29]/90 backdrop-blur-xl border border-slate-200/80 dark:border-rose-900/40 rounded-2xl p-3.5 shadow-xs">
          <div className="flex items-center justify-between gap-2">
            {STEP_TITLES.map((s) => {
              const active = step === s.num;
              const completed = step > s.num;
              return (
                <button
                  key={s.num}
                  type="button"
                  onClick={() => {
                    if (completed || active) setStep(s.num);
                  }}
                  className={`flex-1 text-center py-2 px-1 rounded-xl transition-all ${
                    active
                      ? "bg-[#F25C40] text-white shadow-xs font-bold"
                      : completed
                      ? "bg-[#F25C40]/10 text-[#F25C40] font-semibold"
                      : "text-slate-400 dark:text-slate-600"
                  }`}
                >
                  <div className="flex items-center justify-center gap-1.5 text-xs">
                    <span className={`w-5 h-5 rounded-full flex items-center justify-center text-[11px] font-extrabold ${
                      active ? "bg-white text-[#F25C40]" : completed ? "bg-[#F25C40] text-white" : "bg-slate-200 dark:bg-slate-800 text-slate-500"
                    }`}>
                      {completed ? "✓" : s.num}
                    </span>
                    <span className="hidden sm:inline text-xs font-semibold">{s.title}</span>
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Main Wizard Card Container */}
        <div className="bg-white/80 dark:bg-[#181d29]/90 backdrop-blur-xl border border-slate-200/80 dark:border-rose-900/40 rounded-2xl p-6 sm:p-8 shadow-sm space-y-6 min-h-[380px] flex flex-col justify-between">
          
          {/* STEP 1: PRACTICE MODE */}
          {step === 1 && (
            <div className="space-y-6 my-auto">
              <div className="text-center space-y-2">
                <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#F25C40]/10 text-[#F25C40] text-xs font-bold">
                  <Sparkles size={14} />
                  <span>Step 1 of 4</span>
                </div>
                <h2 className="text-xl sm:text-2xl font-extrabold text-slate-900 dark:text-white tracking-tight">
                  Select Your Practice Mode
                </h2>
                <p className="text-xs text-slate-500 dark:text-slate-400 max-w-md mx-auto">
                  Choose between group discussion with multiple AI peers or sharp 1:1 debate
                </p>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                {/* Group Discussion Card */}
                <button
                  type="button"
                  onClick={() => setMode("gd")}
                  className={`p-6 rounded-2xl border text-left transition-all duration-200 relative flex flex-col justify-between space-y-4 group ${
                    mode === "gd"
                      ? "bg-[#F25C40]/5 dark:bg-[#F25C40]/10 border-[#F25C40] ring-2 ring-[#F25C40]/80 shadow-md shadow-[#F25C40]/10"
                      : "bg-white/50 dark:bg-slate-900/30 border-slate-200/80 dark:border-slate-800 hover:border-slate-300 dark:hover:border-slate-700"
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <div className={`w-11 h-11 rounded-2xl flex items-center justify-center transition-all ${
                      mode === "gd"
                        ? "bg-[#F25C40] text-white shadow-md shadow-[#F25C40]/25"
                        : "bg-[#F25C40]/10 text-[#F25C40]"
                    }`}>
                      <Users size={20} />
                    </div>
                    {mode === "gd" && (
                      <span className="px-2.5 py-1 rounded-full bg-[#F25C40] text-white text-[10px] font-extrabold">
                        ✓ Selected
                      </span>
                    )}
                  </div>

                  <div>
                    <h3 className="text-base font-extrabold text-slate-900 dark:text-white">
                      Group Discussion
                    </h3>
                    <p className="text-xs text-slate-500 dark:text-slate-400 mt-1.5 leading-relaxed">
                      Multi-persona room with AI peers & moderator. Practice natural turn-taking & group dynamics.
                    </p>
                  </div>
                </button>

                {/* 1:1 Debate Card */}
                <button
                  type="button"
                  onClick={() => setMode("debate")}
                  className={`p-6 rounded-2xl border text-left transition-all duration-200 relative flex flex-col justify-between space-y-4 group ${
                    mode === "debate"
                      ? "bg-[#F25C40]/5 dark:bg-[#F25C40]/10 border-[#F25C40] ring-2 ring-[#F25C40]/80 shadow-md shadow-[#F25C40]/10"
                      : "bg-white/50 dark:bg-slate-900/30 border-slate-200/80 dark:border-slate-800 hover:border-slate-300 dark:hover:border-slate-700"
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <div className={`w-11 h-11 rounded-2xl flex items-center justify-center transition-all ${
                      mode === "debate"
                        ? "bg-[#F25C40] text-white shadow-md shadow-[#F25C40]/25"
                        : "bg-indigo-500/10 text-indigo-500"
                    }`}>
                      <Swords size={20} />
                    </div>
                    {mode === "debate" && (
                      <span className="px-2.5 py-1 rounded-full bg-[#F25C40] text-white text-[10px] font-extrabold">
                        ✓ Selected
                      </span>
                    )}
                  </div>

                  <div>
                    <h3 className="text-base font-extrabold text-slate-900 dark:text-white">
                      1:1 Debate
                    </h3>
                    <p className="text-xs text-slate-500 dark:text-slate-400 mt-1.5 leading-relaxed">
                      Direct argument & counter-rebuttal challenge with 1 AI opponent. Sharpen logic under pressure.
                    </p>
                  </div>
                </button>
              </div>
            </div>
          )}

          {/* STEP 2: TOPIC SELECTION */}
          {step === 2 && (
            <div className="space-y-5 my-auto">
              <div className="text-center space-y-1">
                <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#F25C40]/10 text-[#F25C40] text-xs font-bold">
                  <span>Step 2 of 4</span>
                </div>
                <h2 className="text-xl font-extrabold text-slate-900 dark:text-white tracking-tight">
                  Choose Topic or Natural Prompt
                </h2>
                <p className="text-xs text-slate-500 dark:text-slate-400">
                  Select a curated topic from our library or type your custom prompt
                </p>
              </div>

              {/* Source Switcher */}
              <div className="flex items-center justify-center bg-slate-100 dark:bg-[#111622] rounded-xl p-1 text-xs max-w-sm mx-auto">
                <button
                  type="button"
                  onClick={() => setTopicSource("library")}
                  className={`flex-1 flex items-center justify-center gap-1.5 py-2 rounded-lg font-bold transition-all ${
                    topicSource === "library"
                      ? "bg-white dark:bg-[#202737] text-slate-900 dark:text-white shadow-2xs"
                      : "text-slate-500 hover:text-slate-800 dark:hover:text-slate-200"
                  }`}
                >
                  <Library size={14} />
                  <span>Curated Library</span>
                </button>
                <button
                  type="button"
                  onClick={() => setTopicSource("custom")}
                  className={`flex-1 flex items-center justify-center gap-1.5 py-2 rounded-lg font-bold transition-all ${
                    topicSource === "custom"
                      ? "bg-white dark:bg-[#202737] text-slate-900 dark:text-white shadow-2xs"
                      : "text-slate-500 hover:text-slate-800 dark:hover:text-slate-200"
                  }`}
                >
                  <PenTool size={14} />
                  <span>Custom Prompt</span>
                </button>
              </div>

              {topicSource === "library" ? (
                <div className="space-y-4 pt-1">
                  {/* Category Pills */}
                  <div className="flex items-center justify-center flex-wrap gap-2">
                    {CATEGORIES.map((cat) => {
                      const Icon = cat.icon;
                      const selected = category === cat.key;
                      return (
                        <button
                          key={cat.key}
                          type="button"
                          onClick={() => {
                            setCategory(cat.key);
                            const first = categories[cat.key]?.[0] || "";
                            setTopic(first);
                          }}
                          className={`flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold transition-all ${
                            selected
                              ? "bg-[#F25C40] text-white shadow-xs"
                              : "bg-slate-100/80 dark:bg-slate-800/60 text-slate-700 dark:text-slate-300 hover:bg-slate-200"
                          }`}
                        >
                          <Icon size={14} />
                          <span>{cat.label}</span>
                        </button>
                      );
                    })}
                  </div>

                  {/* Custom Styled Topic Dropdown */}
                  <div className="space-y-1.5 pt-2">
                    <label className="block text-xs font-bold text-slate-700 dark:text-slate-300">
                      Select Topic:
                    </label>
                    <CustomSelect
                      options={topicOptions}
                      value={topic}
                      onChange={(val) => setTopic(val)}
                      placeholder="Select a topic to discuss..."
                    />
                  </div>
                </div>
              ) : (
                /* Custom Natural Language Prompt Input */
                <div className="space-y-2 pt-1">
                  <label className="block text-xs font-bold text-slate-700 dark:text-slate-300">
                    Enter Custom Prompt or Scenario:
                  </label>
                  <textarea
                    value={customPrompt}
                    onChange={(e) => setCustomPrompt(e.target.value)}
                    placeholder={
                      mode === "debate"
                        ? "Enter your debate motion (e.g., Remote work should be a mandatory right for employees)"
                        : "Enter your discussion scenario (e.g., How will AI transform creative human jobs by 2030?)"
                    }
                    rows={4}
                    className="w-full bg-white dark:bg-[#111622] border border-slate-200 dark:border-slate-800 rounded-xl p-3.5 text-xs text-slate-900 dark:text-white placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#F25C40] resize-none"
                  />
                </div>
              )}
            </div>
          )}

          {/* STEP 3: VOICE PARTNERS */}
          {step === 3 && (
            <div className="space-y-5 my-auto">
              <div className="text-center space-y-1">
                <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#F25C40]/10 text-[#F25C40] text-xs font-bold">
                  <span>Step 3 of 4</span>
                </div>
                <h2 className="text-xl font-extrabold text-slate-900 dark:text-white tracking-tight">
                  Select AI Voice {mode === "debate" ? "Opponent" : "Partners"}
                </h2>
                <p className="text-xs text-slate-500 dark:text-slate-400">
                  {mode === "debate" ? "Choose 1 AI Opponent for your 1:1 debate" : "Choose 2 or more AI discussion partners"}
                </p>
              </div>

              {mode === "debate" ? (
                /* 1:1 DEBATE CUSTOM DROPDOWN & PREVIEW */
                <div className="space-y-4 pt-1">
                  <CustomSelect
                    options={opponentOptions}
                    value={debateOpponent}
                    onChange={(val) => setDebateOpponent(val)}
                    placeholder="Select debate opponent..."
                  />

                  <div className="flex items-center gap-4 bg-slate-100/70 dark:bg-slate-900/40 p-4 rounded-xl border border-slate-200/60 dark:border-slate-800">
                    <div className="w-11 h-11 rounded-xl bg-[#F25C40] text-white flex items-center justify-center font-bold text-base shrink-0">
                      {selectedOpponentObj.name.charAt(0)}
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-sm font-extrabold text-slate-900 dark:text-white">{selectedOpponentObj.name}</span>
                        <span className="text-sm">{selectedOpponentObj.flag}</span>
                        <span className="text-xs font-semibold text-[#F25C40]">({selectedOpponentObj.accent})</span>
                      </div>
                      <p className="text-xs font-bold text-slate-700 dark:text-slate-300 mt-0.5">{selectedOpponentObj.title}</p>
                      <p className="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5">{selectedOpponentObj.style}</p>
                    </div>
                  </div>
                </div>
              ) : (
                /* GROUP DISCUSSION PARTNER PILLS */
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-1">
                  {VOICE_PARTNERS.map((p) => {
                    const active = gdPartners.includes(p.key);
                    return (
                      <button
                        key={p.key}
                        type="button"
                        onClick={() => toggleGdPartner(p.key)}
                        className={`p-3.5 rounded-xl border text-left flex items-center gap-3.5 transition-all ${
                          active
                            ? "bg-[#F25C40]/10 border-[#F25C40] text-slate-900 dark:text-white ring-1 ring-[#F25C40]"
                            : "bg-white/40 dark:bg-slate-900/20 border-slate-200/80 dark:border-slate-800 text-slate-600 dark:text-slate-400 hover:border-slate-300"
                        }`}
                      >
                        <div className={`w-9 h-9 rounded-xl flex items-center justify-center font-bold text-sm shrink-0 ${
                          active ? "bg-[#F25C40] text-white" : "bg-slate-200 dark:bg-slate-800 text-slate-600"
                        }`}>
                          {p.name.charAt(0)}
                        </div>
                        <div className="min-w-0 flex-1">
                          <div className="flex items-center justify-between">
                            <span className="text-xs font-extrabold truncate">{p.name} {p.flag}</span>
                            {active && <UserCheck size={14} className="text-[#F25C40] shrink-0" />}
                          </div>
                          <span className="text-[11px] font-semibold text-[#F25C40] block truncate">{p.title}</span>
                          <span className="text-[10px] text-slate-400 block truncate">{p.accent}</span>
                        </div>
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
          )}

          {/* STEP 4: DIFFICULTY & DURATION SETUP */}
          {step === 4 && (
            <div className="space-y-6 my-auto">
              <div className="text-center space-y-1">
                <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#F25C40]/10 text-[#F25C40] text-xs font-bold">
                  <span>Step 4 of 4</span>
                </div>
                <h2 className="text-xl font-extrabold text-slate-900 dark:text-white tracking-tight">
                  Setup Pace & Session Duration
                </h2>
                <p className="text-xs text-slate-500 dark:text-slate-400">
                  Finalize your session settings before launching the room
                </p>
              </div>

              {/* Difficulty Cards */}
              <div className="space-y-2">
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300">
                  Difficulty Level:
                </label>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                  {DIFFICULTIES.map((d) => {
                    const active = difficulty === d.key;
                    return (
                      <button
                        key={d.key}
                        type="button"
                        onClick={() => setDifficulty(d.key)}
                        className={`p-3.5 rounded-xl border text-left transition-all ${
                          active
                            ? "bg-[#F25C40] text-white border-[#F25C40] shadow-sm font-bold"
                            : "bg-white/50 dark:bg-slate-900/30 border-slate-200/80 dark:border-slate-800 text-slate-700 dark:text-slate-300 hover:border-slate-300"
                        }`}
                      >
                        <p className={`text-xs font-bold ${active ? "text-white" : "text-slate-900 dark:text-white"}`}>
                          {d.label}
                        </p>
                        <p className={`text-[11px] mt-0.5 ${active ? "text-white/80" : "text-slate-400"}`}>
                          {d.desc}
                        </p>
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Target Duration */}
              <div className="space-y-2">
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300">
                  Target Duration:
                </label>
                <div className="grid grid-cols-2 gap-3">
                  {DURATIONS.map((dur) => {
                    const active = duration === dur;
                    return (
                      <button
                        key={dur}
                        type="button"
                        onClick={() => setDuration(dur)}
                        className={`py-3 px-4 rounded-xl border font-bold text-xs flex items-center justify-center gap-2 transition-all ${
                          active
                            ? "bg-[#F25C40] text-white border-[#F25C40] shadow-sm"
                            : "bg-white/50 dark:bg-slate-900/30 border-slate-200/80 dark:border-slate-800 text-slate-700 dark:text-slate-300 hover:border-slate-300"
                        }`}
                      >
                        <Clock size={15} />
                        <span>{dur} Minutes Session</span>
                      </button>
                    );
                  })}
                </div>
              </div>
            </div>
          )}

          {/* Error Alert */}
          {error && (
            <div className="p-3 bg-red-500/10 border border-red-500/30 rounded-xl text-red-500 text-xs font-medium">
              {error}
            </div>
          )}

          {/* Wizard Navigation Footer */}
          <div className="flex items-center justify-between gap-3 pt-4 border-t border-slate-200/60 dark:border-rose-900/30 mt-4">
            {step > 1 ? (
              <button
                type="button"
                onClick={() => setStep(step - 1)}
                className="px-4 py-2.5 rounded-xl border border-slate-200 dark:border-slate-800 text-xs font-bold text-slate-700 dark:text-slate-300 hover:bg-slate-100 flex items-center gap-1.5 transition-all"
              >
                <ArrowLeft size={14} />
                <span>Back</span>
              </button>
            ) : (
              <div></div>
            )}

            {step < 4 ? (
              <button
                type="button"
                onClick={() => setStep(step + 1)}
                className="px-6 py-2.5 bg-[#F25C40] text-white font-extrabold text-xs rounded-xl shadow-xs hover:bg-[#FA5A3A] flex items-center gap-1.5 transition-all"
              >
                <span>Continue</span>
                <ArrowRight size={14} />
              </button>
            ) : (
              <button
                type="button"
                onClick={handleStart}
                disabled={creating}
                className="px-6 py-3 bg-gradient-to-r from-[#FA5A3A] to-[#F25C40] text-white font-extrabold text-xs sm:text-sm rounded-xl shadow-md shadow-[#F25C40]/25 hover:shadow-lg hover:scale-[1.003] active:scale-[0.997] flex items-center gap-2 transition-all disabled:opacity-50"
              >
                {creating ? (
                  <span>Preparing Live Room...</span>
                ) : (
                  <>
                    <span>
                      Launch {mode === "debate" ? `1:1 Debate (${selectedOpponentObj.name})` : `GD (${gdPartners.length} Partners)`} ({duration}m)
                    </span>
                    <ArrowRight size={16} />
                  </>
                )}
              </button>
            )}
          </div>
        </div>
    </div>
  );
}
