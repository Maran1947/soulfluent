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
    <div className="max-w-2xl mx-auto">
      <div className="mb-6">
        <h1 className="font-display text-3xl text-ink mb-2">Start a Group Discussion</h1>
        <p className="text-ink-soft text-sm leading-relaxed">
          Two AI voices, one live conversation. They react to exactly what you say.
        </p>
      </div>

      {/* Persona intro strip — the two personas are the product's core hook,
          so they get a permanent presence right where a session begins. */}
      <div className="flex gap-3 mb-6">
        <div className="card-flat flex-1 p-3.5 flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-sage text-white flex items-center justify-center font-display font-semibold shrink-0">
            R
          </div>
          <div className="min-w-0">
            <p className="text-sm font-medium">Riya</p>
            <p className="text-xs text-ink-soft truncate">Empathetic peacemaker</p>
          </div>
        </div>
        <div className="card-flat flex-1 p-3.5 flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-apricot text-white flex items-center justify-center font-display font-semibold shrink-0">
            M
          </div>
          <div className="min-w-0">
            <p className="text-sm font-medium">Meera</p>
            <p className="text-xs text-ink-soft truncate">Confident contrarian</p>
          </div>
        </div>
      </div>

      <div className="card p-6 space-y-6">
        <div>
          <label className="eyebrow block mb-2.5">Category</label>
          <div className="flex flex-wrap gap-2">
            <button
              onClick={() => {
                setCategory("");
                setTopic("");
              }}
              className={`chip ${category === "" ? "chip-active" : ""}`}
            >
              Surprise me
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
          <div>
            <label className="eyebrow block mb-2.5">Topic</label>
            <div className="space-y-2 max-h-48 overflow-y-auto pr-1 scroll-thin">
              {(categories[category] || []).map((t) => (
                <button
                  key={t}
                  onClick={() => setTopic(t)}
                  className={`w-full text-left px-4 py-2.5 rounded-xl text-sm border transition ${
                    topic === t
                      ? "border-lavender bg-lavender-soft text-ink"
                      : "border-ink/10 hover:border-ink/20"
                  }`}
                >
                  {t}
                </button>
              ))}
            </div>
          </div>
        )}

        <div>
          <label className="eyebrow block mb-2.5">Difficulty</label>
          <div className="grid grid-cols-3 gap-1.5 sm:gap-2">
            {DIFFICULTIES.map((d) => (
              <button
                key={d.key}
                onClick={() => setDifficulty(d.key)}
                className={`chip min-w-0 px-1.5 sm:px-4 py-2 text-xs sm:text-sm text-center truncate ${
                  difficulty === d.key ? "chip-active" : ""
                }`}
              >
                {d.label}
              </button>
            ))}
          </div>
        </div>

        <div>
          <label className="eyebrow block mb-2.5">Duration</label>
          <div className="grid grid-cols-4 gap-2">
            {DURATIONS.map((d) => (
              <button
                key={d}
                onClick={() => setDuration(d)}
                className={`chip min-w-0 px-1.5 sm:px-4 text-center tabular-nums ${
                  duration === d ? "chip-active" : ""
                }`}
              >
                {d}m
              </button>
            ))}
          </div>
        </div>

        {error && <p className="text-sm text-rose-500 bg-rose-50 rounded-xl px-3 py-2">{error}</p>}

        <button onClick={handleStart} disabled={creating} className="btn-primary w-full">
          {creating ? "Setting up your session…" : "Start Group Discussion"}
        </button>
      </div>
    </div>
  );
}
