# Production Audit

## Executive result
**PASS WITH ACCEPTED WARNINGS**

The Ojoro release has no identified P0/P1 software, authorization, data-integrity or deployment-readiness defect. The implementation is approved for a controlled production deployment subject to post-deploy smoke verification.

Audit basis: product/architecture contracts, implementation inspection, successful locked CI (`33951328705`), production Supabase migration/RLS inspection, Supabase security/performance advisor output, QA report and requirements traceability.

## Findings
| ID | Severity | Category | Evidence | Impact | Remediation | Blocking |
|---|---|---|---|---|---|---|
| AUD-01 | Medium | Auth hardening | Supabase leaked-password protection is disabled | Users can choose a password present in known breach corpora | Enable leaked-password protection in Supabase Auth before broad scale | No |
| AUD-02 | Low | Database security hygiene | `citext` is installed in `public` in the shared/legacy database | Extension placement is less isolated than preferred | Move extension in a separately reviewed migration if legacy dependencies permit | No |
| AUD-03 | Low | RPC exposure | Supabase warns that intended authenticated `SECURITY DEFINER` command RPCs are executable by authenticated users | Generic advisor cannot infer the RPCs' internal actor/resource authorization | Keep explicit grants narrow; retain internal authorization checks; regression-test privilege boundaries | No |
| AUD-04 | Low | Legacy public RPC | Legacy `get_ojoro_public_event()` remains an anonymous SECURITY DEFINER lookup | Public lookup is reachable by design in pre-existing Command Centre surface | Re-evaluate separately from Ojoro consumer release; constrain result columns/logic if legacy requirements change | No |
| AUD-05 | Low | Performance | Several Ojoro RLS policies trigger `auth_rls_initplan`; three tables have multiple permissive-policy warnings | Additional per-row policy work may matter at high scale | Rewrite hot policies with `(select auth.uid())` form and consolidate policies after query profiling | No |
| AUD-06 | Info | Test isolation | Authenticated full-flow CI fixtures are not run against the production database | CI does not create/delete production users or events | Add an isolated Supabase test branch with seeded actors for destructive/full journey E2E | No |

## Requirements coverage
- `docs/qa/REQUIREMENTS_TRACEABILITY.md` maps R01–R50 and UX-A–UX-G to implementation evidence.
- Core P0/P1 application requirements are implemented.
- P2/provider/annual/championship items described by the product contract as expansion-ready primitives are explicitly recorded as foundations, not falsely claimed as live external integrations.
- No AI requirements apply; Ojoro is explicitly deterministic for this release.

## Security and reliability
- Consumer `oj_*` tables have RLS enabled.
- Privileged mutations are concentrated in authenticated server actions/RPC command paths rather than browser-held service credentials.
- Sensitive Ojoro command RPCs are not available to anonymous callers; authenticated SECURITY DEFINER functions perform actor/resource authorization internally.
- Activity attendance, clan-role changes, team membership, result verification and tournament operations have dedicated authorization paths.
- Existing shared Command Centre data was preserved; Ojoro migrations are additive and migration-backed.
- The production security advisor reports WARN-level hardening observations but no ERROR-level release finding.
- The performance pass added missing consumer foreign-key indexes; remaining unindexed-FK findings are legacy shared-schema objects.
- Reproducibility is enforced by a committed npm lockfile and read-only `npm ci` CI.

## Operational and AI readiness
- `DEPLOYMENT.md`, `ENVIRONMENT.md`, `OBSERVABILITY.md` and `RUNBOOK.md` define release topology, smoke signals, incident handling and rollback procedure.
- Vercel is the intended web runtime; Supabase is the database/auth runtime.
- No LLM, agent, prompt, embedding, model provider or probabilistic permission/scoring path exists. AI evaluation is therefore **not applicable**.

## Test sufficiency
Release gate evidence includes:
- ESLint PASS
- strict TypeScript PASS
- 9/9 deterministic domain unit tests PASS
- production Next.js build PASS
- Playwright Chromium browser suite PASS
- authentication enforcement across all tested private top-level surfaces PASS
- production database schema/RLS/migration inspection PASS
- Supabase security/performance advisor review COMPLETE

The audit does not equate compilation with product correctness: QA separately records the absence of isolated authenticated fixture E2E as a non-blocking gap for subsequent test-system investment.

## Release recommendation
**APPROVE CONTROLLED PRODUCTION DEPLOYMENT.**

Required immediately after deployment:
1. smoke landing/login/protected-route behavior;
2. confirm runtime error logs are clean;
3. confirm deployed app targets the intended Supabase project using publishable client credentials only;
4. record deployment/project identifiers in release readiness;
5. verify rollback by retaining the prior Vercel deployment and documenting promotion/revert behavior.

The accepted WARN items should remain visible in the hardening backlog and must not be silently converted to PASS.