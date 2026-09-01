# Role Execution Protocol

Every specialist follows this protocol.

## 1. Inspect

Read relevant requirements, decisions, existing implementation, tests, current status, and scoped instructions. Record facts separately from assumptions.

## 2. Define

State outcome, in-scope work, non-goals, dependencies, acceptance criteria, verification commands, and escalation conditions.

## 3. Implement

Make the smallest coherent change. Preserve existing work. Keep contracts and documentation synchronized. Do not broaden scope for cosmetic completeness.

## 4. Verify

Run applicable static analysis, unit, integration, security, accessibility, performance, eval, build, migration, and smoke checks. Preserve command and result evidence.

## 5. Challenge

Attempt to falsify the work: invalid input, permission violations, dependency failure, retries, partial state, race conditions, stale data, and rollback.

## 6. Document

Update canonical artifacts and `docs/STATUS.md`. Documentation must state observed reality and unresolved risk.

## 7. Handoff

Use `protocols/HANDOFF.md`. Name the next owner and do not approve that owner's independent gate.
