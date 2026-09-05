# Ojoro Test Strategy

## Pyramid

1. **Domain unit tests** — score/level/reliability/rating helpers, validators, waitlist transitions.
2. **Database integration tests** — migrations, constraints, RLS, triggers, idempotent XP/result confirmations.
3. **Server action tests** — auth, validation, authorization and error mapping.
4. **Component/accessibility tests** — navigation, forms, state rendering, keyboard semantics.
5. **Playwright E2E** — public/auth surfaces in CI; authenticated critical journeys against a configured test Supabase environment.
6. **Production smoke** — landing, auth reachability, signed-in home read, discovery read, safe create/cleanup test account path when production policy permits.

## Critical journeys

- Sign up → onboarding → discover → RSVP → attendance → XP/profile history.
- Create clan → invite/join → create team/activity → manage attendance.
- Full activity → waitlist → cancellation → promotion without duplicate participation.
- Competitive result → confirmations → verified → rating update exactly once.
- Private clan/event cannot be read by unrelated user.
- Blocked user cannot initiate permitted direct social path.
- Organizer cannot alter unrelated activity; member cannot promote own role.
- Competition Quiet Mode hides ranking UI without erasing data.

## Negative / recovery cases

Expired auth, duplicate submit, stale capacity, cancelled event, RSVP deadline elapsed, network retry, realtime reconnect, malformed IDs, direct database call under anon/authenticated roles, duplicate XP source, result disagreement, deleted/blocked actor, empty city, no matches.

## Accessibility

Keyboard-complete critical navigation/forms, visible focus, form labels/errors, dialog/sheet focus trapping where used, reduced motion, contrast checks, 320px width and 200% zoom sanity.

## CI commands

```bash
npm --prefix apps/ojoro-web install
npm --prefix apps/ojoro-web run lint
npm --prefix apps/ojoro-web run typecheck
npm --prefix apps/ojoro-web run test
npm --prefix apps/ojoro-web run build
npm --prefix apps/ojoro-web run test:e2e
python scripts/validate_factory.py .
python -m unittest discover -s tests -v
```

Authenticated database/E2E suites require `NEXT_PUBLIC_SUPABASE_URL` and a publishable test key plus test-user fixtures. CI must mark those suites blocked rather than silently mock production behavior when secrets are absent.
