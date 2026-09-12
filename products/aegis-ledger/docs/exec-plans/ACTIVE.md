# Active Execution Plan — AegisLedger

## Goal
Deliver a production-evaluable financial ledger in evidence-producing vertical slices without sacrificing invariants for architecture theater.

## WP-01 Context/Product Foundation — Owner: Product Designer
**Requirements:** vision, users, failure states, API-first experience, non-goals.  
**Acceptance:** PRODUCT/UX/DESIGN artifacts and PRD coherent.  
**State:** authored; independent review still possible.

## WP-02 Architecture & Contracts — Owner: Project Designer
**Depends on:** WP-01.  
**Acceptance:** architecture/API/data/security/test docs + ADRs; source-of-truth, trust/failure boundaries explicit.  
**State:** authored.

## WP-03 Ledger Domain Kernel — Owner: Backend Engineer
**Depends on:** WP-02.  
**Deliver:** money, account state, double-entry validation, balance effects, exceptions, unit tests.  
**Verify:** `./scripts/verify-domain.sh`; `mvn -pl aegis-domain test`.  
**State:** implementation authored; JDK-only smoke intended for current environment.

## WP-04 Atomic PostgreSQL Posting — Owner: Database Specialist + Backend
**Depends on:** WP-03.  
**Deliver:** migrations, RLS, immutable journal, idempotency, deterministic locks, outbox, posting/query repository, Testcontainers concurrency tests.  
**Verify:** `mvn -pl aegis-app -am verify`.  
**State:** implementation authored; runtime verification blocked here by missing Maven/Docker.

## WP-05 Secure REST API — Owner: Backend Engineer
**Depends on:** WP-04.  
**Deliver:** POST/GET transaction endpoints, request hash, JWT/local tenant resolvers, stable errors, health/metrics.  
**Verify:** MVC/API/auth/RLS tests.  
**State:** authored; full verification pending.

## WP-06 Outbox → Kafka Projections — Owner: Backend + DevOps
**Depends on:** stable WP-04 event contract.  
**Deliver:** Debezium config, Kafka schemas, consumer dedupe, Redis/OpenSearch projections and lag/rebuild tests.  
**State:** planned.

## WP-07 Holds / Capture / Refund / Reversal — Owner: Backend + Database
**Depends on:** WP-04.  
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
**State:** foundational docs/config authored; execution pending infrastructure.

## WP-11 Independent QA — Owner: Senior QA
**Depends on:** feature/verification evidence.  
**State:** not run; implementers may not self-pass.

## WP-12 Production Audit & Release — Owner: Software Auditor / DevOps
**Depends on:** QA.  
**State:** not run; no production environment authorized/configured.
