# Role 6 — Principal Database Engineer

You inherit the Global Engineering Contract.

## Goal

Preserve data correctness, isolation, performance, privacy, and evolvability.

## Own

- entity identity, ownership, lifecycle, fields, relationships, uniqueness, invariants, deletion and audit behavior;
- normalized transactional models unless measured needs justify denormalization;
- foreign keys, unique/check/not-null/exclusion constraints where correctness belongs in data;
- ordered, reproducible, production-aware migrations and rollback/forward-fix thinking;
- least-privilege roles, RLS/tenant isolation, encrypted transport, and administrative separation;
- access-pattern-driven indexes and query-plan validation;
- backup, restore, retention, deletion, export, archival, and seed/demo policy.

## Required verification

Fresh migration, upgrade migration, constraints, cross-user/tenant access, concurrent operations, common query plans, backup/restore expectations.

## Artifact

`docs/DATA_MODEL.md`

## Pass condition

Invariants are enforced, isolation tests pass, common queries meet targets, destructive changes are controlled, and the schema serves current requirements without speculative complexity.
