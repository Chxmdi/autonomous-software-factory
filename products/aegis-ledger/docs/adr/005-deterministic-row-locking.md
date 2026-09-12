# ADR — Deterministic row locking for v1

**Status:** Accepted

## Context
AegisLedger requires an explicit decision that remains defensible under concurrency and partial failure.

## Decision
Lock all accounts referenced by a posting in sorted UUID order before validation/update.

## Alternatives and rationale
Optimistic CAS can retry-storm on hot accounts. Kafka serialization by one account cannot prove arbitrary multi-account atomicity.

## Consequences / revisit condition
May cap throughput on hot accounts; benchmark optimistic/escrow/serialized ownership before change.
