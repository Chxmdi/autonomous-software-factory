# AegisLedger — Canonical Product Requirements Document

## 1. Vision
AegisLedger is a high-throughput multi-tenant financial ledger and settlement foundation. It treats money as immutable accounting facts and remains correct under duplicate requests, concurrency, worker crashes, delayed messages, dependency outages and ambiguous external-provider outcomes.

## 2. Business objective
Provide reusable ledger infrastructure for wallets, marketplaces, merchant settlement, stored-value products and internal financial platforms without coupling accounting truth to external processor availability.

## 3. Core principles
- Correctness before convenience.
- Immutable posted financial history.
- Business-level exactly-once effects, not magical transport exactly-once claims.
- Derived balances/search/cache state must be reconstructable.
- Failure and UNKNOWN outcomes are explicit states.
- PostgreSQL is the atomic source of financial truth.

## 4. Functional requirements
### FR-01 Double-entry journals
Every posted transaction contains at least two positive lines and satisfies `sum(DEBIT) == sum(CREDIT)` in one currency.

### FR-02 Tenant isolation
Every financially meaningful row is tenant-owned. Tenant identity is trusted server context, enforced in repository predicates and PostgreSQL RLS.

### FR-03 Protected balances
Accounts declare `ALLOW_NEGATIVE`, `DISALLOW_NEGATIVE`, or `LIMITED_NEGATIVE`. Concurrent postings must never push a protected account below its allowed floor.

### FR-04 Idempotent mutation boundary
Every mutation requires a client `Idempotency-Key`. Scope is tenant + operation + key. Canonical request SHA-256 is stored durably. Same key/same payload replays the original resource; same key/different payload returns conflict.

### FR-05 Immutable journal
Posted journal transactions and lines cannot be updated or deleted. Corrections are new reversal/refund transactions referencing the original.

### FR-06 Transactional outbox
Journal effects and an outbox event commit in one PostgreSQL transaction. Domain publication is derived after commit so a process crash cannot create a DB/Kafka dual-write gap.

### FR-07 Account and transaction queries
Authorized callers can query current account projection and immutable transaction history scoped to tenant.

### FR-08 Holds and authorization
Model hold lifecycle `ACTIVE → CAPTURED|RELEASED|EXPIRED|CANCELLED`, including partial capture. Full implementation is a later vertical slice but schemas/contracts must not preclude it.

### FR-09 Settlement lifecycle
Model `INITIATED → SUBMITTED → CONFIRMED|FAILED|UNKNOWN`. UNKNOWN triggers query/reconciliation rather than blind resubmission.

### FR-10 Refund/reversal limits
Total refunds cannot exceed captured amount unless an explicitly approved product rule says otherwise. Posted corrections are new accounting events.

### FR-11 Reconciliation
Support journal self-checks, projection-vs-journal checks and external settlement reconciliation. Discrepancies are quarantined and evidenced, never silently edited away.

### FR-12 Auditability
Every administrative mutation records actor, action, resource, reason, timestamp, auth context and correlation identifier.

## 5. Domain model
Tenant → Ledger → Accounts → Journal Transactions → Journal Lines. Account classification (asset/liability/equity/revenue/expense) is separate from operational role. Each account has currency, normal balance side, status, negative policy, optional credit limit, materialized posted balance and concurrency version.

## 6. Money
Binary floating point is forbidden. V1 represents monetary quantities as signed/unsigned 64-bit integer minor units plus a 3-letter currency code. Arithmetic uses overflow-detecting operations.

## 7. Balance semantics
For a debit-normal account, DEBIT increases and CREDIT decreases its positive normal balance. For a credit-normal account, CREDIT increases and DEBIT decreases it. Negative-policy validation applies atomically to the post-transaction final balance.

## 8. Posting transaction boundary
Within one local PostgreSQL transaction:
1. set trusted tenant session context;
2. claim idempotency key;
3. validate ledger/currency;
4. lock all referenced account rows in deterministic ID order;
5. validate ownership/status/policies;
6. compute final balance effects;
7. insert journal transaction/lines;
8. update materialized account projections;
9. insert outbox event;
10. complete idempotency record;
11. commit.

No partial financial write may escape this boundary.

## 9. Concurrency strategy
V1 deliberately uses deterministic row locking for multi-account atomic correctness and easy proof. Benchmarks must compare this against optimistic CAS and Kafka-serialized hot-account command paths. Kafka partitioning by a single account ID alone is insufficient to prove arbitrary multi-account transaction atomicity.

## 10. Events
All events contain eventId, eventType, eventVersion, tenantId, aggregateId, correlationId, causationId, occurredAt and traceId where available. Consumers assume duplicate delivery and must be idempotent.

## 11. APIs
Initial endpoints:
- `POST /v1/transactions`
- `GET /v1/transactions/{transactionId}`
- `GET /actuator/health`

Future endpoints include holds, capture, void, refund, settlements, reconciliation and administrative account lifecycle.

## 12. Security
Production uses OAuth 2.0 resource-server JWT validation and derives tenant from `tenant_id` claim. Local development header tenancy is profile-gated and must never be enabled in production. TLS, encrypted storage/backups, secret management, least privilege and administrative separation are mandatory production controls.

## 13. Non-functional requirements
- committed ledger RPO: 0 target;
- write availability target: 99.99%;
- nominal posting P95 < 50 ms and P99 < 100 ms only after workload/hardware is published;
- initial throughput benchmark target: 15,000 logical postings/sec across an appropriately sized cluster;
- stateless-node recovery target < 30 seconds; broader production RTO < 5 minutes initially;
- no financial truth dependency on Redis/OpenSearch.

## 14. Capacity workloads
Benchmark uniform load, 80/20 skew, one hot account, 2–5 account transactions, replay storms and read-heavy traffic. Publish CPU, heap, GC, DB connections/locks/WAL, Kafka lag and p50/p95/p99.

## 15. Failure behavior
- crash before DB commit: no transaction exists; message/request can safely retry;
- crash after DB commit before response: same idempotency key returns committed transaction;
- duplicate event: consumer deduplicates or applies naturally idempotent projection;
- Redis/OpenSearch down: financial writes remain correct; optional reads degrade;
- PostgreSQL down: mutations fail closed;
- provider timeout after dispatch: mark UNKNOWN and reconcile.

## 16. Observability
Trace HTTP → application → SQL → outbox/CDC → Kafka projection paths. Metrics include transaction latency/result, idempotency hits/conflicts, lock wait/retry, unbalanced rejection, negative-policy rejection, outbox age, reconciliation discrepancy and settlement UNKNOWN age.

## 17. Testing
Unit, property, API, auth, RLS, migration, idempotency, concurrency, integration, provider-contract, recovery, Testcontainers, Toxiproxy/chaos, performance and backup/restore tests. Core invariant generators must prove debit=credit, no protected overdraft and no logical duplicate application.

## 18. Release definition
Production ready means requirements are traced, automated verification passes, independent QA has no unresolved P0 and accepted P1 risk, audit is PASS/conditional approval, deploy/migrations are reproducible, external smoke succeeds, telemetry/runbooks/backups exist, and rollback or forward-fix is tested.

## 19. Portfolio success
A reviewer can ask what happens on duplicate submission, concurrent spend, commit-then-crash, Kafka redelivery, provider timeout, tenant spoofing or projection corruption and find executable evidence rather than architecture claims.
