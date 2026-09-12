# ADR — Integer minor units for money

**Status:** Accepted

## Context
AegisLedger requires an explicit decision that remains defensible under concurrency and partial failure.

## Decision
Represent money as 64-bit integer minor units plus currency.

## Alternatives and rationale
BigDecimal is valid but needs scale/rounding discipline at every boundary; binary floating point is unacceptable.

## Consequences / revisit condition
Currency metadata must define minor-unit rules. Revisit for instruments requiring arbitrary precision.
