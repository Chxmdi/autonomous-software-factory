# AegisLedger API Contracts

Base path: `/v1`. Production authentication: OAuth2 bearer JWT. Tenant is derived from JWT claim `tenant_id`.

## POST /v1/transactions
Headers:
- `Authorization: Bearer <jwt>` production
- `Idempotency-Key: <1..128 characters>` required
- `X-Correlation-Id` optional; server generates one when absent
- `X-Tenant-Id` accepted only in `local` profile

Request:
```json
{
  "ledgerId": "97a4cf5b-88f8-42d1-a4cb-a8669dcaf949",
  "currency": "CAD",
  "reference": "purchase-123",
  "effectiveAt": "2026-09-11T19:00:00Z",
  "entries": [
    {"accountId":"...","direction":"DEBIT","amountMinor":10000},
    {"accountId":"...","direction":"CREDIT","amountMinor":10000}
  ]
}
```

Rules:
- at least 2 entries;
- positive `amountMinor`;
- one currency per transaction;
- debit total exactly equals credit total;
- all accounts must be in tenant/ledger and ACTIVE;
- protected final balances must stay above configured floor.

Success `201 Created`:
```json
{
  "transactionId":"...",
  "status":"POSTED",
  "reference":"purchase-123",
  "currency":"CAD",
  "effectiveAt":"...",
  "postedAt":"...",
  "entries":[...]
}
```
A replay with the same key and request returns `200 OK` with the same immutable transaction resource. A key reused with a different request returns `409`.

## GET /v1/transactions/{id}
Returns the tenant-scoped immutable transaction or `404`.

## Error envelope
```json
{
  "error": {
    "code": "INSUFFICIENT_FUNDS",
    "message": "Available account balance is insufficient.",
    "correlationId": "...",
    "retryable": false
  }
}
```

Stable codes: `INVALID_REQUEST`, `UNBALANCED_TRANSACTION`, `CURRENCY_MISMATCH`, `ACCOUNT_NOT_FOUND`, `ACCOUNT_UNAVAILABLE`, `INSUFFICIENT_FUNDS`, `IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_PAYLOAD`, `TRANSACTION_NOT_FOUND`, `TENANT_CONTEXT_MISSING`, `INTERNAL_ERROR`.

## Retry contract
Callers may retry transport failures only with the same idempotency key and identical payload. `422` financial/business rejections are non-retryable without a changed business request. `503` may be retried with backoff and the same key.
