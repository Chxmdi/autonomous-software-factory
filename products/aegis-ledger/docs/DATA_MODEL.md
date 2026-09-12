# AegisLedger Data Model

## Core tables
### tenants
`id`, `name`, `created_at`.

### ledgers
`id`, `tenant_id`, `name`, `currency`, timestamps. Unique name per tenant. V1 ledger is single-currency.

### accounts
`id`, `tenant_id`, `ledger_id`, `account_type`, `operational_role`, `normal_balance`, `currency`, `status`, `negative_policy`, `credit_limit_minor`, `posted_balance_minor`, `version`, timestamps.

### journal_transactions
Immutable posted resource: `id`, tenant/ledger, type, reference, currency, effective/post time, correlation ID.

### journal_lines
Immutable line: `id`, tenant, transaction, account, sequence, direction, positive minor-unit amount. Unique sequence per transaction.

### idempotency_records
Unique `(tenant_id, operation_type, idempotency_key)` plus request hash, status and resulting resource ID. Stored in the same transaction as the financial effect.

### outbox_events
Committed publication intent with event UUID, tenant, aggregate ID/type, event type/version, topic/key, JSON payload and creation time.

## Database invariants
- positive journal amounts;
- valid currency format;
- at least policy-compatible credit limit;
- account currency matches ledger by application + FK ownership checks;
- duplicate idempotency scope impossible;
- journal update/delete prohibited by trigger;
- deferred constraint trigger validates debit total equals credit total and line count >= 2;
- RLS scopes every tenant-owned table to session `app.tenant_id`.

## Concurrency
Referenced account rows are locked in deterministic UUID order. Balances are updated with a version predicate as defense in depth. This avoids read-modify-write races and makes multi-account posting atomic in one DB transaction.

## Monetary representation
All persisted values are `BIGINT` minor units. `float`, `double`, `REAL` and `DOUBLE PRECISION` are prohibited for money.

## Retention
Journal history is permanent for this reference implementation. Idempotency records default to a 72-hour product retention target but cleanup is not implemented until replay/audit requirements are finalized. Outbox events require archival/cleanup only after downstream delivery evidence exists.

## Backup/recovery
Production target requires PostgreSQL WAL/PITR, encrypted backups and recurring restore tests. Derived Redis/OpenSearch state can be rebuilt from authoritative data/events.
