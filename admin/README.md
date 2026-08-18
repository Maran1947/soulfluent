# FluentSoul Admin Read-Only Dashboard

Standalone, read-only Admin Dashboard for FluentSoul platform metrics, session costs, transcript history, daily speak analysis, signup/onboarding conversion rates, and streak leaderboard.

## Development

```bash
cd admin
npm install
npm run dev
```

App runs at http://localhost:3001.

## Features

- **Overview Dashboard**: Total signups, onboarded %, started tracks, total platform LLM cost ($USD), signup sources, and CEFR distribution.
- **User Sessions & Cost**: View all sessions with total tokens used and calculated LLM usage costs ($USD). Search and filter by status or mode.
- **Detail Session Message & Cost Breakdown**: Modal view showing turn-by-turn message log (speaker, role, text, duration), feedback report, and itemized LLM call cost log (`stt`, `turn`, `tts`, `analysis`).
- **Daily Speak with Cost**: Log of daily speak practice, completed dates, audio durations, and associated LLM costs.
- **Streak-Wise User Leaderboard**: Dynamic user ranking based on consecutive daily streaks, completed sessions, track activities, and total speaking time.
- **Strictly Read-Only**: No edit/write endpoints or data mutations.
