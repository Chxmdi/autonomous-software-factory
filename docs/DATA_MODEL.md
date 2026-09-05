# Ojoro Data Model

## Core ownership graph

```text
auth.users ─1:1─ profiles ─< user_sports
             │       ├─< availability
             │       ├─< goals
             │       ├─< xp_ledger
             │       ├─< ratings
             │       └─< achievements
             │
             ├─< clan_members >─ clans ─< teams
             │                    │        └─< team_members
             │                    └─< activities
             │
             ├─< activity_participants >─ activities ─< match_results / stats
             ├─< challenge_members >─ challenges
             ├─< posts / comments / reactions
             ├─< channel_members >─ chat_channels ─< messages
             ├─< notifications
             ├─< reports
             └─< blocks
```

## Invariants

- One profile per auth user; username unique case-insensitively.
- One membership per profile/clan and profile/team.
- One participation row per profile/activity.
- `end_at > start_at`; capacity positive; cost non-negative.
- RSVP cannot bypass private visibility, deadlines or capacity logic.
- One XP event per `(profile, source_kind, source_id, reason)`.
- Lifetime XP is derived/updated only from ledger writes; normal users cannot set it directly.
- Ratings are unique per `(profile, sport, season)` and update only after verified competitive results.
- Result confirmation unique per `(result, profile)`.
- Clan ownership cannot be represented by an arbitrary client role mutation.
- Messages are immutable except soft-delete/moderation metadata; channel access is membership-derived.
- Reported content/user records are not visible to unrelated users.

## Delete behavior

Most relationship rows cascade with the parent resource. Account deletion requires an explicit application workflow: profile PII is deleted/anonymized; authored social content can be deleted or anonymized; event/result records may retain a null/anonymized participant reference only if product/legal policy requires historical integrity. No migration performs user-data deletion implicitly.

## Index strategy

- activities: `(city, start_at)`, `(sport, start_at)`, `(clan_id, start_at)`, status/start.
- memberships: profile and clan/team composites.
- feed: `(created_at desc)`, clan/activity scopes.
- messages: `(channel_id, created_at desc)`.
- notifications: `(profile_id, read_at, created_at desc)`.
- leaderboards: rating/score indexes or bounded materialized/stat views after measured need.
- usernames, clan slugs unique.

## Derived data

Transparent views/functions calculate:
- recent reliability;
- Ojoro Score inputs;
- clan contribution totals;
- sport passport;
- seasonal leaderboards.

Derived values that are cheap are computed; expensive ranking snapshots may be materialized only after query evidence warrants it.
