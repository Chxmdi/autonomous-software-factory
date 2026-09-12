# ADR — PostgreSQL is atomic posting boundary

**Status:** Accepted

## Context
AegisLedger requires an explicit decision that remains defensible under concurrency and partial failure.

## Decision
One PostgreSQL transaction commits journal, materialized balances, idempotency and outbox.

## Alternatives and rationale
Cross-system transaction coordinators are operationally heavier; Kafka transactions do not make PostgreSQL + arbitrary providers globally atomic.

## Consequences / revisit condition
Requires durable PostgreSQL/PITR. Revisit only with a new authoritative storage model.
