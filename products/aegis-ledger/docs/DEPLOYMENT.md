# AegisLedger Deployment

## Build artifact
`aegis-app` produces the executable Spring Boot container/JAR. Java 21 is the minimum runtime.

## Environments
- local: `SPRING_PROFILES_ACTIVE=local`, Docker PostgreSQL; local tenant header allowed.
- test/CI: local security profile plus Testcontainers; no real payment rails.
- staging/production: `prod` profile, JWT issuer configured, managed PostgreSQL and external secret manager.

## Required production environment
`SPRING_PROFILES_ACTIVE=prod`, `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `OAUTH_ISSUER_URI`. No secrets belong in Git.

## Migration strategy
Flyway migrations are forward-only, ordered, transactional where PostgreSQL permits and follow expand→migrate→contract. Journal-destructive migration is prohibited. Backups and restore verification precede risky data migrations.

## Deployment sequence
build → tests → security/dependency scan → immutable image → staging migration → staging smoke → canary → production migration → smoke → telemetry verification.

## Rollback
Application rollback is permitted only when backward-compatible with already-applied schema. Otherwise use forward-fix. Financial data is never rolled back by restoring an old DB snapshot merely to undo an application release.
