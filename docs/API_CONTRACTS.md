# Ojoro Application Contracts

The primary server interface is typed Next.js server actions backed by Supabase. Database RLS remains authoritative.

## Result envelope

Mutations return a serializable result:

```ts
type ActionResult<T = undefined> =
  | { ok: true; data?: T }
  | { ok: false; code: string; message: string; fieldErrors?: Record<string, string[]> };
```

Never return stack traces, raw database messages or secret values.

## Authentication

All authenticated actions resolve identity from the Supabase server session. `profile_id`, `organizer_id`, `author_id` and similar ownership values are never trusted from form data.

## Core commands

### `createActivity(input)`
Auth: required. Validates title, sport, mode, times, city/location, capacity, visibility, optional clan/team permission. Organizer is current user. Returns activity ID/slug.

### `rsvpActivity(activityId, status)`
Auth: required. Status in `going|maybe|cancelled`. Server determines capacity and waitlist; client cannot force `going` when full. Idempotent per activity/profile.

### `recordAttendance(activityId, profileId, state)`
Auth: organizer or authorized clan role. State in `attended|excused|late_cancel|no_show`. Database trigger updates idempotent XP and derived reputation inputs.

### `createClan(input)` / `joinClan(clanId)` / `leaveClan(clanId)`
Auth: required. Public clans permit direct membership; private clans create a pending request. Last founder/owner cannot leave without ownership transfer.

### `createChallenge(input)` / `joinChallenge(id)` / `updateChallengeProgress(id, value)`
Auth: required. Progress is bounded and challenge-type authorization applies. Device/provider verified progress is a future input type, not required.

### `createMatchResult(input)` / `confirmMatchResult(resultId)`
Auth: eligible participants/captains/organizers. Competitive rating changes only after required confirmation threshold and verified state.

### `sendMessage(channelId, body)`
Auth: required channel access. Body length bounded; blocked-user rules apply to direct channels.

### `createPost(input)` / `reactToPost(postId, reaction)`
Auth: required. Clan/activity visibility is checked by RLS.

### `setAvailability(input)` / `setStatus(input)`
Auth: current user only. Status expires and does not expose precise location.

### `reportEntity(kind, entityId, reason, details)` / `blockUser(profileId)`
Auth: required. Reports are private to reporter and moderation/admin paths; blocking immediately suppresses direct social discovery and messaging paths where queries enforce it.

## Read contracts

Reads are server functions that return bounded projections rather than `select('*')` on sensitive tables:
- `getHomeSnapshot()`
- `discoverActivities(filters, cursor)`
- `discoverClans(filters, cursor)`
- `getActivity(id)`
- `getClan(slug)`
- `getProfile(username)`
- `getLeaderboards(scope, sport, season, cursor)`
- `getMessages(channel, cursor)`
- `getNotifications(cursor)`

All collections use a default limit ≤ 30 and hard maximum ≤ 100.

## Error codes

Stable codes include `AUTH_REQUIRED`, `FORBIDDEN`, `NOT_FOUND`, `VALIDATION_ERROR`, `CONFLICT`, `CAPACITY_FULL`, `RSVP_CLOSED`, `BLOCKED`, `RATE_LIMITED`, `DEPENDENCY_UNAVAILABLE`, `UNKNOWN`.

## Idempotency

- RSVP uses one row per activity/profile.
- XP ledger has unique source keys.
- result confirmation has one row per result/profile.
- reactions have one row per post/profile/type.
- join membership is unique per clan/profile.

Retries must therefore converge rather than duplicate side effects.
