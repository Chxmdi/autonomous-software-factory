# AegisLedger Security

## Trust model
Production callers authenticate with OAuth 2.0/JWT. A trusted JWT claim `tenant_id` determines tenancy. Client request bodies and arbitrary forwarding headers never define production ownership.

## Local-only exception
The `local` Spring profile permits `X-Tenant-Id` and unauthenticated requests solely for isolated development. Deployment manifests must never set `SPRING_PROFILES_ACTIVE=local` outside local/test.

## Authorization
Initial transaction endpoints require authenticated callers. Fine-grained scopes to add before production: `ledger:read`, `ledger:write`, `account:read`, `settlement:write`, `reconciliation:read`, `reconciliation:resolve`.

## Defense in depth
- repository queries always include tenant predicates;
- PostgreSQL RLS uses transaction-local `app.tenant_id`;
- tenant-aware foreign keys/ownership validation prevent cross-tenant account composition;
- local profile is visibly separate;
- journal history is immutable;
- mutation idempotency is database-enforced;
- secrets are environment/secret-manager supplied, never committed;
- API errors suppress stack traces/sensitive payloads.

## Threats and controls
| Threat | Control |
|---|---|
| tenant header spoofing | production ignores tenant headers; JWT claim only |
| idempotency replay with modified amount | SHA-256 canonical request hash + 409 |
| duplicate concurrent command | unique DB constraint + same transaction |
| journal tampering | no update/delete trigger + restricted DB role |
| account race/double spend | deterministic row locks + protected final balance check |
| compromised cache/search | neither is authoritative |
| provider timeout after money moved | UNKNOWN + query/reconciliation, no blind retry |
| log credential leakage | structured allowlist fields; no token/body logging |

## Production gaps before release
- explicit IdP/issuer and scope policy;
- database roles separating migrations/runtime/read-only operations;
- TLS/mTLS termination design;
- secret-manager integration and rotation evidence;
- container/image/SBOM vulnerability gates;
- security penetration test and independent audit.
