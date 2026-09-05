# Ojoro Deployment

## Topology

```text
Browser / installed PWA
        |
        v
Vercel — Next.js 16 application
        |
        +---- Supabase Auth
        +---- PostgREST / RPC
        +---- PostgreSQL + RLS
```

The web root is `apps/ojoro-web`. Supabase project ref is `iddujjsbyytwbrvqsxrg` in Canada Central. Consumer tables/functions are prefixed `oj_` so the pre-existing Ojoro Command Centre schema is not repurposed.

## Required environment variables

- `NEXT_PUBLIC_SUPABASE_URL` — project API URL; client-visible by design.
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` — publishable client key; client-visible by design.

No service-role key is required by the web application. Authorization is enforced by Supabase Auth, RLS and bounded SECURITY DEFINER RPCs.

## Build

```bash
cd apps/ojoro-web
npm ci
npm run lint
npm run typecheck
npm test
npm run build
npm run test:e2e -- --project=chromium
```

The repository-level factory validation also runs before release.

## Database migration order

Apply `supabase/migrations/` in filename order. Ojoro migrations are additive/forward-only in this release; they do not drop or rename legacy Command Centre objects. The latest production schema includes core social platform, security hardening, atomic community commands, competition/clan operations, tournament operations and covering performance indexes.

## Release procedure

1. Confirm CI is green at the exact release SHA.
2. Confirm Supabase project health and that all repository migrations appear in migration history.
3. Run security advisor; any ERROR is release-blocking.
4. Run database smoke checks: all `oj_*` tables have RLS, anonymous role has no sensitive command RPC execution, core public lookup queries work.
5. Deploy the exact release SHA to Vercel preview using root directory `apps/ojoro-web` and production Supabase publishable configuration.
6. Smoke `/`, `/login`, authentication redirect protection, and a signed-in read flow.
7. Promote the verified deployment to production.
8. Re-run public health/smoke and inspect Vercel runtime errors plus Supabase API/Auth/Postgres logs.
9. Record deployment ID/URL and release SHA in `docs/RELEASE_READINESS.md`.

## Rollback / forward-fix

### Web
Vercel deployments are immutable. Roll back by promoting the last known-good deployment; no source-history rewrite is required.

### Database
Do not attempt destructive down migrations against user data. Ojoro uses forward-fix migrations. If a new application build depends on a migration that must be reverted, first roll the web deployment back to a schema-compatible version, then ship a reviewed forward migration that restores compatible behavior. Existing `oj_*` data is preserved.

## Data recovery

Supabase-managed backup availability depends on the project plan and must be verified in the Supabase dashboard before relying on point-in-time restore as an incident control. Application recovery therefore also depends on reversible web deployment, append-only XP ledgers, idempotent command sources, and non-destructive schema evolution.

## Deployment status

Database migrations are applied and healthy. Web production deployment remains release-gated until verification, QA and audit evidence are complete.
