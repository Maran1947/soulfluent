"use client";

import { useEffect, useState } from "react";
import { X, DollarSign, MessageSquare, BarChart2, Volume2 } from "lucide-react";
import { fetchSessionDetail, SessionDetail } from "@/lib/api";

interface Props {
  sessionId: string;
  onClose: () => void;
}

export default function SessionDetailModal({ sessionId, onClose }: Props) {
  const [detail, setDetail] = useState<SessionDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<"transcript" | "cost" | "report">("transcript");

  useEffect(() => {
    async function load() {
      setLoading(true);
      const res = await fetchSessionDetail(sessionId);
      setDetail(res);
      setLoading(false);
    }
    load();
  }, [sessionId]);

  return (
    <div className="fixed inset-0 z-50 bg-slate-900/80 dark:bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 overflow-y-auto">
      <div className="glass-panel w-full max-w-4xl rounded-2xl border border-slate-200 dark:border-slate-800 shadow-2xl overflow-hidden flex flex-col max-h-[90vh] bg-white dark:bg-[#1e293b]">
        {/* Header */}
        <div className="px-6 py-4 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between bg-slate-50 dark:bg-slate-900">
          <div>
            <div className="flex items-center gap-2">
              <span className="px-2.5 py-0.5 text-xs font-bold uppercase rounded-full bg-[#f25c40]/10 text-[#f25c40] border border-[#f25c40]/30">
                {detail?.session.mode || "Session"}
              </span>
              <span className={`px-2.5 py-0.5 text-xs font-bold rounded-full border ${
                detail?.session.status === "completed"
                  ? "bg-emerald-500/10 text-emerald-700 dark:text-emerald-400 border-emerald-500/30"
                  : "bg-amber-500/10 text-amber-700 dark:text-amber-400 border-amber-500/30"
              }`}>
                {detail?.session.status}
              </span>
            </div>
            <h2 className="text-lg font-extrabold text-slate-900 dark:text-white mt-1">{detail?.session.topic || "Loading Session..."}</h2>
            <p className="text-xs text-slate-600 dark:text-slate-400 mt-0.5">
              User: <span className="text-slate-900 dark:text-slate-200 font-bold">{detail?.session.user_name}</span> ({detail?.session.user_email}) &bull; ID: <span className="font-mono text-slate-500 dark:text-slate-400">{sessionId.slice(0, 8)}...</span>
            </p>
          </div>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-slate-200 dark:bg-slate-800 hover:bg-slate-300 dark:hover:bg-slate-700 text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white flex items-center justify-center transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {loading ? (
          <div className="p-12 text-center text-slate-500 dark:text-slate-400 flex flex-col items-center gap-3">
            <div className="w-8 h-8 border-2 border-[#f25c40] border-t-transparent rounded-full animate-spin"></div>
            <span>Fetching detailed session logs & cost breakdown...</span>
          </div>
        ) : detail ? (
          <>
            {/* Quick Metrics Bar */}
            <div className="grid grid-cols-4 border-b border-slate-200 dark:border-slate-800 bg-slate-100 dark:bg-slate-950/60 divide-x divide-slate-200 dark:divide-slate-800 text-xs">
              <div className="p-3 text-center">
                <span className="text-slate-500 dark:text-slate-400 block text-[11px]">Total Cost</span>
                <span className="font-extrabold text-emerald-600 dark:text-emerald-400 text-sm">${detail.total_cost_usd.toFixed(4)} USD</span>
              </div>
              <div className="p-3 text-center">
                <span className="text-slate-500 dark:text-slate-400 block text-[11px]">Total Turns</span>
                <span className="font-bold text-slate-900 dark:text-slate-200 text-sm">{detail.messages.length} Turns</span>
              </div>
              <div className="p-3 text-center">
                <span className="text-slate-500 dark:text-slate-400 block text-[11px]">Duration</span>
                <span className="font-bold text-slate-900 dark:text-slate-200 text-sm">{detail.session.duration_minutes} Minutes</span>
              </div>
              <div className="p-3 text-center">
                <span className="text-slate-500 dark:text-slate-400 block text-[11px]">LLM Calls Logged</span>
                <span className="font-bold text-[#f25c40] text-sm">{detail.usage_logs.length} Calls</span>
              </div>
            </div>

            {/* Navigation Tabs */}
            <div className="flex border-b border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-900/30 px-6 gap-6 text-sm">
              <button
                onClick={() => setActiveTab("transcript")}
                className={`py-3 font-bold border-b-2 flex items-center gap-2 transition-colors ${
                  activeTab === "transcript"
                    ? "border-[#f25c40] text-[#f25c40]"
                    : "border-transparent text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200"
                }`}
              >
                <MessageSquare className="w-4 h-4" />
                Turn Transcript ({detail.messages.length})
              </button>
              <button
                onClick={() => setActiveTab("cost")}
                className={`py-3 font-bold border-b-2 flex items-center gap-2 transition-colors ${
                  activeTab === "cost"
                    ? "border-[#f25c40] text-[#f25c40]"
                    : "border-transparent text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200"
                }`}
              >
                <DollarSign className="w-4 h-4" />
                Itemized Cost Log (${detail.total_cost_usd.toFixed(4)})
              </button>
              {detail.report && (
                <button
                  onClick={() => setActiveTab("report")}
                  className={`py-3 font-bold border-b-2 flex items-center gap-2 transition-colors ${
                    activeTab === "report"
                      ? "border-[#f25c40] text-[#f25c40]"
                      : "border-transparent text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200"
                  }`}
                >
                  <BarChart2 className="w-4 h-4" />
                  Feedback Analysis Report
                </button>
              )}
            </div>

            {/* Content Body */}
            <div className="p-6 overflow-y-auto flex-1 space-y-4">
              {activeTab === "transcript" && (
                <div className="space-y-3">
                  <div className="text-xs text-slate-500 dark:text-slate-400 flex items-center justify-between pb-2 border-b border-slate-200 dark:border-slate-800">
                    <span>Detailed chronologic log of turn messages exchanged:</span>
                    <span>{detail.messages.length} messages</span>
                  </div>
                  {detail.messages.length === 0 ? (
                    <div className="text-center py-8 text-slate-500 dark:text-slate-400 text-sm">No messages recorded in this session.</div>
                  ) : (
                    detail.messages.map((m) => {
                      const isUser = m.speaker === "user";
                      return (
                        <div
                          key={m.id}
                          className={`p-4 rounded-xl border transition-all ${
                            isUser
                              ? "bg-[#f25c40]/10 border-[#f25c40]/30 text-slate-900 dark:text-slate-100 ml-8"
                              : "bg-slate-50 dark:bg-slate-900 border-slate-200 dark:border-slate-800 text-slate-900 dark:text-slate-200 mr-8"
                          }`}
                        >
                          <div className="flex items-center justify-between mb-1.5 text-xs">
                            <div className="flex items-center gap-2">
                              <span className={`font-bold ${isUser ? "text-[#f25c40]" : "text-amber-600 dark:text-amber-400"}`}>
                                Turn #{m.turn_index}: {isUser ? `User (${detail.session.user_name})` : m.speaker}
                              </span>
                              <span className="text-[10px] px-2 py-0.5 rounded bg-slate-200 dark:bg-slate-800 text-slate-700 dark:text-slate-300 font-mono">
                                role: {m.speaker_role}
                              </span>
                            </div>
                            <div className="flex items-center gap-2 text-[11px] text-slate-500 dark:text-slate-400">
                              {m.audio_duration_seconds > 0 && (
                                <span className="flex items-center gap-1 font-semibold">
                                  <Volume2 className="w-3 h-3 text-[#f25c40]" />
                                  {m.audio_duration_seconds.toFixed(1)}s
                                </span>
                              )}
                              <span>{new Date(m.created_at).toLocaleTimeString()}</span>
                            </div>
                          </div>
                          <p className="text-sm leading-relaxed whitespace-pre-wrap">{m.text}</p>
                        </div>
                      );
                    })
                  )}
                </div>
              )}

              {activeTab === "cost" && (
                <div className="space-y-4">
                  <div className="text-xs text-slate-600 dark:text-slate-400 pb-2 border-b border-slate-200 dark:border-slate-800">
                    Itemized breakdown of every Gemini LLM call recorded for session <span className="font-mono text-[#f25c40] font-bold">{sessionId}</span>:
                  </div>
                  <div className="overflow-x-auto rounded-xl border border-slate-200 dark:border-slate-800">
                    <table className="w-full text-left text-xs">
                      <thead className="bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 font-bold border-b border-slate-200 dark:border-slate-700">
                        <tr>
                          <th className="p-3">Call Type</th>
                          <th className="p-3">Model</th>
                          <th className="p-3 text-right">Input Tokens</th>
                          <th className="p-3 text-right">Output Tokens</th>
                          <th className="p-3 text-right">Total Tokens</th>
                          <th className="p-3 text-right">Cost ($USD)</th>
                          <th className="p-3 text-right">Timestamp</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-200 dark:divide-slate-800 bg-white dark:bg-slate-900/60">
                        {detail.usage_logs.map((log) => (
                          <tr key={log.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/60">
                            <td className="p-3 font-extrabold uppercase text-[#f25c40]">{log.call_type}</td>
                            <td className="p-3 font-mono text-slate-800 dark:text-slate-200">{log.model}</td>
                            <td className="p-3 text-right text-slate-700 dark:text-slate-300 font-mono">{log.input_tokens.toLocaleString()}</td>
                            <td className="p-3 text-right text-slate-700 dark:text-slate-300 font-mono">{log.output_tokens.toLocaleString()}</td>
                            <td className="p-3 text-right font-bold text-slate-900 dark:text-slate-100 font-mono">{log.total_tokens.toLocaleString()}</td>
                            <td className="p-3 text-right font-extrabold text-emerald-600 dark:text-emerald-400 font-mono">${log.cost_usd.toFixed(5)}</td>
                            <td className="p-3 text-right text-slate-500 dark:text-slate-400 text-[11px]">
                              {new Date(log.created_at).toLocaleTimeString()}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                      <tfoot className="bg-slate-100 dark:bg-slate-800 border-t border-slate-200 dark:border-slate-700 font-bold text-xs">
                        <tr>
                          <td colSpan={4} className="p-3 text-right text-slate-700 dark:text-slate-300">Total Session Cost:</td>
                          <td className="p-3 text-right text-[#f25c40] font-mono">
                            {detail.usage_logs.reduce((acc, curr) => acc + curr.total_tokens, 0).toLocaleString()}
                          </td>
                          <td className="p-3 text-right text-emerald-600 dark:text-emerald-400 font-mono">${detail.total_cost_usd.toFixed(4)}</td>
                          <td></td>
                        </tr>
                      </tfoot>
                    </table>
                  </div>
                </div>
              )}

              {activeTab === "report" && detail.report && (
                <div className="space-y-4 text-xs">
                  <div className="grid grid-cols-3 gap-4">
                    <div className="glass-card p-4 rounded-xl text-center bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800">
                      <span className="text-slate-500 dark:text-slate-400 block text-[11px] font-medium">Speaking Speed</span>
                      <span className="text-xl font-extrabold text-[#f25c40] mt-1 block">{detail.report.wpm} WPM</span>
                    </div>
                    <div className="glass-card p-4 rounded-xl text-center bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800">
                      <span className="text-slate-500 dark:text-slate-400 block text-[11px] font-medium">Filler Words Count</span>
                      <span className="text-xl font-extrabold text-amber-600 dark:text-amber-400 mt-1 block">{detail.report.filler_words_count}</span>
                    </div>
                    <div className="glass-card p-4 rounded-xl text-center bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800">
                      <span className="text-slate-500 dark:text-slate-400 block text-[11px] font-medium">Overall AI Score</span>
                      <span className="text-xl font-extrabold text-emerald-600 dark:text-emerald-400 mt-1 block">{detail.report.overall_score || "N/A"} / 10</span>
                    </div>
                  </div>

                  <div className="space-y-3 pt-2">
                    <div className="glass-card p-4 rounded-xl border border-slate-200 dark:border-slate-800">
                      <h4 className="font-bold text-slate-900 dark:text-white text-xs mb-1">Vocabulary & Expression Feedback</h4>
                      <p className="text-slate-700 dark:text-slate-300 leading-relaxed">{detail.report.vocabulary_feedback || "No feedback logged."}</p>
                    </div>

                    <div className="glass-card p-4 rounded-xl border border-slate-200 dark:border-slate-800">
                      <h4 className="font-bold text-slate-900 dark:text-white text-xs mb-1">Argument Quality & Counter-Points</h4>
                      <p className="text-slate-700 dark:text-slate-300 leading-relaxed">{detail.report.argument_quality || "No analysis logged."}</p>
                    </div>

                    <div className="glass-card p-4 rounded-xl border border-slate-200 dark:border-slate-800">
                      <h4 className="font-bold text-emerald-600 dark:text-emerald-400 text-xs mb-1">Key Highlights</h4>
                      <p className="text-slate-700 dark:text-slate-300 leading-relaxed">{detail.report.key_highlights || "No highlights."}</p>
                    </div>

                    <div className="glass-card p-4 rounded-xl border border-slate-200 dark:border-slate-800">
                      <h4 className="font-bold text-amber-600 dark:text-amber-400 text-xs mb-1">Actionable Recommendations</h4>
                      <p className="text-slate-700 dark:text-slate-300 leading-relaxed">{detail.report.actionable_recommendations || "No recommendations."}</p>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </>
        ) : (
          <div className="p-8 text-center text-rose-500">Failed to load session details.</div>
        )}
      </div>
    </div>
  );
}
