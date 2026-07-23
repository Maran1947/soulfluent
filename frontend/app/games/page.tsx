"use client";

import { Gamepad2 } from "lucide-react";
import Link from "next/link";

export default function GamesPage() {
  return (
    <div className="pt-6 flex flex-col items-center text-center">
      <div className="w-16 h-16 rounded-full bg-apricot-soft flex items-center justify-center mb-5">
        <Gamepad2 size={26} className="text-apricot-deep" />
      </div>
      <h2 className="font-display text-xl text-ink mb-2">Games are warming up</h2>
      <p className="text-sm text-ink-soft max-w-xs mb-6">
        Quick, playful drills for vocabulary and quick-thinking are on their
        way. For now, the fastest way to build fluency is a real conversation.
      </p>
      <Link href="/" className="btn-primary">
        Start a practice session
      </Link>
    </div>
  );
}
