# Ojoro UX Specification

## Experience character

Energetic, athletic and social without looking like a generic fitness dashboard or a gaming HUD. The UI should feel like an excellent consumer sports product: bold type, spacious cards, tactile controls, strong photography-ready surfaces, concise copy and fast one-handed mobile use.

## Information architecture

```text
Public
├── Landing
└── Sign in / Sign up

Authenticated shell
├── Home
│   ├── Today / Right Now
│   ├── Upcoming
│   ├── Clan Pulse
│   ├── Goal / Quest progress
│   └── Activity feed
├── Discover
│   ├── Activities
│   ├── Clans
│   ├── People / partners
│   └── Filters + map-ready results
├── Create
│   ├── Activity
│   ├── Clan
│   ├── Challenge
│   ├── Match
│   └── Tournament
├── Compete
│   ├── Personal / sport / clan / city leaderboards
│   ├── Challenges
│   ├── Ratings
│   ├── Seasons
│   └── Tournaments
├── You
│   ├── Sports résumé
│   ├── Passport
│   ├── Goals
│   ├── Achievements
│   ├── Reputation
│   ├── Availability
│   └── Settings
├── Clan detail
├── Activity detail + event chat
├── Messages
└── Notifications
```

## First-use flow

1. Create account / sign in.
2. Choose city and coarse location preference.
3. Choose sports/activities and skill level for each.
4. Choose intent: Social, Fitness, Competitive, Learning (multi-select).
5. Set optional regular availability.
6. Choose first action: **Find something today**, **Join a clan**, or **Create an activity**.
7. Home immediately reflects choices; do not force profile completion before utility.

## Home

### Purpose
Answer “What should I do next?” in under five seconds.

### Order
1. greeting + location scope + notification/messages controls;
2. Today card: soon activities, friends/clan activity, weekly goal progress;
3. quick actions: Find a game, I’m available, Create;
4. upcoming RSVP timeline;
5. Clan Pulse;
6. quest/goal progress;
7. activity-driven feed.

Empty home prioritizes Discover and clan suggestions rather than showing empty analytics.

## Discover

Default is a card list sorted by joinability and soonness, not popularity. A sticky filter row exposes: distance, sport, skill, intent, date/time, price, indoor/outdoor, open spots and clan/public.

“Right now” applies deterministic filters: starts within configurable hours, has open capacity, user not blocked, visibility permits access, compatible intent/skill unless user broadens it.

Cards show only decision-critical information: sport, title, mode, time, travel-distance placeholder when coordinates are available, location label, skill, spots, cost and organizer/clan trust indicators.

## Activity detail

Primary action is always one of: Join, Join waitlist, Leave, Manage, Confirm result. Include event chat only after access rules permit it.

Sections: essentials → participants → organizer → what to bring → chat/updates → result/recap. Exact address can be withheld until RSVP for privacy-sensitive events.

RSVP states: Going, Maybe, Waitlist, Cancelled. Attendance states: Scheduled, Attended, Excused, Late cancel, No-show. Cancellation copy explains reliability impact before confirmation.

## Clan detail

Hero: identity, city, sports, trust/verified state, member count, join/follow CTA. Tabs: Overview, Activities, Teams, Feed, Members, Stats. Admin actions are role-gated and visually separate from member actions.

Multi-sport clans show sport lanes while preserving one clan identity.

## Create flow

One create screen begins with an object picker. Forms progressively reveal advanced options. Required fields are minimal.

Activity required: title/activity, date/time, duration, location label/city, capacity, mode. Optional: clan/team, skill, cost, equipment, privacy, waitlist, RSVP deadline, precise coordinates/address.

On success, show a share-ready confirmation and next actions: invite clan, copy link, open event chat.

## Compete

Competition Quiet Mode replaces leaderboards with personal trends while preserving challenges and achievements. Ranking surfaces always explain whether a value is seasonal, sport-specific and verified.

## You

Top: identity, city, primary activities, level/XP. Then a sports résumé with recent activity, consistency, records, achievements, clan roles and passport. Reputation surfaces objective behavior first (e.g. 93% recent attendance) instead of arbitrary stars.

## Loading / errors / offline

- Use skeletons only for content likely to arrive quickly; otherwise show explicit progress text.
- Network failures keep the last readable screen when safe and provide Retry.
- Mutations disable duplicate submit and return actionable inline errors.
- Offline mode may show cached navigation/content but must not pretend an RSVP or result was saved.
- Permission errors explain what role/access is needed without leaking private resource existence.

## Accessibility

Target WCAG 2.2 AA. Minimum 44px touch targets; visible focus; semantic headings/nav/buttons/forms; errors associated to controls; color never carries state alone; reduced-motion support; no autoplay media; meaningful icon labels; sufficient contrast; keyboard-complete desktop flows.

## Responsive behavior

- < 768px: bottom navigation, full-width cards, center Create action, sheet-style filters.
- 768–1199px: compact left rail + content column.
- ≥ 1200px: persistent rail, primary content max-width, contextual right rail where useful.

## Acceptance highlights

- New user reaches a joinable activity in ≤ 3 primary interactions after onboarding.
- Organizer can create a basic activity in ≤ 90 seconds without configuring advanced fields.
- Join/leave/waitlist state is immediately understandable and resilient to refresh.
- Competitive mode can be hidden globally without breaking progress or social utility.
- No critical action relies on hover, color alone or precise geolocation permission.
