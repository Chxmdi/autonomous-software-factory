# Ojoro Operations Runbook

## First response

1. Identify whether impact is public web, authentication, database read, deterministic mutation, or a specific feature.
2. Capture environment, release SHA/deployment ID, route/RPC, UTC timestamp and request/user/entity IDs when safe.
3. Check Vercel deployment/runtime errors and Supabase project health plus API/Auth/Postgres logs.
4. Do not mutate or delete production data while diagnosing.
5. Classify: P0 data exposure/privilege bypass/corruption; P1 critical journey unavailable; P2 degraded/non-critical feature; P3 cosmetic/improvement.

## Common incidents

### Login/sign-up failures
- check Supabase Auth health/logs and redirect URL configuration;
- verify the active Vercel environment has the correct public project URL/key;
- verify `/auth/callback` deploys from the same SHA as the login page;
- do not disable authentication as a workaround.

### RSVP / waitlist inconsistency
- inspect `oj_activities` capacity and `oj_activity_participants` state;
- inspect RPC/API/Postgres errors for `oj_rsvp_activity`;
- do not manually overwrite multiple participant rows unless an approved repair migration/script is prepared;
- preserve first-joined waitlist order.

### Clan or chat access mismatch
- inspect `oj_clan_members`, `oj_chat_channels`, and `oj_channel_members`;
- verify membership transition RPC completed;
- treat any unrelated-user read access as P0.

### Attendance / XP issue
- verify organizer/clan role authorization;
- inspect `oj_activity_participants.attendance_status` and append-only XP ledger source tuple;
- repeated XP source IDs must remain idempotent; do not award manual duplicate XP.

### Competitive result / tournament issue
- verified match results must not be overwritten; use dispute/forward-fix paths;
- confirm tournament actor satisfies `oj_can_manage_tournament` before fixture mutation;
- do not advance a knockout round while current non-bye fixtures are incomplete.

### High web error rate after deploy
- compare error start time with Vercel deployment timestamp;
- if new release is implicated, roll web back to previous immutable deployment;
- keep database schema forward-compatible and ship a forward-fix migration if needed.

## Rollback

Web rollback is the first-line recovery path for application regressions. Promote the last known-good Vercel deployment. Database changes are forward-fixed rather than destructively reversed. Never drop `oj_*` tables or reset the shared Ojoro Command Centre project as an incident shortcut.

## Backup and restore

Before declaring backup/restore readiness, verify the active Supabase project plan's backup/PITR capabilities in the Supabase dashboard. In an actual restore event, stop writes where practical, identify the recovery point, preserve forensic evidence, and obtain explicit owner approval for any restore that can discard newer user writes.

## Security incident

If cross-user exposure, privilege escalation or compromised credentials are suspected: stop promotion, rotate affected credentials, restrict the affected path, preserve logs, and treat as P0. Publishable client keys are designed to be public; service-role or administrative secrets are not used by the Ojoro web client.

## Escalation

Owner judgment is required for destructive data recovery, legal/privacy notification, material safety incidents, billing/purchase changes, or user-visible downtime tradeoffs. Routine safe diagnostics, deployment rollback and non-destructive forward fixes remain within the engineering runbook.
