# Autonomous Software Factory

A reusable, evidence-driven engineering operating system for Codex and human teams. It turns a product brief or PRD into a governed delivery workflow with explicit ownership, durable context, release gates, independent QA, and production-readiness auditing.

## What this is

This repository is a template, not an application framework. Install it into an existing or new product repository, complete `docs/PROJECT_CONTEXT.md`, then run the build command in `BUILD_PRODUCT.md`.

The factory deliberately separates:

- product truth from implementation;
- deterministic software from probabilistic AI;
- implementation ownership from independent approval;
- credentials from model-visible context;
- claims of readiness from reproducible evidence.

## Quick start

```bash
python scripts/bootstrap_project.py /path/to/product --name "Product Name"
cd /path/to/product
python scripts/validate_factory.py .
```

Then give Codex this instruction:

> Read `BUILD_PRODUCT.md`, `AGENTS.md`, `factory.yaml`, `docs/PROJECT_CONTEXT.md`, and `docs/exec-plans/ACTIVE.md`. Execute every applicable Software Factory gate. Do not stop at planning or scaffolding. Do not claim production readiness until independent QA, audit, deployment smoke verification, and rollback readiness pass with evidence.

## Core workflow

1. Digital Twin / context bootstrap
2. Product design
3. Technical and delivery architecture
4. Database, backend, frontend, and Applied AI workstreams
5. Platform and deployment engineering
6. Independent QA
7. Independent production audit
8. Production release

The Context & Prompt Engineer operates horizontally whenever an AI system or complex coding-agent workflow is present.

## Validation

```bash
python scripts/validate_factory.py .
python -m unittest discover -s tests -v
```

## License

MIT. See `LICENSE`.
