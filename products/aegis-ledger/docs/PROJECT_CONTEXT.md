# Project Context — AegisLedger

## Identity
- Product: **AegisLedger**
- Product root: `products/aegis-ledger/`
- Product owner: Chimdindu Okelekwe
- Current stage: implementation foundation
- Primary implementation: Java 21 + Spring Boot 4.1.x

## Outcome
AegisLedger is financial infrastructure that can prove where money came from, where it went, why it moved, and that concurrent retries or partial failures did not create or destroy value.

## Product truth
- Canonical requirements: `docs/requirements/AEGIS_LEDGER_PRD.md`
- API contract: `docs/API_CONTRACTS.md`
- Data truth: `docs/DATA_MODEL.md`
- Security truth: `docs/SECURITY.md`
- Active plan: `docs/exec-plans/ACTIVE.md`

## Core invariants
1. Every posted journal transaction balances: total debits equal total credits.
2. Posted journal history is immutable.
3. A logical mutation identified by tenant + operation + idempotency key has at most one financial effect.
4. Protected accounts cannot cross their configured lower bound under concurrency.
5. Tenant A cannot read or mutate Tenant B financial state.
6. A cache or search-index failure cannot corrupt financial truth.
7. External settlement ambiguity is modeled explicitly and reconciled instead of blindly retried.

## Standing architectural decisions
- PostgreSQL is the atomic financial authority.
- Start as a modular monolith; extract services only when scaling/ownership/failure isolation justifies it.
- The synchronous direct-DB posting path is the first working slice. Kafka is used for outbox-derived domain propagation and later command serialization only where measured contention benefits.
- Multi-account postings lock accounts in deterministic UUID order in v1 to preserve simple atomic correctness; optimistic/serialized alternatives remain benchmarked ADR candidates.
- Redis and OpenSearch are derived-state infrastructure only.
- No AI belongs in deterministic financial control paths.

## Environment
- Local/test: PostgreSQL, optional Kafka/Redis/OpenSearch, Testcontainers in CI.
- CI: Maven verify on GitHub Actions.
- Production target: containerized Kubernetes-compatible deployment; production release remains gated until external infrastructure exists.

## Authorization
Repository changes for this build are explicitly requested. Production financial actions, real payment-provider calls, and destructive production data operations are not authorized by this project build.
