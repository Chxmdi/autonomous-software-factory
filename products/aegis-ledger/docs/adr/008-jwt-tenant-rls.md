# ADR — Trusted JWT tenant context plus RLS

**Status:** Accepted

## Context
AegisLedger requires an explicit decision that remains defensible under concurrency and partial failure.

## Decision
Production tenant comes from verified JWT `tenant_id`; repository filters and PostgreSQL RLS enforce isolation.

## Alternatives and rationale
Body/header tenant identifiers are spoofable. Application-only filters are vulnerable to missed predicates.

## Consequences / revisit condition
Requires careful DB session context and runtime/migration role separation.
