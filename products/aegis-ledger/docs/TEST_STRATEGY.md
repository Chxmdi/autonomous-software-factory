# AegisLedger Test Strategy

## Test pyramid
1. framework-free domain unit/property tests;
2. application use-case tests with deterministic fakes;
3. PostgreSQL Testcontainers integration tests;
4. API/security tests;
5. concurrency/replay tests;
6. outbox/CDC/Kafka integration tests;
7. chaos/provider ambiguity tests;
8. load/capacity benchmarks;
9. backup/restore and deployment smoke tests.

## Required invariant tests
- debit total must equal credit total;
- money amount must be positive and overflow-safe;
- normal-balance effect is correct for debit/credit accounts;
- protected accounts never cross lower bound;
- same idempotency key cannot create two journal transactions;
- same key/different hash conflicts;
- posted journal rows reject update/delete;
- tenant A cannot query or post against tenant B account;
- transaction replay after simulated response loss returns same resource.

## Concurrency scenario
Seed customer liability +100 and merchant liability 0. Submit 200 distinct concurrent $1 transactions (debit customer, credit merchant). Exactly 100 must succeed, 100 must fail insufficient funds; final customer=0, merchant=100, 100 posted journals, all journals balanced.

## Chaos scenarios
- kill app before/after DB commit;
- duplicate/reorder Kafka messages;
- delay DB and provider responses;
- Redis/OpenSearch unavailable;
- provider processes settlement then response is dropped;
- PostgreSQL primary failover.

## Performance evidence
Every benchmark publishes hardware/resources, dataset, partition count, workload skew and p50/p95/p99 with DB lock/WAL/connection metrics. Marketing throughput numbers without this context are invalid.

## Current execution evidence
This session runtime has Java 21 but no Maven/Docker and no outbound package resolution. `scripts/verify-domain.sh` provides a JDK-only sanity check. Full `mvn verify`/Testcontainers evidence must come from CI or a prepared developer machine and is not claimed as passing here.
