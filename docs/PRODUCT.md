# Ojoro Product Specification

## Product thesis

Ojoro should not primarily track exercise. It should **create reasons for people to exercise, compete, and meet**. The product is differentiated by turning local physical activity into a social graph, participation record, community structure, and optional competition layer.

## Jobs to be done

### Participant
- When I want to move, help me find something I can actually join soon.
- When I am new to a sport or city, help me find welcoming people at my level.
- When I keep showing up, make my progress and identity visible.
- When I want competition, show fair, sport-specific comparison without punishing casual users.

### Organizer / clan leader
- Help me fill activities with people who are likely to show up.
- Give my community roles, teams, communication, schedules, records and identity.
- Make attendance, waitlists, results and recurring activity easy to operate.

### Competitive participant
- Give me trustworthy results, seasonal ratings, records, leaderboards, tournaments and clan-vs-clan structure.

## Product principles

1. **Activity before content.** Social content exists to cause, document or celebrate real-world activity.
2. **One Ojoro identity.** A user has one evolving sports résumé across sports and communities.
3. **Clans are the social primitive.** Clans can be multi-sport umbrella communities with teams beneath them.
4. **Show-up trust matters.** Reliability is behavior-derived and contextual, never a toxic human star rating.
5. **Progress is broader than performance.** Reward consistency, improvement, trying new sports, organizing and helping others.
6. **Competition is opt-in.** Social, Fitness, Competitive and Learning modes are first-class.
7. **Local utility wins.** “What can I do right now?” and “Who is free?” should be faster than browsing feeds.
8. **Safe by default.** Report/block controls, organizer trust, data minimization and coarse-location defaults are core.
9. **No AI dependency.** Discovery, matching, ranking and recommendations use deterministic filters and transparent scoring.

## Core navigation

- **Home** — Today on Ojoro, upcoming activities, clan pulse, goals/quests, activity-driven feed.
- **Discover** — activities, pickup games, clans, people and partners with time/location/skill/mode filters.
- **Create** — prominent center action for Activity, Clan, Challenge, Match or Tournament.
- **Compete** — leaderboards, challenges, seasons, ratings, tournaments and records.
- **You** — sports résumé, passport, stats, goals, achievements, reputation, availability and settings.

Messages and notifications remain globally reachable without consuming a primary tab.

## Release scope

### P0 — utility loop
Account/profile; sport selection; clans; multi-sport clan pages; roles/teams; activity creation; RSVP/waitlist; attendance; discovery; notifications; goals; XP and levels; activity feed; chat; profile statistics; safety report/block.

### P1 — progression and competition
Ojoro Score; sport and clan leaderboards; challenges; match results and verification; Elo-like sport ratings; seasons; tournaments; clan-vs-clan; achievements; passport; statuses; availability; activity recap; community contribution.

### P2 — expansion-ready primitives
Calendar connections, community sport spots, wearable data imports, verified organizer workflows and annual Wrapped. Provider credentials and privacy review gate these integrations; the domain model supports them without requiring them for the core loop.

## UX additions approved for this build

- **Tonight / Right Now mode:** one tap narrows Discover to joinable activities starting soon.
- **Clan Pulse:** aggregates member-declared availability and open activities; never exposes precise private location.
- **Last Spot Rescue:** organizer can mark an activity as urgently needing players; matching users see a high-signal card.
- **Afterglow Recap:** post-activity recap groups attendance, result, personal bests, photos and XP in one shareable artifact.
- **Community Impact:** separate contribution stats for hosting, coaching, filling last-minute spots and welcoming newcomers.
- **Competition Quiet Mode:** hides rankings while retaining personal progress and community features.
- **Location Privacy Ladder:** city → approximate area → event-only precise address; precise address is revealed only when appropriate for the event.

## Success metrics

Primary:
- weekly participants who attend at least one Ojoro activity;
- discover-to-RSVP conversion;
- RSVP-to-attendance rate;
- 4-week participant retention;
- activities successfully filled.

Secondary:
- new-sport trials per active user;
- clan member retention;
- organizer repeat-host rate;
- challenge completion;
- reports per 1,000 attended activities and resolution time.

Guardrails:
- no-show rate;
- block/report rate;
- percentage of users who disable competitive surfaces;
- accessibility errors on critical journeys;
- location/privacy incidents.

## Definition of product success

A new user in a supported city can create an account, select interests and intent, find a suitable nearby/soon activity or clan, join it, communicate with participants, show up, have attendance recorded, receive progress/XP, and see that activity become part of their Ojoro identity. An organizer can create and fill the same activity without spreadsheets or group-chat chaos.
