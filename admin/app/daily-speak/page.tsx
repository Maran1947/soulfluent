"use client";

import { useEffect, useState } from "react";
import { Mic, DollarSign, CheckCircle2, ExternalLink, Calendar } from "lucide-react";
import { fetchDailySpeakList, DailySpeakListResponse } from "@/lib/api";
import SessionDetailModal from "@/components/SessionDetailModal";

export default function DailySpeakAdminPage() {
  const [data, setData] = useState<DailySpeakListResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [datePreset, setDatePreset] = useState<string>("all");
  const [selectedSessionId, setSelectedSessionId] = useState<string | null>(null);

  useEffect(() => {
    async function load() {
      setLoading(true);
      let sDate = "";
      let eDate = "";

      if (datePreset === "today") {
        sDate = new Date().toISOString().split("T")[0];
        eDate = sDate;
      } else if (datePreset === "7d") {
        const d = new Date();
        d.setDate(d.getDate() - 7);
        sDate = d.toISOString().split("T")[0];
        eDate = new Date().toISOString().split("T")[0];
      } else if (datePreset === "30d") {
        const d = new Date();
        d.setDate(d.getDate() - 30);
        sDate = d.toISOString().split("T")[0];
        eDate = new Date().toISOString().split("T")[0];
      }

      const res = await fetchDailySpeakList(sDate || undefined, eDate || undefined);
      setData(res);
      setLoading(false);
    }
    load();
  }, [datePreset]);

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-slate-900 dark:text-slate-100">Daily Speak Analytics & Cost Log</h1>
          <p className="text-xs text-slate-600 dark:text-slate-400 mt-1">
            Read-only history of daily speaking challenges completed by learners with Gemini API cost attribution.
          </p>
        </div>

        {/* Date Filter */}
        <div className="glass-card px-4 py-2.5 rounded-xl border border-slate-200 dark:border-slate-800 flex items-center gap-3 text-xs bg-white dark:bg-slate-900 shadow-sm">
          <div className="flex items-center gap-1.5 font-semibold text-slate-700 dark:text-slate-300">
            <Calendar className="w-4 h-4 text-[#f25c40]" />
            <span>Date Filter:</span>
          </div>

          <select
            value={datePreset}
            onChange={(e) => setDatePreset(e.target.value)}
            className="bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg px-3 py-1 text-slate-900 dark:text-slate-100 font-medium focus:outline-none"
          >
            <option value="all">All Time</option>
            <option value="today">Today</option>
            <option value="7d">Last 7 Days</option>
            <option value="30d">Last 30 Days</option>
          </select>
        </div>
      </div>

      {loading || !data ? (
        <div className="p-12 text-center text-slate-500 dark:text-slate-400">Loading daily speak analytics...</div>
      ) : (
        <>
          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
            <div className="glass-card rounded-2xl p-5 border border-slate-200 dark:border-slate-800 bg-white dark:bg-[#1e293b]">
              <span className="text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Total Daily Speak Completions</span>
              <div className="flex items-center justify-between mt-2">
                <span className="text-3xl font-extrabold text-slate-900 dark:text-white">{data.total_completions}</span>
                <div className="w-10 h-10 rounded-xl bg-[#f25c40]/10 text-[#f25c40] flex items-center justify-center font-bold">
                  <Mic className="w-5 h-5" />
                </div>
              </div>
            </div>

            <div className="glass-card rounded-2xl p-5 border border-slate-200 dark:border-slate-800 bg-white dark:bg-[#1e293b]">
              <span className="text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Daily Speak Total Cost</span>
              <div className="flex items-center justify-between mt-2">
                <span className="text-3xl font-extrabold text-emerald-600 dark:text-emerald-400">${data.total_cost_usd.toFixed(3)} USD</span>
                <div className="w-10 h-10 rounded-xl bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 flex items-center justify-center font-bold">
                  <DollarSign className="w-5 h-5" />
                </div>
              </div>
            </div>

            <div className="glass-card rounded-2xl p-5 border border-slate-200 dark:border-slate-800 bg-white dark:bg-[#1e293b]">
              <span className="text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Average Cost / Daily Speak</span>
              <div className="flex items-center justify-between mt-2">
                <span className="text-3xl font-extrabold text-[#f25c40]">
                  ${data.total_completions > 0 ? (data.total_cost_usd / data.total_completions).toFixed(4) : "0.0000"}
                </span>
                <div className="w-10 h-10 rounded-xl bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 flex items-center justify-center font-bold">
                  <CheckCircle2 className="w-5 h-5" />
                </div>
              </div>
            </div>
          </div>

          {/* Table */}
          <div className="glass-panel rounded-2xl border border-slate-200 dark:border-slate-800 overflow-hidden bg-white dark:bg-slate-900 shadow-sm">
            <div className="p-4 border-b border-slate-200 dark:border-slate-800 font-bold text-sm text-slate-900 dark:text-white">
              Recent Daily Speak Completions Log
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 font-bold border-b border-slate-200 dark:border-slate-700">
                  <tr>
                    <th className="p-4">Learner</th>
                    <th className="p-4">Topic</th>
                    <th className="p-4">Completed Date</th>
                    <th className="p-4 text-right">Cost ($USD)</th>
                    <th className="p-4 text-center">Session Log</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-200/80 dark:divide-slate-800 bg-white dark:bg-slate-900/60">
                  {data.items.map((item) => (
                    <tr key={item.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/60 transition-colors">
                      <td className="p-4">
                        <div className="font-bold text-slate-900 dark:text-slate-100 text-sm">{item.user_name}</div>
                        <div className="text-slate-500 dark:text-slate-400 text-xs font-mono">{item.user_email}</div>
                      </td>
                      <td className="p-4 font-semibold text-slate-900 dark:text-slate-200 max-w-sm">
                        {item.topic_title}
                      </td>
                      <td className="p-4 text-slate-600 dark:text-slate-400 font-mono text-[11px]">
                        {new Date(item.completed_at_date).toLocaleDateString()} {new Date(item.completed_at_date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                      </td>
                      <td className="p-4 text-right font-extrabold text-emerald-600 dark:text-emerald-400 font-mono">
                        ${item.cost_usd.toFixed(4)}
                      </td>
                      <td className="p-4 text-center">
                        {item.session_id ? (
                          <button
                            onClick={() => setSelectedSessionId(item.session_id!)}
                            className="px-3 py-1.5 rounded-xl bg-[#f25c40]/10 hover:bg-[#f25c40]/20 text-[#f25c40] font-bold border border-[#f25c40]/30 flex items-center gap-1.5 mx-auto transition-colors"
                          >
                            <ExternalLink className="w-3.5 h-3.5" />
                            <span>Inspect Session</span>
                          </button>
                        ) : (
                          <span className="text-slate-500 dark:text-slate-400 text-[11px]">Direct Log</span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}

      {selectedSessionId && (
        <SessionDetailModal
          sessionId={selectedSessionId}
          onClose={() => setSelectedSessionId(null)}
        />
      )}
    </div>
  );
}
