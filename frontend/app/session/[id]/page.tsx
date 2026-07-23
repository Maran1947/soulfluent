"use client";

import { useEffect, useRef, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth";
import { api, GDMessage, GDSession } from "@/lib/api";
import MicButton from "@/components/MicButton";
import ParticipantCard from "@/components/ParticipantCard";

const PERSONA_BUBBLE: Record<string, string> = {
  riya: "bg-sage-soft text-ink",
  meera: "bg-apricot-soft text-ink",
};
const PERSONA_DOT: Record<string, string> = {
  riya: "bg-sage",
  meera: "bg-apricot",
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

  return (
    <div className="max-w-3xl mx-auto py-6 min-h-screen flex flex-col">
      <div className="flex items-center justify-between mb-6">
        <div className="min-w-0">
          <p className="eyebrow mb-1">
            {session.category.replace(/_/g, " ")} · {session.difficulty}
          </p>
          <h1 className="text-xl font-semibold tracking-tight truncate">{session.topic}</h1>
        </div>
        <div className="flex items-center gap-3 shrink-0">
          <div
            className={`card px-4 py-2 text-sm font-medium tabular-nums transition-colors ${
              low ? "text-rose-500" : ""
            }`}
          >
            {secondsRemaining !== null ? formatTime(secondsRemaining) : "--:--"}
          </div>
          <button onClick={handleEnd} disabled={ending} className="btn-secondary !py-2 !px-4 text-xs">
            {ending ? "Ending…" : "End session"}
          </button>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-3 mb-6">
        {session.personas.map((p) => (
          <ParticipantCard key={p.key} name={p.name} isSpeaking={speakingKey === p.key} />
        ))}
        <ParticipantCard name="You" isUser isSpeaking={speakingKey === "user"} />
      </div>

      <div className="card p-4 mb-6 flex-1 min-h-[18rem] max-h-[26rem] overflow-y-auto scroll-thin space-y-3">
        {messages.length === 0 && (
          <p className="text-sm text-ink-soft text-center mt-24">
            Hold the mic button below and share your opening point on the topic.
          </p>
        )}
        {messages.map((m) => {
          const isUser = m.speaker === "user";
          const label = isUser ? "You" : personaByKey[m.speaker]?.name || m.speaker;
          const bubbleClass = isUser
            ? "bg-lavender text-white"
            : PERSONA_BUBBLE[m.speaker] || "bg-ink/5 text-ink";
          return (
            <div key={m.id} className={`flex ${isUser ? "justify-end" : "justify-start"}`}>
              <div className={`max-w-[80%] rounded-2xl px-4 py-2.5 text-sm ${bubbleClass}`}>
                <p className="text-xs opacity-60 mb-0.5 flex items-center gap-1.5">
                  {!isUser && (
                    <span className={`inline-block w-1.5 h-1.5 rounded-full ${PERSONA_DOT[m.speaker] || "bg-ink-soft"}`} />
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

      {error && <p className="text-sm text-rose-500 mb-3 text-center">{error}</p>}

      <div className="flex justify-center pb-2">
        {sessionOver ? (
          <div className="text-center">
            <p className="text-sm text-ink-soft mb-3">This session has ended.</p>
            <button onClick={handleEnd} className="btn-primary">
              View feedback report
            </button>
          </div>
        ) : (
          <MicButton disabled={processing} onRecordingComplete={handleRecordingComplete} />
        )}
      </div>
    </div>
  );
}
