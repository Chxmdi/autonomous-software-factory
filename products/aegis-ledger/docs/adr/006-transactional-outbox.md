# ADR — Transactional outbox

**Status:** Accepted

## Context
AegisLedger requires an explicit decision that remains defensible under concurrency and partial failure.

## Decision
Persist outbox event in same DB transaction and publish via CDC/relay.

## Alternatives and rationale
Direct DB write then Kafka publish has a crash window; Kafka-first creates a different consistency problem.

## Consequences / revisit condition
Adds CDC/relay lag and cleanup operations but preserves committed intent.
