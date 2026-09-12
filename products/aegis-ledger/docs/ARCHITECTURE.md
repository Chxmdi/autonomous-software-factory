# AegisLedger Architecture

## System context
```text
Client / Platform Service
        |
        | HTTPS + JWT + Idempotency-Key
        v
+-------------------------+
| AegisLedger API         |
| auth / tenant / hashing |
+------------+------------+
             |
             v
+-------------------------+
| Ledger Application      |
| invariant orchestration |
+------------+------------+
             |
             v
+--------------------------------------------------+
| PostgreSQL                                       |
| journal + accounts + idempotency + outbox + RLS|
+----------------------+---------------------------+
                       |
                    CDC/outbox
                       v
                 +-----------+
                 |   Kafka   |
                 +-----+-----+
                       |
         +-------------+-------------+
         |                           |
         v                           v
  projections                  settlement /
 Redis/OpenSearch              reconciliation
```

## Architectural style
A modular monolith is the first deployment unit. Domain and application modules are framework-independent; infrastructure is in `aegis-app`. This maximizes transactional clarity while preserving future service extraction boundaries.

## Write path
1. Spring Security authenticates the caller in production.
2. `TenantResolver` derives tenant from JWT claim `tenant_id`; request bodies cannot supply ownership.
3. API validates shape and calculates a stable SHA-256 request hash.
4. application validates double-entry structure.
5. persistence starts one PostgreSQL transaction and sets `app.tenant_id` using `set_config(..., true)` for RLS.
6. idempotency record is inserted with a unique tenant/operation/key constraint.
7. all referenced accounts are locked in deterministic UUID order using `FOR UPDATE`.
8. final account effects and protected-balance rules are checked.
9. journal transaction/lines, materialized balances and outbox event are written atomically.
10. idempotency record is completed with immutable transaction resource ID.
11. response is built from immutable journal data.

## Why deterministic row locks in v1
The transaction may touch multiple accounts. Kafka partitioning by one account does not prove atomicity across arbitrary accounts. Deterministic row locking gives an easily auditable first correctness proof and prevents deadlocks caused by inconsistent lock order. ADRs require benchmark evidence before replacing it with optimistic/CAS or serialized command ownership.

## Source-of-truth boundaries
- PostgreSQL journal: financial truth.
- PostgreSQL account balance: materialized projection protected in same transaction.
- Outbox: durable publication intent.
- Kafka: propagation/order domain, not financial authority.
- Redis: optional cache/rate-limit/idempotency accelerator only.
- OpenSearch: audit/search projection only.

## Failure boundaries
- API process may die at any point; idempotency + DB transaction determine outcome.
- Kafka/CDC may lag; committed journal remains authoritative.
- Redis/OpenSearch may fail without changing financial correctness.
- External settlement providers can return UNKNOWN; settlement state machine owns recovery.

## Future extraction seams
Settlement, reconciliation and read projections can become independently deployed workers when workload/failure isolation justifies it. Ledger posting remains co-located with its atomic PostgreSQL transaction until evidence supports a different model.
