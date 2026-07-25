export default function AmbientBackground() {
  return (
    <div className="fixed inset-0 -z-10 overflow-hidden bg-slate-50">
      {/* Top Left Gradient Orb */}
      <div className="absolute -top-32 -left-20 w-[36rem] h-[36rem] rounded-full bg-indigo-100/70 blur-3xl motion-safe:animate-drift" />
      {/* Right Gradient Orb */}
      <div className="absolute top-1/4 -right-20 w-[40rem] h-[40rem] rounded-full bg-amber-100/60 blur-3xl motion-safe:animate-drift-slow" />
      {/* Bottom Left Gradient Orb */}
      <div className="absolute -bottom-24 left-1/3 w-[36rem] h-[36rem] rounded-full bg-emerald-100/60 blur-3xl motion-safe:animate-drift" />
    </div>
  );
}
