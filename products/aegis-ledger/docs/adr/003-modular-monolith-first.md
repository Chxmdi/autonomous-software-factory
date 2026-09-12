# ADR — Modular monolith first

**Status:** Accepted

## Context
AegisLedger requires an explicit decision that remains defensible under concurrency and partial failure.

## Decision
Deploy ledger/application/API as one unit initially with framework-free module boundaries.

## Alternatives and rationale
Premature microservices add distributed transactions and operational failure modes before independent scaling is proven.

## Consequences / revisit condition
Extract settlement/reconciliation/projections when scaling, ownership or failure isolation requires it.
