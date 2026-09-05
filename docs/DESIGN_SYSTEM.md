# Ojoro Design System

## Brand direction

**Movement-first, warm, urban, athletic.** Avoid neon-on-black gamer clichés, glassmorphism overload, AI gradients, dense enterprise dashboards and generic card grids.

## Tokens

CSS custom properties are the source of truth.

### Color roles
- `--ink`: near-black text and high-emphasis controls.
- `--paper`: warm off-white page background.
- `--surface`: white raised surface.
- `--muted`: secondary copy.
- `--line`: low-contrast borders.
- `--brand`: energetic Ojoro orange.
- `--brand-strong`: dark orange for contrast states.
- `--lime`: success/progress accent used sparingly.
- `--blue`: informational/competitive accent.
- `--danger`: destructive/reporting state.

Do not encode attendance, verification or competition status by color alone; pair with icon/text.

### Typography
- Display: system sans with tight tracking and 700–900 weight.
- Body: system sans optimized for platform rendering.
- Numeric stats: tabular-nums.
- Scale: 12 / 14 / 16 / 20 / 24 / 32 / 44 / clamp(52–80).

### Space / shape
- 4px base grid.
- Main card radius: 22px mobile, 26px desktop.
- Compact control radius: 14px.
- Pills: 999px.
- Shadow: subtle depth only on interactive/raised surfaces; structure comes from spacing and borders.

## Core components

- AppShell / MobileNav / DesktopRail
- Wordmark
- PrimaryButton / SecondaryButton / IconButton
- SportPill / ModePill / TrustBadge
- ActivityCard / ClanCard / PersonCard
- ProgressMeter / StatTile / RecordRow
- FilterChips / FilterSheet
- AvatarStack
- EmptyState / ErrorState / Skeleton
- FormField / SegmentedControl
- FeedItem / RecapCard
- BottomSheet (mobile progressive actions)

## Motion

150–220ms for local UI; 250–320ms for sheets. Prefer transform/opacity. Respect `prefers-reduced-motion`. Motion clarifies state change, never delays action.

## Content style

Short, active and specific. Prefer “3 spots left” over “Capacity available”; “Starts in 45 min” over raw timestamps when local and unambiguous; “You’re in” over generic “Success”. Avoid shame language around missed events.

## Visual hierarchy rules

1. Every screen has one obvious primary next action.
2. Stats support decisions; they never push the activity itself below the fold.
3. Use large imagery only when it represents a real clan/event/person; never use decorative stock imagery as the product’s identity.
4. Empty states are invitations to act, not illustrations with no utility.
5. Progression should feel earned and legible, not casino-like.
