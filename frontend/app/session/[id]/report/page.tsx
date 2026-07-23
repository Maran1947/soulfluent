"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import { Sparkles, ArrowRight } from "lucide-react";
import { useAuth } from "@/lib/auth";
import { api, FeedbackReport } from "@/lib/api";
import ScoreGauge from "@/components/ScoreGauge";

// Sub-score keys get a persona-ish color so the report visually rhymes with
// the transcript the person just came from, rather than defaulting to one
// flat accent for every bar.
const SUBSCORE_COLOR = ["bg-lavender", "bg-sage", "bg-apricot", "bg-lavender-deep", "bg-sage-deep", "bg-apricot-deep"];

function MetricRow({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="flex items-center justify-between py-1.5 text-sm">
      <span className="text-ink-soft">{label}</span>
      <span className="font-medium tabular-nums">{value}</span>
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
    return <p className="text-center text-sm text-rose-500 mt-12">{error}</p>;
  }

  if (!report) {
    return (
      <div className="flex flex-col items-center gap-3 mt-16">
        <div className="w-8 h-8 rounded-full border-2 border-lavender/30 border-t-lavender animate-spin" />
        <p className="text-sm text-ink-soft">Generating your feedback report…</p>
      </div>
    );
  }

  const fm = report.fluency_metrics;
  const vm = report.vocabulary_metrics;
  const am = report.argument_metrics;

  return (
    <div className="max-w-3xl mx-auto space-y-5 pb-4">
      <div className="flex items-center justify-between">
        <div>
          <p className="eyebrow mb-1">Session report</p>
          <h1 className="font-display text-2xl text-ink">How it went</h1>
        </div>
        <Link href="/" className="btn-secondary !py-2 !px-4 text-xs shrink-0">
          New session
        </Link>
      </div>

      <div className="card p-5 sm:p-6 flex flex-col sm:flex-row items-center gap-6 sm:gap-8 motion-safe:animate-rise">
        <ScoreGauge score={report.overall_score} label="Overall score" />
        {/* A row-list (label · bar · value) rather than a wrapping grid — each
            row is self-contained, so a long label like "Argument Quality"
            wrapping to two lines can never push a sibling's bar out of line. */}
        <div className="flex-1 w-full space-y-3">
          {Object.entries(report.sub_scores).map(([key, val], i) => (
            <div key={key} className="flex items-center gap-3">
              <span className="w-24 sm:w-32 shrink-0 text-xs text-ink-soft capitalize leading-tight">
                {key.replace(/_/g, " ")}
              </span>
              <div className="flex-1 h-2 rounded-full bg-ink/5 overflow-hidden">
                <div
                  className={`h-full rounded-full ${SUBSCORE_COLOR[i % SUBSCORE_COLOR.length]}`}
                  style={{ width: `${Math.max(0, Math.min(100, val))}%` }}
                />
              </div>
              <span className="w-7 shrink-0 text-right text-sm font-medium tabular-nums">
                {Math.round(val)}
              </span>
            </div>
          ))}
        </div>
      </div>

      <div className="grid sm:grid-cols-3 gap-4">
        <div className="card p-5">
          <h3 className="font-medium mb-2 text-sm">Fluency</h3>
          <MetricRow label="Words per minute" value={fm.words_per_minute} />
          <MetricRow label="Filler words" value={fm.filler_word_count} />
          <MetricRow label="Sentence completion" value={`${Math.round(fm.sentence_completion_rate * 100)}%`} />
          <MetricRow label="Avg. sentence length" value={fm.average_sentence_length} />
        </div>
        <div className="card p-5">
          <h3 className="font-medium mb-2 text-sm">Vocabulary</h3>
          <MetricRow
            label="Richness score"
            value={`${Math.round(vm.vocabulary_richness_score * 100)}%`}
          />
          <MetricRow label="Grammar issues" value={vm.grammar_errors?.length ?? 0} />
          <MetricRow label="Repeated phrases" value={vm.repeated_phrases?.length ?? 0} />
        </div>
        <div className="card p-5">
          <h3 className="font-medium mb-2 text-sm">Argument Quality</h3>
          <MetricRow label="Points made" value={am.distinct_points_made} />
          <MetricRow label="Points defended" value={am.points_successfully_defended} />
          <MetricRow label="Talk time" value={`${am.talk_time_percentage}%`} />
          <MetricRow label="Relevance" value={`${Math.round(am.relevance_score * 100)}%`} />
        </div>
      </div>

      {vm.phrases_to_avoid?.length > 0 && (
        <div className="card p-5">
          <h3 className="font-medium mb-3 text-sm">Phrases to swap out</h3>
          <div className="space-y-2.5">
            {vm.phrases_to_avoid.map((phrase: string, i: number) => (
              <div key={i} className="flex items-center gap-3 text-sm flex-wrap">
                <span className="line-through text-ink-soft/70">{phrase}</span>
                <ArrowRight size={14} className="text-lavender shrink-0" />
                <span className="font-medium">{vm.replacement_suggestions?.[i]}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="grid sm:grid-cols-2 gap-4">
        <div className="card p-5">
          <h3 className="font-medium mb-2.5 text-sm flex items-center gap-1.5">
            <span className="w-1.5 h-1.5 rounded-full bg-sage" /> Best moments
          </h3>
          <ul className="space-y-2 text-sm text-ink-soft">
            {report.highlight_reel.best_moments?.map((m, i) => (
              <li key={i} className="pl-3 border-l-2 border-sage/40">
                {m}
              </li>
            ))}
          </ul>
        </div>
        <div className="card p-5">
          <h3 className="font-medium mb-2.5 text-sm flex items-center gap-1.5">
            <span className="w-1.5 h-1.5 rounded-full bg-apricot" /> Focus areas
          </h3>
          <ul className="space-y-2 text-sm text-ink-soft">
            {report.highlight_reel.improvement_areas?.map((m, i) => (
              <li key={i} className="pl-3 border-l-2 border-apricot/40">
                {m}
              </li>
            ))}
          </ul>
        </div>
      </div>

      <div className="card p-5 bg-lavender-soft/60 border-lavender/20">
        <h3 className="font-medium mb-1.5 text-sm flex items-center gap-1.5">
          <Sparkles size={14} className="text-lavender-deep" /> What to practice next
        </h3>
        <p className="text-sm text-ink-soft leading-relaxed">{report.recommendation}</p>
      </div>

      <p className="text-center text-xs text-ink-soft/50">
        {report.total_tokens.toLocaleString()} tokens · ${report.total_cost_usd.toFixed(4)} this session
      </p>
    </div>
  );
}
