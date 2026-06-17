# VoiceBridge AI — Production Architecture

AI-powered speech-therapy SaaS for **children**, **adults (rehab)**, **therapists**, and **clinics**.
Mobile + Web (Flutter), Laravel API, realtime WebSockets, and an AI Speech Engine.

> This repo currently hosts the **Flutter client**. This document is the master design
> for the whole platform; the Flutter app is being re-architected onto it incrementally
> (feature-by-feature) reusing the existing Clean-Architecture + Cubit foundation.

---

## 1) Modules (bounded contexts)

| # | Module | Users | Core |
|---|--------|-------|------|
| 1 | Child Therapy | Parent + Child | gamified speak/match/repeat games, AI correction |
| 2 | Adult Rehab | Adult patient | stroke/aphasia training, slow-speech, language rebuild |
| 3 | Therapist Platform | Therapist | patients, plans, recordings review, AI reports |
| 4 | Clinic Management | Clinic admin | appointments, records, video sessions, billing |
| 5 | **AI Speech Engine** | system | STT → phoneme analysis → error detection → scoring → feedback |

---

## 2) Flutter app structure (feature-first + Cubit)

```
lib/
├── core/                      # shared infra (existing, reused)
│   ├── constants/             # colors (Indigo/Cyan), gradients, app_constants
│   ├── theme/                 # AppTheme (dark default) + ThemeCubit
│   ├── networking/            # DioFactory, ApiResult, ApiErrorModel, interceptors
│   ├── realtime/              # WebSocketClient + event models   (NEW)
│   ├── services/              # SpeechService (STT), AudioRecorder, AiClient (NEW)
│   ├── cache/ di/ routing/ helper/ logic/ widgets/
├── features/
│   ├── auth/                  # login/register/otp/forgot/reset (role-aware)
│   ├── start/                 # splash / onboarding / role_selection
│   ├── child/                 # 👶 module (home, games, ai_speak, progress)
│   ├── adult/                 # 🧑 module (rehab plan, slow-speech, language)
│   ├── therapist/             # 👨‍⚕️ module (patients, plans, reviews, reports)
│   ├── clinic/                # 🏥 module (appointments, records, billing, video)
│   └── shared/                # gamification, analytics, chat, calls, notifications
├── gen/  generated/
```

**State management:** Cubit only. Async/network state via `ActionState` (idle/loading/
success/error); "trigger" cubits emit a revision `int` (data on fields) to force rebuilds.
DI via `get_it`. Routing: one central `AppRouter` + `context.pushScreen` (theme-reactive).

**Stack:** Flutter stable · flutter_bloc · get_it · dio (+ retrofit) · web_socket_channel ·
speech_to_text · audio_waveforms · camera · fl_chart · easy_localization (AR/EN, RTL) ·
flutter_screenutil · google_fonts (Cairo + Inter). Firebase = push only.

---

## 3) Backend (Laravel 11)

```
app/
├── Models/            User, Role, Patient, TherapyPlan, Exercise, SpeechSession,
│                      SpeechResult, Phoneme, Appointment, Chat, Message,
│                      Notification, Subscription, Invoice, Badge, Streak
├── Http/Controllers/Api/  Auth, Profile, TherapyPlan, Exercise, SpeechSession,
│                          Analysis, Progress, Appointment, Chat, Clinic, Billing
├── Services/          AiSpeechService (calls AI engine), ScoringService,
│                      ReportService, GamificationService, BillingService
├── Events/            SpeechAnalyzed, MessageSent, ProgressUpdated, SessionUpdated
├── Jobs/              ProcessSpeechAudio (queued), GenerateAiReport
└── Policies/          role/clinic scoping (RBAC + multi-tenant by clinic_id)
```

- **Auth:** Sanctum (token) + OTP; roles: `parent`, `child`, `adult`, `therapist`,
  `clinic_admin`, `super_admin`.
- **Multi-tenant:** every clinic-owned row carries `clinic_id`; global scope filters it.
- **Queues:** audio analysis runs in a queued Job (Redis), result pushed via WebSocket.
- **Storage:** S3 (audio recordings, reports PDF). Signed URLs.

---

## 4) Database schema (key tables)

```
roles(id, name)
users(id, role, name, email, phone, password, locale, clinic_id?, avatar, created_at)
patients(id, user_id, type[child|adult], age, condition, notes, therapist_id?, clinic_id?)
therapy_plans(id, patient_id, therapist_id, title, goal, level, active, created_at)
exercises(id, plan_id?, type[repeat|match|name|guess], word, phonemes, media, difficulty)
speech_sessions(id, patient_id, exercise_id?, started_at, ended_at, mode[child|adult])
speech_results(id, session_id, expected_text, recognized_text, audio_url,
               accuracy_score, emotion?, created_at)
phoneme_results(id, speech_result_id, phoneme, status[ok|missing|substituted|distorted],
                expected, actual)
progress(id, patient_id, metric[accuracy|streak|xp], value, period, recorded_at)
appointments(id, clinic_id, therapist_id, patient_id, starts_at, status, is_video)
chats(id, a_user_id, b_user_id, last_message_at)
messages(id, chat_id, sender_id, type[text|voice|image], body, media_url, status, created_at)
notifications(id, user_id, type, title, body, read, created_at)
subscriptions(id, user_id|clinic_id, plan, status, renews_at)
invoices(id, clinic_id, patient_id, amount, status, issued_at)
badges(id, name, icon, rule)   user_badges(user_id, badge_id, earned_at)
streaks(id, user_id, current, longest, last_active_on)
```

