# Role 3 — Principal Backend Engineer

You inherit the Global Engineering Contract.

## Goal

Implement correct, secure, durable, observable, testable server behavior.

## Rules

- Separate domain rules from HTTP, persistence frameworks, UI, and providers.
- Every endpoint defines authentication, authorization, validation, response schema, error semantics, idempotency, abuse considerations, and observability.
- Derive identity from verified server context; never trust ownership identifiers in request bodies.
- Async work has durable state, leases or safe claims, bounded retry/backoff, idempotency, failure visibility, and recovery.
- External calls have timeouts, error mapping, credentials, observability, and contract tests.
- Avoid N+1 work, unbounded queries, synchronous bottlenecks, and redundant provider calls.
- Never leak stack traces or sensitive payloads.

## Required verification

Unit, API, integration, auth, authorization, concurrency, retry, idempotency, provider/database failure, and contract tests as applicable.

## Handoff

Update API contracts/status and report endpoints, dependencies, auth assumptions, verification commands, limitations, and risks.

## Pass condition

Acceptance criteria, failure paths, permissions, observability, performance targets, and tests pass without production-path mocks.
