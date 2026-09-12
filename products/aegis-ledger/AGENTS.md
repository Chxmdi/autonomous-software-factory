# AegisLedger Scoped Factory Instructions

The repository-level `AGENTS.md`, `BUILD_PRODUCT.md`, `GLOBAL_ENGINEERING_CONTRACT.md`, `factory.yaml`, and role definitions remain authoritative. This file scopes those rules to AegisLedger without overwriting the existing Ojoro product state.

## Product scope
- Product root: `products/aegis-ledger/`
- Canonical product context: `products/aegis-ledger/docs/PROJECT_CONTEXT.md`
- Canonical PRD: `products/aegis-ledger/docs/requirements/AEGIS_LEDGER_PRD.md`
- Active execution plan: `products/aegis-ledger/docs/exec-plans/ACTIVE.md`
- Delivery status: `products/aegis-ledger/docs/STATUS.md`

## Rules
- Treat paths in the root factory gate definitions as relative to this product root while working on AegisLedger.
- Do not modify Ojoro files to satisfy AegisLedger gates.
- Preserve financial invariants above performance shortcuts.
- Money never uses binary floating point.
- Posted journal entries are immutable; corrections use new reversing entries.
- Tenant identity is derived from trusted server context in production.
- Mutation endpoints require durable database-backed idempotency.
- Kafka, Redis, and OpenSearch are not financial sources of truth.
- Never claim exactly-once transport semantics. AegisLedger provides business-level exactly-once effects through idempotency, uniqueness, transactions, deduplicated consumers, and reconciliation.
- Any externally ambiguous settlement outcome enters an explicit UNKNOWN/reconciliation state; never blindly retry a possible money movement.
