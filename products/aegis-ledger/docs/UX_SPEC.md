# AegisLedger Developer & Operator Experience Specification

AegisLedger is API-first; there is no end-user visual UI in v1. The product experience is the API, errors, observability and operator recovery workflow.

## Integration experience
1. Obtain production OAuth/JWT credentials and a tenant-scoped identity.
2. Discover the OpenAPI contract.
3. Send every mutation with `Idempotency-Key`.
4. Receive a stable transaction resource or a typed error with correlation ID and retryability.
5. Query the transaction resource after timeouts rather than guessing whether money moved.

## Required API states
- authenticated / unauthenticated;
- authorized / tenant denied;
- accepted and posted;
- idempotent replay;
- idempotency payload mismatch;
- unbalanced request;
- account unavailable/frozen;
- insufficient funds;
- dependency unavailable;
- unknown settlement outcome (future settlement slice).

## Operator experience
Alerts link to a correlation/transaction identifier, documented runbook, relevant metrics and immutable evidence. Operators resolve problems through compensating/reconciliation workflows, never direct journal edits.

## Accessibility
Human-facing generated documentation and any future operations console must target WCAG 2.2 AA. Current API responses avoid color-only or visual-only semantics.
