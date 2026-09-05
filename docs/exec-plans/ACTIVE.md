# Active Execution Plan — Ojoro

## Outcome
Ship a production-capable Ojoro web platform that satisfies the core real-world activity loop and establishes durable primitives for the full master feature set without AI dependencies.

## WP1 — Product + UX truth
Owner: Product Designer
Dependencies: source specification
Acceptance: product loop, scope, screen/state inventory, accessibility and design system explicit.
Verification: artifact review against requirements.
Status: complete.

## WP2 — Architecture/contracts/security
Owner: Project Designer
Dependencies: WP1
Acceptance: modular boundaries, data model, auth/RLS, contracts, NFRs, deployment/test strategy explicit.
Verification: architecture review + traceability.
Status: complete.

## WP3 — Database foundation
Owner: Database Specialist
Dependencies: WP2, live schema inspection
Acceptance: additive migrations for identity, clans, activities, social, progression, competition, challenges, safety and notifications; RLS enabled; critical constraints/indexes/triggers/idempotency in place.
Verification: migration apply on inspected target; RLS/security advisor checks; representative SQL tests.
Status: in progress.

## WP4 — Server/domain implementation
Owner: Backend Engineer
Dependencies: WP3 contracts
Acceptance: validated authenticated server actions and bounded read functions for core flows; deterministic scoring and waitlist/rating rules; safe errors.
Verification: unit/server tests + typecheck.
Status: in progress.

## WP5 — Consumer web UX
Owner: Frontend Engineer
Dependencies: WP1/WP4 contracts
Acceptance: mobile-first Home, Discover, Create, Compete, You, activity/clan detail, auth, messages/notifications; responsive/accessibility/error/empty states.
Verification: lint/typecheck/build/E2E + accessibility review.
Status: in progress.

## WP6 — CI/deployment/observability
Owner: DevOps
Dependencies: WP3–5
Acceptance: GitHub CI, environment contract, Vercel configuration, migration/deploy/runbook/health/rollback docs.
Verification: clean CI and preview/production smoke where credentials/targets are available.
Status: queued.

## WP7 — Independent QA
Owner: Senior QA
Dependencies: WP3–6
Acceptance: requirements traceability; critical/negative/auth/accessibility journeys evaluated; no unresolved P0.
Verification: `docs/qa/*` evidence and defects.
Status: queued.

## WP8 — Production audit
Owner: Software Auditor
Dependencies: WP7
Acceptance: independent audit of requirements/security/data/ops/tests; PASS or conditional findings.
Verification: `docs/audits/PRODUCTION_AUDIT.md`.
Status: queued.

## Dependency notes

- Live DB writes wait for existing Ojoro schema inspection.
- Production deploy waits for migration and QA/audit gates.
- Wearable/calendar provider connections are non-blocking expansion integrations and require provider credentials/privacy review.
