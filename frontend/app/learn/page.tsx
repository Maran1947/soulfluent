"use client";

import { BookOpen } from "lucide-react";
import Link from "next/link";

export default function LearnPage() {
  return (
    <div className="pt-6 flex flex-col items-center text-center">
      <div className="w-16 h-16 rounded-full bg-sage-soft flex items-center justify-center mb-5">
        <BookOpen size={26} className="text-sage-deep" />
      </div>
      <h2 className="font-display text-xl text-ink mb-2">Learn is warming up</h2>
      <p className="text-sm text-ink-soft max-w-xs mb-6">
        Bite-sized lessons on vocabulary, grammar, and speaking confidence are
        on their way. For now, the fastest way to build fluency is a real
        conversation.
      </p>
      <Link href="/" className="btn-primary">
        Start a practice session
      </Link>
    </div>
  );
}
