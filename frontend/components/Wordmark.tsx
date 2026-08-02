export default function Wordmark({ tagline }: { tagline?: string }) {
  return (
    <div className="text-left mb-8">
      <div className="flex items-center gap-3 mb-3">
        {/* Coral Audio Soundwave Badge Icon */}
        <div className="w-11 h-11 bg-gradient-to-br from-[#FA5A3A] to-[#F25C40] rounded-2xl flex items-center justify-center gap-[3px] shadow-md shadow-[#F25C40]/20 shrink-0">
          <span className="w-[3px] h-3.5 bg-white rounded-full"></span>
          <span className="w-[3px] h-5 bg-white rounded-full"></span>
          <span className="w-[3px] h-6 bg-white rounded-full"></span>
          <span className="w-[3px] h-4 bg-white rounded-full"></span>
          <span className="w-[3px] h-2.5 bg-white rounded-full"></span>
        </div>
        <span className="text-2xl font-bold tracking-tight">
          <span className="text-slate-900 dark:text-slate-100">Soul</span>
          <span className="text-[#F25C40]">Fluent</span>
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
