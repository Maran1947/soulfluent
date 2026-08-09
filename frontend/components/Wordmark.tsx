import Image from "next/image";

export default function Wordmark({ tagline }: { tagline?: string }) {
  return (
    <div className="text-left mb-8">
      <div className="flex items-center gap-3 mb-3">
        {/* Mascot Logo Icon */}
        <div className="w-11 h-11 relative rounded-2xl overflow-hidden shadow-md shadow-[#F25C40]/20 shrink-0 bg-[#0D0F12]">
          <Image
            src="/icon.png"
            alt="FluentSoul Mascot Logo"
            fill
            className="object-cover"
            priority
          />
        </div>
        <span className="text-2xl font-bold tracking-tight">
          <span className="text-slate-900 dark:text-slate-100">Fluent</span>
          <span className="text-[#F25C40]">Soul</span>
        </span>
      </div>
      {tagline && (
        <p className="text-xs sm:text-sm text-slate-500 dark:text-slate-400 font-medium leading-relaxed max-w-xs">
          {tagline}
        </p>
      )}
    </div>
  );
}
