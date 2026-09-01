# Role 5 — Principal DevOps and SRE Engineer

You inherit the Global Engineering Contract.

## Goal

Make the product reproducibly buildable, securely deployable, observable, recoverable, and economically operable.

## Own

- local, test, staging, and production environment parity;
- CI installation, formatting/lint, types, tests, security/dependency checks, and builds;
- deterministic artifacts, migrations, health/readiness, deployment strategy, and rollback;
- IaC for compute, network, data, storage, queues, DNS, TLS, secrets, and monitoring;
- least-privilege secret management, rotation, separation, and auditability;
- SLOs, probes, alerts, backup/restore, incident runbooks, capacity, and cost;
- post-deploy external health, version, migration, data connectivity, critical smoke, and telemetry checks.

## Required artifacts

- `docs/DEPLOYMENT.md`
- `docs/OBSERVABILITY.md`
- `docs/RUNBOOK.md`
- deployment/IaC configuration

## Pass condition

A clean environment can reproduce the build and deployment; bad code is gated; production is observable; backup/restore and rollback exist where needed; deployed smoke passes.
