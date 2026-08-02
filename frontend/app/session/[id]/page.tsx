"use client";

import { useEffect, useRef, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { MessageSquareText, PhoneOff, ShieldCheck, X, Sparkles } from "lucide-react";
import { useAuth } from "@/lib/auth";
import { api, GDMessage, GDSession } from "@/lib/api";
import MicButton from "@/components/MicButton";
import ParticipantCard from "@/components/ParticipantCard";
import ThemeToggle from "@/components/ThemeToggle";
import { useTheme } from "@/lib/theme";

const PERSONA_BUBBLE: Record<string, { dark: string; light: string }> = {
  riya: {
    dark: "bg-emerald-950/80 border border-emerald-800/60 text-emerald-100",
    light: "bg-emerald-50 border border-emerald-200 text-emerald-950",
  },
  meera: {
    dark: "bg-amber-950/80 border border-amber-800/60 text-amber-100",
    light: "bg-amber-50 border border-amber-200 text-amber-950",
  },
};

const PERSONA_DOT: Record<string, string> = {
  riya: "bg-emerald-500",
  meera: "bg-amber-500",
};

function formatTime(seconds: number) {
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${m}:${s.toString().padStart(2, "0")}`;
}

function base64ToAudioUrl(base64: string): string {
  const byteChars = atob(base64);
  const byteNumbers = new Array(byteChars.length);
  for (let i = 0; i < byteChars.length; i++) byteNumbers[i] = byteChars.charCodeAt(i);
  const byteArray = new Uint8Array(byteNumbers);
  const blob = new Blob([byteArray], { type: "audio/wav" });
  return URL.createObjectURL(blob);
}

export default function SessionPage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const { user, loading } = useAuth();

  const [session, setSession] = useState<GDSession | null>(null);
  const [messages, setMessages] = useState<GDMessage[]>([]);
  const [speakingKey, setSpeakingKey] = useState<string | null>(null);
  const [processing, setProcessing] = useState(false);
  const [secondsRemaining, setSecondsRemaining] = useState<number | null>(null);
  const [error, setError] = useState("");
  const [ending, setEnding] = useState(false);
  const [showChat, setShowChat] = useState(true);
  const { theme: themeMode } = useTheme();

  const audioRef = useRef<HTMLAudioElement | null>(null);
  const transcriptEndRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (!loading && !user) router.push("/login");
  }, [loading, user, router]);

  useEffect(() => {
    if (!id) return;
    api.getSession(id).then((s) => {
      setSession(s);
      setSecondsRemaining(s.duration_minutes * 60);
    });
    api.getMessages(id).then(setMessages);
  }, [id]);

  useEffect(() => {
    transcriptEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  // local ticking clock between turns
  useEffect(() => {
    if (secondsRemaining === null || session?.status !== "active") return;
    const interval = setInterval(() => {
      setSecondsRemaining((prev) => (prev !== null ? Math.max(0, prev - 1) : prev));
    }, 1000);
    return () => clearInterval(interval);
  }, [secondsRemaining !== null, session?.status]);

  async function handleEnd() {
    if (!id || ending) return;
    setEnding(true);
    try {
      await api.endSession(id);
    } catch {
      /* session may already be ended */
    }
    router.push(`/session/${id}/report`);
  }

  async function handleRecordingComplete(blob: Blob, durationSeconds: number) {
    if (!id) return;
    setProcessing(true);
    setSpeakingKey("user");
    setError("");
    try {
      const turn = await api.submitTurn(id, blob, durationSeconds);
      setSpeakingKey(null);

      setMessages((prev) => [
        ...prev,
        {
          id: `local-user-${turn.turn_index}`,
          turn_index: turn.turn_index - 1,
          speaker: "user",
          text: turn.user_transcript,
          created_at: new Date().toISOString(),
        },
        {
          id: `local-ai-${turn.turn_index}`,
          turn_index: turn.turn_index,
          speaker: turn.ai_speaker,
          text: turn.ai_text,
          created_at: new Date().toISOString(),
        },
      ]);
      setSecondsRemaining(turn.seconds_remaining);

      const url = base64ToAudioUrl(turn.ai_audio_base64);
      const audio = new Audio(url);
      audioRef.current = audio;
      setSpeakingKey(turn.ai_speaker);
      audio.onended = () => {
        setSpeakingKey(null);
        setProcessing(false);
        URL.revokeObjectURL(url);
        if (turn.session_status === "completed") {
          handleEnd();
        }
      };
      await audio.play();
    } catch (e: any) {
      setError(e.message || "Something went wrong processing your turn");
      setProcessing(false);
      setSpeakingKey(null);
    }
  }

  if (loading || !user || !session) return null;

  const personaByKey = Object.fromEntries(session.personas.map((p) => [p.key, p]));
  const sessionOver = session.status !== "active";
  const low = secondsRemaining !== null && secondsRemaining <= 30 && secondsRemaining > 0;
  const isLight = themeMode === "light";

  return (
    <div className={`fixed inset-0 z-50 w-screen h-screen overflow-hidden p-4 sm:p-6 flex flex-col justify-between transition-colors duration-300 ${
      isLight
        ? "bg-slate-100 text-slate-900"
        : "bg-slate-950 text-white"
    }`}>
      {/* Google Meet Header Bar */}
      <div className={`flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b z-20 shrink-0 ${
        isLight ? "border-slate-200" : "border-slate-800/80"
      }`}>
        <div className="flex items-center gap-3 min-w-0">
          <div className={`flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold border ${
            isLight ? "bg-white border-slate-200 text-slate-700 shadow-sm" : "bg-slate-900 border-slate-800 text-slate-300"
          }`}>
            <ShieldCheck size={14} className="text-emerald-500" />
            <span>SoulFluent Room</span>
          </div>
          <h1 className={`font-semibold text-sm sm:text-base truncate tracking-tight ${isLight ? "text-slate-900" : "text-slate-100"}`}>
            {session.topic}
          </h1>
        </div>

        <div className="flex items-center gap-3 shrink-0 self-end sm:self-auto">
          {/* Timer Badge */}
          <div
            className={`px-3.5 py-1.5 rounded-full text-xs font-semibold tabular-nums border transition-colors ${
              low
                ? "bg-rose-950/80 text-rose-300 border-rose-800 animate-pulse"
                : isLight
                ? "bg-white text-slate-800 border-slate-200 shadow-sm"
                : "bg-slate-900 text-slate-200 border-slate-800"
            }`}
          >
            ⏱️ {secondsRemaining !== null ? formatTime(secondsRemaining) : "--:--"}
          </div>

          {/* In-Call Chat Toggle Button */}
          <button
            onClick={() => setShowChat((v) => !v)}
            className={`px-3.5 py-1.5 rounded-full text-xs font-semibold flex items-center gap-2 border transition-all ${
              showChat
                ? "bg-indigo-600 text-white border-indigo-500 shadow-sm"
                : isLight
                ? "bg-white text-slate-700 border-slate-200 hover:bg-slate-100 shadow-sm"
                : "bg-slate-900 text-slate-300 border-slate-800 hover:bg-slate-800"
            }`}
          >
            <MessageSquareText size={14} />
            <span className="hidden sm:inline">In-call messages</span>
            <span className={`px-1.5 py-0.2 rounded-full text-[10px] ${isLight ? "bg-slate-200 text-slate-800" : "bg-slate-950/60"}`}>
              {messages.length}
            </span>
          </button>

          {/* Theme Toggle at extreme top right corner */}
          <ThemeToggle />
        </div>
      </div>

      {/* Google Meet Room Main Stage Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-stretch flex-1 my-2 z-10 min-h-0 overflow-hidden">
        {/* Left / Main Stage: Google Meet Video Tiles Grid */}
        <div className={`${showChat ? "lg:col-span-7 xl:col-span-8" : "lg:col-span-12"} transition-all duration-300 flex flex-col justify-center`}>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 my-auto">
            {session.personas.map((p) => (
              <ParticipantCard key={p.key} name={p.name} isSpeaking={speakingKey === p.key} themeMode={themeMode} />
            ))}
            <ParticipantCard name="You" isUser isSpeaking={speakingKey === "user"} themeMode={themeMode} />
          </div>
        </div>

        {/* Right Sidebar: Google Meet In-Call Transcript / Messages */}
        {showChat && (
          <div className={`lg:col-span-5 xl:col-span-4 border rounded-2xl p-4 flex flex-col h-full motion-safe:animate-rise overflow-hidden ${
            isLight ? "bg-white border-slate-200 text-slate-900 shadow-md" : "bg-slate-900/90 border-slate-800 text-slate-100"
          }`}>
            <div className={`flex items-center justify-between pb-3 mb-3 border-b shrink-0 ${isLight ? "border-slate-200" : "border-slate-800"}`}>
              <div className="flex items-center gap-2">
                <MessageSquareText size={16} className="text-indigo-500" />
                <h3 className="text-xs font-semibold uppercase tracking-wider">
                  In-call messages
                </h3>
              </div>
              <button
                onClick={() => setShowChat(false)}
                className={`p-1 rounded-lg transition-colors ${isLight ? "text-slate-500 hover:bg-slate-100" : "text-slate-400 hover:text-white hover:bg-slate-800"}`}
              >
                <X size={16} />
              </button>
            </div>

            <div className="flex-1 overflow-y-auto pr-1 scroll-thin space-y-3">
              {messages.length === 0 && (
                <div className="h-full flex flex-col items-center justify-center text-center px-4 text-slate-400">
                  <Sparkles size={24} className="mb-2 text-indigo-500 opacity-60" />
                  <p className="text-xs font-medium">Messages will appear here as you and AI personas speak.</p>
                </div>
              )}
              {messages.map((m) => {
                const isUser = m.speaker === "user";
                const label = isUser ? "You" : personaByKey[m.speaker]?.name || m.speaker;
                const personaStyle = PERSONA_BUBBLE[m.speaker];
                const bubbleClass = isUser
                  ? "bg-indigo-600 text-white shadow-sm"
                  : isLight
                  ? personaStyle?.light || "bg-slate-100 border border-slate-200 text-slate-900"
                  : personaStyle?.dark || "bg-slate-800 text-slate-200 border border-slate-700";
                return (
                  <div key={m.id} className={`flex ${isUser ? "justify-end" : "justify-start"}`}>
                    <div className={`max-w-[88%] rounded-2xl px-3.5 py-2.5 text-xs leading-relaxed ${bubbleClass}`}>
                      <p className={`text-[10px] font-bold mb-1 flex items-center gap-1.5 ${isUser ? "text-indigo-200" : isLight ? "text-slate-600" : "text-slate-400"}`}>
                        {!isUser && (
                          <span className={`inline-block w-1.5 h-1.5 rounded-full ${PERSONA_DOT[m.speaker] || "bg-slate-400"}`} />
                        )}
                        {label}
                      </p>
                      {m.text}
                    </div>
                  </div>
                );
              })}
              <div ref={transcriptEndRef} />
            </div>
          </div>
        )}
      </div>

      {/* Google Meet Bottom Floating Action Bar / Dock */}
      <div className="fixed bottom-6 inset-x-0 z-30 flex justify-center px-4 pointer-events-none">
        <div className={`pointer-events-auto flex items-center gap-4 border rounded-full px-5 py-2.5 shadow-2xl backdrop-blur-xl transition-colors ${
          isLight ? "bg-white/95 border-slate-200 text-slate-800 shadow-2xl" : "bg-slate-900/95 border-slate-800 text-white"
        }`}>
          {sessionOver ? (
            <button onClick={handleEnd} className="btn-primary !py-2.5 !px-6 text-xs font-semibold shadow-lg">
              View Feedback Report →
            </button>
          ) : (
            <>
              {/* Integrated Live Speaking Status Badge */}
              <div className={`flex items-center gap-2 pr-3.5 border-r text-xs font-semibold ${
                isLight ? "border-slate-200 text-slate-700" : "border-slate-800 text-slate-300"
              }`}>
                <span className="relative flex h-2.5 w-2.5">
                  <span className={`animate-ping absolute inline-flex h-full w-full rounded-full ${speakingKey ? 'bg-emerald-400' : 'bg-slate-400'} opacity-75`}></span>
                  <span className={`relative inline-flex rounded-full h-2.5 w-2.5 ${speakingKey ? 'bg-emerald-500' : 'bg-slate-400'}`}></span>
                </span>
                <span className="whitespace-nowrap">
                  {processing
                    ? "AI responding…"
                    : speakingKey === "user"
                    ? "You are speaking…"
                    : speakingKey
                    ? `${personaByKey[speakingKey]?.name || speakingKey} speaking…`
                    : "Floor open — hold [Space] or Mic"}
                </span>
              </div>

              {/* Center Mic Button with Compact Mode */}
              <MicButton compact disabled={processing} onRecordingComplete={handleRecordingComplete} />

              {/* In-Call Chat Button */}
              <button
                onClick={() => setShowChat((v) => !v)}
                className={`w-12 h-12 rounded-full flex items-center justify-center border transition-all ${
                  showChat
                    ? "bg-indigo-600 border-indigo-500 text-white shadow-lg"
                    : isLight
                    ? "bg-slate-100 border-slate-300 text-slate-700 hover:bg-slate-200"
                    : "bg-slate-800 border-slate-700 text-slate-300 hover:bg-slate-700"
                }`}
                aria-label="Toggle in-call messages"
                title="Toggle In-call Messages"
              >
                <MessageSquareText size={20} />
              </button>

              {/* Leave / End Call Button */}
              <button
                onClick={handleEnd}
                disabled={ending}
                className="w-12 h-12 rounded-full bg-rose-600 hover:bg-rose-700 text-white flex items-center justify-center border border-rose-500 shadow-lg transition-all"
                aria-label="Leave call"
                title="Leave Call / End Session"
              >
                <PhoneOff size={20} />
              </button>
            </>
          )}
        </div>
      </div>

      {error && (
        <div className="absolute top-16 left-1/2 -translate-x-1/2 z-40 bg-rose-950/90 border border-rose-800 text-rose-200 px-4 py-2 rounded-full text-xs font-medium shadow-lg">
          {error}
        </div>
      )}
    </div>
  );
}
