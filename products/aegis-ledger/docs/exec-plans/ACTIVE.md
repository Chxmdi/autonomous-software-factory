# Active Execution Plan — AegisLedger

## Goal
Deliver a production-evaluable financial ledger in evidence-producing vertical slices without sacrificing invariants for architecture theater.

## WP-01 Context/Product Foundation — Owner: Product Designer
**Requirements:** vision, users, failure states, API-first experience, non-goals.  
**Acceptance:** PRODUCT/UX/DESIGN artifacts and PRD coherent.  
**State:** PASS (artifact review).

## WP-02 Architecture & Contracts — Owner: Project Designer
**Depends on:** WP-01.  
**Acceptance:** architecture/API/data/security/test docs + ADRs; source-of-truth, trust/failure boundaries explicit.  
**State:** PASS (artifact review).

## WP-03 Ledger Domain Kernel — Owner: Backend Engineer
**Depends on:** WP-02.  
**Deliver:** money, account state, double-entry validation, balance effects, exceptions, unit tests.  
**Verify:** `./scripts/verify-domain.sh`; `mvn -pl aegis-domain test`.  
**State:** PASS for current scope. GitHub Actions run `34666000816` passed Maven tests and independent framework-free domain smoke.

## WP-04 Atomic PostgreSQL Posting — Owner: Database Specialist + Backend
**Depends on:** WP-03.  
**Deliver:** migrations, RLS, immutable journal, idempotency, deterministic locks, outbox, posting/query repository, Testcontainers concurrency tests.  
**Verify:** `mvn -pl aegis-app -am verify`.  
**State:** PASS for current scope. CI verifies Flyway on PostgreSQL 18.6, DB idempotency, immutable journal, RLS, and 200-way concurrent debit test with exactly 100 successes from a protected balance of 100 and final balance 0.

## WP-05 Secure REST API — Owner: Backend Engineer
**Depends on:** WP-04.  
**Deliver:** POST/GET transaction endpoints, request hash, JWT/local tenant resolvers, stable errors, health/metrics.  
**Verify:** MVC/API/auth/RLS tests.  
**State:** IMPLEMENTED FOUNDATION; persistence/security context is CI-verified, dedicated MVC/auth contract coverage remains to be expanded before marking full WP-05 PASS.

## WP-06 Outbox → Kafka Projections — Owner: Backend + DevOps
**Depends on:** stable WP-04 event contract.  
**Deliver:** versioned transaction-posted event contract, Debezium config, Kafka consumer, durable consumer deduplication, read projection, replay/rebuild behavior and lag/duplicate tests. Redis/OpenSearch remain derived optimizations and must not become financial truth.  
**Acceptance:** a committed journal produces an outbox event; duplicate event delivery creates one projection effect; consumer crash/replay is safe; projection can be rebuilt from durable events/source facts; ledger correctness does not depend on Kafka/Redis/OpenSearch availability.  
**Verify:** Maven integration tests plus embedded broker consumer tests; CDC runtime smoke remains a separate operational check.  
**State:** IMPLEMENTED / VERIFYING — self-contained v1 event, RLS projection schema, durable dedupe, Kafka listener and duplicate/rebuild integration test are committed; CI evidence pending.

## WP-07 Holds / Capture / Refund / Reversal — Owner: Backend + Database
**Depends on:** WP-04 and stable event contracts from WP-06.  
**Deliver:** lifecycle/state invariants and partial-capture/refund concurrency tests.  
**State:** planned.

## WP-08 Settlement & UNKNOWN Recovery — Owner: Backend
**Depends on:** WP-07.  
**Deliver:** provider port, idempotent provider calls, timeout ambiguity state, query-before-retry, simulated provider contract tests.  
**State:** planned.

## WP-09 Reconciliation — Owner: Backend + Database
**Depends on:** WP-04, WP-08.  
**Deliver:** journal/projected/external comparison, discrepancy records, repair/rebuild workflows.  
**State:** planned.

## WP-10 SRE & Capacity — Owner: DevOps
**Depends on:** WP-05 onward.  
**Deliver:** dashboards, alerts, runbooks, backup/restore, k8s/IaC, uniform/skew/hot-account benchmarks and chaos suite.  
**State:** foundational docs/config authored; execution evidence pending later feature slices and infrastructure.

## WP-11 Independent QA — Owner: Senior QA
**Depends on:** feature/verification evidence.  
**State:** not run; implementers may not self-pass.

## WP-12 Production Audit & Release — Owner: Software Auditor / DevOps
**Depends on:** QA.  
**State:** not run; no production environment authorized/configured.

## Current verified evidence
- Branch: `product/aegis-ledger`
- Permanent CI: `.github/workflows/aegis-ledger-ci.yml`
- Cleaned-state green run: `34666000816`
- Core Maven reactor: PASS
- PostgreSQL/Testcontainers integration suite: PASS
- Framework-free domain smoke: PASS

## Immediate dependency order
1. Finish WP-06 CI verification and CDC runtime smoke.
2. Expand WP-05 MVC/auth contract tests while event semantics remain frozen at v1.
3. Proceed to WP-07 only after WP-06 evidence is green.
4. Keep QA/audit gates independent and unopened until feature/verification evidence is complete.
