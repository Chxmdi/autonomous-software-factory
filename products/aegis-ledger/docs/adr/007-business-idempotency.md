# ADR — Database-backed business idempotency

**Status:** Accepted

## Context
AegisLedger requires an explicit decision that remains defensible under concurrency and partial failure.

## Decision
Unique tenant+operation+key record with request hash participates in posting transaction.

## Alternatives and rationale
Redis-only idempotency can disappear/fail over and is not sufficient for money.

## Consequences / revisit condition
Storage grows; retention/archival policy required. Same key/different request is a conflict.
