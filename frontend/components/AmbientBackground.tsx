export default function AmbientBackground() {
  return (
    <div className="fixed inset-0 -z-10 overflow-hidden bg-gradient-to-br from-dawn-peach via-dawn-lavender to-dawn-sage">
      <div className="absolute -top-24 -left-20 w-80 h-80 rounded-full bg-lavender/30 blur-3xl motion-safe:animate-drift" />
      <div className="absolute top-1/3 -right-24 w-96 h-96 rounded-full bg-apricot/25 blur-3xl motion-safe:animate-drift-slow" />
      <div className="absolute bottom-0 left-1/4 w-96 h-96 rounded-full bg-sage/30 blur-3xl motion-safe:animate-drift" />
    </div>
  );
}
