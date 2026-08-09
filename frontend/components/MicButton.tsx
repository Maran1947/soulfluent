"use client";

import { useEffect, useRef, useState } from "react";
import { Mic } from "lucide-react";

type Props = {
  disabled?: boolean;
  compact?: boolean;
  onRecordingComplete: (blob: Blob, durationSeconds: number) => void;
};

export default function MicButton({ disabled, compact = false, onRecordingComplete }: Props) {
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
      const mimeType = MediaRecorder.isTypeSupported("audio/webm") ? "audio/webm" : "audio/mp4";
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

  const recordingRef = useRef(recording);
  recordingRef.current = recording;
  const disabledRef = useRef(disabled);
  disabledRef.current = disabled;
  const isSpacePressedRef = useRef(false);

  useEffect(() => {
    function isEditableTarget(element: Element | null): boolean {
      if (!element) return false;
      const tag = element.tagName.toLowerCase();
      if (tag === "input" || tag === "textarea") return true;
      return element instanceof HTMLElement && element.isContentEditable;
    }

    function handleKeyDown(e: KeyboardEvent) {
      if (e.code !== "Space" && e.key !== " ") return;

      if (isEditableTarget(document.activeElement)) return;

      if (!isSpacePressedRef.current && !disabledRef.current && !recordingRef.current) {
        e.preventDefault();
        isSpacePressedRef.current = true;
        startRecording();
      } else if (isSpacePressedRef.current) {
        e.preventDefault();
      }
    }

    function handleKeyUp(e: KeyboardEvent) {
      if (e.code === "Space" || e.key === " ") {
        if (isEditableTarget(document.activeElement)) return;

        if (isSpacePressedRef.current) {
          e.preventDefault();
          isSpacePressedRef.current = false;
          stopRecording();
        }
      }
    }

    window.addEventListener("keydown", handleKeyDown);
    window.addEventListener("keyup", handleKeyUp);

    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      window.removeEventListener("keyup", handleKeyUp);
    };
  }, []);

  const labelText = recording
    ? "Release [Space] or Mic to send"
    : disabled
      ? "Please wait…"
      : "Hold [Space] or Mic to speak";

  if (compact) {
    return (
      <div className="relative group flex items-center justify-center">
        {/* Floating Tooltip Above Button */}
        <div className="absolute -top-10 left-1/2 -translate-x-1/2 opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none z-50 whitespace-nowrap bg-slate-900 text-white text-[11px] font-semibold px-2.5 py-1 rounded-md shadow-lg border border-slate-700">
          {labelText}
        </div>

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
          aria-label={labelText}
          className={`relative select-none w-12 h-12 rounded-full flex items-center justify-center transition-all duration-200 ${
            recording
              ? "bg-rose-600 border border-rose-500 shadow-[0_0_20px_rgba(242,92,64,0.6)] scale-105"
              : "bg-[#F25C40] border border-[#FA5A3A] text-white hover:bg-[#E04B30] shadow-md shadow-[#F25C40]/20"
          } disabled:opacity-40 disabled:cursor-not-allowed`}
        >
          {recording && (
            <>
              <span className="absolute inset-0 rounded-full bg-rose-500/40 animate-ping" />
              <span className="absolute -inset-1 rounded-full border border-rose-400/50" />
            </>
          )}
          {recording ? (
            <div className="relative z-10 flex items-end gap-[2px] h-4">
              {[0, 1, 2, 3].map((i) => (
                <span
                  key={i}
                  className="w-[2.5px] rounded-full bg-white motion-safe:animate-wave"
                  style={{ height: "100%", animationDelay: `${i * 0.12}s` }}
                />
              ))}
            </div>
          ) : (
            <Mic size={20} className="relative z-10 text-white" strokeWidth={2.2} />
          )}
        </button>
      </div>
    );
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
        aria-label={labelText}
        className={`relative select-none w-20 h-20 rounded-full flex items-center justify-center transition-all duration-200
          ${
            recording
              ? "bg-rose-500 shadow-[0_10px_30px_-8px_rgba(242,92,64,0.6)] scale-105"
              : "bg-[#F25C40] shadow-md shadow-[#F25C40]/25 hover:bg-[#E04B30]"
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
      <p className="text-xs font-medium text-slate-600 dark:text-slate-400">{labelText}</p>
    </div>
  );
}
