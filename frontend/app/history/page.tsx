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
    <div className="max-w-3xl mx-auto">
      <div className="mb-6">
        <h1 className="font-display text-2xl text-ink mb-1">Your sessions</h1>
        <p className="text-sm text-ink-soft">Every conversation you've practiced, in one place.</p>
      </div>

      {loadingSessions ? (
        <div className="space-y-3">
          {[0, 1, 2].map((i) => (
            <div key={i} className="card-flat h-[68px] animate-pulse" />
          ))}
        </div>
      ) : sessions.length === 0 ? (
        <div className="card p-8 flex flex-col items-center text-center">
          <div className="w-14 h-14 rounded-full bg-lavender-soft flex items-center justify-center mb-4">
            <MessagesSquare size={22} className="text-lavender-deep" />
          </div>
          <p className="text-sm font-medium mb-1">No sessions yet</p>
          <p className="text-sm text-ink-soft mb-5">
            Your first Group Discussion is one tap away.
          </p>
          <Link href="/" className="btn-primary">
            Start your first session
          </Link>
        </div>
      ) : (
        <div className="space-y-3">
          {sessions.map((s) => (
            <Link
              key={s.id}
              href={s.status === "active" ? `/session/${s.id}` : `/session/${s.id}/report`}
              className="card p-4 flex items-center justify-between gap-4 hover:shadow-glow-lavender transition block"
            >
              <div className="min-w-0">
                <p className="font-medium text-sm truncate">{s.topic}</p>
                <p className="text-xs text-ink-soft mt-1 flex items-center gap-1.5 flex-wrap">
                  <span className="capitalize">{s.category.replace(/_/g, " ")}</span>
                  <span aria-hidden>·</span>
                  <span className="capitalize">{s.difficulty}</span>
                  <span aria-hidden>·</span>
                  <span className="inline-flex items-center gap-1">
                    <Clock size={11} /> {s.duration_minutes}m
                  </span>
                  <span aria-hidden>·</span>
                  <span>{timeAgo(s.started_at)}</span>
                </p>
              </div>
              <span
                className={`shrink-0 text-xs font-medium px-2.5 py-1 rounded-full capitalize ${
                  STATUS_STYLE[s.status] || STATUS_STYLE.abandoned
                }`}
              >
                {s.status}
              </span>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
