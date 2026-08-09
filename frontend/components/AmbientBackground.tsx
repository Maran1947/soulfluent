export default function AmbientBackground() {
  return (
    <div className="fixed inset-0 -z-10 overflow-hidden bg-[#faf5f3] dark:bg-[#0f121a] transition-colors duration-300 pointer-events-none">
      {/* Top Left Warm Peach Ambient Aura Glow */}
      <div className="absolute -top-32 -left-20 w-[44rem] h-[44rem] rounded-full bg-[#fdece7]/70 dark:bg-rose-950/20 blur-3xl" />

      {/* Bottom Left Topographic Waveform Line Art (matching user mockup) */}
      <div className="absolute bottom-0 left-0 w-[45rem] h-[35rem] opacity-40 dark:opacity-10 pointer-events-none select-none overflow-hidden">
        <svg
          viewBox="0 0 800 600"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="w-full h-full stroke-[#f25c40]/25 dark:stroke-rose-500/20"
        >
          <path
            d="M-100 600 C 100 500, 250 400, 350 250 C 450 100, 300 0, 200 -100"
            strokeWidth="1.2"
          />
          <path
            d="M-80 600 C 120 480, 270 380, 370 230 C 470 80, 320 -20, 220 -100"
            strokeWidth="1.2"
          />
          <path
            d="M-60 600 C 140 460, 290 360, 390 210 C 490 60, 340 -40, 240 -100"
            strokeWidth="1.2"
          />
          <path
            d="M-40 600 C 160 440, 310 340, 410 190 C 510 40, 360 -60, 260 -100"
            strokeWidth="1.2"
          />
          <path
            d="M-20 600 C 180 420, 330 320, 430 170 C 530 20, 380 -80, 280 -100"
            strokeWidth="1.2"
          />
          <path
            d="M0 600 C 200 400, 350 300, 450 150 C 550 0, 400 -100, 300 -100"
            strokeWidth="1.2"
          />
          <path
            d="M20 600 C 220 380, 370 280, 470 130 C 570 -20, 420 -120, 320 -100"
            strokeWidth="1.2"
          />
          <path
            d="M40 600 C 240 360, 390 260, 490 110 C 590 -40, 440 -140, 340 -100"
            strokeWidth="1.2"
          />
          <path
            d="M60 600 C 260 340, 410 240, 510 90 C 610 -60, 460 -160, 360 -100"
            strokeWidth="1.2"
          />
          <path
            d="M80 600 C 280 320, 430 220, 530 70 C 630 -80, 480 -180, 380 -100"
            strokeWidth="1.2"
          />
        </svg>
      </div>
    </div>
  );
}
