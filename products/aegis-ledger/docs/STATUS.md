# AegisLedger Delivery Status

Updated: 2026-09-11

## Baseline
- Isolated product workspace is active on branch `product/aegis-ledger` under `products/aegis-ledger/`; existing Ojoro product state remains untouched.
- Canonical PRD, product, architecture, API, data, security, test, deployment, observability, runbook and ADR artifacts are present.
- First vertical slice is implemented and CI-verified: double-entry posting, durable DB idempotency, deterministic account locking, PostgreSQL RLS, immutable journals, atomic materialized balances, and transactional outbox.
- Permanent root workflow: `.github/workflows/aegis-ledger-ci.yml`.

## Gates
| Gate | State | Evidence / blocker |
|---|---|---|
| Product Ready | PASS (artifact review) | `docs/PRODUCT.md`, `docs/UX_SPEC.md`, `docs/DESIGN_SYSTEM.md`, canonical PRD |
| Architecture Ready | PASS (artifact review) | architecture/API/data/security/test documents + ADRs |
| Implementation Ready | PASS | `docs/exec-plans/ACTIVE.md` |
| Feature Complete | IN PROGRESS | WP-03/WP-04 core posting slice verified; Kafka projections, payments, settlement and reconciliation remain |
| Verification Ready | IN PROGRESS / CORE SLICE PASS | GitHub Actions run `34666000816`: Maven reactor PASS + PostgreSQL/Testcontainers PASS + framework-free domain smoke PASS |
| QA Passed | NOT RUN | independent Senior QA required after feature/verification completion |
| Audit Passed | NOT RUN | independent Software Auditor gate required after QA |
| Production Release | NOT READY | no authorized production deployment, external smoke, restore or rollback evidence yet |

## Verified first-slice evidence
CI run `34666000816` on branch `product/aegis-ledger` completed successfully after cleanup of one-time bootstrap assets.

Verified behavior includes:
- domain double-entry and balance-rule unit tests;
- Flyway migration application against PostgreSQL 18.6;
- non-superuser application/database execution path;
- same-request idempotent replay returns one financial transaction;
- same idempotency key with a different request hash conflicts;
- 200 concurrent debit attempts against a protected balance of 100 produce exactly 100 successful unit debits, final protected balance 0, and no overdraw;
- PostgreSQL RLS hides another tenant's account;
- posted journal rows reject mutation;
- JDK-only framework-free domain smoke passes independently of Spring.

## P0/P1 findings
- P0: none currently open in the verified posting slice.
- P1: WP-06 outbox-to-Kafka projection/deduplication/rebuild path is not yet verified.
- P1: payment holds/capture/refund/reversal, external settlement ambiguity handling and reconciliation are not yet feature complete.
- P1: benchmark, chaos, backup/restore and deployment evidence remain outstanding before release consideration.

## Resolved build findings
- Added Spring Boot 4 Flyway starter so modular Flyway auto-configuration executes migrations.
- Migrated Testcontainers dependencies/API to 2.x modules.
- Separated PostgreSQL test bootstrap superuser from the non-superuser `aegis` runtime role so RLS tests are meaningful.
- Removed `final` from the transactional JDBC repository so Spring can proxy the repository correctly.
- Bound `TIMESTAMPTZ` parameters explicitly as UTC `OffsetDateTime` rather than relying on PostgreSQL JDBC inference for `Instant`.
- Removed one-time bootstrap workflow, inactive product-local workflow and CI activation marker after permanent CI became green.

## External blockers
- None for continued branch development and CI verification.
- Production release remains intentionally blocked on production infrastructure/authorization plus later QA and audit gates.
