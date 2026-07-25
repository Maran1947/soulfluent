"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { MessagesSquare, Clock } from "lucide-react";
import { useAuth } from "@/lib/auth";
import { api, GDSession } from "@/lib/api";

const STATUS_STYLE: Record<string, string> = {
  active: "bg-lavender-soft text-lavender-deep",
  completed: "bg-sage-soft text-sage-deep",
  abandoned: "bg-ink/5 text-ink-soft",
};

function timeAgo(iso: string): string {
  const diffMs = Date.now() - new Date(iso).getTime();
  const mins = Math.floor(diffMs / 60000);
  if (mins < 1) return "just now";
  if (mins < 60) return `${mins}m ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d ago`;
  return new Date(iso).toLocaleDateString();
}

export default function HistoryPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [sessions, setSessions] = useState<GDSession[]>([]);
  const [loadingSessions, setLoadingSessions] = useState(true);

  useEffect(() => {
    if (!loading && !user) router.push("/login");
  }, [loading, user, router]);

  useEffect(() => {
    api
      .listSessions()
      .then(setSessions)
      .finally(() => setLoadingSessions(false));
  }, []);

  if (loading || !user) return null;

  return (
    <div className="py-4">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="font-display text-3xl text-ink font-semibold tracking-tight mb-1">Your Session History</h1>
          <p className="text-sm text-slate-600">Review past conversations, transcripts, and AI fluency reports.</p>
        </div>
        <Link href="/" className="btn-primary !py-2.5 !px-5 text-xs sm:text-sm self-start sm:self-auto shrink-0 shadow-sm">
          + Start New Session
        </Link>
      </div>

      {loadingSessions ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {[0, 1, 2, 3, 4, 5].map((i) => (
            <div key={i} className="card h-40 animate-pulse bg-slate-100/60 border-slate-200/60" />
          ))}
        </div>
      ) : sessions.length === 0 ? (
        <div className="card p-12 flex flex-col items-center text-center max-w-lg mx-auto">
          <div className="w-16 h-16 rounded-full bg-indigo-50 flex items-center justify-center mb-4">
            <MessagesSquare size={26} className="text-lavender" />
          </div>
          <h2 className="text-base font-semibold text-slate-900 mb-1">No practice sessions yet</h2>
          <p className="text-sm text-slate-500 mb-6 max-w-xs">
            Start your first AI Group Discussion to build fluency and track your progress over time.
          </p>
          <Link href="/" className="btn-primary">
            Start your first session →
          </Link>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {sessions.map((s) => (
            <Link
              key={s.id}
              href={s.status === "active" ? `/session/${s.id}` : `/session/${s.id}/report`}
              className="card p-5 flex flex-col justify-between hover:shadow-card-hover hover:-translate-y-0.5 transition-all duration-200 group"
            >
              <div>
                <div className="flex items-center justify-between gap-2 mb-3">
                  <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">
                    {s.category.replace(/_/g, " ")}
                  </span>
                  <span
                    className={`text-[11px] font-semibold px-2.5 py-0.5 rounded-full capitalize ${
                      STATUS_STYLE[s.status] || STATUS_STYLE.abandoned
                    }`}
                  >
                    {s.status}
                  </span>
                </div>
                <h3 className="font-semibold text-slate-900 text-base leading-snug group-hover:text-lavender transition-colors line-clamp-2 mb-4">
                  {s.topic}
                </h3>
              </div>

              <div className="pt-3 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500">
                <div className="flex items-center gap-3">
                  <span className="capitalize font-medium text-slate-700">{s.difficulty}</span>
                  <span aria-hidden>·</span>
                  <span className="inline-flex items-center gap-1 font-medium">
                    <Clock size={12} className="text-slate-400" /> {s.duration_minutes}m
                  </span>
                </div>
                <span>{timeAgo(s.started_at)}</span>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
