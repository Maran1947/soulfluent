const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/api/v1";

export type User = { id: string; email: string; name: string };
export type TokenResponse = { access_token: string; token_type: string; user: User };

export type Persona = {
  key: string;
  name: string;
  personality: string;
  voice_name: string;
};

export type GDSession = {
  id: string;
  topic: string;
  category: string;
  difficulty: "beginner" | "intermediate" | "advanced";
  duration_minutes: number;
  personas: Persona[];
  status: "active" | "completed" | "abandoned";
  started_at: string;
  ended_at: string | null;
};

export type GDMessage = {
  id: string;
  turn_index: number;
  speaker: string;
  text: string;
  created_at: string;
};

export type TurnResponse = {
  user_transcript: string;
  ai_speaker: string;
  ai_speaker_name: string;
  ai_text: string;
  ai_audio_base64: string;
  turn_index: number;
  seconds_remaining: number;
  session_status: "active" | "completed" | "abandoned";
};

export type FeedbackReport = {
  id: string;
  session_id: string;
  overall_score: number;
  fluency_metrics: Record<string, any>;
  vocabulary_metrics: Record<string, any>;
  argument_metrics: Record<string, any>;
  sub_scores: Record<string, number>;
  highlight_reel: { best_moments: string[]; improvement_areas: string[] };
  recommendation: string;
  total_tokens: number;
  total_cost_usd: number;
  created_at: string;
};

export type UsageLog = {
  total_tokens: number;
  total_cost_usd: number;
  calls: {
    call_type: string;
    model: string;
    input_tokens: number;
    output_tokens: number;
    total_tokens: number;
    cost_usd: number;
    created_at: string;
  }[];
};

function getToken(): string | null {
  if (typeof window === "undefined") return null;
  return localStorage.getItem("soulfluent_token");
}

export function setToken(token: string) {
  localStorage.setItem("soulfluent_token", token);
}

export function clearToken() {
  localStorage.removeItem("soulfluent_token");
}

async function request<T>(
  path: string,
  options: RequestInit = {}
): Promise<T> {
  const token = getToken();
  const headers: Record<string, string> = {
    ...(options.headers as Record<string, string>),
  };
  if (token) headers["Authorization"] = `Bearer ${token}`;
  if (!(options.body instanceof FormData) && options.body) {
    headers["Content-Type"] = "application/json";
  }

  const res = await fetch(`${API_URL}${path}`, { ...options, headers });
  if (!res.ok) {
    let detail = res.statusText;
    try {
      const data = await res.json();
      detail = data.detail || detail;
    } catch {
      /* ignore */
    }
    throw new Error(detail);
  }
  return res.json();
}

export const api = {
  register: (email: string, password: string, name: string) =>
    request<TokenResponse>("/auth/register", {
      method: "POST",
      body: JSON.stringify({ email, password, name }),
    }),
  login: (email: string, password: string) =>
    request<TokenResponse>("/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    }),
  me: () => request<User>("/auth/me"),

  getTopics: () => request<{ categories: Record<string, string[]> }>("/gd/topics"),

  createSession: (payload: {
    topic?: string;
    category?: string;
    difficulty?: string;
    duration_minutes?: number;
    persona_keys?: string[];
  }) =>
    request<GDSession>("/gd/sessions", {
      method: "POST",
      body: JSON.stringify(payload),
    }),

  listSessions: () => request<GDSession[]>("/gd/sessions"),
  getSession: (id: string) => request<GDSession>(`/gd/sessions/${id}`),
  getMessages: (id: string) => request<GDMessage[]>(`/gd/sessions/${id}/messages`),

  submitTurn: (id: string, audioBlob: Blob, durationSeconds: number) => {
    const form = new FormData();
    form.append("audio", audioBlob, "turn.webm");
    form.append("duration_seconds", String(durationSeconds));
    return request<TurnResponse>(`/gd/sessions/${id}/turn`, {
      method: "POST",
      body: form,
    });
  },

  endSession: (id: string) =>
    request<FeedbackReport>(`/gd/sessions/${id}/end`, { method: "POST" }),

  getReport: (id: string) => request<FeedbackReport>(`/gd/sessions/${id}/report`),
  getUsage: (id: string) => request<UsageLog>(`/gd/sessions/${id}/usage`),
};
