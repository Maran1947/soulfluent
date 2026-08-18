"use client";

import { useEffect, useState } from "react";
import { Search, Filter, Eye, Calendar } from "lucide-react";
import { fetchSessions, SessionListItem } from "@/lib/api";
import SessionDetailModal from "@/components/SessionDetailModal";

export default function UserSessionsPage() {
  const [sessions, setSessions] = useState<SessionListItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [modeFilter, setModeFilter] = useState<string>("all");
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

      const data = await fetchSessions(
        statusFilter === "all" ? undefined : statusFilter,
        modeFilter === "all" ? undefined : modeFilter,
        sDate || undefined,
        eDate || undefined
      );
      setSessions(data);
      setLoading(false);
    }
    load();
  }, [statusFilter, modeFilter, datePreset]);

  const filteredSessions = sessions.filter((s) => {
    const q = search.toLowerCase();
    return (
      s.user_name.toLowerCase().includes(q) ||
      s.user_email.toLowerCase().includes(q) ||
      s.topic.toLowerCase().includes(q) ||
      s.id.toLowerCase().includes(q)
    );
  });

  const totalCost = filteredSessions.reduce((acc, curr) => acc + curr.total_cost_usd, 0);

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      {/* Page Title */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-slate-900 dark:text-slate-100">User Sessions & LLM Cost Logs</h1>
          <p className="text-xs text-slate-600 dark:text-slate-400 mt-1">
            Read-only list of speaking sessions with computed Gemini LLM usage costs ($USD).
          </p>
        </div>
        <div className="glass-card px-4 py-2.5 rounded-xl border border-slate-200 dark:border-slate-800 flex items-center gap-3 text-xs bg-white dark:bg-slate-900 shadow-sm">
          <span className="text-slate-600 dark:text-slate-400 font-medium">Filtered Session Cost:</span>
          <span className="text-base font-bold text-emerald-600 dark:text-emerald-400">${totalCost.toFixed(4)} USD</span>
        </div>
      </div>

      {/* Controls Bar */}
      <div className="glass-panel p-4 rounded-2xl border border-slate-200 dark:border-slate-800 flex flex-col md:flex-row items-center justify-between gap-4 bg-white dark:bg-slate-900 shadow-sm">
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by user, email, topic, or ID..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-xs rounded-xl pl-9 pr-4 py-2.5 text-slate-900 dark:text-slate-100 focus:outline-none focus:border-[#f25c40] focus:ring-2 focus:ring-[#f25c40]/20"
          />
        </div>

        <div className="flex flex-wrap items-center gap-3 w-full md:w-auto text-xs">
          <div className="flex items-center gap-2">
            <Calendar className="w-3.5 h-3.5 text-[#f25c40]" />
            <span className="text-slate-600 dark:text-slate-400 font-medium">Date:</span>
            <select
              value={datePreset}
              onChange={(e) => setDatePreset(e.target.value)}
              className="bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg px-2.5 py-1.5 text-slate-900 dark:text-slate-100 font-medium focus:outline-none"
            >
              <option value="all">All Time</option>
              <option value="today">Today</option>
              <option value="7d">Last 7 Days</option>
              <option value="30d">Last 30 Days</option>
            </select>
          </div>

          <div className="flex items-center gap-2">
            <Filter className="w-3.5 h-3.5 text-slate-400" />
            <span className="text-slate-600 dark:text-slate-400 font-medium">Status:</span>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg px-2.5 py-1.5 text-slate-900 dark:text-slate-100 font-medium focus:outline-none"
            >
              <option value="all">All Statuses</option>
              <option value="completed">Completed</option>
              <option value="active">Active</option>
              <option value="abandoned">Abandoned</option>
            </select>
          </div>

          <div className="flex items-center gap-2">
            <span className="text-slate-600 dark:text-slate-400 font-medium">Mode:</span>
            <select
              value={modeFilter}
              onChange={(e) => setModeFilter(e.target.value)}
              className="bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg px-2.5 py-1.5 text-slate-900 dark:text-slate-100 font-medium focus:outline-none"
            >
              <option value="all">All Modes</option>
              <option value="gd">Group Discussion</option>
              <option value="debate">Debate</option>
              <option value="conversation">Conversation</option>
              <option value="interview">Interview</option>
            </select>
          </div>
        </div>
      </div>

      {/* Sessions Table */}
      <div className="glass-panel rounded-2xl border border-slate-200 dark:border-slate-800 overflow-hidden bg-white dark:bg-slate-900 shadow-sm">
        {loading ? (
          <div className="p-12 text-center text-slate-500 dark:text-slate-400">Loading user sessions...</div>
        ) : filteredSessions.length === 0 ? (
          <div className="p-12 text-center text-slate-500 dark:text-slate-400">No matching sessions found.</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 font-bold border-b border-slate-200 dark:border-slate-700">
                <tr>
                  <th className="p-4">User</th>
                  <th className="p-4">Mode / Category</th>
                  <th className="p-4">Topic</th>
                  <th className="p-4">Status</th>
                  <th className="p-4 text-center">Turns / Duration</th>
                  <th className="p-4 text-right">Total Tokens</th>
                  <th className="p-4 text-right">Cost ($USD)</th>
                  <th className="p-4 text-center">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200/80 dark:divide-slate-800 bg-white dark:bg-slate-900/60">
                {filteredSessions.map((s) => (
                  <tr key={s.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/60 transition-colors">
                    <td className="p-4">
                      <div className="font-bold text-slate-900 dark:text-slate-100 text-sm">{s.user_name || "Learner"}</div>
                      <div className="text-slate-500 dark:text-slate-400 text-xs font-mono">{s.user_email}</div>
                    </td>
                    <td className="p-4">
                      <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase bg-[#f25c40]/10 text-[#f25c40] border border-[#f25c40]/30">
                        {s.mode}
                      </span>
                      <div className="text-slate-600 dark:text-slate-400 text-xs mt-1 font-medium">{s.category}</div>
                    </td>
                    <td className="p-4 max-w-xs">
                      <div className="font-semibold text-slate-900 dark:text-slate-100 truncate text-xs" title={s.topic}>
                        {s.topic}
                      </div>
                      <div className="text-slate-500 dark:text-slate-400 text-[11px] font-mono mt-0.5">
                        Started: {new Date(s.started_at).toLocaleDateString()} {new Date(s.started_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                      </div>
                    </td>
                    <td className="p-4">
                      <span className={`px-2.5 py-0.5 rounded-full text-[10px] font-bold border ${
                        s.status === "completed"
                          ? "bg-emerald-500/10 text-emerald-700 dark:text-emerald-400 border-emerald-500/30"
                          : s.status === "active"
                          ? "bg-blue-500/10 text-blue-700 dark:text-blue-400 border-blue-500/30"
                          : "bg-amber-500/10 text-amber-700 dark:text-amber-400 border-amber-500/30"
                      }`}>
                        {s.status}
                      </span>
                    </td>
                    <td className="p-4 text-center">
                      <div className="font-bold text-slate-800 dark:text-slate-200">{s.turn_index} turns</div>
                      <div className="text-slate-500 dark:text-slate-400 text-xs">{s.duration_minutes} mins</div>
                    </td>
                    <td className="p-4 text-right font-mono font-medium text-slate-700 dark:text-slate-300">
                      {s.total_tokens.toLocaleString()}
                    </td>
                    <td className="p-4 text-right font-extrabold text-emerald-600 dark:text-emerald-400 font-mono">
                      ${s.total_cost_usd.toFixed(4)}
                    </td>
                    <td className="p-4 text-center">
                      <button
                        onClick={() => setSelectedSessionId(s.id)}
                        className="px-3 py-1.5 rounded-xl bg-[#f25c40]/10 hover:bg-[#f25c40]/20 text-[#f25c40] font-bold border border-[#f25c40]/30 flex items-center gap-1.5 mx-auto transition-colors"
                      >
                        <Eye className="w-3.5 h-3.5" />
                        <span>Inspect</span>
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Session Detail Modal */}
      {selectedSessionId && (
        <SessionDetailModal
          sessionId={selectedSessionId}
          onClose={() => setSelectedSessionId(null)}
        />
      )}
    </div>
  );
}