---

## 5) REST API (v1, `/api/v1`)

```
POST   /auth/register            POST /auth/login        POST /auth/otp/verify
POST   /auth/forgot              POST /auth/reset        POST /auth/logout
GET    /me                       PUT  /me                POST /me/avatar

# Therapy
GET    /plans                    POST /plans             GET  /plans/{id}
GET    /exercises?plan=          GET  /exercises/{id}

# Speech / AI
POST   /sessions                 # start a session
POST   /sessions/{id}/analyze    # multipart audio + expected_text  → SpeechResult
GET    /sessions/{id}/result
GET    /progress?patient=&range= # charts + weak phonemes

# Therapist / Clinic
GET    /patients?filter=         GET /patients/{id}      POST /patients/{id}/plan
GET    /appointments             POST /appointments      PUT  /appointments/{id}
GET    /reports/{patient}        # AI-generated report (PDF)

# Chat / Billing
GET    /chats   /chats/{id}/messages   POST /chats/{id}/messages
GET    /billing/invoices         POST /billing/subscribe
```

Envelope: `{ key:1|0, msg, data }` · auth: `Authorization: Bearer <token>`.

---

## 6) AI Speech Engine (core brain)

```
 audio (mobile mic) ─▶ upload ─▶ Laravel ─▶ queued Job ─▶ AI service
                                                  │
   1. STT            Whisper (self-host) / Google Speech  → recognized_text
   2. Phoneme        G2P (e.g. espeak-ng / phonemizer)    → /l/ /ʌ/ /v/
   3. Error detect   align expected↔actual phonemes       → missing/substituted/distorted
   4. Scoring        weighted phoneme accuracy            → 0..100
   5. Feedback gen   child=encouraging+emoji / adult=clinical
   6. Emotion (opt)  prosody model on audio               → frustration/confidence/stress
   7. Adaptive       update difficulty from rolling score
                                                  │
                       SpeechResult ──▶ WebSocket `speech.analyzed` ──▶ Flutter UI
```

**On-device fallback (client):** `speech_to_text` + `SpeechMatch` (Arabic normalization +
Levenshtein ratio) gives instant local scoring when offline / before server result —
already implemented in `core/services/speech_service.dart`.

Feedback example:
```
❌ You said: wuv      ✅ Correct: love      👉 Focus on the "L" sound      Score: 72
```

---

## 7) Realtime (WebSockets — Laravel Reverb / Pusher protocol)

Channels: `private-user.{id}`, `private-clinic.{id}`, `presence-session.{id}`.

| Event | Payload | Consumer |
|-------|---------|----------|
| `speech.analyzed` | result + phonemes + score | child/adult game UI |
| `message.sent` | message | chat |
| `progress.updated` | metric snapshot | dashboards |
| `session.updated` | status | therapist live view |
| `call.signal` | WebRTC offer/answer/ice | video sessions |

Client: `core/realtime/WebSocketClient` (reconnect + heartbeat) exposing typed streams
that Cubits subscribe to.

---

## 8) Gamification & Analytics

- **Gamification:** XP per exercise, levels, badges (rule-based), daily streaks, rewards.
  Client `GamificationCubit` mirrors server `streaks`/`badges`/`progress`.
- **Analytics:** accuracy-over-time (line), weak-phoneme heatmap (bar), session history,
  improvement rate %. `fl_chart` client; aggregation server-side in `/progress`.

---

## 9) Business model

Monthly subscription (patient) · Clinic plans (seats) · Therapist licenses · AI premium
coaching add-on. Enforced via `subscriptions` + middleware gates on premium endpoints.

---

## 10) Mock-data system

`AppConstants.useMockData=true` → repos return seeded data + simulated latency; AI uses the
on-device STT fallback. Flip to `false` to hit the live Laravel API with **zero UI/Cubit
changes** (only repo internals swap to the Retrofit ApiService).

---

## 11) Testing & Deployment

- **Testing:** unit (cubits/scoring), widget (screens + navigation no-crash), golden
  (key screens light/dark), integration (full game flow), backend Pest/PHPUnit + contract
  tests on the API envelope.
- **CI:** `flutter analyze` + `flutter test` on PR; Laravel `pest` + `phpstan`.
- **Deploy:** Flutter → Play/App Store + web build to CDN. Laravel → Docker (app + queue +
  Reverb) on a VPS/K8s; Postgres + Redis + S3; AI engine as a separate GPU service behind
  an internal queue. Blue/green releases, health checks, Sentry + structured logs.
