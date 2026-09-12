# AegisLedger Decision Register

| ADR | Decision | Status |
|---|---|---|
| 001 | Double-entry immutable journal is financial truth | Accepted |
| 002 | `BIGINT` minor units for money | Accepted |
| 003 | Modular monolith first | Accepted |
| 004 | PostgreSQL transaction is atomic posting boundary | Accepted |
| 005 | Deterministic row locking for v1 multi-account concurrency | Accepted, benchmark/revisit |
| 006 | Transactional outbox for domain publication | Accepted |
| 007 | DB-backed business idempotency | Accepted |
| 008 | JWT tenant claim + PostgreSQL RLS | Accepted |
| 009 | Kafka/Redis/OpenSearch are non-authoritative | Accepted |
| 010 | External timeout can become UNKNOWN; no blind financial retry | Accepted |

Material conflicts are recorded here before implementation changes. The canonical PRD outranks implementation convenience.
