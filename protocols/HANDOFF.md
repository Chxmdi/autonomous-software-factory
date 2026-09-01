# Handoff Contract

Each handoff contains:

```yaml
work_package: stable identifier
owner: role that performed the work
outcome: concise result
requirements_addressed: []
files_changed: []
contracts_changed: []
data_or_migration_impact: none
security_impact: none
verification:
  - command: exact command
    result: pass|fail|blocked
    evidence: concise output or artifact
known_limitations: []
open_risks: []
blockers: []
rollback_or_recovery: concise procedure
next_owner: role
requested_review: explicit review objective
```

A handoff is incomplete if the recipient must rediscover the goal, relevant files, validation command, or unresolved risks.
