# Architecture & Product Decisions

## ADR-001 — Ojoro is not an AI application
Status: accepted.

The source concept contains a future AI recommendation idea, but the current owner instruction explicitly states the product is not an AI app. No model/provider/agent dependency is included. Matching and ranking are deterministic and explainable.

## ADR-002 — Modular monolith over microservices
Status: accepted.

Next.js + Supabase provides sufficient scale, auth, realtime and transactional boundaries for the initial product. Domain modules stay separable so services can be extracted only after measured operational need.

## ADR-003 — Supabase is authoritative for identity/data
Status: accepted.

Use the existing connected `Ojoro Command Centre` project after schema inspection. Git migrations are canonical. RLS is required on all user/community data.

## ADR-004 — Competition is opt-in
Status: accepted.

Social/Fitness/Competitive/Learning modes exist on activities and user preference. Ratings update only from competitive, sufficiently verified results.

## ADR-005 — Separate XP, Ojoro Score and skill rating
Status: accepted.

Lifetime XP = cumulative participation/contribution progression and never decreases. Ojoro Score = current broad engagement/progress score. Skill rating = sport-specific competitive estimate. Keeping them separate prevents elite skill from becoming the only definition of progress.

## ADR-006 — Location privacy before precision
Status: accepted.

Profile stores city, not home coordinates. Event coordinates are optional. Exact address may be visibility-gated. “Nearby” can degrade to city-based discovery.

## ADR-007 — Existing production data is preserved
Status: accepted.

Before applying Ojoro schema migrations to the existing Supabase project, inspect current migrations/tables. Migrations are additive/forward-compatible and must not drop or truncate existing user data without explicit owner approval.
