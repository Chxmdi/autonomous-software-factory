# AegisLedger Design System

V1 is API-first and has no graphical interface. This gate artifact defines interaction consistency for developer-facing surfaces.

## Naming
- resource IDs are UUIDs;
- money uses integer minor units plus ISO currency code;
- timestamps are RFC 3339 UTC;
- error codes are stable `UPPER_SNAKE_CASE` identifiers;
- event types are lower-case dotted names such as `ledger.transaction.posted`.

## Response principles
- deterministic fields for financial resources;
- explicit status/state instead of implied success;
- `correlationId` on error responses;
- `retryable` is explicit;
- no stack traces or secret material.

## Documentation surfaces
Use concise diagrams, copy-pasteable examples, clear invariant callouts, and explicit failure semantics. Future UI must inherit accessible typography/contrast rules rather than inventing a financial-dashboard aesthetic.
