# Ojoro Security & Privacy

## Threat model priorities

1. Cross-user/clan data access via guessed IDs.
2. Privilege escalation to clan admin/organizer.
3. Fake attendance/results/XP/rank manipulation.
4. Harassment through discovery/chat.
5. Precise location leakage for real-world events.
6. Stored XSS/content abuse through posts/messages/profile text.
7. Session theft/CSRF-like unsafe mutations.
8. Mass enumeration/scraping of users and private clans.

## Controls

- Supabase Auth sessions; server derives identity.
- RLS on every user/community table; no application-only authorization.
- Foreign keys, checks and unique constraints enforce invariants.
- Security-definer functions use fixed search paths and minimum grants.
- Score/XP/rating columns are not directly writable by normal users.
- Zod validates server action input; output is projected/minimized.
- React escapes user content; no raw HTML rendering.
- Messages/posts/profile fields have length limits and moderation/report controls.
- Direct messaging requires channel membership and block checks.
- Private clan/event membership gates private content.
- Precise event coordinates/address are optional and separate from city/location label; profile home coordinates are not stored.
- Publishable Supabase key may be client-visible; service-role key is prohibited from client bundles.
- Secrets live in deployment secret stores and `.env.local`, never Git.

## Authorization model

Clan role order: Founder → Leader → Captain/Coach/Event Organizer/Moderator → Member. Permissions are capability-specific, not simply numeric: e.g. a Moderator can moderate community content but cannot transfer ownership; Event Organizer can manage activities but not member roles.

Activity organizer or authorized clan role may record attendance. Participants can change only their own RSVP. Competitive result verification requires eligible participant/captain confirmation before ratings are updated.

## Abuse controls

Application actions are designed for platform-level rate limiting. High-risk operations (account creation, DM initiation, report spam, invites, result submissions) require dedicated rate limits before large public launch. Database constraints prevent duplicate amplification regardless of HTTP retries.

## Privacy lifecycle

- Users can edit profile visibility and competitive visibility.
- Blocks are private.
- Reports are private moderation records.
- Account deletion workflow must remove/anonymize personal content consistent with legal retention requirements while preserving aggregate event integrity where necessary.
- Activity history may be retained as anonymized records when a user deletes an account if required to preserve results; decision must be documented before launch.
- Export endpoint/provider job is P2 before broad public launch.

## Security verification

Required before release: RLS adversarial tests for two unrelated users, private/public clans, organizer/member roles, channel membership, notifications and reports; dependency audit; secret scan; XSS review; authorization tests for attendance/result/rating paths; Supabase security advisors with no unresolved critical findings.
