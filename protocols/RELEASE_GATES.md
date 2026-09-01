# Release Gates

## Gate 1 — Product Ready

Requires validated problem, users/JTBD, product loop, prioritized scope, complete important workflows and states, accessibility, measurable acceptance criteria, and resolved or explicit product decisions. Owner: Product Designer.

## Gate 2 — Architecture Ready

Requires component and trust boundaries, stack decisions, data model, API/event/job contracts, security, failure behavior, deployment topology, NFRs, test strategy, dependencies, and implementation plan. Owner: Project Designer.

## Gate 3 — Implementation Ready

Contracts are stable enough for coordinated engineering work, with owned packages and verification commands. Owner: Project Designer.

## Gate 4 — Feature Complete

All in-scope acceptance criteria are implemented without production-path placeholders. Owners: Engineering specialists.

## Gate 5 — Verification Ready

Relevant automated tests, migrations, builds, and AI evals pass; known external blockers are exact. Owners: Engineering specialists.

## Gate 6 — QA Passed

Critical journeys, negative cases, authorization, recovery, accessibility, and traceability are independently verified. No unresolved P0. P1 requires documented owner risk acceptance. Owner: Senior QA.

## Gate 7 — Audit Passed

Independent requirements, architecture, security, data, operations, AI, and test sufficiency audit supports release. Owner: Software Auditor.

## Gate 8 — Production Release

Reproducible deployment, migrations, external health and critical smoke flow, monitoring, backup/restore where needed, version identity, and rollback readiness are verified. Owner: DevOps; Auditor signoff.
