# Global Engineering Contract

This contract applies to every role, work package, and release.

## Objective

Build the smallest coherent product that satisfies the approved requirements and is secure, testable, observable, maintainable, deployable, and recoverable.

## Source-of-truth order

When documents conflict, resolve them in this order:

1. explicit current user instruction;
2. approved product requirements and recorded decisions;
3. architecture and interface contracts;
4. active execution plan;
5. implementation and tests;
6. older plans and chat history.

Record material conflict resolutions in `docs/DECISIONS.md`.

## Non-negotiable rules

1. No hidden scope. Every feature maps to a requirement or documented decision.
2. No false completion. A claim requires reproducible evidence.
3. No production-path placeholders, hard-coded demo success, or silent mocks.
4. No client-side authorization or secret ownership.
5. No raw secrets in prompts, logs, commits, issues, or reports.
6. No probabilistic AI for deterministic control decisions.
7. AI outputs used by software are schema-validated and fail safely.
8. User-owned data has explicit ownership, lifecycle, access control, deletion, and retention behavior.
9. Background work is durable, retryable, idempotent, observable, and bounded.
10. External integrations have timeouts, error mapping, credential handling, and test strategy.
11. Accessibility is a release requirement, not polish.
12. Destructive operations require resolved scope and appropriate authorization.
13. Existing user changes are preserved unless replacement is explicitly authorized.
14. Documentation must describe reality, not intention.

## Required engineering behavior

For each work package:

1. inspect the current state;
2. state the outcome and acceptance criteria;
3. identify dependencies and risks;
4. implement the smallest coherent change;
5. test happy, negative, permission, and recovery paths as applicable;
6. run adversarial self-review;
7. update canonical documentation;
8. create a structured handoff.

## Escalation boundary

Continue autonomously when repository evidence, tests, documentation, or safe diagnostics can resolve the issue. Escalate only when:

- a product decision materially changes behavior and cannot be inferred;
- required authorization is absent;
- a destructive or financially consequential action needs approval;
- a required secret or infrastructure permission is unavailable;
- legal, privacy, or security risk requires owner judgment;
- mutually exclusive requirements cannot be reconciled.

## Definition of production ready

Production readiness requires:

- requirements coverage;
- passing relevant automated checks;
- independent QA with no unresolved P0 and accepted P1 risk;
- independent audit result of PASS or documented conditional approval;
- reproducible deployment and migrations;
- externally verified smoke flow;
- observability and incident response;
- backup/restore where state matters;
- tested rollback or forward-fix procedure;
- known limitations and unresolved risks documented.
