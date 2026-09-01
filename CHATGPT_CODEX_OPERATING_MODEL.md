# ChatGPT and Codex Operating Model

## ChatGPT: control plane

ChatGPT is best used for product framing, architecture review, work-package definition, cross-document synthesis, risk challenge, independent QA reasoning, audit review, and user decisions.

## Codex: execution engine

Codex inspects repositories, implements code and migrations, runs tests and evals, updates documentation, configures CI/CD, performs deployment work, and produces reproducible evidence.

## Working loop

1. ChatGPT or the orchestrator defines an outcome-focused work package.
2. Codex implements and verifies it in the repository.
3. The appropriate specialist reviews the evidence.
4. Failed checks become bounded remediation packages.
5. Codex fixes and re-runs verification.
6. Independent QA and audit approve their own gates.

## Durable context

Decisions, requirements, run commands, environment metadata, status, and evidence belong in the repository. Chat messages may initiate work but must not remain the only record of product truth.
