"use client";

import { useRef, useState } from "react";
import { Mic } from "lucide-react";

type Props = {
  disabled?: boolean;
  onRecordingComplete: (blob: Blob, durationSeconds: number) => void;
};

export default function MicButton({ disabled, onRecordingComplete }: Props) {
  const [recording, setRecording] = useState(false);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const startTimeRef = useRef<number>(0);
  const streamRef = useRef<MediaStream | null>(null);

  async function startRecording() {
    if (disabled || recording) return;
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      streamRef.current = stream;
      const mimeType = MediaRecorder.isTypeSupported("audio/webm")
        ? "audio/webm"
        : "audio/mp4";
      const recorder = new MediaRecorder(stream, { mimeType });
      chunksRef.current = [];
      recorder.ondataavailable = (e) => {
        if (e.data.size > 0) chunksRef.current.push(e.data);
      };
      recorder.onstop = () => {
        const durationSeconds = (Date.now() - startTimeRef.current) / 1000;
        const blob = new Blob(chunksRef.current, { type: mimeType });
        streamRef.current?.getTracks().forEach((t) => t.stop());
        if (durationSeconds > 0.4) {
          onRecordingComplete(blob, durationSeconds);
        }
      };
      mediaRecorderRef.current = recorder;
      startTimeRef.current = Date.now();
      recorder.start();
      setRecording(true);
    } catch (err) {
      console.error("Mic access denied or unavailable", err);
    }
  }

  function stopRecording() {
    if (mediaRecorderRef.current && recording) {
      mediaRecorderRef.current.stop();
      setRecording(false);
    }
  }

  return (
    <div className="flex flex-col items-center gap-3">
      <button
        disabled={disabled}
        onMouseDown={startRecording}
        onMouseUp={stopRecording}
        onMouseLeave={stopRecording}
        onTouchStart={(e) => {
          e.preventDefault();
          startRecording();
        }}
        onTouchEnd={(e) => {
          e.preventDefault();
          stopRecording();
        }}
        aria-pressed={recording}
        aria-label={recording ? "Recording — release to send" : "Hold to speak"}
        className={`relative select-none w-20 h-20 rounded-full flex items-center justify-center transition-all duration-200
          ${
            recording
              ? "bg-rose-500 shadow-[0_10px_30px_-8px_rgba(244,63,94,0.6)] scale-105"
              : "bg-lavender shadow-glow-lavender hover:bg-lavender-deep"
          }
          disabled:opacity-40 disabled:cursor-not-allowed`}
      >
        {recording && (
          <>
            <span className="absolute inset-0 rounded-full bg-rose-500/40 animate-ping" />
            <span className="absolute -inset-2 rounded-full border border-rose-400/50" />
          </>
        )}
        {recording ? (
          <div className="relative z-10 flex items-end gap-[3px] h-6">
            {[0, 1, 2, 3].map((i) => (
              <span
                key={i}
                className="w-[3px] rounded-full bg-white motion-safe:animate-wave"
                style={{ height: "100%", animationDelay: `${i * 0.12}s` }}
              />
            ))}
          </div>
        ) : (
          <Mic size={26} className="relative z-10 text-white" strokeWidth={2.2} />
        )}
      </button>
      <p className="text-xs font-medium text-ink-soft">
        {recording
          ? "Release to send"
          : disabled
          ? "Please wait…"
          : "Hold to speak"}
      </p>
    </div>
  );
}
