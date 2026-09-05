# Ojoro Architecture

## Decision summary

Ojoro uses a **modular monolith**: a Next.js 16 web application with server actions/server components and Supabase for Postgres, Auth, Storage and Realtime. This is the simplest architecture that provides transactional integrity, row-level authorization, mobile-first web delivery, realtime chat and a path to native clients later without premature microservices.

## System context

```text
Browser / PWA
   │ HTTPS
   ▼
Next.js application (Vercel)
   ├── Server Components: reads
   ├── Server Actions: validated mutations
   ├── Domain modules: deterministic scoring/rules
   └── Auth session bridge
        │
        ▼
Supabase
   ├── Auth
   ├── Postgres + RLS
   ├── Realtime (chat/feed subscriptions)
   └── Storage (avatars/event media)
```

No AI service exists in the architecture.

## Trust boundaries

1. Browser is untrusted. IDs, role claims, scores, XP, attendance and ownership supplied by the client are never authoritative.
2. Next.js server derives user identity from Supabase auth claims/session.
3. Postgres RLS is the final authorization boundary for user-owned/community data.
4. Database functions that change XP/rating/reputation run with tightly scoped security definer permissions and fixed `search_path`.
5. Service-role credentials, if ever needed for operations, stay server-side and are not required for normal participant flows.

## Modules

- `auth` — session and onboarding.
- `identity` — profile, sports, intents, availability, follows/blocks.
- `clans` — clans, membership, roles, teams, clan progression.
- `activities` — events, RSVP/waitlist, attendance, pickup/rescue, recaps.
- `competition` — results, sport metrics, ratings, leaderboards, seasons.
- `challenges` — personal/friend/clan/city/global goals and progress.
- `social` — feed, reactions/comments, chat channels/messages, statuses.
- `safety` — reports, blocks, organizer verification state.
- `progression` — XP ledger, levels, achievements, passport, Ojoro Score, community impact.
- `notifications` — durable in-app notifications and future provider fan-out.
- `tournaments` — entries, fixtures, standings and format metadata.

## Read/write flow

```text
UI submit
→ Zod parse
→ resolve authenticated user
→ domain permission/precondition check
→ Supabase query/mutation
→ DB constraints + RLS
→ transaction/trigger derived state
→ revalidate affected routes
→ typed result / safe error
```

## Realtime

Realtime is an enhancement, not a correctness requirement. Chat and feed can subscribe to permitted rows. Write acknowledgement comes from the database mutation; reconnect/refetch repairs missed realtime events.

## Scoring boundary

- XP is append-only in `xp_ledger` with idempotent source keys.
- Lifetime XP never decreases.
- Level derives from lifetime XP.
- Ojoro Score is a transparent, recomputable 0–1000 engagement/progress score and does not equal skill.
- Skill rating is sport-specific and seasonal; only verified competitive results may change it.
- Reliability is derived from recent attendance with excused/organizer-cancelled events excluded.

## Location

Store city and optional event coordinates. User profile does not require precise home coordinates. Discovery accepts coarse client coordinates only for the current request and can fall back to city filters. Exact private-event address visibility is handled separately from broad location labels.

## Scale assumptions / NFRs

Initial target: 100k registered users, 10k daily actives, 100k activities/month, bursty chat. Postgres remains authoritative. Common list queries are cursor/limit bounded and indexed on time, city, sport, clan and membership dimensions.

Targets:
- p95 cached/static navigation < 500ms server response where applicable.
- p95 normal DB-backed page/server action < 1.5s excluding user network.
- no unbounded leaderboard/feed query.
- availability objective 99.9% after production launch.
- RPO ≤ 24h using managed backups; RTO target ≤ 4h for catastrophic data recovery, with forward-fix preferred for application releases.

## Deployment topology

GitHub → CI → Vercel preview → release gates → Vercel production. Supabase migrations are versioned in `supabase/migrations` and applied before production app promotion. Rollback prioritizes forward-compatible migrations; destructive migrations require separate owner approval and a staged deprecation cycle.
