# SoulFluent

Voice-first Group Discussion (GD) practice, MVP scope: two AI personas
(Riya — empathetic peacemaker, Meera — confident contrarian), voice in/out,
and a full post-session feedback report.

Backend and frontend are **fully separate projects** — separate
`docker-compose.yml`, separate `Makefile`, independently buildable/deployable.
They only talk to each other over HTTP (`NEXT_PUBLIC_API_URL`).

## Stack

- **Backend** (`/backend`): FastAPI, SQLAlchemy (async) + PostgreSQL, Alembic,
  Pydantic v2, Gemini (speech understanding for STT, structured JSON output
  for persona turns, TTS for voice)
- **Frontend** (`/frontend`): Next.js (App Router) + Tailwind CSS

## Running the backend

### Native mode (recommended for dev)

Postgres runs in Docker, everything else runs directly on your Mac:

```
cd backend
python3 -m venv .venv && source .venv/bin/activate
make install
cp .env.example .env        # add your GEMINI_API_KEY; DATABASE_URL already points at localhost:5346
make db                      # starts just Postgres, in the background
make migrate-local            # run once
make run                      # uvicorn with --reload
```

Backend runs at http://localhost:8000 (docs at `/docs`).

### Full Docker mode

```
cd backend
cp .env.example .env        # add your GEMINI_API_KEY, and switch DATABASE_URL to use db:5432
make up                      # starts postgres + backend
make migrate                 # run once, in another terminal
```

Either way, Postgres is exposed on host port `5346` if you want to connect a
GUI tool directly.

## Running the frontend

```
cd frontend
cp .env.local.example .env.local   # points at http://localhost:8000/api/v1 by default
npm install
npm run dev
```

Frontend runs at http://localhost:3000. (Docker mode is also available via
`make up` in that folder if you'd rather containerize it too.) It just needs
the backend URL above reachable — doesn't care whether the backend runs
natively or in Docker.

## How a session works

1. `POST /gd/sessions` creates a session with a topic, difficulty, duration,
   and the two MVP personas.
2. Each turn: the browser records a push-to-talk clip → `POST
   /gd/sessions/{id}/turn` → Gemini transcribes it, decides which persona
   responds next (a single structured-output call that folds in simple
   urgency/turn-fairness logic — who was addressed, who's been quiet, who has
   a counterpoint), generates that persona's in-character reply, and
   synthesizes it to speech. The browser plays it back and the loop
   continues until time runs out.
3. `POST /gd/sessions/{id}/end` computes objective metrics (WPM, filler
   words, talk-time %) from the stored turns and asks Gemini for the
   qualitative analysis (vocabulary, argument quality, highlights,
   recommendation), then stores the combined `FeedbackReport`.

## Notes / deliberate scope cuts (per product decision)

- No payments, no video avatars, no debate mode, no Flutter mobile app —
  this PRD's MVP was voice GD only.
- Two personas instead of the full four-persona + moderator cast from the
  PRD, to keep turn-taking logic simple. Time-boxing and turn fairness are
  handled in code (`turn_manager.py`), not by a separate Moderator persona.
- Auth is simple email/password + JWT, no password reset flow yet.
