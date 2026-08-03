"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import {
  Sparkles,
  ArrowRight,
  ArrowLeft,
  Trophy,
  Target,
  Zap,
  BookOpen,
  MessageSquare,
  BarChart3,
  CheckCircle2,
  AlertCircle,
  Clock,
  TrendingUp,
  Award,
} from "lucide-react";
import { useAuth } from "@/lib/auth";
import { api, FeedbackReport } from "@/lib/api";
import ScoreGauge from "@/components/ScoreGauge";

const SUBSCORE_CONFIG: Record<
  string,
  { label: string; color: string; bg: string; icon: any }
> = {
  fluency: {
    label: "Speech Fluency",
    color: "from-amber-500 to-[#F25C40]",
    bg: "bg-[#F25C40]",
    icon: Zap,
  },
  vocabulary: {
    label: "Vocabulary Richness",
    color: "from-indigo-500 to-purple-600",
    bg: "bg-indigo-500",
    icon: BookOpen,
  },
  argument_quality: {
    label: "Argument Structure",
    color: "from-emerald-500 to-teal-600",
    bg: "bg-emerald-500",
    icon: BarChart3,
  },
  listening_responsiveness: {
    label: "Listening & Rebuttals",
    color: "from-cyan-500 to-blue-600",
    bg: "bg-cyan-500",
    icon: MessageSquare,
  },
};

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
    return (
      <div className="max-w-xl mx-auto my-12 p-6 bg-red-500/10 border border-red-500/30 rounded-2xl text-center space-y-3">
        <AlertCircle size={28} className="mx-auto text-red-500" />
        <p className="text-sm font-semibold text-red-500">{error}</p>
        <Link
          href="/"
          className="inline-flex items-center gap-1.5 px-4 py-2 bg-red-500 text-white rounded-xl text-xs font-bold"
        >
          Return Home
        </Link>
      </div>
    );
  }

  if (!report) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] gap-4">
        <div className="w-12 h-12 rounded-2xl border-4 border-[#F25C40]/20 border-t-[#F25C40] animate-spin" />
        <div className="text-center space-y-1">
          <p className="text-sm font-extrabold text-slate-900 dark:text-white">
            Analyzing Session Performance...
          </p>
          <p className="text-xs text-slate-500 dark:text-slate-400">
            Evaluating fluency, WPM, filler words & argument strength
          </p>
        </div>
      </div>
    );
  }

  const fm = report.fluency_metrics || {};
  const vm = report.vocabulary_metrics || {};
  const am = report.argument_metrics || {};

  const scoreTier =
    report.overall_score >= 80
      ? { title: "Outstanding Fluency", color: "text-emerald-500", bg: "bg-emerald-500/10 border-emerald-500/30" }
      : report.overall_score >= 60
      ? { title: "Solid Speaking Performance", color: "text-[#F25C40]", bg: "bg-[#F25C40]/10 border-[#F25C40]/30" }
      : { title: "Building Confidence", color: "text-amber-500", bg: "bg-amber-500/10 border-amber-500/30" };

  return (
    <div className="max-w-5xl mx-auto py-6 space-y-8 pb-12">
      {/* Top Action Header */}
      <div className="flex flex-wrap items-center justify-between gap-4 pb-4 border-b border-slate-200/80 dark:border-rose-900/30">
        <div className="flex items-center gap-3">
          <button
            onClick={() => router.push("/history")}
            className="px-3.5 py-2 rounded-xl border border-slate-200 dark:border-slate-800 text-xs font-bold text-slate-700 dark:text-slate-300 hover:bg-slate-100 flex items-center gap-1.5 transition-all"
          >
            <ArrowLeft size={14} />
            <span>Back to History</span>
          </button>
          <div className="hidden sm:block">
            <span className="text-[10px] font-bold tracking-wider text-[#F25C40] uppercase">
              Live Session Analysis
            </span>
            <h1 className="text-sm font-extrabold text-slate-900 dark:text-white">
              Speaking Performance Report
            </h1>
          </div>
        </div>

        <div className="flex items-center gap-2.5">
          <Link
            href="/"
            className="px-4 py-2 bg-gradient-to-r from-[#FA5A3A] to-[#F25C40] text-white text-xs font-extrabold rounded-xl shadow-md shadow-[#F25C40]/25 hover:shadow-lg flex items-center gap-1.5 transition-all"
          >
            <span>+ Start Next Session</span>
            <ArrowRight size={14} />
          </Link>
        </div>
      </div>

      {/* HERO VISUAL SCORE BOARD */}
      <div className="bg-white/80 dark:bg-[#181d29]/90 backdrop-blur-xl border border-slate-200/80 dark:border-rose-900/40 rounded-3xl p-6 sm:p-8 shadow-sm flex flex-col md:flex-row items-center gap-8 relative overflow-hidden">
        {/* Radial Score Gauge Visual */}
        <div className="flex flex-col items-center justify-center shrink-0 p-4 bg-slate-50/70 dark:bg-slate-900/50 rounded-2xl border border-slate-200/60 dark:border-slate-800">
          <ScoreGauge score={report.overall_score} label="Overall Score" />
          <div className={`mt-3 px-3 py-1 rounded-full border text-xs font-extrabold ${scoreTier.bg} ${scoreTier.color}`}>
            {scoreTier.title}
          </div>
        </div>

        {/* Competency Skill Bar Visuals */}
        <div className="flex-1 w-full space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-xs font-bold tracking-wider text-[#F25C40] uppercase flex items-center gap-1.5">
              <Award size={15} />
              <span>Core Competency Breakdown</span>
            </h3>
            <span className="text-[11px] text-slate-400 font-medium">0 - 100 Scale</span>
          </div>

          <div className="space-y-3.5">
            {Object.entries(report.sub_scores).map(([key, val]) => {
              const cfg = SUBSCORE_CONFIG[key] || {
                label: key.replace(/_/g, " "),
                color: "from-indigo-500 to-[#F25C40]",
                bg: "bg-[#F25C40]",
                icon: BarChart3,
              };
              const Icon = cfg.icon;
              const roundedVal = Math.round(val);

              return (
                <div key={key} className="space-y-1">
                  <div className="flex items-center justify-between text-xs">
                    <div className="flex items-center gap-2 font-bold text-slate-900 dark:text-white capitalize">
                      <div className={`p-1 rounded-md bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300`}>
                        <Icon size={13} />
                      </div>
                      <span>{cfg.label}</span>
                    </div>
                    <span className="font-extrabold tabular-nums text-slate-900 dark:text-white text-sm">
                      {roundedVal} / 100
                    </span>
                  </div>

                  {/* Gradient Visual Progress Bar */}
                  <div className="h-3 rounded-full bg-slate-100 dark:bg-slate-800/80 overflow-hidden p-0.5 border border-slate-200/50 dark:border-slate-800">
                    <div
                      className={`h-full rounded-full bg-gradient-to-r ${cfg.color} transition-all duration-700`}
                      style={{ width: `${Math.max(5, Math.min(100, val))}%` }}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* METRIC VISUAL BREAKDOWN GRID */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        
        {/* 1. FLUENCY VISUAL CARD */}
        <div className="bg-white/80 dark:bg-[#181d29]/90 backdrop-blur-xl border border-slate-200/80 dark:border-rose-900/40 rounded-2xl p-5 shadow-xs space-y-4">
          <div className="flex items-center justify-between pb-3 border-b border-slate-100 dark:border-slate-800">
            <div className="flex items-center gap-2">
              <div className="p-2 rounded-xl bg-amber-500/10 text-amber-500 font-bold">
                <Zap size={16} />
              </div>
              <h3 className="text-sm font-extrabold text-slate-900 dark:text-white">
                Speech Pace & Fluency
              </h3>
            </div>
            <span className="text-xs font-extrabold text-amber-500">
              {fm.words_per_minute || 0} WPM
            </span>
          </div>

          <div className="space-y-3 text-xs">
            <div className="flex items-center justify-between py-1 border-b border-slate-100 dark:border-slate-800/50">
              <span className="text-slate-500 dark:text-slate-400">Words / Minute</span>
              <span className="font-extrabold text-slate-900 dark:text-white">
                {fm.words_per_minute || 0} (Target: 120-150)
              </span>
            </div>

            <div className="flex items-center justify-between py-1 border-b border-slate-100 dark:border-slate-800/50">
              <span className="text-slate-500 dark:text-slate-400">Filler Words</span>
              <span className={`px-2 py-0.5 rounded-md font-bold text-[11px] ${
                (fm.filler_word_count || 0) <= 2
                  ? "bg-emerald-500/10 text-emerald-500"
                  : "bg-amber-500/10 text-amber-500"
              }`}>
                {fm.filler_word_count || 0} used
              </span>
            </div>

            <div className="flex items-center justify-between py-1 border-b border-slate-100 dark:border-slate-800/50">
              <span className="text-slate-500 dark:text-slate-400">Sentence Completion</span>
              <span className="font-extrabold text-slate-900 dark:text-white">
                {Math.round((fm.sentence_completion_rate || 0.9) * 100)}%
              </span>
            </div>

            <div className="flex items-center justify-between py-1">
              <span className="text-slate-500 dark:text-slate-400">Avg Sentence Length</span>
              <span className="font-extrabold text-slate-900 dark:text-white">
                {fm.average_sentence_length || 12} words
              </span>
            </div>
          </div>
        </div>

        {/* 2. VOCABULARY VISUAL CARD */}
        <div className="bg-white/80 dark:bg-[#181d29]/90 backdrop-blur-xl border border-slate-200/80 dark:border-rose-900/40 rounded-2xl p-5 shadow-xs space-y-4">
          <div className="flex items-center justify-between pb-3 border-b border-slate-100 dark:border-slate-800">
            <div className="flex items-center gap-2">
              <div className="p-2 rounded-xl bg-indigo-500/10 text-indigo-500 font-bold">
                <BookOpen size={16} />
              </div>
              <h3 className="text-sm font-extrabold text-slate-900 dark:text-white">
                Vocabulary & Syntax
              </h3>
            </div>
            <span className="text-xs font-extrabold text-indigo-500">
              {Math.round((vm.vocabulary_richness_score || 0.8) * 100)}% Richness
            </span>
          </div>

          <div className="space-y-3 text-xs">
            <div className="flex items-center justify-between py-1 border-b border-slate-100 dark:border-slate-800/50">
              <span className="text-slate-500 dark:text-slate-400">Richness Score</span>
              <span className="font-extrabold text-slate-900 dark:text-white">
                {Math.round((vm.vocabulary_richness_score || 0.8) * 100)}%
              </span>
            </div>

            <div className="flex items-center justify-between py-1 border-b border-slate-100 dark:border-slate-800/50">
              <span className="text-slate-500 dark:text-slate-400">Grammar Issues</span>
              <span className="font-extrabold text-slate-900 dark:text-white">
                {vm.grammar_errors?.length || 0} flagged
              </span>
            </div>

            <div className="flex items-center justify-between py-1">
              <span className="text-slate-500 dark:text-slate-400">Repeated Expressions</span>
              <span className="font-extrabold text-slate-900 dark:text-white">
                {vm.repeated_phrases?.length || 0} detected
              </span>
            </div>
          </div>
        </div>

        {/* 3. ARGUMENT QUALITY VISUAL CARD */}
        <div className="bg-white/80 dark:bg-[#181d29]/90 backdrop-blur-xl border border-slate-200/80 dark:border-rose-900/40 rounded-2xl p-5 shadow-xs space-y-4">
          <div className="flex items-center justify-between pb-3 border-b border-slate-100 dark:border-slate-800">
            <div className="flex items-center gap-2">
              <div className="p-2 rounded-xl bg-emerald-500/10 text-emerald-500 font-bold">
                <BarChart3 size={16} />
              </div>
              <h3 className="text-sm font-extrabold text-slate-900 dark:text-white">
                Argument & Logic
              </h3>
            </div>
            <span className="text-xs font-extrabold text-emerald-500">
              {Math.round((am.relevance_score || 0.85) * 100)}% Relevance
            </span>
          </div>

          <div className="space-y-3 text-xs">
            <div className="flex items-center justify-between py-1 border-b border-slate-100 dark:border-slate-800/50">
              <span className="text-slate-500 dark:text-slate-400">Points Made</span>
              <span className="font-extrabold text-slate-900 dark:text-white">
                {am.distinct_points_made || 0} arguments
              </span>
            </div>

            <div className="flex items-center justify-between py-1 border-b border-slate-100 dark:border-slate-800/50">
              <span className="text-slate-500 dark:text-slate-400">Points Defended</span>
              <span className="font-extrabold text-slate-900 dark:text-white">
                {am.points_successfully_defended || 0} defended
              </span>
            </div>

            <div className="flex items-center justify-between py-1">
              <span className="text-slate-500 dark:text-slate-400">Talk Time Share</span>
              <span className="font-extrabold text-[#F25C40]">
                {am.talk_time_percentage || 50}% of discussion
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* VISUAL PHRASE SWAP CARDS */}
      {vm.phrases_to_avoid && vm.phrases_to_avoid.length > 0 && (
        <div className="bg-white/80 dark:bg-[#181d29]/90 backdrop-blur-xl border border-slate-200/80 dark:border-rose-900/40 rounded-3xl p-6 shadow-sm space-y-4">
          <h3 className="text-xs font-bold tracking-wider text-[#F25C40] uppercase flex items-center gap-2">
            <Sparkles size={14} />
            <span>Vocabulary Upgrades & Professional Swaps</span>
          </h3>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
            {vm.phrases_to_avoid.map((phrase: string, i: number) => (
              <div
                key={i}
                className="p-3.5 rounded-2xl bg-slate-50 dark:bg-slate-900/50 border border-slate-200/70 dark:border-slate-800 flex items-center justify-between gap-3 text-xs"
              >
                <div className="flex items-center gap-2 min-w-0">
                  <span className="px-2 py-0.5 rounded-md bg-red-500/10 text-red-500 font-semibold line-through truncate">
                    {phrase}
                  </span>
                </div>
                <ArrowRight size={14} className="text-[#F25C40] shrink-0" />
                <div className="flex items-center gap-1.5 font-extrabold text-slate-900 dark:text-white shrink-0">
                  <span className="px-2 py-0.5 rounded-md bg-emerald-500/10 text-emerald-500">
                    {vm.replacement_suggestions?.[i] || "Stronger expression"}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* BEST MOMENTS & FOCUS AREAS SIDE-BY-SIDE */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
        {/* Best Moments */}
        <div className="bg-emerald-500/5 dark:bg-emerald-950/20 border border-emerald-500/30 rounded-3xl p-6 shadow-xs space-y-3.5">
          <div className="flex items-center gap-2 text-emerald-500 font-extrabold text-sm">
            <Trophy size={18} />
            <span>Key Strengths & Highlights</span>
          </div>

          <ul className="space-y-2.5 text-xs text-slate-700 dark:text-slate-300">
            {report.highlight_reel?.best_moments?.map((m, i) => (
              <li key={i} className="flex items-start gap-2.5 leading-relaxed">
                <CheckCircle2 size={15} className="text-emerald-500 shrink-0 mt-0.5" />
                <span className="font-semibold">{m}</span>
              </li>
            ))}
          </ul>
        </div>

        {/* Focus Areas */}
        <div className="bg-amber-500/5 dark:bg-amber-950/20 border border-amber-500/30 rounded-3xl p-6 shadow-xs space-y-3.5">
          <div className="flex items-center gap-2 text-amber-500 font-extrabold text-sm">
            <Target size={18} />
            <span>Growth & Target Focus Areas</span>
          </div>

          <ul className="space-y-2.5 text-xs text-slate-700 dark:text-slate-300">
            {report.highlight_reel?.improvement_areas?.map((m, i) => (
              <li key={i} className="flex items-start gap-2.5 leading-relaxed">
                <AlertCircle size={15} className="text-amber-500 shrink-0 mt-0.5" />
                <span className="font-semibold">{m}</span>
              </li>
            ))}
          </ul>
        </div>
      </div>

      {/* AI RECOMMENDATION BANNER */}
      <div className="bg-gradient-to-r from-[#FA5A3A]/10 via-[#F25C40]/10 to-purple-500/10 border border-[#F25C40]/30 rounded-3xl p-6 shadow-sm flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div className="space-y-1 max-w-2xl">
          <div className="flex items-center gap-2 text-[#F25C40] font-extrabold text-xs">
            <Sparkles size={16} />
            <span>AI Recommendation for Next Session</span>
          </div>
          <p className="text-xs sm:text-sm text-slate-800 dark:text-slate-200 font-semibold leading-relaxed">
            {report.recommendation}
          </p>
        </div>

        <Link
          href="/"
          className="px-5 py-3 bg-[#F25C40] text-white font-extrabold text-xs rounded-xl shadow-md shadow-[#F25C40]/25 hover:bg-[#FA5A3A] shrink-0 transition-all"
        >
          Practice Next Room →
        </Link>
      </div>

      {/* Token Usage Footer */}
      <p className="text-center text-[11px] text-slate-400 dark:text-slate-500 font-mono">
        {report.total_tokens?.toLocaleString() || 0} tokens processed · ${report.total_cost_usd?.toFixed(4) || "0.0000"} estimated cost
      </p>
    </div>
  );
}
