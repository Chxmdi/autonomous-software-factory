# Project Context — Ojoro

## Identity

- Product name: **Ojoro**
- Repository: `Chxmdi/autonomous-software-factory` (product branch: `product/ojoro-platform`)
- Product owner: Chimdindu Okelekwe
- Current stage: implementation

## Outcome

Ojoro is a real-world social operating system for physical activity. It should create reasons for people to get outside, join communities, participate consistently, compete when they want to, meet people, and build a visible history of movement.

## Product truth

- Canonical requirements: `docs/requirements/OJORO_REQUIREMENTS.md`
- Approved design reference: `docs/UX_SPEC.md` + `docs/DESIGN_SYSTEM.md`
- Target users: people looking for activities/people/clans; community organizers; team captains/coaches; competitive participants
- Core loop: **Discover → Join/Create Clan → Show Up → Participate → Track → Compete (optional) → Earn Status → Meet People → Repeat**

## Scope

- In scope: identity/profile, sports passport, clans/teams/roles, discover, activity creation and RSVP, attendance/reliability, feeds, chat, goals, XP/levels/Ojoro Score, challenges, leaderboards, matches/results, tournaments, seasons, reputation, safety/reporting, notifications, availability/status, calendar surfaces and mobile-first responsive UX.
- Non-goal: Ojoro is **not an AI app**. No LLM, agent, chatbot, RAG, generative recommendation, or probabilistic control path is part of this release.
- Non-goal: medical coaching or health diagnosis.
- Non-goal: requiring a wearable to participate.
- Target release: production-capable web/PWA foundation with all core domain primitives; external wearable/calendar provider integrations can ship behind explicit integrations later.

## Environment

- Local: Next.js + Supabase local/remote schema
- Test: GitHub Actions
- Staging: Vercel preview + Supabase branch/target when configured
- Production: Vercel + Supabase `Ojoro Command Centre`

## Standing decisions and authorization

- Repository writes: allowed within this explicit build request.
- Branch/PR creation: allowed; use a dedicated product branch and PR.
- Production database: inspect before migration; migration-backed writes only.
- Production deployment: release-gated.
- Destructive production actions: explicit per-action approval.
- Existing product data must never be dropped or reset by an application migration.

## Open product decisions

- Final commercial model (free, organizer subscription, event fees) is intentionally not coupled to the initial architecture.
- Calendar provider OAuth and wearable providers require future provider credentials and privacy review.
- Precise live-location sharing is excluded until a dedicated safety/privacy review.
