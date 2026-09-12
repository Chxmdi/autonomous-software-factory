# AegisLedger Product Definition

## Problem
Platforms that store or move value frequently mix mutable balances, external payment status, and business records. Under retries, concurrency and partial failure this creates duplicate charges, negative balances, irreconcilable records and opaque incident recovery.

## Users
- Platform/backend engineers integrating money movement.
- Payment engineers operating authorization/capture/settlement.
- Finance and reconciliation teams proving internal/external agreement.
- SREs diagnosing failures without editing financial history.
- Auditors reconstructing who moved what, when and why.

## Jobs to be done
- Post a balanced financial transaction exactly once at the business level.
- Query immutable journal history and account state.
- Reject unsafe concurrent debits.
- Replay client requests safely.
- Publish committed financial facts without dual-write loss.
- Detect projection/provider discrepancies and recover without rewriting history.

## Minimum useful product loop
Create ledger/accounts (administrative bootstrap) → submit balanced transaction with idempotency key → atomically post journal and account projection → emit outbox fact → query immutable transaction → reconcile derived state.

## V1 scope
- single-currency ledgers;
- double-entry journal posting;
- protected account balances;
- idempotent mutation boundary;
- transaction query;
- PostgreSQL RLS and immutable journal controls;
- transactional outbox;
- operational telemetry and health;
- concurrency/replay tests;
- provider/settlement interfaces and state model documented, with full external orchestration in later work packages.

## Explicit non-goals for first slice
- live ACH/card movement;
- cardholder-data storage;
- FX execution;
- fraud scoring;
- tax/accounting ERP;
- consumer UI;
- blockchain consensus.

## Product acceptance
A reviewer can deliberately duplicate, race, crash and replay posting operations and the final ledger remains balanced, protected accounts remain within policy, and each logical command has no more than one financial effect.
