# AegisLedger Observability

## Golden signals
- posting request rate/result/latency;
- DB transaction/lock wait latency;
- idempotency replay/conflict rate;
- rejected negative-balance attempts;
- outbox age/backlog;
- Kafka consumer lag once enabled;
- settlement UNKNOWN count/age;
- reconciliation discrepancy count/age.

## Correctness alarms
Any observed unbalanced committed transaction, protected-account breach, duplicate logical transaction, or unexplained journal/projection divergence is severity P0/P1 depending on confirmed customer impact.

## Tracing
Propagate W3C trace context from HTTP through SQL, outbox and Kafka. Financial identifiers may be span attributes; raw secrets/tokens/payment credentials may not.

## Logs
Structured fields: service, tenantId when safe, transactionId, accountId when relevant, correlationId, traceId, errorCode. Do not log bearer tokens, secrets or full request bodies.

## Dashboards
1. ledger correctness;
2. posting performance and lock contention;
3. dependencies/outbox/Kafka;
4. settlement and reconciliation;
5. JVM/GC/pool saturation.
