"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth";
import { api } from "@/lib/api";

const CATEGORY_LABELS: Record<string, string> = {
  current_affairs: "Current Affairs",
  abstract: "Abstract",
  case_based: "Case Study",
  mba_specific: "MBA / GD Prep",
  ielts_aligned: "IELTS Speaking",
};

const DIFFICULTIES: { key: "beginner" | "intermediate" | "advanced"; label: string }[] = [
  { key: "beginner", label: "Beginner" },
  { key: "intermediate", label: "Intermediate" },
  { key: "advanced", label: "Advanced" },
];

const DURATIONS = [5, 10, 15, 20];

export default function HomePage() {
  const { user, loading } = useAuth();
  const router = useRouter();

  const [categories, setCategories] = useState<Record<string, string[]>>({});
  const [category, setCategory] = useState<string>("");
  const [topic, setTopic] = useState<string>("");
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
      const session = await api.createSession({
        topic: topic || undefined,
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

  if (loading || !user) return null;

  return (
    <div className="py-4">
      {/* Top Banner Header */}
      <div className="mb-8">
        <h1 className="font-display text-3xl sm:text-4xl text-ink font-semibold tracking-tight mb-2">
          Start a Group Discussion
        </h1>
        <p className="text-slate-600 text-sm sm:text-base max-w-2xl leading-relaxed">
          Practice speaking naturally with intelligent AI personas who challenge, react, and build upon your points in real time.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        {/* Left Column: Configuration Form (7 cols on lg) */}
        <div className="lg:col-span-7 space-y-6">
          <div className="card p-6 sm:p-8 space-y-6">
            <div>
              <div className="flex items-center justify-between mb-3">
                <label className="eyebrow">1. Category</label>
                {category && (
                  <button
                    onClick={() => {
                      setCategory("");
                      setTopic("");
                    }}
                    className="text-xs text-lavender font-medium hover:underline"
                  >
                    Reset category
                  </button>
                )}
              </div>
              <div className="flex flex-wrap gap-2">
                <button
                  onClick={() => {
                    setCategory("");
                    setTopic("");
                  }}
                  className={`chip ${category === "" ? "chip-active" : ""}`}
                >
                  ✨ Surprise me
                </button>
                {Object.keys(categories).map((cat) => (
                  <button
                    key={cat}
                    onClick={() => {
                      setCategory(cat);
                      setTopic("");
                    }}
                    className={`chip ${category === cat ? "chip-active" : ""}`}
                  >
                    {CATEGORY_LABELS[cat] || cat}
                  </button>
                ))}
              </div>
            </div>

            {category && (
              <div className="motion-safe:animate-rise">
                <label className="eyebrow block mb-3">2. Select Topic</label>
                <div className="space-y-2 max-h-56 overflow-y-auto pr-1 scroll-thin">
                  {(categories[category] || []).map((t) => (
                    <button
                      key={t}
                      onClick={() => setTopic(t)}
                      className={`w-full text-left px-4 py-3 rounded-2xl text-sm border font-medium transition-all duration-200 ${
                        topic === t
                          ? "border-lavender bg-indigo-50/80 text-lavender-deep shadow-sm"
                          : "border-slate-200/80 bg-white/60 hover:border-slate-300 hover:bg-white text-slate-700"
                      }`}
                    >
                      {t}
                    </button>
                  ))}
                </div>
              </div>
            )}

            <div>
              <label className="eyebrow block mb-3">3. Difficulty Level</label>
              <div className="grid grid-cols-3 gap-2">
                {DIFFICULTIES.map((d) => (
                  <button
                    key={d.key}
                    onClick={() => setDifficulty(d.key)}
                    className={`chip px-3 py-2.5 text-center font-medium ${
                      difficulty === d.key ? "chip-active" : ""
                    }`}
                  >
                    {d.label}
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="eyebrow block mb-3">4. Target Duration</label>
              <div className="grid grid-cols-4 gap-2">
                {DURATIONS.map((d) => (
                  <button
                    key={d}
                    onClick={() => setDuration(d)}
                    className={`chip px-3 py-2.5 text-center font-semibold tabular-nums ${
                      duration === d ? "chip-active" : ""
                    }`}
                  >
                    {d} mins
                  </button>
                ))}
              </div>
            </div>

            {error && (
              <p className="text-sm text-rose-600 bg-rose-50 border border-rose-200/80 rounded-2xl px-4 py-3 font-medium">
                {error}
              </p>
            )}

            <button
              onClick={handleStart}
              disabled={creating}
              className="btn-primary w-full py-4 text-base shadow-lg shadow-indigo-500/20 hover:shadow-indigo-500/30 font-semibold tracking-wide"
            >
              {creating ? "Setting up your GD session…" : "Start Group Discussion →"}
            </button>
          </div>
        </div>

        {/* Right Column: Persona Showcase & How It Works (5 cols on lg) */}
        <div className="lg:col-span-5 space-y-6">
          {/* Persona Card */}
          <div className="card p-6 border-slate-200/80">
            <h2 className="eyebrow mb-4">Your Discussion Partners</h2>
            <div className="space-y-4">
              <div className="card-flat p-4 flex items-start gap-3.5 bg-emerald-50/50 border-emerald-100">
                <div className="w-11 h-11 rounded-2xl bg-sage text-white flex items-center justify-center font-display font-semibold text-lg shrink-0 shadow-sm">
                  R
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <p className="text-sm font-bold text-slate-900">Riya</p>
                    <span className="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-semibold">
                      Empathetic
                    </span>
                  </div>
                  <p className="text-xs text-slate-600 mt-1 leading-relaxed">
                    Summarizes key arguments, bridges views, and ensures everyone gets a fair chance to present ideas.
                  </p>
                </div>
              </div>

              <div className="card-flat p-4 flex items-start gap-3.5 bg-amber-50/50 border-amber-100">
                <div className="w-11 h-11 rounded-2xl bg-apricot text-white flex items-center justify-center font-display font-semibold text-lg shrink-0 shadow-sm">
                  M
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <p className="text-sm font-bold text-slate-900">Meera</p>
                    <span className="px-2 py-0.5 rounded-full bg-amber-100 text-amber-800 text-[10px] font-semibold">
                      Contrarian
                    </span>
                  </div>
                  <p className="text-xs text-slate-600 mt-1 leading-relaxed">
                    Challenges assumptions, presents sharp counter-points, and tests your ability to defend arguments under pressure.
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Quick Guide Card */}
          <div className="card p-6 bg-gradient-to-br from-indigo-50/60 to-purple-50/60 border-indigo-100/80">
            <h3 className="font-display font-semibold text-slate-900 text-base mb-3 flex items-center gap-2">
              💡 How GD Sessions Work
            </h3>
            <ul className="space-y-2.5 text-xs text-slate-600">
              <li className="flex items-start gap-2">
                <span className="font-semibold text-indigo-600 shrink-0">1.</span>
                <span>Hold the microphone button to record your thoughts in natural English.</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="font-semibold text-indigo-600 shrink-0">2.</span>
                <span>Riya & Meera listen and take turns responding to your points via realistic voice audio.</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="font-semibold text-indigo-600 shrink-0">3.</span>
                <span>Get a complete AI breakdown on Fluency, Filler words, and Argument Quality upon completion.</span>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
