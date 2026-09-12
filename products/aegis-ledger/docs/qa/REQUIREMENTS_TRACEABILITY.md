# Requirements Traceability — AegisLedger

| Requirement | Primary evidence | Current state |
|---|---|---|
| FR-01 double entry | domain validator + DB deferred balance trigger | authored |
| FR-02 tenant isolation | JWT resolver + repository tenant predicates + RLS | authored |
| FR-03 protected balances | balance rules + locked posting transaction | authored |
| FR-04 idempotency | DB unique record + request hash | authored |
| FR-05 immutable journal | DB mutation trigger | authored |
| FR-06 outbox | same transaction insert | authored |
| FR-07 query | transaction query endpoint/port | authored |
| FR-08 holds | PRD/schema evolution only | planned |
| FR-09 settlement | design only | planned |
| FR-10 refund/reversal | design only | planned |
| FR-11 reconciliation | strategy/runbook only | planned |
| FR-12 auditability | correlation foundations; admin audit not complete | partial |

QA must convert `authored` to PASS/FAIL from executable evidence.
