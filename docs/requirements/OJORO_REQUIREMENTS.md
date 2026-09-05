# Ojoro Requirements Catalogue

This file converts the master product specification into stable requirement IDs for engineering and QA traceability. The current product-owner instruction that Ojoro is not an AI app supersedes the source's future AI-recommendation idea.

## Identity and community

- **R01 Universal profile** — one identity with picture, username/name, city, bio, sports/skills, positions, learning interests, clans/roles, activity history, achievements, level, score, sport ratings, records, stats, streaks/goals, social graph and behavior-derived reputation.
- **R02 Clans** — create/join/request/invite/search/follow/leave/report public or private, single- or multi-sport clans.
- **R03 Clan profile** — branding, bio, city, sports, visibility, members, founding date, XP/level/rank/record, activities, leaderboards, achievements, feed/media, challenges, directory and stats.
- **R04 Clan roles** — Founder, Leader, Captain, Coach, Event Organizer, Moderator, Member; architecture supports later custom roles.
- **R05 Teams inside clans** — sport-specific sub-teams with memberships while preserving umbrella clan identity.

## Discovery and activity operations

- **R06 Discover** — searchable/filterable clans, sports, activities, games, pickup, tournaments, challenges, training, people/partners/groups/events; filters for distance, sport, skill, intent, date/time, cost, environment, capacity and visibility.
- **R07 Right Now** — quickly surface joinable activities starting soon near the user or in their city.
- **R08 Create activity** — activity/location/date/time/duration/capacity/skill/cost/equipment/privacy/waitlist/team/RSVP settings; Going/Maybe/Can't Go behavior maps to going/maybe/cancelled.
- **R09 Attendance** — attended/missed/late cancel/no-show/organized history and contextual reliability derived without over-punishing legitimate cancellations.
- **R10 Pickup mode** — one-tap find-game path emphasizing start time, distance/city and open spots.
- **R11 Looking for players** — organizers can mark needed slots and target relevant discover surfaces/notifications.
- **R12 Looking for opponent** — teams/clans can publish opponent requests and accept matches.
- **R13 Training partners** — gym/run/tennis/sparring/cycling partner discovery based on activity, city/location, skill and availability.
- **R14 Deterministic matching** — transparent matching from location/city, sports, skill, availability, mutual clans and reliability; no model dependency.
- **R15 Availability** — optional repeating availability that can power clan pulse and creation prompts.

## Progression and competition

- **R16 Compete hub** — individual, clan, sport, city, friends, seasonal, event, challenge and overall leaderboards where data is supported.
- **R17 Ojoro Score** — current broad participation/progress/community score that rewards improvement and contribution, not raw exercise volume only.
- **R18 Ojoro Level / XP** — lifetime XP never decreases; level progression is separate from rank.
- **R19 Sport metrics** — modular sport → metric → leaderboard model supporting football, basketball, running, strength, cycling, swimming and future sports.
- **R20 Clan leaderboards** — rank on participation, results, challenges, hosted events, retention/cross-sport/community contribution and score inputs.
- **R21 Clan vs clan** — multi-event challenge/match structure with XP/trophy/ranking outcomes.
- **R22 Challenges** — personal, friend, clan, clan-vs-clan, city, global and official scopes with goals and progress.
- **R23 Personal goals** — user-defined activity/social/skill goals that influence progress surfaces.
- **R24 Quests** — recurring curated challenges with XP rewards.
- **R25 Achievements** — durable milestone badges shown on profiles.
- **R26 Match creation/results** — teams/players/positions/score/stats/MVP/media/result confirmation.
- **R27 Result verification** — participant/captain/organizer confirmation paths; verified results carry greater competitive weight.
- **R28 Sport skill rating** — Elo-like, sport-specific, team-aware and seasonal; only competitive verified results modify rating.
- **R29 Social vs competitive modes** — Social, Fitness, Competitive, Learning on users/events; competition can be hidden without losing core utility.
- **R30 Clan progression/missions** — clan XP/levels/unlocks-ready model and collective missions.
- **R31 Community contribution** — reward hosting, coaching/welcoming, filling spaces, creating communities and consistent attendance.

## Social and communication

- **R32 Activity-driven feed** — friends/clan posts, results, media, achievements, records, upcoming activities, challenges and announcements; reactions/comments/share/congratulate.
- **R33 Activity recap** — attendance, result, MVP/stats/media, XP and rank movement in a post-activity summary.
- **R34 Chat** — direct, clan, team and event channels with simple channel structure.
- **R35 Notifications** — invites, reminders, challenges, friend activity, leaderboard movement, announcements, nearby/open-slot signals, goal/streak progress.
- **R36 Calendar** — in-app games/training/tournaments/challenges/clan events; provider integrations are expansion work.
- **R37 Ojoro Status** — expiring activity-intent posts such as available tonight / looking for partner.

## Place, seasons and ecosystem

- **R38 Maps/spots foundation** — event coordinates and community sport-location primitives without requiring precise profile location.
- **R39 Tournaments** — knockout, round robin, groups+knockout, league, ladder metadata with entries, fixtures, standings/scores/stats.
- **R40 Seasons** — seasonal competition reset while preserving historical accomplishments.
- **R41 Championships** — data model can qualify top clans for city/championship structures later.
- **R42 Passport** — every distinct participated sport is recorded with exploration achievements.
- **R43 Activity map / annual movement summary** — yearly locations, sports, activities, time/distance when data exists.
- **R44 Wrapped** — annual shareable summary from existing data; no AI generation required.

## Trust and safety

- **R45 Reputation** — objective reliability/sportsmanship/organizer signals derived primarily from behavior; no toxic general-purpose star rating.
- **R46 Safety** — report/block/report clan/event, guidelines/moderation, suspension-ready state, verified-organizer foundation; precise trusted-contact location sharing excluded pending dedicated privacy review.
- **R47 Verification levels** — self, participant, organizer, device/provider, tournament verification metadata.
- **R48 Verified clan/organizer foundation** — verification state can represent established, compliant communities after operational review.
- **R49 Wearable/import foundation** — provider-source fields can verify running/cycling/steps/workout data later; Ojoro remains fully usable without a wearable.
- **R50 Ojoro Daily** — actionable home snapshot: friends/clans soon, goal proximity and joinable activities nearby/in-city.

## Superseded source item

The source proposed future AI activity recommendations. **Current owner instruction supersedes it:** Ojoro is not an AI app. Recommendation/matching behavior in this implementation is deterministic, explainable and based on explicit preferences/context.

## Added UX requirements

- **UX-A Tonight mode** — one tap into high-intent soon/open results.
- **UX-B Clan Pulse** — aggregate declared availability without exposing private precise location.
- **UX-C Last Spot Rescue** — urgent open-capacity signal for organizers.
- **UX-D Afterglow** — consolidated activity recap/share surface.
- **UX-E Community Impact** — contribution stats distinct from athletic skill.
- **UX-F Competition Quiet Mode** — hide rankings globally while preserving personal progress.
- **UX-G Location Privacy Ladder** — city/coarse/event-specific precision rather than always-on precise location.
