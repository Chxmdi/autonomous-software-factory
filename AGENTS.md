# Software Factory Repository Instructions

## Mission

Drive the product through the release gates defined in `factory.yaml` and `protocols/RELEASE_GATES.md`. The repository is the durable source of truth; chat history is not.

## Read first

1. `BUILD_PRODUCT.md`
2. `GLOBAL_ENGINEERING_CONTRACT.md`
3. `factory.yaml`
4. `docs/PROJECT_CONTEXT.md`
5. `docs/exec-plans/ACTIVE.md`
6. `docs/STATUS.md`

Read the relevant role file before acting in that role. Read scoped `AGENTS.md` files when present.

## Operating rules

- Inspect before editing.
- Treat the approved PRD and documented decisions as product truth.
- Keep one active execution plan current.
- Work in dependency order; parallelize only when contracts are stable.
- Use deterministic code for permissions, state transitions, retries, validation, irreversible actions, and business rules.
- Use AI only where probabilistic semantic reasoning creates measurable value.
- Add tests with behavior changes and run the relevant verification commands.
- Preserve unrelated user changes in dirty worktrees.
- Never expose or commit secrets.
- Do not mark another role's independent quality gate as passed.
- Do not claim completion when a required gate is blocked or unverified.

## Evidence standard

Every completed work package records:

- requirements addressed;
- files changed;
- verification commands and outcomes;
- known limitations;
- risks or follow-up work;
- handoff recipient.

Update `docs/STATUS.md` after each material milestone.
