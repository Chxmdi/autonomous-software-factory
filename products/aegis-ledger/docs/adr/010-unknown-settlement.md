# ADR — Explicit UNKNOWN settlement outcome

**Status:** Accepted

## Context
AegisLedger requires an explicit decision that remains defensible under concurrency and partial failure.

## Decision
If an external provider may have processed a request before timeout, enter UNKNOWN and query/reconcile rather than blindly retry.

## Alternatives and rationale
Treating timeout as failure can duplicate real money movement.

## Consequences / revisit condition
Needs provider idempotency/reference support, aged-UNKNOWN alerts and operator runbook.
