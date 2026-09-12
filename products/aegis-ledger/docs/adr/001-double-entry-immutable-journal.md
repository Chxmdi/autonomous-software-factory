# ADR — Double-entry immutable journal

**Status:** Accepted

## Context
AegisLedger requires an explicit decision that remains defensible under concurrency and partial failure.

## Decision
Use append-only double-entry journal transactions as financial truth.

## Alternatives and rationale
A mutable balance-only design is simpler but cannot provide complete provenance or safe historical correction. Event-sourcing every application concern would overreach.

## Consequences / revisit condition
Corrections require reversal/adjustment entries; reporting projections are derived. Revisit only if regulatory/accounting domain changes.
