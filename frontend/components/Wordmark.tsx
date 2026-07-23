// Shared brand mark for the two screens that exist outside AppChrome
// (login/register have no header). A single breathing dot echoes the
// ambient background orbs — the same "calm, alive" signature, just closer up.
export default function Wordmark({ tagline }: { tagline?: string }) {
  return (
    <div className="text-center mb-8">
      <div className="inline-flex items-center gap-2 mb-3">
        <span className="relative w-2.5 h-2.5 rounded-full bg-lavender">
          <span className="absolute inset-0 rounded-full bg-lavender/60 motion-safe:animate-ping" />
        </span>
        <span className="font-display italic text-2xl text-ink tracking-tight">SoulFluent</span>
      </div>
      {tagline && <p className="text-sm text-ink-soft">{tagline}</p>}
    </div>
  );
}
