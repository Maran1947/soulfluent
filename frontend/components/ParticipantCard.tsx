"use client";

// Color is characterization: each persona keeps the same hue everywhere in
// the app (transcript bubbles, avatars, report sub-scores) so users learn
// to recognize "who's talking" at a glance, the way you would in a real GD.
const PERSONA_STYLE: Record<
  string,
  { avatar: string; ring: string; dot: string; soft: string }
> = {
  riya: { avatar: "bg-sage", ring: "ring-sage", dot: "bg-sage", soft: "bg-sage-soft" },
  meera: { avatar: "bg-apricot", ring: "ring-apricot", dot: "bg-apricot", soft: "bg-apricot-soft" },
  user: { avatar: "bg-lavender", ring: "ring-lavender", dot: "bg-lavender", soft: "bg-lavender-soft" },
};

const FALLBACK = { avatar: "bg-slate-400", ring: "ring-slate-400", dot: "bg-slate-400", soft: "bg-slate-100" };

export default function ParticipantCard({
  name,
  isSpeaking,
  isUser = false,
}: {
  name: string;
  isSpeaking: boolean;
  isUser?: boolean;
}) {
  const key = isUser ? "user" : name.toLowerCase();
  const style = PERSONA_STYLE[key] || FALLBACK;
  const initial = name.charAt(0).toUpperCase();

  return (
    <div
      className={`card p-4 flex flex-col items-center gap-2 transition-shadow duration-300 ${
        isSpeaking ? `ring-2 ${style.ring}/60` : ""
      }`}
    >
      <div
        className={`relative w-14 h-14 rounded-full ${style.avatar} text-white flex items-center
          justify-center text-lg font-semibold font-display`}
      >
        {initial}
        {isSpeaking && (
          <span className={`absolute -inset-1.5 rounded-full border-2 ${style.ring}/50 animate-ping`} />
        )}
      </div>
      <span className="text-sm font-medium">{name}</span>
      {isSpeaking ? (
        <div className="flex items-end gap-[2.5px] h-3.5" aria-label="Speaking">
          {[0, 1, 2].map((i) => (
            <span
              key={i}
              className={`w-[3px] rounded-full ${style.dot} motion-safe:animate-wave`}
              style={{ height: "100%", animationDelay: `${i * 0.15}s` }}
            />
          ))}
        </div>
      ) : (
        <span className="text-xs text-ink/40">Listening</span>
      )}
    </div>
  );
}
