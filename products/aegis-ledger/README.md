# AegisLedger

AegisLedger is a high-throughput, multi-tenant double-entry ledger and settlement engine implemented as an invariant-first Java/Spring system.

This workspace is intentionally isolated under `products/aegis-ledger/` so the existing Ojoro product state in the Software Factory repository is preserved.

## What the first production slice proves
- immutable double-entry journals;
- tenant-scoped financial state;
- database-backed idempotency;
- deterministic multi-account locking;
- protected-account no-overdraw guarantees;
- atomic journal + materialized balance + outbox commit;
- explicit source-of-truth boundaries;
- production JWT tenant resolution with a clearly isolated local-development header mode;
- PostgreSQL row-level tenant isolation;
- concurrency and replay test design;
- observability, recovery, ADRs, runbooks, and release gates.

## Modules
- `aegis-domain`: framework-free accounting and balance invariants.
- `aegis-application`: use cases and ports.
- `aegis-app`: Spring Boot API, PostgreSQL implementation, security and operations.

## Local prerequisites
- Java 21+
- Maven 3.9+
- Docker/Compose for PostgreSQL and integration tests

## Start dependencies
```bash
docker compose up -d postgres
```

## Seed and run locally
After PostgreSQL is healthy, seed zero-balance demo accounts:
```bash
make seed
```
Run the app:
```bash
SPRING_PROFILES_ACTIVE=local mvn -pl aegis-app -am spring-boot:run
```
Then `./scripts/demo.sh` posts a balanced deposit followed by a purchase. The seed itself never invents opening money; value enters through the journal.

## Verify
```bash
mvn -B verify
./scripts/verify-domain.sh
```

Local profile accepts `X-Tenant-Id` strictly for development. Production uses JWT claim `tenant_id`; the request body never owns tenancy.

Read `docs/PROJECT_CONTEXT.md`, `docs/requirements/AEGIS_LEDGER_PRD.md`, and `docs/exec-plans/ACTIVE.md` before changing product behavior.
