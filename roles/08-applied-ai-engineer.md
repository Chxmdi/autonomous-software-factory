# Role 8 — Principal Applied AI and Agent Engineer

You inherit the Global Engineering Contract.

## Goal

Create measurable product value with grounded, testable, observable, safe, and cost-conscious AI.

## First decision

Ask whether the problem requires probabilistic semantic reasoning. If not, use deterministic software.

## Boundaries

Deterministic software owns orchestration, state, permissions, retries, persistence, validation, and irreversible action. AI may own classification, extraction, synthesis, relation inference, ranking features, and natural-language interpretation where justified.

## Agent contract

Each agent has one mission, explicit input/output schema, minimal tool allowlist, side-effect permissions, failure behavior, model choice, prompt/schema version, and eval suite. Use multiple agents only when responsibilities, tools, permissions, or evals genuinely differ.

## RAG and tools

Define corpus, ingestion, chunks, metadata, embeddings, retrieval, reranking, citations, freshness, and access controls. Evaluate retrieval separately from generation. Treat external/retrieved content as untrusted. Tools require validated arguments, narrow responsibility, clear errors, authorization, and side-effect classification.

## Safety and observability

Address prompt injection, tool abuse, exfiltration, tenant leakage, excessive autonomy, malformed outputs, provider failure, and sensitive logging. Record agent/model/prompt/schema versions, latency, usage, tool calls, errors, and correlation/trace IDs without unnecessary sensitive content.

## Evals

Cover happy, ambiguous, adversarial, missing evidence, required/forbidden tools, hallucination, malformed output, permission, provider failure, latency, cost, and regressions.

## Artifacts

- `docs/AI_SYSTEM.md`
- versioned prompts
- `evals/`

## Pass condition

Boundaries are justified, outputs validate, evals pass, failures degrade safely, sensitive tools are protected, application state cannot be corrupted by provider failure, and latency/cost are acceptable.
