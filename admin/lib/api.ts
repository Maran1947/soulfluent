export interface OverviewStats {
  total_signups: number;
  onboarded_users: number;
  onboarded_percentage: number;
  started_tracks_users: number;
  total_sessions: number;
  completed_sessions_count: number;
  active_sessions_count: number;
  abandoned_sessions_count: number;
  total_daily_speaks: number;
  total_cost_usd: number;
  signup_sources: Record<string, number>;
  cefr_distribution: Record<string, number>;
}

export interface SessionListItem {
  id: string;
  user_id: string;
  user_name: string;
  user_email: string;
  mode: string;
  topic: string;
  category: string;
  status: string;
  duration_minutes: number;
  turn_index: number;
  started_at: string;
  ended_at?: string;
  total_tokens: number;
  total_cost_usd: number;
}

export interface MessageItem {
  id: string;
  turn_index: number;
  speaker: string;
  speaker_role: string;
  text: string;
  audio_duration_seconds: number;
  created_at: string;
}

export interface LLMUsageItem {
  id: string;
  call_type: string;
  model: string;
  input_tokens: number;
  output_tokens: number;
  total_tokens: number;
  cost_usd: number;
  created_at: string;
}

export interface SessionDetail {
  session: SessionListItem;
  messages: MessageItem[];
  usage_logs: LLMUsageItem[];
  report?: Record<string, any>;
  total_cost_usd: number;
}

export interface DailySpeakItem {
  id: string;
  user_id: string;
  user_name: string;
  user_email: string;
  completed_at_date: string;
  topic_title: string;
  session_id?: string;
  cost_usd: number;
}

export interface DailySpeakListResponse {
  total_completions: number;
  total_cost_usd: number;
  items: DailySpeakItem[];
}

export interface LeaderboardUser {
  rank: number;
  user_id: string;
  user_name: string;
  user_email: string;
  streak_days: number;
  completed_sessions: number;
  completed_daily_speaks: number;
  completed_activities: number;
  total_speak_seconds: number;
  cefr_level: string;
  is_onboarded: boolean;
  created_at: string;
}

export interface AdminUser {
  id: string;
  email: string;
  name: string;
  role: string;
}

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/api/v1";

export function getStoredToken(): string | null {
  if (typeof window === "undefined") return null;
  return localStorage.getItem("fluent_admin_token");
}

export function getStoredAdminUser(): AdminUser | null {
  if (typeof window === "undefined") return null;
  const raw = localStorage.getItem("fluent_admin_user");
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch (e) {
    return null;
  }
}

export function logoutAdmin() {
  if (typeof window !== "undefined") {
    localStorage.removeItem("fluent_admin_token");
    localStorage.removeItem("fluent_admin_user");
    window.location.href = "/login";
  }
}

function getAuthHeaders(): Record<string, string> {
  const token = getStoredToken();
  return token ? { Authorization: `Bearer ${token}` } : {};
}

export async function loginAdmin(email: string, password: string): Promise<AdminUser> {
  const res = await fetch(`${API_BASE}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });

  if (!res.ok) {
    const errData = await res.json().catch(() => ({}));
    throw new Error(errData.detail || "Invalid email or password.");
  }

  const data = await res.json();
  const user = data.user;

  if (user.role !== "ADMIN") {
    throw new Error(
      `Access Denied: Account '${email}' does not have ADMIN role permissions. Only users with role ADMIN can access this dashboard.`
    );
  }

  localStorage.setItem("fluent_admin_token", data.access_token);
  localStorage.setItem("fluent_admin_user", JSON.stringify(user));
  return user;
}

export async function fetchOverviewStats(startDate?: string, endDate?: string): Promise<OverviewStats> {
  const params = new URLSearchParams();
  if (startDate) params.append("start_date", startDate);
  if (endDate) params.append("end_date", endDate);

  const res = await fetch(`${API_BASE}/admin/stats/overview?${params.toString()}`, {
    headers: getAuthHeaders(),
    cache: "no-store",
  });

  if (!res.ok) {
    throw new Error("Failed to load overview stats from server.");
  }

  return await res.json();
}

export async function fetchSessions(
  status?: string,
  mode?: string,
  startDate?: string,
  endDate?: string
): Promise<SessionListItem[]> {
  const params = new URLSearchParams();
  if (status) params.append("status", status);
  if (mode) params.append("mode", mode);
  if (startDate) params.append("start_date", startDate);
  if (endDate) params.append("end_date", endDate);

  const res = await fetch(`${API_BASE}/admin/sessions?${params.toString()}`, {
    headers: getAuthHeaders(),
    cache: "no-store",
  });

  if (!res.ok) {
    throw new Error("Failed to load user sessions from server.");
  }

  return await res.json();
}

export async function fetchSessionDetail(id: string): Promise<SessionDetail> {
  const res = await fetch(`${API_BASE}/admin/sessions/${id}`, {
    headers: getAuthHeaders(),
    cache: "no-store",
  });

  if (!res.ok) {
    throw new Error("Failed to load session details from server.");
  }

  return await res.json();
}

export async function fetchDailySpeakList(startDate?: string, endDate?: string): Promise<DailySpeakListResponse> {
  const params = new URLSearchParams();
  if (startDate) params.append("start_date", startDate);
  if (endDate) params.append("end_date", endDate);

  const res = await fetch(`${API_BASE}/admin/daily-speak?${params.toString()}`, {
    headers: getAuthHeaders(),
    cache: "no-store",
  });

  if (!res.ok) {
    throw new Error("Failed to load daily speak list from server.");
  }

  return await res.json();
}

export async function fetchLeaderboard(): Promise<LeaderboardUser[]> {
  const res = await fetch(`${API_BASE}/admin/users/leaderboard`, {
    headers: getAuthHeaders(),
    cache: "no-store",
  });

  if (!res.ok) {
    throw new Error("Failed to load user leaderboard from server.");
  }

  return await res.json();
}
