# Ojoro Observability

## Signals

### Web / Vercel
- deployment build status and exact git SHA;
- HTTP 5xx/4xx clusters by route;
- serverless/runtime exceptions;
- auth callback failures and redirect loops;
- route latency for Home, Discover, activity detail, clan detail and command submissions.

### Supabase
- Postgres errors/deadlocks/slow queries;
- PostgREST/API errors;
- Auth failures and abnormal login volume;
- RLS/security advisor findings;
- database performance advisor findings;
- migration history and project health.

## Critical business-operation symptoms

Page views alone are not sufficient. Incident investigation should prioritize failed product transitions:

- RSVP command fails or returns inconsistent capacity/waitlist state;
- cancellation does not promote the oldest eligible waitlist member;
- organizer cannot record attendance or an unauthorized member can;
- clan/team membership does not match chat access;
- verified result changes more than once or rating update is duplicated;
- direct-message/block rules permit interaction after block;
- tournament registration exceeds capacity or unauthorized fixture mutation succeeds.

## SLO targets for initial release

These are operating targets, not claims of measured production history:

- public/auth availability: 99.9% monthly target;
- normal read route p95 server response: < 800 ms excluding client/network latency;
- deterministic mutation success when dependencies are healthy: >= 99.5%;
- no unresolved security-advisor ERROR;
- zero known cross-user authorization bypasses;
- restore normal product operation within 60 minutes for a web-only rollback incident.

## Alert / triage thresholds

- any sustained 5xx burst on auth, activity or clan mutation routes: P1;
- evidence of cross-user data exposure or privilege escalation: P0;
- migration failure against production: stop deployment immediately;
- Supabase project unhealthy/unreachable: P1 unless active data corruption/exposure elevates severity;
- isolated client validation failure: P2/P3 depending frequency and user impact.

## Privacy and logging

Do not log access tokens, passwords, private message bodies, precise private location, raw report details, or environment secret values. Use entity IDs/request IDs for correlation. Client-visible publishable Supabase configuration is not an administrative credential.

## Current evidence

Supabase security advisor has no ERROR-level findings for the Ojoro consumer schema. All `oj_*` tables were independently checked with RLS enabled. The remaining RLS init-plan and multiple-permissive-policy findings are performance warnings and are tracked for optimization, not authorization correctness.
