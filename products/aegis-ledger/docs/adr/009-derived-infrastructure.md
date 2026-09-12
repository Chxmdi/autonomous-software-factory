# ADR — Kafka/Redis/OpenSearch are non-authoritative

**Status:** Accepted

## Context
AegisLedger requires an explicit decision that remains defensible under concurrency and partial failure.

## Decision
Use Kafka for propagation, Redis for acceleration, OpenSearch for search; none determine financial truth.

## Alternatives and rationale
Treating cache/search as authority increases corruption risk and complicates recovery.

## Consequences / revisit condition
Financial writes can continue or fail predictably when derived stores are unavailable; rebuild paths are mandatory.
