"use client";

// Tier reads as a word, not just a number — "overall score" is an abstract
// concept, the tier label is what someone actually acts on.
function tier(score: number): { color: string; deep: string; label: string } {
  if (score >= 80) return { color: "#5FA88E", deep: "#3E7E68", label: "Strong" };
  if (score >= 60) return { color: "#6F6BC7", deep: "#524FA0", label: "Solid" };
  if (score >= 40) return { color: "#E7A66D", deep: "#C97E3F", label: "Building" };
  return { color: "#E07A6B", deep: "#B85B4E", label: "Early days" };
}

export default function ScoreGauge({ score, label }: { score: number; label?: string }) {
  const clamped = Math.max(0, Math.min(100, score));
  const radius = 54;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference - (clamped / 100) * circumference;
  const t = tier(clamped);
  const gradientId = "score-gauge-gradient";

  return (
    <div className="flex flex-col items-center gap-1.5">
      <svg width="148" height="148" viewBox="0 0 140 140">
        <defs>
          <linearGradient id={gradientId} x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor={t.color} />
            <stop offset="100%" stopColor={t.deep} />
          </linearGradient>
        </defs>
        <circle cx="70" cy="70" r={radius} fill="none" stroke="#EFEBFB" strokeWidth="12" />
        <circle
          cx="70"
          cy="70"
          r={radius}
          fill="none"
          stroke={`url(#${gradientId})`}
          strokeWidth="12"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          strokeLinecap="round"
          transform="rotate(-90 70 70)"
          style={{ transition: "stroke-dashoffset 0.8s ease" }}
        />
        <text
          x="70"
          y="72"
          textAnchor="middle"
          fontSize="32"
          fontWeight="600"
          fontFamily="var(--font-display)"
          fill="#2B2A3D"
        >
          {Math.round(clamped)}
        </text>
        <text x="70" y="90" textAnchor="middle" fontSize="11" fill="#6B6980">
          {t.label}
        </text>
      </svg>
      {label && <span className="text-sm text-ink-soft">{label}</span>}
    </div>
  );
}
