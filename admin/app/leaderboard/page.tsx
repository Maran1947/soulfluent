"use client";

import { useEffect, useState } from "react";
import { Trophy, Flame, CheckCircle2 } from "lucide-react";
import { fetchLeaderboard, LeaderboardUser } from "@/lib/api";

export default function LeaderboardPage() {
  const [leaderboard, setLeaderboard] = useState<LeaderboardUser[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      setLoading(true);
      const data = await fetchLeaderboard();
      setLeaderboard(data);
      setLoading(false);
    }
    load();
  }, []);

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      <div>
        <div className="flex items-center gap-2 text-[#f25c40] text-xs font-bold uppercase tracking-wider mb-1">
          <Trophy className="w-4 h-4" /> Live Learner Rankings
        </div>
        <h1 className="text-2xl font-extrabold text-slate-900 dark:text-slate-100">Streak-Wise User Leaderboard</h1>
        <p className="text-xs text-slate-600 dark:text-slate-400 mt-1">
          Read-only ranking of learners ordered by consecutive daily practice streak (days), sessions completed, and speak time.
        </p>
      </div>

      {loading ? (
        <div className="p-12 text-center text-slate-500 dark:text-slate-400">Loading user streak leaderboard...</div>
      ) : leaderboard.length === 0 ? (
        <div className="p-12 text-center text-slate-500 dark:text-slate-400">No user activity recorded yet.</div>
      ) : (
        <>
          {/* Top 3 Podium Highlights */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
            {leaderboard.slice(0, 3).map((user, idx) => {
              const ranks = [
                { bg: "from-[#f25c40]/10 to-rose-50 dark:from-[#f25c40]/20 dark:to-rose-950/20 border-[#f25c40]/40", text: "text-[#f25c40]", badge: "🥇 #1 Champion" },
                { bg: "from-slate-100 to-slate-200/50 dark:from-slate-800/40 dark:to-slate-800/20 border-slate-300 dark:border-slate-700", text: "text-slate-700 dark:text-slate-200", badge: "🥈 #2 Runner Up" },
                { bg: "from-amber-100 to-amber-200/50 dark:from-amber-950/30 dark:to-amber-950/10 border-amber-300 dark:border-amber-700/50", text: "text-amber-700 dark:text-amber-400", badge: "🥉 #3 Contender" },
              ];
              const style = ranks[idx];
              return (
                <div
                  key={user.user_id}
                  className={`glass-panel rounded-2xl p-5 border bg-gradient-to-b ${style.bg} relative overflow-hidden flex flex-col justify-between shadow-sm`}
                >
                  <div>
                    <div className="flex items-center justify-between mb-3">
                      <span className={`px-3 py-1 rounded-full text-xs font-extrabold ${style.text} bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 shadow-xs`}>
                        {style.badge}
                      </span>
                      <div className="flex items-center gap-1.5 bg-[#f25c40]/10 border border-[#f25c40]/30 px-3 py-1 rounded-full text-[#f25c40] font-extrabold text-sm">
                        <Flame className="w-4 h-4 fill-[#f25c40] text-[#f25c40] animate-pulse" />
                        <span>{user.streak_days} Days</span>
                      </div>
                    </div>
                    <h3 className="text-xl font-extrabold text-slate-900 dark:text-white">{user.user_name}</h3>
                    <p className="text-xs text-slate-500 dark:text-slate-400 font-mono mt-0.5">{user.user_email}</p>
                  </div>

                  <div className="grid grid-cols-2 gap-2 mt-4 pt-4 border-t border-slate-200 dark:border-slate-800 text-xs">
                    <div>
                      <span className="text-slate-500 dark:text-slate-400 block text-[11px] font-medium">Completed Sessions</span>
                      <span className="font-extrabold text-slate-900 dark:text-slate-100 text-sm">{user.completed_sessions}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 dark:text-slate-400 block text-[11px] font-medium">Total Speaking Time</span>
                      <span className="font-extrabold text-[#f25c40] text-sm">{(user.total_speak_seconds / 60).toFixed(1)} mins</span>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Full Leaderboard Table */}
          <div className="glass-panel rounded-2xl border border-slate-200 dark:border-slate-800 overflow-hidden bg-white dark:bg-slate-900 shadow-sm">
            <div className="p-4 border-b border-slate-200 dark:border-slate-800 font-bold text-sm text-slate-900 dark:text-white flex items-center justify-between">
              <span>Full Platform Streak Leaderboard</span>
              <span className="text-xs font-semibold text-slate-500 dark:text-slate-400">{leaderboard.length} Ranked Learners</span>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 font-bold border-b border-slate-200 dark:border-slate-700">
                  <tr>
                    <th className="p-4 text-center">Rank</th>
                    <th className="p-4">Learner</th>
                    <th className="p-4 text-center">Consecutive Streak</th>
                    <th className="p-4 text-center">Completed Sessions</th>
                    <th className="p-4 text-center">Daily Speaks</th>
                    <th className="p-4 text-center">Track Progress</th>
                    <th className="p-4 text-right">Speak Time</th>
                    <th className="p-4 text-center">CEFR / Onboarded</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-200/80 dark:divide-slate-800 bg-white dark:bg-slate-900/60">
                  {leaderboard.map((u) => (
                    <tr key={u.user_id} className="hover:bg-slate-50 dark:hover:bg-slate-800/60 transition-colors">
                      <td className="p-4 text-center">
                        <span className={`w-8 h-8 rounded-full font-extrabold flex items-center justify-center mx-auto text-xs ${
                          u.rank === 1
                            ? "bg-[#f25c40] text-white shadow-md shadow-[#f25c40]/30"
                            : u.rank === 2
                            ? "bg-slate-200 dark:bg-slate-700 text-slate-900 dark:text-slate-100"
                            : u.rank === 3
                            ? "bg-amber-500 text-white"
                            : "bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400"
                        }`}>
                          #{u.rank}
                        </span>
                      </td>
                      <td className="p-4">
                        <div className="font-bold text-slate-900 dark:text-slate-100 text-sm">{u.user_name}</div>
                        <div className="text-slate-500 dark:text-slate-400 text-xs font-mono">{u.user_email}</div>
                      </td>
                      <td className="p-4 text-center">
                        <div className="inline-flex items-center gap-1 bg-[#f25c40]/10 border border-[#f25c40]/20 px-3 py-1 rounded-full text-[#f25c40] font-extrabold text-xs">
                          <Flame className="w-3.5 h-3.5 fill-[#f25c40] text-[#f25c40]" />
                          <span>{u.streak_days} Days</span>
                        </div>
                      </td>
                      <td className="p-4 text-center font-bold text-slate-900 dark:text-slate-100">
                        {u.completed_sessions}
                      </td>
                      <td className="p-4 text-center font-bold text-slate-900 dark:text-slate-100">
                        {u.completed_daily_speaks}
                      </td>
                      <td className="p-4 text-center font-semibold text-slate-700 dark:text-slate-300">
                        {u.completed_activities} activities
                      </td>
                      <td className="p-4 text-right font-mono font-extrabold text-[#f25c40]">
                        {(u.total_speak_seconds / 60).toFixed(1)} mins
                      </td>
                      <td className="p-4 text-center">
                        <div className="flex items-center justify-center gap-2">
                          <span className="px-2 py-0.5 rounded bg-[#f25c40]/10 text-[#f25c40] font-extrabold text-[10px] border border-[#f25c40]/30">
                            {u.cefr_level}
                          </span>
                          {u.is_onboarded ? (
                            <span className="text-emerald-600 dark:text-emerald-400 text-[10px] font-bold flex items-center gap-0.5">
                              <CheckCircle2 className="w-3 h-3" /> Onboarded
                            </span>
                          ) : (
                            <span className="text-slate-500 dark:text-slate-400 text-[10px] font-medium">Pending</span>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
