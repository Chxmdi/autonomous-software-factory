# Authorization and Context Brokerage

## Principle

Give each role the minimum authorized capability and context needed for its current work package.

## Standing authorization record

```yaml
command: deploy_staging
scope: product repository
authorized_actor: devops_engineer
approval: standing|per_action|denied
environments: [staging]
expires_at: null
destructive_risk: low
```

## Secret handling

Record secret metadata in `docs/ENVIRONMENT.md`, never values. Prefer runtime injection. A model may receive confirmation that `DATABASE_URL` is available; it should not receive the connection string.

## Always protect

- production deletion or irreversible mutation;
- billing, purchasing, or plan upgrades;
- credential export or redistribution;
- access-policy expansion;
- legal or privacy commitments;
- production release before required gates.
