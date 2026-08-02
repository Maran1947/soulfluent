"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import { Sparkles, ArrowRight, ArrowLeft } from "lucide-react";
import { useAuth } from "@/lib/auth";
import { api, FeedbackReport } from "@/lib/api";
import ScoreGauge from "@/components/ScoreGauge";

const SUBSCORE_COLOR = [
  "bg-gradient-to-r from-indigo-500 to-indigo-600",
  "bg-gradient-to-r from-emerald-500 to-teal-500",
  "bg-gradient-to-r from-amber-500 to-orange-500",
  "bg-gradient-to-r from-purple-500 to-pink-500",
  "bg-gradient-to-r from-cyan-500 to-blue-500",
];

function MetricRow({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="flex items-center justify-between py-1.5 text-sm">
      <span className="text-slate-600 dark:text-slate-400">{label}</span>
      <span className="font-medium tabular-nums text-slate-900 dark:text-slate-100">{value}</span>
    </div>
  );
}

export default function ReportPage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const { user, loading } = useAuth();
  const [report, setReport] = useState<FeedbackReport | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!loading && !user) router.push("/login");
  }, [loading, user, router]);

  useEffect(() => {
    if (!id) return;
    api
      .getReport(id)
      .catch(() => api.endSession(id))
      .then((r) => r && setReport(r))
      .catch((e) => setError(e.message || "Could not load report"));
  }, [id]);

  if (loading || !user) return null;

  if (error) {
    return <p className="text-center text-sm text-rose-500 dark:text-rose-400 mt-12">{error}</p>;
  }

  if (!report) {
    return (
      <div className="flex flex-col items-center gap-3 mt-16">
        <div className="w-8 h-8 rounded-full border-2 border-lavender/30 border-t-lavender animate-spin" />
        <p className="text-sm text-slate-600 dark:text-slate-400">Generating your feedback report…</p>
      </div>
    );
  }

  const fm = report.fluency_metrics;
  const vm = report.vocabulary_metrics;
  const am = report.argument_metrics;

  return (
    <div className="py-4 space-y-6 pb-6">
      {/* User-friendly Top Action Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-slate-200/80 dark:border-slate-800/80">
        <div className="flex items-center gap-3">
          <button
            onClick={() => {
              if (typeof window !== "undefined" && window.history.length > 2) {
                router.back();
              } else {
                router.push("/history");
              }
            }}
            className="btn-secondary !py-2 !px-3.5 text-xs flex items-center gap-2 font-semibold text-slate-700 dark:text-slate-200 hover:text-slate-900 dark:hover:text-white border-slate-200/90 dark:border-slate-800 shadow-sm transition-all"
            aria-label="Go back"
          >
            <ArrowLeft size={14} />
            <span>Back to Sessions</span>
          </button>
          <span className="hidden sm:inline text-slate-300 dark:text-slate-700">|</span>
          <div className="hidden sm:block">
            <p className="eyebrow text-[10px]">Session Report</p>
            <h1 className="text-sm font-bold text-slate-900 dark:text-slate-100 truncate">Performance Breakdown</h1>
          </div>
        </div>

        <div className="flex items-center gap-2.5 self-start sm:self-auto">
          <Link href="/history" className="btn-secondary !py-2 !px-4 text-xs font-semibold">
            All History
          </Link>
          <Link href="/" className="btn-primary !py-2 !px-4 text-xs font-semibold shadow-sm">
            + Start New Session
          </Link>
        </div>
      </div>

      {/* Main Title & Topic Card */}
      <div className="space-y-1">
        <p className="eyebrow text-slate-500 dark:text-slate-400">Feedback Summary</p>
        <h1 className="font-display text-2xl sm:text-3xl text-slate-900 dark:text-slate-100 font-semibold tracking-tight">
          Performance Analysis
        </h1>
      </div>

      {/* Main Score Hero Banner */}
      <div className="card p-6 sm:p-8 flex flex-col md:flex-row items-center gap-8 border-slate-200/80 dark:border-slate-800/80 shadow-md">
        <ScoreGauge score={report.overall_score} label="Overall Score" />

        <div className="flex-1 w-full space-y-4">
          <h3 className="eyebrow">Detailed Competency Scores</h3>
          <div className="space-y-3">
            {Object.entries(report.sub_scores).map(([key, val], i) => (
              <div key={key} className="flex items-center gap-4">
                <span className="w-28 sm:w-36 shrink-0 text-xs font-semibold text-slate-700 dark:text-slate-300 capitalize leading-tight">
                  {key.replace(/_/g, " ")}
                </span>
                <div className="flex-1 h-3 rounded-full bg-slate-100 dark:bg-slate-800 overflow-hidden p-0.5 border border-slate-200/50 dark:border-slate-700/50">
                  <div
                    className={`h-full rounded-full ${SUBSCORE_COLOR[i % SUBSCORE_COLOR.length]} transition-all duration-500`}
                    style={{ width: `${Math.max(0, Math.min(100, val))}%` }}
                  />
                </div>
                <span className="w-8 shrink-0 text-right text-sm font-bold tabular-nums text-slate-900 dark:text-slate-100">
                  {Math.round(val)}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Metric Breakdown Grid: 3 columns on sm+ */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">
        <div className="card p-5 border-slate-200/80 dark:border-slate-800/80">
          <h3 className="font-semibold text-slate-900 dark:text-slate-100 text-sm mb-3 pb-2 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
            <span>Fluency</span>
            <span className="w-2 h-2 rounded-full bg-lavender" />
          </h3>
          <MetricRow label="Words / Min" value={fm.words_per_minute} />
          <MetricRow label="Filler Words" value={fm.filler_word_count} />
          <MetricRow label="Sentence Completion" value={`${Math.round(fm.sentence_completion_rate * 100)}%`} />
          <MetricRow label="Avg. Sentence Length" value={fm.average_sentence_length} />
        </div>

        <div className="card p-5 border-slate-200/80 dark:border-slate-800/80">
          <h3 className="font-semibold text-slate-900 dark:text-slate-100 text-sm mb-3 pb-2 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
            <span>Vocabulary</span>
            <span className="w-2 h-2 rounded-full bg-sage" />
          </h3>
          <MetricRow label="Richness Score" value={`${Math.round(vm.vocabulary_richness_score * 100)}%`} />
          <MetricRow label="Grammar Issues" value={vm.grammar_errors?.length ?? 0} />
          <MetricRow label="Repeated Phrases" value={vm.repeated_phrases?.length ?? 0} />
        </div>

        <div className="card p-5 border-slate-200/80 dark:border-slate-800/80">
          <h3 className="font-semibold text-slate-900 dark:text-slate-100 text-sm mb-3 pb-2 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
            <span>Argument Quality</span>
            <span className="w-2 h-2 rounded-full bg-apricot" />
          </h3>
          <MetricRow label="Points Made" value={am.distinct_points_made} />
          <MetricRow label="Points Defended" value={am.points_successfully_defended} />
          <MetricRow label="Talk Time Share" value={`${am.talk_time_percentage}%`} />
          <MetricRow label="Relevance" value={`${Math.round(am.relevance_score * 100)}%`} />
        </div>
      </div>

      {vm.phrases_to_avoid?.length > 0 && (
        <div className="card p-6 border-slate-200/80 dark:border-slate-800/80">
          <h3 className="font-semibold text-slate-900 dark:text-slate-100 text-sm mb-4">Phrases to Swap Out</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {vm.phrases_to_avoid.map((phrase: string, i: number) => (
              <div key={i} className="card-flat p-3 flex items-center gap-3 text-xs bg-slate-50/70 dark:bg-slate-900/60 border-slate-200 dark:border-slate-800">
                <span className="line-through text-slate-400 dark:text-slate-500 font-medium">{phrase}</span>
                <ArrowRight size={14} className="text-indigo-500 shrink-0" />
                <span className="font-semibold text-slate-900 dark:text-slate-100">{vm.replacement_suggestions?.[i]}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Best Moments & Focus Areas Side-by-Side */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
        <div className="card p-6 border-emerald-200/80 dark:border-emerald-900/40 bg-emerald-50/30 dark:bg-emerald-950/20">
          <h3 className="font-semibold text-slate-900 dark:text-slate-100 text-sm mb-3 flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-emerald-500" /> Best Moments
          </h3>
          <ul className="space-y-2.5 text-xs text-slate-700 dark:text-slate-300">
            {report.highlight_reel.best_moments?.map((m, i) => (
              <li key={i} className="pl-3 border-l-2 border-emerald-400 dark:border-emerald-500 font-medium leading-relaxed">
                {m}
              </li>
            ))}
          </ul>
        </div>

        <div className="card p-6 border-amber-200/80 dark:border-amber-900/40 bg-amber-50/30 dark:bg-amber-950/20">
          <h3 className="font-semibold text-slate-900 dark:text-slate-100 text-sm mb-3 flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-amber-500" /> Focus Areas
          </h3>
          <ul className="space-y-2.5 text-xs text-slate-700 dark:text-slate-300">
            {report.highlight_reel.improvement_areas?.map((m, i) => (
              <li key={i} className="pl-3 border-l-2 border-amber-400 dark:border-amber-500 font-medium leading-relaxed">
                {m}
              </li>
            ))}
          </ul>
        </div>
      </div>

      {/* Recommendation Card */}
      <div className="card p-6 bg-gradient-to-r from-indigo-50 to-purple-50 dark:from-indigo-950/40 dark:to-slate-900/60 border-indigo-100 dark:border-slate-800">
        <h3 className="font-semibold text-slate-900 dark:text-slate-100 text-sm mb-2 flex items-center gap-2">
          <Sparkles size={16} className="text-indigo-600 dark:text-indigo-400" /> AI Recommendation for Next Session
        </h3>
        <p className="text-xs sm:text-sm text-slate-700 dark:text-slate-300 leading-relaxed font-medium">{report.recommendation}</p>
      </div>

      <p className="text-center text-xs text-slate-400 dark:text-slate-500 font-mono">
        {report.total_tokens.toLocaleString()} tokens processed · ${report.total_cost_usd.toFixed(4)} estimated cost
      </p>
    </div>
  );
}
