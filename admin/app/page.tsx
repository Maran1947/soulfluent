"use client";

import { useEffect, useState } from "react";
import { Users, UserCheck, Compass, MessageSquareText, DollarSign, ArrowUpRight, ShieldCheck, Calendar } from "lucide-react";
import { fetchOverviewStats, OverviewStats } from "@/lib/api";

export default function OverviewPage() {
  const [stats, setStats] = useState<OverviewStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [datePreset, setDatePreset] = useState<string>("all");
  const [startDate, setStartDate] = useState<string>("");
  const [endDate, setEndDate] = useState<string>("");

  useEffect(() => {
    async function load() {
      setLoading(true);
      let sDate = startDate;
      let eDate = endDate;

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
      } else if (datePreset === "all") {
        sDate = "";
        eDate = "";
      }

      const data = await fetchOverviewStats(sDate || undefined, eDate || undefined);
      setStats(data);
      setLoading(false);
    }
    load();
  }, [datePreset, startDate, endDate]);

  return (
    <div className="space-y-8 max-w-7xl mx-auto">
      {/* Header & Date Range Filter */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-[#f25c40] text-xs font-bold uppercase tracking-wider mb-1">
            <ShieldCheck className="w-4 h-4" /> Read-Only Admin Metrics
          </div>
          <h1 className="text-3xl font-extrabold text-slate-900 dark:text-slate-100 tracking-tight">
            Platform Overview & Signups Analytics
          </h1>
          <p className="text-sm text-slate-600 dark:text-slate-400 mt-1">
            Real-time aggregated view of platform signups, onboarding conversion, track engagement, and LLM costs.
          </p>
        </div>

        {/* Date Range Selector */}
        <div className="glass-card px-4 py-3 rounded-xl border border-slate-200 dark:border-slate-800 flex flex-wrap items-center gap-3 text-xs bg-white dark:bg-slate-900 shadow-sm">
          <div className="flex items-center gap-1.5 font-semibold text-slate-700 dark:text-slate-300">
            <Calendar className="w-4 h-4 text-[#f25c40]" />
            <span>Signups Date Filter:</span>
          </div>

          <select
            value={datePreset}
            onChange={(e) => setDatePreset(e.target.value)}
            className="bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg px-3 py-1.5 font-medium text-slate-900 dark:text-slate-100 focus:outline-none focus:border-[#f25c40]"
          >
            <option value="all">All Time</option>
            <option value="today">Today</option>
            <option value="7d">Last 7 Days</option>
            <option value="30d">Last 30 Days</option>
            <option value="custom">Custom Date Range</option>
          </select>

          {datePreset === "custom" && (
            <div className="flex items-center gap-2">
              <input
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
                className="bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg px-2 py-1 text-slate-900 dark:text-slate-100 text-xs"
              />
              <span className="text-slate-400">to</span>
              <input
                type="date"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
                className="bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg px-2 py-1 text-slate-900 dark:text-slate-100 text-xs"
              />
            </div>
          )}
        </div>
      </div>

      {loading || !stats ? (
        <div className="p-12 text-center text-slate-500 dark:text-slate-400">Loading overview metrics...</div>
      ) : (
        <>
          {/* Top KPI Cards Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-5">
            {/* Card 1: Signups */}
            <div className="glass-card rounded-2xl p-5 border border-slate-200 dark:border-slate-800 relative overflow-hidden group hover:border-[#f25c40]/40 transition-all bg-white dark:bg-[#1e293b]">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Total Signups</span>
                <div className="w-9 h-9 rounded-xl bg-[#f25c40]/10 text-[#f25c40] flex items-center justify-center font-bold">
                  <Users className="w-5 h-5" />
                </div>
              </div>
              <div className="mt-3">
                <span className="text-3xl font-extrabold text-slate-900 dark:text-white">{stats.total_signups}</span>
                <div className="flex items-center gap-2 mt-1 text-xs text-slate-500 dark:text-slate-400">
                  <span className="text-emerald-600 dark:text-emerald-400 font-bold flex items-center">
                    <ArrowUpRight className="w-3.5 h-3.5" /> 100%
                  </span>
                  <span>Registered users</span>
                </div>
              </div>
            </div>

            {/* Card 2: Onboarded */}
            <div className="glass-card rounded-2xl p-5 border border-slate-200 dark:border-slate-800 relative overflow-hidden group hover:border-emerald-500/40 transition-all bg-white dark:bg-[#1e293b]">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Onboarded Users</span>
                <div className="w-9 h-9 rounded-xl bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 flex items-center justify-center font-bold">
                  <UserCheck className="w-5 h-5" />
                </div>
              </div>
              <div className="mt-3">
                <div className="flex items-baseline gap-2">
                  <span className="text-3xl font-extrabold text-slate-900 dark:text-white">{stats.onboarded_users}</span>
                  <span className="text-xs font-bold text-emerald-600 dark:text-emerald-400">({stats.onboarded_percentage}%)</span>
                </div>
                <div className="w-full bg-slate-100 dark:bg-slate-800 h-1.5 rounded-full mt-2 overflow-hidden border border-slate-200 dark:border-slate-700">
                  <div
                    className="bg-emerald-500 h-full rounded-full transition-all duration-500"
                    style={{ width: `${Math.min(stats.onboarded_percentage, 100)}%` }}
                  ></div>
                </div>
              </div>
            </div>

            {/* Card 3: Started Tracks */}
            <div className="glass-card rounded-2xl p-5 border border-slate-200 dark:border-slate-800 relative overflow-hidden group hover:border-indigo-500/40 transition-all bg-white dark:bg-[#1e293b]">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Started Tracks</span>
                <div className="w-9 h-9 rounded-xl bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 flex items-center justify-center font-bold">
                  <Compass className="w-5 h-5" />
                </div>
              </div>
              <div className="mt-3">
                <span className="text-3xl font-extrabold text-slate-900 dark:text-white">{stats.started_tracks_users}</span>
                <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">Unique active track learners</p>
              </div>
            </div>

            {/* Card 4: Total Sessions */}
            <div className="glass-card rounded-2xl p-5 border border-slate-200 dark:border-slate-800 relative overflow-hidden group hover:border-blue-500/40 transition-all bg-white dark:bg-[#1e293b]">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Total Sessions</span>
                <div className="w-9 h-9 rounded-xl bg-blue-500/10 text-blue-600 dark:text-blue-400 flex items-center justify-center font-bold">
                  <MessageSquareText className="w-5 h-5" />
                </div>
              </div>
              <div className="mt-3">
                <span className="text-3xl font-extrabold text-slate-900 dark:text-white">{stats.total_sessions}</span>
                <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">GD, Debate, Speak turns</p>
              </div>
            </div>

            {/* Card 5: Platform LLM Cost */}
            <div className="glass-card rounded-2xl p-5 border border-slate-200 dark:border-slate-800 relative overflow-hidden group hover:border-amber-500/40 transition-all bg-white dark:bg-[#1e293b]">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Total Cost (USD)</span>
                <div className="w-9 h-9 rounded-xl bg-amber-500/10 text-amber-600 dark:text-amber-400 flex items-center justify-center font-bold">
                  <DollarSign className="w-5 h-5" />
                </div>
              </div>
              <div className="mt-3">
                <span className="text-3xl font-extrabold text-emerald-600 dark:text-emerald-400">${stats.total_cost_usd.toFixed(3)}</span>
                <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">STT + Turn + TTS + Analysis</p>
              </div>
            </div>
          </div>

          {/* Breakdown Section */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Session Status Breakdown */}
            <div className="glass-panel rounded-2xl p-6 border border-slate-200 dark:border-slate-800 bg-white dark:bg-[#1e293b]">
              <h3 className="text-lg font-bold text-slate-900 dark:text-white mb-1">Session Status Breakdown</h3>
              <p className="text-xs text-slate-500 dark:text-slate-400 mb-4">Completed vs Active vs Abandoned/Failed</p>
              <div className="space-y-3.5">
                <div className="flex items-center justify-between p-3 rounded-xl bg-emerald-500/10 border border-emerald-500/30">
                  <div className="flex items-center gap-2">
                    <div className="w-2.5 h-2.5 rounded-full bg-emerald-500"></div>
                    <span className="text-xs font-bold text-slate-800 dark:text-slate-200">Completed Sessions</span>
                  </div>
                  <span className="text-sm font-extrabold text-emerald-600 dark:text-emerald-400">{stats.completed_sessions_count}</span>
                </div>

                <div className="flex items-center justify-between p-3 rounded-xl bg-blue-500/10 border border-blue-500/30">
                  <div className="flex items-center gap-2">
                    <div className="w-2.5 h-2.5 rounded-full bg-blue-500"></div>
                    <span className="text-xs font-bold text-slate-800 dark:text-slate-200">Active / In-Progress</span>
                  </div>
                  <span className="text-sm font-extrabold text-blue-600 dark:text-blue-400">{stats.active_sessions_count}</span>
                </div>

                <div className="flex items-center justify-between p-3 rounded-xl bg-amber-500/10 border border-amber-500/30">
                  <div className="flex items-center gap-2">
                    <div className="w-2.5 h-2.5 rounded-full bg-amber-500"></div>
                    <span className="text-xs font-bold text-slate-800 dark:text-slate-200">Abandoned / Failed</span>
                  </div>
                  <span className="text-sm font-extrabold text-amber-600 dark:text-amber-400">{stats.abandoned_sessions_count}</span>
                </div>
              </div>
            </div>

            {/* Signup Sources */}
            <div className="glass-panel rounded-2xl p-6 border border-slate-200 dark:border-slate-800 bg-white dark:bg-[#1e293b]">
              <h3 className="text-lg font-bold text-slate-900 dark:text-white mb-1">Signup Sources Breakdown</h3>
              <p className="text-xs text-slate-500 dark:text-slate-400 mb-4">Registration authentication providers</p>
              <div className="space-y-4">
                {Object.entries(stats.signup_sources).map(([source, count]) => {
                  const pct = stats.total_signups > 0 ? Math.round((count / stats.total_signups) * 100) : 0;
                  return (
                    <div key={source} className="space-y-1.5">
                      <div className="flex justify-between text-xs font-semibold">
                        <span className="text-slate-800 dark:text-slate-200">{source} Authentication</span>
                        <span className="text-slate-600 dark:text-slate-400">{count} users ({pct}%)</span>
                      </div>
                      <div className="w-full bg-slate-100 dark:bg-slate-800 h-2 rounded-full overflow-hidden border border-slate-200 dark:border-slate-700">
                        <div
                          className="bg-[#f25c40] h-full rounded-full transition-all"
                          style={{ width: `${pct}%` }}
                        ></div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* CEFR Level Distribution */}
            <div className="glass-panel rounded-2xl p-6 border border-slate-200 dark:border-slate-800 bg-white dark:bg-[#1e293b]">
              <h3 className="text-lg font-bold text-slate-900 dark:text-white mb-1">Learner CEFR Distribution</h3>
              <p className="text-xs text-slate-500 dark:text-slate-400 mb-4">Self-assessed English proficiency levels</p>
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                {["A1", "A2", "B1", "B2", "C1", "C2"].map((level) => {
                  const count = stats.cefr_distribution[level] || 0;
                  return (
                    <div key={level} className="glass-card rounded-xl p-3.5 border border-slate-200 dark:border-slate-800 text-center bg-slate-50 dark:bg-slate-900/60">
                      <div className="w-7 h-7 rounded-lg bg-[#f25c40]/10 text-[#f25c40] font-bold text-xs flex items-center justify-center mx-auto mb-2">
                        {level}
                      </div>
                      <span className="text-xl font-bold text-slate-900 dark:text-white block">{count}</span>
                      <span className="text-[10px] text-slate-500 dark:text-slate-400 uppercase tracking-wider font-semibold">Learners</span>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
