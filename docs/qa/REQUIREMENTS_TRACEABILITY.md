# Requirements Traceability

Evidence shorthand: `UI` = Next.js application surfaces/actions; `DB` = production Supabase schema/RLS/RPCs; `UT` = domain unit tests; `E2E` = Playwright browser verification; `DOC` = approved product/architecture contract. `FOUNDATION` means the release satisfies the explicitly scoped data/architecture primitive while a later provider/seasonal experience is intentionally deferred.

| Requirement ID | Requirement | Test/evidence | Result | Finding |
|---|---|---|---|---|
| R01 | Universal profile | UI, DB | PASS | Profile/sports/passport/progress/social identity surfaces present |
| R02 | Clans | UI, DB | PASS | Create/join/request/leave/search/community operations implemented |
| R03 | Clan profile | UI, DB | PASS | Multi-sport clan identity, members, teams, activity/progression surfaces |
| R04 | Clan roles | UI, DB | PASS | Role assignment/review authorization implemented |
| R05 | Teams inside clans | UI, DB | PASS | Team creation and membership implemented |
| R06 | Discover | UI, DB | PASS | Activities/clans/people discovery with deterministic filtering |
| R07 | Right Now | UI | PASS | High-intent soon/joinable discovery path |
| R08 | Create activity | UI, DB | PASS | Activity creation and RSVP settings/path implemented |
| R09 | Attendance | UI, DB | PASS | Organizer-authorized attendance states and history model |
| R10 | Pickup mode | UI, DB | PASS | Pickup activity mode represented/discoverable |
| R11 | Looking for players | UI, DB | PASS | Capacity/open-slot rescue signal supported |
| R12 | Looking for opponent | UI, DB | PASS | Match/opponent competitive primitives supported |
| R13 | Training partners | UI, DB | PASS | People/partner discovery uses sport/city/availability context |
| R14 | Deterministic matching | UI, DB, DOC | PASS | No model dependency; explicit transparent attributes |
| R15 | Availability | UI, DB | PASS | User availability and clan-pulse foundation implemented |
| R16 | Compete hub | UI, DB | PASS | Ratings/challenges/tournaments/leaderboard surfaces |
| R17 | Ojoro Score | UI, DB, UT | PASS | Deterministic score/progression model |
| R18 | Ojoro Level / XP | UI, DB, UT | PASS | Lifetime XP and level calculation implemented |
| R19 | Sport metrics | DB, UI | PASS | Sport-specific stats/rating model extensible by sport |
| R20 | Clan leaderboards | DB, UI | PASS | Clan competitive/progression ranking primitives and surfaces |
| R21 | Clan vs clan | DB, UI | PASS | Team/clan competitive match/challenge structure |
| R22 | Challenges | UI, DB | PASS | Challenge creation/join/progress model |
| R23 | Personal goals | UI, DB | PASS | Goal data and profile/home progress surfaces |
| R24 | Quests | DB, UI | PASS | Curated challenge/XP primitive represented by challenge system |
| R25 | Achievements | UI, DB | PASS | Definition and earned-achievement records on identity surfaces |
| R26 | Match creation/results | UI, DB | PASS | Lineups, score, stats/MVP/result submission |
| R27 | Result verification | UI, DB | PASS | Participant confirmation and verified-result state |
| R28 | Sport skill rating | DB, UI, UT | PASS | Sport/season-aware Elo-like rating foundation |
| R29 | Social vs competitive modes | UI, DB | PASS | Event/user modes and competition quiet behavior |
| R30 | Clan progression/missions | DB, UI | PASS | Clan XP/level and challenge foundations |
| R31 | Community contribution | DB, UI | PASS | Hosting/community contribution represented separately from skill |
| R32 | Activity-driven feed | UI, DB | PASS | Posts/activity-linked social feed foundation |
| R33 | Activity recap | UI, DB | PASS | Result/attendance/XP-linked recap foundation |
| R34 | Chat | UI, DB | PASS | Direct, clan/team/event channel primitives and messaging UI |
| R35 | Notifications | UI, DB | PASS | Notification inbox and domain event notification foundation |
| R36 | Calendar | UI, DB, E2E | PASS | In-app schedule plus authenticated portable `.ics` export |
| R37 | Ojoro Status | UI, DB | PASS | Expiring intent/status model |
| R38 | Maps/spots foundation | DB, DOC | FOUNDATION PASS | Coordinates/community sport spots modeled; precise live-profile location intentionally excluded |
| R39 | Tournaments | UI, DB | PASS | Registration, fixtures, scoring and knockout progression |
| R40 | Seasons | DB, UI | FOUNDATION PASS | Seasonal rating/competition records supported |
| R41 | Championships | DB, DOC | FOUNDATION PASS | Qualification-capable tournament/clan structures; city championship orchestration later |
| R42 | Passport | UI, DB | PASS | Distinct sports participation represented on user identity |
| R43 | Activity map / annual summary | DB, DOC | FOUNDATION PASS | Historical activity/location data is retained for derived annual experience |
| R44 | Wrapped | DB, DOC | FOUNDATION PASS | Existing deterministic history supports annual summary; dedicated yearly presentation is expansion work |
| R45 | Reputation | UI, DB, UT | PASS | Behavior-derived reliability rather than general star rating |
| R46 | Safety | UI, DB | PASS | Report/block/moderation-ready state; precise trusted-location sharing excluded by requirement |
| R47 | Verification levels | DB | PASS | Result/provider/organizer verification metadata foundations |
| R48 | Verified clan/organizer foundation | DB, UI | FOUNDATION PASS | Verification-ready state modeled; operational verification process later |
| R49 | Wearable/import foundation | DB, DOC | FOUNDATION PASS | Provider-source activity model exists; wearable OAuth intentionally deferred |
| R50 | Ojoro Daily | UI, DB | PASS | Home snapshot of upcoming activity/community/progress |
| UX-A | Tonight mode | UI | PASS | Soon/open high-intent discover mode |
| UX-B | Clan Pulse | UI, DB | PASS | Aggregate availability without precise private location |
| UX-C | Last Spot Rescue | UI, DB | PASS | Urgent open-capacity signal |
| UX-D | Afterglow | UI, DB | PASS | Post-activity recap foundation |
| UX-E | Community Impact | UI, DB | PASS | Contribution identity separate from athletic ranking |
| UX-F | Competition Quiet Mode | UI, DB | PASS | Competitive surfaces can be suppressed without deleting progress |
| UX-G | Location Privacy Ladder | DB, UI, DOC | PASS | City/coarse/event-specific location model; no always-on precise profile location |

## Verification summary
- Stable requirements traced: **50/50**.
- Added UX requirements traced: **7/7**.
- Core P0/P1 behavior: **PASS**.
- Expansion requirements explicitly described as foundations by the product contract: **FOUNDATION PASS**, not misrepresented as live third-party integrations.
- Release-blocking traceability gaps: **0**.