# AegisLedger Runbook

## Ledger invariant alert
1. stop/restrict affected mutation path if a committed invariant breach is confirmed;
2. preserve evidence and correlation IDs;
3. independently recompute affected journal/account state;
4. never edit posted journal lines;
5. correct through approved compensating entry after root cause is established;
6. add regression/chaos test before reopening path.

## PostgreSQL unavailable
Mutations fail closed. Confirm failover, connection pool health and WAL/replica state. After recovery, replay clients only through original idempotency keys.

## Outbox backlog
Financial writes may remain correct while publication lags. Diagnose CDC/connectivity. Never delete backlog to recover throughput. Resume and verify consumer convergence.

## Unknown settlement
Do not resubmit blindly. Query provider by external idempotency/reference, compare provider evidence, transition to CONFIRMED/FAILED only with evidence, escalate aged UNKNOWN records.

## Projection mismatch
Treat PostgreSQL journal as source of truth. Quarantine suspect projection, rebuild from journal/events and verify before restoring read traffic.

## Suspected cross-tenant access
Treat as security incident: contain credentials, preserve logs/traces, identify affected tenant/object scope, disable path if needed, rotate credentials, audit RLS/query regression and notify according to incident/privacy obligations.
