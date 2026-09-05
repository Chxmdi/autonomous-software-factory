-- Ojoro consumer social-activity platform
-- Additive migration only. Existing Ojoro Command Centre tables are intentionally preserved.

create extension if not exists pgcrypto;
create extension if not exists citext;

-- ---------- Types ----------
do $$ begin create type public.oj_skill_level as enum ('beginner','recreational','intermediate','competitive','elite'); exception when duplicate_object then null; end $$;
do $$ begin create type public.oj_activity_mode as enum ('social','fitness','competitive','learning'); exception when duplicate_object then null; end $$;
do $$ begin create type public.oj_membership_status as enum ('pending','active','left','removed','banned'); exception when duplicate_object then null; end $$;
do $$ begin create type public.oj_clan_role as enum ('founder','leader','captain','coach','event_organizer','moderator','member'); exception when duplicate_object then null; end $$;
do $$ begin create type public.oj_rsvp_status as enum ('going','maybe','waitlist','cancelled'); exception when duplicate_object then null; end $$;
do $$ begin create type public.oj_attendance_status as enum ('scheduled','attended','excused','late_cancel','no_show'); exception when duplicate_object then null; end $$;
do $$ begin create type public.oj_visibility as enum ('public','members','private'); exception when duplicate_object then null; end $$;
do $$ begin create type public.oj_verification_level as enum ('self_reported','participant_verified','organizer_verified','device_verified','tournament_verified'); exception when duplicate_object then null; end $$;
do $$ begin create type public.oj_channel_kind as enum ('direct','clan','team','activity'); exception when duplicate_object then null; end $$;
do $$ begin create type public.oj_challenge_scope as enum ('personal','friends','clan','clan_vs_clan','city','global','official'); exception when duplicate_object then null; end $$;
do $$ begin create type public.oj_tournament_format as enum ('knockout','round_robin','group_knockout','league','ladder'); exception when duplicate_object then null; end $$;

-- ---------- Catalog and identity ----------
create table if not exists public.oj_sports (
  slug text primary key check (slug ~ '^[a-z0-9-]+$'),
  name text not null unique,
  category text not null default 'sport',
  metrics jsonb not null default '[]'::jsonb,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.oj_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username citext not null unique,
  full_name text,
  avatar_url text,
  bio text check (char_length(bio) <= 600),
  city text,
  timezone text not null default 'America/Toronto',
  profile_visibility public.oj_visibility not null default 'public',
  competition_quiet boolean not null default false,
  onboarding_completed boolean not null default false,
  lifetime_xp bigint not null default 0 check (lifetime_xp >= 0),
  level integer not null default 1 check (level >= 1),
  verified_organizer boolean not null default false,
  suspended_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.oj_user_sports (
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  sport_slug text not null references public.oj_sports(slug),
  skill_level public.oj_skill_level not null default 'recreational',
  preferred_positions text[] not null default '{}',
  wants_to_learn boolean not null default false,
  primary key (profile_id, sport_slug)
);

create table if not exists public.oj_user_intents (
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  mode public.oj_activity_mode not null,
  primary key (profile_id, mode)
);

create table if not exists public.oj_availability (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  weekday smallint not null check (weekday between 0 and 6),
  start_time time not null,
  end_time time not null,
  timezone text not null default 'America/Toronto',
  check (end_time > start_time),
  unique (profile_id, weekday, start_time, end_time)
);

create table if not exists public.oj_follows (
  follower_id uuid not null references public.oj_profiles(id) on delete cascade,
  followed_id uuid not null references public.oj_profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, followed_id),
  check (follower_id <> followed_id)
);

create table if not exists public.oj_blocks (
  blocker_id uuid not null references public.oj_profiles(id) on delete cascade,
  blocked_id uuid not null references public.oj_profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

-- ---------- Clans and teams ----------
create table if not exists public.oj_clans (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.oj_profiles(id),
  slug citext not null unique,
  name text not null check (char_length(name) between 2 and 80),
  bio text check (char_length(bio) <= 1000),
  city text not null,
  logo_url text,
  cover_url text,
  brand_color text check (brand_color is null or brand_color ~ '^#[0-9A-Fa-f]{6}$'),
  is_public boolean not null default true,
  lifetime_xp bigint not null default 0 check (lifetime_xp >= 0),
  level integer not null default 1 check (level >= 1),
  verified_state text not null default 'unverified' check (verified_state in ('unverified','pending','verified','suspended')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.oj_clan_sports (
  clan_id uuid not null references public.oj_clans(id) on delete cascade,
  sport_slug text not null references public.oj_sports(slug),
  is_primary boolean not null default false,
  primary key (clan_id, sport_slug)
);

create table if not exists public.oj_clan_members (
  clan_id uuid not null references public.oj_clans(id) on delete cascade,
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  role public.oj_clan_role not null default 'member',
  status public.oj_membership_status not null default 'active',
  joined_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (clan_id, profile_id)
);

create table if not exists public.oj_teams (
  id uuid primary key default gen_random_uuid(),
  clan_id uuid not null references public.oj_clans(id) on delete cascade,
  sport_slug text not null references public.oj_sports(slug),
  slug citext not null,
  name text not null check (char_length(name) between 2 and 80),
  description text check (char_length(description) <= 600),
  created_by uuid not null references public.oj_profiles(id),
  created_at timestamptz not null default now(),
  unique (clan_id, slug)
);

create table if not exists public.oj_team_members (
  team_id uuid not null references public.oj_teams(id) on delete cascade,
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  is_captain boolean not null default false,
  joined_at timestamptz not null default now(),
  primary key (team_id, profile_id)
);

-- ---------- Activities ----------
create table if not exists public.oj_activities (
  id uuid primary key default gen_random_uuid(),
  organizer_id uuid not null references public.oj_profiles(id),
  clan_id uuid references public.oj_clans(id) on delete set null,
  team_id uuid references public.oj_teams(id) on delete set null,
  sport_slug text not null references public.oj_sports(slug),
  title text not null check (char_length(title) between 3 and 120),
  description text check (char_length(description) <= 2000),
  mode public.oj_activity_mode not null default 'social',
  skill_level public.oj_skill_level,
  location_name text not null,
  address text,
  city text not null,
  latitude numeric(9,6) check (latitude between -90 and 90),
  longitude numeric(9,6) check (longitude between -180 and 180),
  reveal_exact_address_after_rsvp boolean not null default false,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  max_participants integer not null check (max_participants between 1 and 10000),
  cost_cents integer not null default 0 check (cost_cents >= 0),
  currency char(3) not null default 'CAD',
  equipment text,
  visibility public.oj_visibility not null default 'public',
  clan_only boolean not null default false,
  waitlist_enabled boolean not null default true,
  rsvp_deadline timestamptz,
  urgent_spots boolean not null default false,
  status text not null default 'scheduled' check (status in ('draft','scheduled','cancelled','completed')),
  verification_level public.oj_verification_level not null default 'self_reported',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at > starts_at),
  check (rsvp_deadline is null or rsvp_deadline <= starts_at),
  check ((latitude is null and longitude is null) or (latitude is not null and longitude is not null))
);

create table if not exists public.oj_activity_participants (
  activity_id uuid not null references public.oj_activities(id) on delete cascade,
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  rsvp_status public.oj_rsvp_status not null default 'going',
  attendance_status public.oj_attendance_status not null default 'scheduled',
  team_side text check (team_side is null or team_side in ('home','away')),
  position text,
  joined_at timestamptz not null default now(),
  cancelled_at timestamptz,
  checked_in_at timestamptz,
  checked_out_at timestamptz,
  primary key (activity_id, profile_id)
);

-- ---------- Goals, challenges, progression ----------
create table if not exists public.oj_goals (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  title text not null check (char_length(title) between 2 and 120),
  metric text not null,
  target_value numeric not null check (target_value > 0),
  current_value numeric not null default 0 check (current_value >= 0),
  starts_at date not null default current_date,
  ends_at date,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  check (ends_at is null or ends_at >= starts_at)
);

create table if not exists public.oj_challenges (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references public.oj_profiles(id),
  clan_id uuid references public.oj_clans(id) on delete cascade,
  title text not null check (char_length(title) between 3 and 120),
  description text check (char_length(description) <= 1200),
  scope public.oj_challenge_scope not null default 'personal',
  sport_slug text references public.oj_sports(slug),
  metric text not null,
  target_value numeric not null check (target_value > 0),
  xp_reward integer not null default 100 check (xp_reward between 0 and 5000),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  status text not null default 'active' check (status in ('draft','active','completed','cancelled')),
  created_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create table if not exists public.oj_challenge_members (
  challenge_id uuid not null references public.oj_challenges(id) on delete cascade,
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  progress numeric not null default 0 check (progress >= 0),
  joined_at timestamptz not null default now(),
  completed_at timestamptz,
  primary key (challenge_id, profile_id)
);

create table if not exists public.oj_achievement_definitions (
  slug text primary key,
  name text not null,
  description text not null,
  icon text,
  category text not null default 'general',
  xp_reward integer not null default 0 check (xp_reward >= 0),
  active boolean not null default true
);

create table if not exists public.oj_user_achievements (
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  achievement_slug text not null references public.oj_achievement_definitions(slug),
  earned_at timestamptz not null default now(),
  source_id uuid,
  primary key (profile_id, achievement_slug)
);

create table if not exists public.oj_xp_ledger (
  id bigint generated always as identity primary key,
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  amount integer not null check (amount > 0 and amount <= 5000),
  source_kind text not null,
  source_id uuid,
  reason text not null,
  created_at timestamptz not null default now()
);
create unique index if not exists oj_xp_idempotency on public.oj_xp_ledger(profile_id, source_kind, source_id, reason) where source_id is not null;

create table if not exists public.oj_clan_xp_ledger (
  id bigint generated always as identity primary key,
  clan_id uuid not null references public.oj_clans(id) on delete cascade,
  amount integer not null check (amount > 0 and amount <= 10000),
  source_kind text not null,
  source_id uuid,
  reason text not null,
  created_at timestamptz not null default now()
);
create unique index if not exists oj_clan_xp_idempotency on public.oj_clan_xp_ledger(clan_id, source_kind, source_id, reason) where source_id is not null;

-- ---------- Seasons and competition ----------
create table if not exists public.oj_seasons (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  city text,
  sport_slug text references public.oj_sports(slug),
  starts_at date not null,
  ends_at date not null,
  active boolean not null default true,
  unique (name, city, sport_slug),
  check (ends_at >= starts_at)
);

create table if not exists public.oj_ratings (
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  sport_slug text not null references public.oj_sports(slug),
  season_id uuid not null references public.oj_seasons(id) on delete cascade,
  rating integer not null default 1200 check (rating between 100 and 4000),
  games_played integer not null default 0 check (games_played >= 0),
  wins integer not null default 0 check (wins >= 0),
  draws integer not null default 0 check (draws >= 0),
  losses integer not null default 0 check (losses >= 0),
  updated_at timestamptz not null default now(),
  primary key (profile_id, sport_slug, season_id)
);

create table if not exists public.oj_match_results (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid not null unique references public.oj_activities(id) on delete cascade,
  submitted_by uuid not null references public.oj_profiles(id),
  home_name text not null,
  away_name text not null,
  home_score integer not null check (home_score >= 0),
  away_score integer not null check (away_score >= 0),
  mvp_profile_id uuid references public.oj_profiles(id) on delete set null,
  status text not null default 'submitted' check (status in ('submitted','verified','disputed','void')),
  confirmations_required integer not null default 2 check (confirmations_required between 1 and 50),
  verified_at timestamptz,
  rating_applied_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.oj_match_stats (
  result_id uuid not null references public.oj_match_results(id) on delete cascade,
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  metric text not null,
  value numeric not null,
  primary key (result_id, profile_id, metric)
);

create table if not exists public.oj_result_confirmations (
  result_id uuid not null references public.oj_match_results(id) on delete cascade,
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  agrees boolean not null,
  created_at timestamptz not null default now(),
  primary key (result_id, profile_id)
);

-- ---------- Social ----------
create table if not exists public.oj_posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.oj_profiles(id) on delete cascade,
  clan_id uuid references public.oj_clans(id) on delete cascade,
  activity_id uuid references public.oj_activities(id) on delete cascade,
  kind text not null default 'post' check (kind in ('post','result','achievement','record','recap','announcement')),
  body text not null check (char_length(body) between 1 and 3000),
  media_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.oj_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.oj_posts(id) on delete cascade,
  author_id uuid not null references public.oj_profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 1500),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.oj_reactions (
  post_id uuid not null references public.oj_posts(id) on delete cascade,
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  reaction text not null check (reaction in ('like','fire','clap','respect','congrats')),
  created_at timestamptz not null default now(),
  primary key (post_id, profile_id, reaction)
);

create table if not exists public.oj_chat_channels (
  id uuid primary key default gen_random_uuid(),
  kind public.oj_channel_kind not null,
  clan_id uuid references public.oj_clans(id) on delete cascade,
  team_id uuid references public.oj_teams(id) on delete cascade,
  activity_id uuid references public.oj_activities(id) on delete cascade,
  name text,
  created_by uuid not null references public.oj_profiles(id),
  created_at timestamptz not null default now()
);

create table if not exists public.oj_channel_members (
  channel_id uuid not null references public.oj_chat_channels(id) on delete cascade,
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  last_read_at timestamptz,
  primary key (channel_id, profile_id)
);

create table if not exists public.oj_messages (
  id bigint generated always as identity primary key,
  channel_id uuid not null references public.oj_chat_channels(id) on delete cascade,
  sender_id uuid not null references public.oj_profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 4000),
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.oj_notifications (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  kind text not null,
  title text not null,
  body text,
  href text,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.oj_statuses (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  kind text not null check (kind in ('available','looking_for_players','looking_for_opponent','looking_for_partner','other')),
  sport_slug text references public.oj_sports(slug),
  city text,
  message text check (char_length(message) <= 280),
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

-- ---------- Tournaments / places / provider foundation ----------
create table if not exists public.oj_tournaments (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references public.oj_profiles(id),
  clan_id uuid references public.oj_clans(id) on delete set null,
  sport_slug text not null references public.oj_sports(slug),
  name text not null check (char_length(name) between 3 and 120),
  city text not null,
  format public.oj_tournament_format not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  max_entries integer check (max_entries is null or max_entries > 1),
  status text not null default 'draft' check (status in ('draft','registration','active','completed','cancelled')),
  created_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create table if not exists public.oj_tournament_entries (
  tournament_id uuid not null references public.oj_tournaments(id) on delete cascade,
  team_id uuid references public.oj_teams(id) on delete cascade,
  clan_id uuid references public.oj_clans(id) on delete cascade,
  display_name text not null,
  seed integer,
  joined_at timestamptz not null default now(),
  id uuid primary key default gen_random_uuid(),
  check (team_id is not null or clan_id is not null)
);

create table if not exists public.oj_fixtures (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.oj_tournaments(id) on delete cascade,
  round_label text,
  home_entry_id uuid references public.oj_tournament_entries(id) on delete set null,
  away_entry_id uuid references public.oj_tournament_entries(id) on delete set null,
  starts_at timestamptz,
  home_score integer check (home_score is null or home_score >= 0),
  away_score integer check (away_score is null or away_score >= 0),
  status text not null default 'scheduled' check (status in ('scheduled','live','completed','cancelled'))
);

create table if not exists public.oj_spots (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  city text not null,
  sport_slugs text[] not null default '{}',
  latitude numeric(9,6) not null check (latitude between -90 and 90),
  longitude numeric(9,6) not null check (longitude between -180 and 180),
  description text,
  verified boolean not null default false,
  created_by uuid references public.oj_profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.oj_provider_activities (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.oj_profiles(id) on delete cascade,
  provider text not null,
  external_id text not null,
  sport_slug text references public.oj_sports(slug),
  started_at timestamptz not null,
  duration_seconds integer check (duration_seconds is null or duration_seconds >= 0),
  distance_meters numeric check (distance_meters is null or distance_meters >= 0),
  steps integer check (steps is null or steps >= 0),
  verification_level public.oj_verification_level not null default 'device_verified',
  raw_metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (profile_id, provider, external_id)
);

-- ---------- Safety ----------
create table if not exists public.oj_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.oj_profiles(id) on delete cascade,
  entity_kind text not null check (entity_kind in ('profile','clan','activity','post','message')),
  entity_id uuid not null,
  reason text not null,
  details text check (char_length(details) <= 3000),
  status text not null default 'open' check (status in ('open','reviewing','resolved','dismissed')),
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

-- ---------- Indexes ----------
create index if not exists oj_profiles_city_idx on public.oj_profiles(city);
create index if not exists oj_clans_city_idx on public.oj_clans(city, is_public);
create index if not exists oj_clan_members_profile_idx on public.oj_clan_members(profile_id, status);
create index if not exists oj_activities_city_start_idx on public.oj_activities(city, starts_at) where status = 'scheduled';
create index if not exists oj_activities_sport_start_idx on public.oj_activities(sport_slug, starts_at) where status = 'scheduled';
create index if not exists oj_activities_clan_start_idx on public.oj_activities(clan_id, starts_at) where clan_id is not null;
create index if not exists oj_activity_participants_profile_idx on public.oj_activity_participants(profile_id, rsvp_status);
create index if not exists oj_posts_created_idx on public.oj_posts(created_at desc);
create index if not exists oj_posts_clan_idx on public.oj_posts(clan_id, created_at desc) where clan_id is not null;
create index if not exists oj_messages_channel_idx on public.oj_messages(channel_id, created_at desc);
create index if not exists oj_notifications_profile_idx on public.oj_notifications(profile_id, read_at, created_at desc);
create index if not exists oj_statuses_city_expiry_idx on public.oj_statuses(city, expires_at);
create index if not exists oj_ratings_board_idx on public.oj_ratings(sport_slug, season_id, rating desc);

-- ---------- Utility / security helpers ----------
create or replace function public.oj_level_for_xp(xp bigint)
returns integer language sql immutable as $$
  select greatest(1, floor(sqrt(greatest(xp, 0)::numeric / 250))::integer + 1)
$$;

create or replace function public.oj_is_blocked(other_id uuid)
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.oj_blocks
    where (blocker_id = auth.uid() and blocked_id = other_id)
       or (blocker_id = other_id and blocked_id = auth.uid())
  )
$$;

create or replace function public.oj_is_clan_member(target_clan uuid)
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.oj_clan_members
    where clan_id = target_clan and profile_id = auth.uid() and status = 'active'
  )
$$;

create or replace function public.oj_has_clan_role(target_clan uuid, allowed text[])
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.oj_clan_members
    where clan_id = target_clan
      and profile_id = auth.uid()
      and status = 'active'
      and role::text = any(allowed)
  )
$$;

create or replace function public.oj_is_channel_member(target_channel uuid)
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.oj_channel_members
    where channel_id = target_channel and profile_id = auth.uid()
  )
$$;

create or replace function public.oj_touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

create or replace function public.oj_rollup_profile_xp()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update public.oj_profiles
  set lifetime_xp = lifetime_xp + new.amount,
      level = public.oj_level_for_xp(lifetime_xp + new.amount),
      updated_at = now()
  where id = new.profile_id;
  return new;
end $$;

create or replace function public.oj_rollup_clan_xp()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update public.oj_clans
  set lifetime_xp = lifetime_xp + new.amount,
      level = public.oj_level_for_xp(lifetime_xp + new.amount),
      updated_at = now()
  where id = new.clan_id;
  return new;
end $$;

create or replace function public.oj_handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.oj_profiles(id, username, full_name)
  values (
    new.id,
    ('user_' || substr(new.id::text, 1, 8))::citext,
    nullif(coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name'), '')
  )
  on conflict (id) do nothing;
  return new;
end $$;

create or replace function public.oj_after_clan_insert()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.oj_clan_members(clan_id, profile_id, role, status)
  values (new.id, new.owner_id, 'founder', 'active')
  on conflict (clan_id, profile_id) do update set role = 'founder', status = 'active';

  insert into public.oj_xp_ledger(profile_id, amount, source_kind, source_id, reason)
  values (new.owner_id, 250, 'clan', new.id, 'created_clan')
  on conflict do nothing;

  insert into public.oj_clan_xp_ledger(clan_id, amount, source_kind, source_id, reason)
  values (new.id, 250, 'clan', new.id, 'founded')
  on conflict do nothing;
  return new;
end $$;

-- ---------- Atomic domain commands ----------
create or replace function public.oj_join_clan(target_clan uuid)
returns text
language plpgsql security definer set search_path = public as $$
declare v_public boolean; v_status public.oj_membership_status;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  select is_public into v_public from public.oj_clans where id = target_clan;
  if not found then raise exception 'NOT_FOUND'; end if;
  v_status := case when v_public then 'active'::public.oj_membership_status else 'pending'::public.oj_membership_status end;
  insert into public.oj_clan_members(clan_id, profile_id, role, status)
  values (target_clan, auth.uid(), 'member', v_status)
  on conflict (clan_id, profile_id) do update set status = excluded.status, updated_at = now();
  return v_status::text;
end $$;

create or replace function public.oj_leave_clan(target_clan uuid)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if exists (select 1 from public.oj_clans where id=target_clan and owner_id=auth.uid()) then
    raise exception 'OWNER_TRANSFER_REQUIRED';
  end if;
  update public.oj_clan_members set status='left', updated_at=now()
  where clan_id=target_clan and profile_id=auth.uid();
end $$;

create or replace function public.oj_rsvp_activity(target_activity uuid, desired text)
returns text
language plpgsql security definer set search_path = public as $$
declare
  v_activity public.oj_activities%rowtype;
  v_going integer;
  v_status public.oj_rsvp_status;
  v_promote uuid;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if desired not in ('going','maybe','cancelled') then raise exception 'VALIDATION_ERROR'; end if;

  select * into v_activity from public.oj_activities where id=target_activity for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  if v_activity.status <> 'scheduled' or v_activity.starts_at <= now() then raise exception 'RSVP_CLOSED'; end if;
  if v_activity.rsvp_deadline is not null and v_activity.rsvp_deadline < now() then raise exception 'RSVP_CLOSED'; end if;
  if (v_activity.visibility <> 'public' or v_activity.clan_only) and v_activity.clan_id is not null
     and not public.oj_is_clan_member(v_activity.clan_id) and v_activity.organizer_id <> auth.uid() then
    raise exception 'FORBIDDEN';
  end if;

  if desired = 'going' then
    select count(*) into v_going from public.oj_activity_participants
    where activity_id=target_activity and rsvp_status='going';
    if v_going >= v_activity.max_participants then
      if not v_activity.waitlist_enabled then raise exception 'CAPACITY_FULL'; end if;
      v_status := 'waitlist';
    else
      v_status := 'going';
    end if;
  elsif desired = 'maybe' then
    v_status := 'maybe';
  else
    v_status := 'cancelled';
  end if;

  insert into public.oj_activity_participants(activity_id, profile_id, rsvp_status, cancelled_at)
  values (target_activity, auth.uid(), v_status, case when v_status='cancelled' then now() else null end)
  on conflict (activity_id, profile_id) do update
    set rsvp_status=excluded.rsvp_status,
        cancelled_at=excluded.cancelled_at;

  if v_status='cancelled' then
    select profile_id into v_promote
    from public.oj_activity_participants
    where activity_id=target_activity and rsvp_status='waitlist'
    order by joined_at asc
    limit 1
    for update skip locked;
    if v_promote is not null then
      update public.oj_activity_participants set rsvp_status='going' where activity_id=target_activity and profile_id=v_promote;
      insert into public.oj_notifications(profile_id, kind, title, body, href)
      values (v_promote, 'waitlist_promoted', 'You’re in', 'A spot opened up and you moved off the waitlist.', '/activities/'||target_activity::text);
    end if;
  end if;

  return v_status::text;
end $$;

create or replace function public.oj_record_attendance(target_activity uuid, target_profile uuid, new_state text)
returns void
language plpgsql security definer set search_path = public as $$
declare v_activity public.oj_activities%rowtype;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if new_state not in ('attended','excused','late_cancel','no_show') then raise exception 'VALIDATION_ERROR'; end if;
  select * into v_activity from public.oj_activities where id=target_activity;
  if not found then raise exception 'NOT_FOUND'; end if;
  if v_activity.organizer_id <> auth.uid() and (v_activity.clan_id is null or not public.oj_has_clan_role(v_activity.clan_id, array['founder','leader','captain','coach','event_organizer'])) then
    raise exception 'FORBIDDEN';
  end if;
  update public.oj_activity_participants
  set attendance_status = new_state::public.oj_attendance_status,
      checked_in_at = case when new_state='attended' and checked_in_at is null then now() else checked_in_at end
  where activity_id=target_activity and profile_id=target_profile;
  if not found then raise exception 'NOT_FOUND'; end if;

  if new_state='attended' then
    insert into public.oj_xp_ledger(profile_id, amount, source_kind, source_id, reason)
    values (target_profile, 100, 'activity', target_activity, 'attended') on conflict do nothing;
    if v_activity.clan_id is not null then
      insert into public.oj_clan_xp_ledger(clan_id, amount, source_kind, source_id, reason)
      values (v_activity.clan_id, 25, 'activity', target_activity, 'member_attendance') on conflict do nothing;
    end if;
  end if;
end $$;

create or replace function public.oj_join_challenge(target_challenge uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if not exists (select 1 from public.oj_challenges where id=target_challenge and status='active' and now() between starts_at and ends_at) then raise exception 'CHALLENGE_CLOSED'; end if;
  insert into public.oj_challenge_members(challenge_id, profile_id) values (target_challenge, auth.uid()) on conflict do nothing;
end $$;

create or replace function public.oj_set_challenge_progress(target_challenge uuid, new_progress numeric)
returns numeric language plpgsql security definer set search_path = public as $$
declare v_target numeric; v_reward integer; v_completed timestamptz;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if new_progress < 0 then raise exception 'VALIDATION_ERROR'; end if;
  select target_value, xp_reward into v_target, v_reward from public.oj_challenges
  where id=target_challenge and status='active' and now() <= ends_at;
  if not found then raise exception 'CHALLENGE_CLOSED'; end if;
  update public.oj_challenge_members
  set progress=least(new_progress, v_target),
      completed_at=case when new_progress >= v_target then coalesce(completed_at, now()) else completed_at end
  where challenge_id=target_challenge and profile_id=auth.uid()
  returning completed_at into v_completed;
  if not found then raise exception 'NOT_JOINED'; end if;
  if v_completed is not null and v_reward > 0 then
    insert into public.oj_xp_ledger(profile_id, amount, source_kind, source_id, reason)
    values (auth.uid(), v_reward, 'challenge', target_challenge, 'completed') on conflict do nothing;
  end if;
  return least(new_progress, v_target);
end $$;

create or replace function public.oj_get_or_create_direct_channel(other_profile uuid)
returns uuid language plpgsql security definer set search_path = public as $$
declare v_channel uuid;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if other_profile=auth.uid() or public.oj_is_blocked(other_profile) then raise exception 'BLOCKED'; end if;
  select c.id into v_channel
  from public.oj_chat_channels c
  join public.oj_channel_members a on a.channel_id=c.id and a.profile_id=auth.uid()
  join public.oj_channel_members b on b.channel_id=c.id and b.profile_id=other_profile
  where c.kind='direct'
    and (select count(*) from public.oj_channel_members m where m.channel_id=c.id)=2
  limit 1;
  if v_channel is null then
    insert into public.oj_chat_channels(kind, created_by) values ('direct', auth.uid()) returning id into v_channel;
    insert into public.oj_channel_members(channel_id, profile_id) values (v_channel, auth.uid()), (v_channel, other_profile);
  end if;
  return v_channel;
end $$;

create or replace function public.oj_current_season(target_sport text)
returns uuid language sql stable security definer set search_path = public as $$
  select id from public.oj_seasons
  where active=true and current_date between starts_at and ends_at
    and (sport_slug is null or sport_slug=target_sport)
  order by (sport_slug is not null) desc, starts_at desc limit 1
$$;

create or replace function public.oj_apply_verified_ratings(target_result uuid)
returns void language plpgsql security definer set search_path = public as $$
declare
  v_result public.oj_match_results%rowtype;
  v_activity public.oj_activities%rowtype;
  v_season uuid;
  v_home_avg numeric;
  v_away_avg numeric;
  v_home_score numeric;
  v_away_score numeric;
  rec record;
  v_rating integer;
  v_opp numeric;
  v_expected numeric;
  v_delta integer;
begin
  select * into v_result from public.oj_match_results where id=target_result for update;
  if not found or v_result.status <> 'verified' or v_result.rating_applied_at is not null then return; end if;
  select * into v_activity from public.oj_activities where id=v_result.activity_id;
  if v_activity.mode <> 'competitive' then update public.oj_match_results set rating_applied_at=now() where id=target_result; return; end if;
  v_season := public.oj_current_season(v_activity.sport_slug);
  if v_season is null then return; end if;

  select coalesce(avg(coalesce(r.rating,1200)),1200) into v_home_avg
  from public.oj_activity_participants p left join public.oj_ratings r on r.profile_id=p.profile_id and r.sport_slug=v_activity.sport_slug and r.season_id=v_season
  where p.activity_id=v_activity.id and p.team_side='home' and p.attendance_status='attended';
  select coalesce(avg(coalesce(r.rating,1200)),1200) into v_away_avg
  from public.oj_activity_participants p left join public.oj_ratings r on r.profile_id=p.profile_id and r.sport_slug=v_activity.sport_slug and r.season_id=v_season
  where p.activity_id=v_activity.id and p.team_side='away' and p.attendance_status='attended';

  if v_result.home_score > v_result.away_score then v_home_score:=1; v_away_score:=0;
  elsif v_result.home_score < v_result.away_score then v_home_score:=0; v_away_score:=1;
  else v_home_score:=0.5; v_away_score:=0.5; end if;

  for rec in select profile_id, team_side from public.oj_activity_participants where activity_id=v_activity.id and attendance_status='attended' and team_side in ('home','away') loop
    select coalesce((select rating from public.oj_ratings where profile_id=rec.profile_id and sport_slug=v_activity.sport_slug and season_id=v_season),1200) into v_rating;
    v_opp := case when rec.team_side='home' then v_away_avg else v_home_avg end;
    v_expected := 1 / (1 + power(10, (v_opp - v_rating) / 400.0));
    v_delta := round(24 * ((case when rec.team_side='home' then v_home_score else v_away_score end) - v_expected));
    insert into public.oj_ratings(profile_id,sport_slug,season_id,rating,games_played,wins,draws,losses)
    values (
      rec.profile_id, v_activity.sport_slug, v_season, greatest(100, v_rating+v_delta), 1,
      case when (rec.team_side='home' and v_home_score=1) or (rec.team_side='away' and v_away_score=1) then 1 else 0 end,
      case when v_home_score=0.5 then 1 else 0 end,
      case when (rec.team_side='home' and v_home_score=0) or (rec.team_side='away' and v_away_score=0) then 1 else 0 end
    )
    on conflict (profile_id,sport_slug,season_id) do update set
      rating=greatest(100, public.oj_ratings.rating+v_delta),
      games_played=public.oj_ratings.games_played+1,
      wins=public.oj_ratings.wins+excluded.wins,
      draws=public.oj_ratings.draws+excluded.draws,
      losses=public.oj_ratings.losses+excluded.losses,
      updated_at=now();
  end loop;
  update public.oj_match_results set rating_applied_at=now() where id=target_result;
end $$;

create or replace function public.oj_confirm_result(target_result uuid, agrees_with_result boolean)
returns text language plpgsql security definer set search_path = public as $$
declare v_activity uuid; v_required integer; v_yes integer; v_status text;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  select activity_id, confirmations_required into v_activity, v_required from public.oj_match_results where id=target_result;
  if not found then raise exception 'NOT_FOUND'; end if;
  if not exists (select 1 from public.oj_activity_participants where activity_id=v_activity and profile_id=auth.uid() and rsvp_status='going') then raise exception 'FORBIDDEN'; end if;
  insert into public.oj_result_confirmations(result_id,profile_id,agrees) values(target_result,auth.uid(),agrees_with_result)
  on conflict (result_id,profile_id) do update set agrees=excluded.agrees, created_at=now();
  if not agrees_with_result then
    update public.oj_match_results set status='disputed' where id=target_result and status<>'void';
    return 'disputed';
  end if;
  select count(*) into v_yes from public.oj_result_confirmations where result_id=target_result and agrees=true;
  if v_yes >= v_required then
    update public.oj_match_results set status='verified', verified_at=coalesce(verified_at,now()) where id=target_result and status<>'void';
    perform public.oj_apply_verified_ratings(target_result);
    v_status:='verified';
  else v_status:='submitted'; end if;
  return v_status;
end $$;

-- ---------- Derived views ----------
create or replace view public.oj_profile_reputation with (security_invoker=true) as
select p.id as profile_id,
  count(ap.*) filter (where ap.attendance_status in ('attended','late_cancel','no_show')) as considered_events,
  count(ap.*) filter (where ap.attendance_status='attended') as attended_events,
  count(ap.*) filter (where ap.attendance_status='late_cancel') as late_cancels,
  count(ap.*) filter (where ap.attendance_status='no_show') as no_shows,
  case when count(ap.*) filter (where ap.attendance_status in ('attended','late_cancel','no_show'))=0 then null
    else round(100.0 * (
      count(ap.*) filter (where ap.attendance_status='attended') + 0.35 * count(ap.*) filter (where ap.attendance_status='late_cancel')
    ) / count(ap.*) filter (where ap.attendance_status in ('attended','late_cancel','no_show')))
  end as reliability_percent
from public.oj_profiles p
left join public.oj_activity_participants ap on ap.profile_id=p.id
left join public.oj_activities a on a.id=ap.activity_id and a.starts_at >= now()-interval '180 days'
group by p.id;

create or replace view public.oj_passport with (security_invoker=true) as
select ap.profile_id, a.sport_slug, min(a.starts_at) first_played_at, count(*) activities
from public.oj_activity_participants ap
join public.oj_activities a on a.id=ap.activity_id
where ap.attendance_status='attended'
group by ap.profile_id,a.sport_slug;

create or replace view public.oj_sport_leaderboard with (security_invoker=true) as
select r.sport_slug,r.season_id,r.profile_id,p.username,p.full_name,p.avatar_url,r.rating,r.games_played,r.wins,r.draws,r.losses
from public.oj_ratings r join public.oj_profiles p on p.id=r.profile_id
where p.competition_quiet=false and p.suspended_at is null;

create or replace view public.oj_clan_leaderboard with (security_invoker=true) as
select id,slug,name,city,lifetime_xp,level,
  dense_rank() over (partition by city order by lifetime_xp desc) as city_rank
from public.oj_clans where verified_state<>'suspended';

-- ---------- Triggers ----------
drop trigger if exists oj_profiles_touch on public.oj_profiles;
create trigger oj_profiles_touch before update on public.oj_profiles for each row execute function public.oj_touch_updated_at();
drop trigger if exists oj_clans_touch on public.oj_clans;
create trigger oj_clans_touch before update on public.oj_clans for each row execute function public.oj_touch_updated_at();
drop trigger if exists oj_posts_touch on public.oj_posts;
create trigger oj_posts_touch before update on public.oj_posts for each row execute function public.oj_touch_updated_at();
drop trigger if exists oj_comments_touch on public.oj_comments;
create trigger oj_comments_touch before update on public.oj_comments for each row execute function public.oj_touch_updated_at();
drop trigger if exists oj_profile_xp_rollup on public.oj_xp_ledger;
create trigger oj_profile_xp_rollup after insert on public.oj_xp_ledger for each row execute function public.oj_rollup_profile_xp();
drop trigger if exists oj_clan_xp_rollup on public.oj_clan_xp_ledger;
create trigger oj_clan_xp_rollup after insert on public.oj_clan_xp_ledger for each row execute function public.oj_rollup_clan_xp();
drop trigger if exists oj_clan_founder on public.oj_clans;
create trigger oj_clan_founder after insert on public.oj_clans for each row execute function public.oj_after_clan_insert();
drop trigger if exists oj_auth_user_created on auth.users;
create trigger oj_auth_user_created after insert on auth.users for each row execute function public.oj_handle_new_user();

-- ---------- RLS ----------
alter table public.oj_profiles enable row level security;
alter table public.oj_user_sports enable row level security;
alter table public.oj_user_intents enable row level security;
alter table public.oj_availability enable row level security;
alter table public.oj_follows enable row level security;
alter table public.oj_blocks enable row level security;
alter table public.oj_clans enable row level security;
alter table public.oj_clan_sports enable row level security;
alter table public.oj_clan_members enable row level security;
alter table public.oj_teams enable row level security;
alter table public.oj_team_members enable row level security;
alter table public.oj_activities enable row level security;
alter table public.oj_activity_participants enable row level security;
alter table public.oj_goals enable row level security;
alter table public.oj_challenges enable row level security;
alter table public.oj_challenge_members enable row level security;
alter table public.oj_user_achievements enable row level security;
alter table public.oj_xp_ledger enable row level security;
alter table public.oj_clan_xp_ledger enable row level security;
alter table public.oj_seasons enable row level security;
alter table public.oj_ratings enable row level security;
alter table public.oj_match_results enable row level security;
alter table public.oj_match_stats enable row level security;
alter table public.oj_result_confirmations enable row level security;
alter table public.oj_posts enable row level security;
alter table public.oj_comments enable row level security;
alter table public.oj_reactions enable row level security;
alter table public.oj_chat_channels enable row level security;
alter table public.oj_channel_members enable row level security;
alter table public.oj_messages enable row level security;
alter table public.oj_notifications enable row level security;
alter table public.oj_statuses enable row level security;
alter table public.oj_tournaments enable row level security;
alter table public.oj_tournament_entries enable row level security;
alter table public.oj_fixtures enable row level security;
alter table public.oj_spots enable row level security;
alter table public.oj_provider_activities enable row level security;
alter table public.oj_reports enable row level security;

-- Profiles
create policy oj_profiles_read on public.oj_profiles for select to authenticated using ((id=auth.uid() or profile_visibility='public') and not public.oj_is_blocked(id));
create policy oj_profiles_update on public.oj_profiles for update to authenticated using (id=auth.uid()) with check (id=auth.uid());
-- User preference tables
create policy oj_user_sports_read on public.oj_user_sports for select to authenticated using (profile_id=auth.uid() or exists(select 1 from public.oj_profiles p where p.id=profile_id and p.profile_visibility='public'));
create policy oj_user_sports_write on public.oj_user_sports for all to authenticated using (profile_id=auth.uid()) with check (profile_id=auth.uid());
create policy oj_user_intents_self on public.oj_user_intents for all to authenticated using (profile_id=auth.uid()) with check (profile_id=auth.uid());
create policy oj_availability_self on public.oj_availability for all to authenticated using (profile_id=auth.uid()) with check (profile_id=auth.uid());
create policy oj_follows_read on public.oj_follows for select to authenticated using (follower_id=auth.uid() or followed_id=auth.uid());
create policy oj_follows_write on public.oj_follows for insert to authenticated with check (follower_id=auth.uid() and not public.oj_is_blocked(followed_id));
create policy oj_follows_delete on public.oj_follows for delete to authenticated using (follower_id=auth.uid());
create policy oj_blocks_self on public.oj_blocks for all to authenticated using (blocker_id=auth.uid()) with check (blocker_id=auth.uid());

-- Clans / teams
create policy oj_clans_read on public.oj_clans for select to authenticated using (is_public or owner_id=auth.uid() or public.oj_is_clan_member(id));
create policy oj_clans_insert on public.oj_clans for insert to authenticated with check (owner_id=auth.uid());
create policy oj_clans_update on public.oj_clans for update to authenticated using (owner_id=auth.uid() or public.oj_has_clan_role(id,array['founder','leader'])) with check (owner_id=(select owner_id from public.oj_clans c where c.id=oj_clans.id));
create policy oj_clan_sports_read on public.oj_clan_sports for select to authenticated using (exists(select 1 from public.oj_clans c where c.id=clan_id and (c.is_public or c.owner_id=auth.uid() or public.oj_is_clan_member(c.id))));
create policy oj_clan_sports_write on public.oj_clan_sports for all to authenticated using (public.oj_has_clan_role(clan_id,array['founder','leader'])) with check (public.oj_has_clan_role(clan_id,array['founder','leader']));
create policy oj_clan_members_read on public.oj_clan_members for select to authenticated using (profile_id=auth.uid() or public.oj_is_clan_member(clan_id) or exists(select 1 from public.oj_clans c where c.id=clan_id and c.is_public));
create policy oj_teams_read on public.oj_teams for select to authenticated using (exists(select 1 from public.oj_clans c where c.id=clan_id and (c.is_public or public.oj_is_clan_member(c.id))));
create policy oj_teams_insert on public.oj_teams for insert to authenticated with check (created_by=auth.uid() and public.oj_has_clan_role(clan_id,array['founder','leader','captain','coach']));
create policy oj_teams_update on public.oj_teams for update to authenticated using (public.oj_has_clan_role(clan_id,array['founder','leader','captain','coach']));
create policy oj_team_members_read on public.oj_team_members for select to authenticated using (exists(select 1 from public.oj_teams t where t.id=team_id and public.oj_is_clan_member(t.clan_id)));

-- Activities
create policy oj_activities_read on public.oj_activities for select to authenticated using (visibility='public' or organizer_id=auth.uid() or (clan_id is not null and public.oj_is_clan_member(clan_id)));
create policy oj_activities_insert on public.oj_activities for insert to authenticated with check (organizer_id=auth.uid() and (clan_id is null or public.oj_is_clan_member(clan_id)));
create policy oj_activities_update on public.oj_activities for update to authenticated using (organizer_id=auth.uid() or (clan_id is not null and public.oj_has_clan_role(clan_id,array['founder','leader','captain','coach','event_organizer'])));
create policy oj_activity_participants_read on public.oj_activity_participants for select to authenticated using (exists(select 1 from public.oj_activities a where a.id=activity_id and (a.visibility='public' or a.organizer_id=auth.uid() or (a.clan_id is not null and public.oj_is_clan_member(a.clan_id)))));

-- Goals/challenges/progression
create policy oj_goals_self on public.oj_goals for all to authenticated using (profile_id=auth.uid()) with check (profile_id=auth.uid());
create policy oj_challenges_read on public.oj_challenges for select to authenticated using (scope in ('city','global','official','friends','personal') or creator_id=auth.uid() or (clan_id is not null and public.oj_is_clan_member(clan_id)));
create policy oj_challenges_insert on public.oj_challenges for insert to authenticated with check (creator_id=auth.uid() and (clan_id is null or public.oj_is_clan_member(clan_id)));
create policy oj_challenge_members_read on public.oj_challenge_members for select to authenticated using (profile_id=auth.uid() or exists(select 1 from public.oj_challenges c where c.id=challenge_id and c.scope in ('city','global','official')));
create policy oj_user_achievements_read on public.oj_user_achievements for select to authenticated using (profile_id=auth.uid() or exists(select 1 from public.oj_profiles p where p.id=profile_id and p.profile_visibility='public'));
create policy oj_xp_self_read on public.oj_xp_ledger for select to authenticated using (profile_id=auth.uid());
create policy oj_clan_xp_read on public.oj_clan_xp_ledger for select to authenticated using (public.oj_is_clan_member(clan_id));

-- Competition
create policy oj_seasons_read on public.oj_seasons for select to authenticated using (true);
create policy oj_ratings_read on public.oj_ratings for select to authenticated using (not public.oj_is_blocked(profile_id));
create policy oj_match_results_read on public.oj_match_results for select to authenticated using (exists(select 1 from public.oj_activities a where a.id=activity_id and (a.visibility='public' or a.organizer_id=auth.uid() or (a.clan_id is not null and public.oj_is_clan_member(a.clan_id)))));
create policy oj_match_results_insert on public.oj_match_results for insert to authenticated with check (submitted_by=auth.uid() and exists(select 1 from public.oj_activities a where a.id=activity_id and (a.organizer_id=auth.uid() or (a.clan_id is not null and public.oj_has_clan_role(a.clan_id,array['founder','leader','captain','coach','event_organizer'])))));
create policy oj_match_stats_read on public.oj_match_stats for select to authenticated using (exists(select 1 from public.oj_match_results r join public.oj_activities a on a.id=r.activity_id where r.id=result_id and (a.visibility='public' or a.organizer_id=auth.uid() or (a.clan_id is not null and public.oj_is_clan_member(a.clan_id)))));
create policy oj_result_confirmations_read on public.oj_result_confirmations for select to authenticated using (profile_id=auth.uid());

-- Social
create policy oj_posts_read on public.oj_posts for select to authenticated using ((clan_id is null or public.oj_is_clan_member(clan_id) or exists(select 1 from public.oj_clans c where c.id=clan_id and c.is_public)) and not public.oj_is_blocked(author_id));
create policy oj_posts_insert on public.oj_posts for insert to authenticated with check (author_id=auth.uid() and (clan_id is null or public.oj_is_clan_member(clan_id)));
create policy oj_posts_update on public.oj_posts for update to authenticated using (author_id=auth.uid());
create policy oj_posts_delete on public.oj_posts for delete to authenticated using (author_id=auth.uid() or (clan_id is not null and public.oj_has_clan_role(clan_id,array['founder','leader','moderator'])));
create policy oj_comments_read on public.oj_comments for select to authenticated using (not public.oj_is_blocked(author_id));
create policy oj_comments_insert on public.oj_comments for insert to authenticated with check (author_id=auth.uid());
create policy oj_comments_update on public.oj_comments for update to authenticated using (author_id=auth.uid());
create policy oj_comments_delete on public.oj_comments for delete to authenticated using (author_id=auth.uid());
create policy oj_reactions_read on public.oj_reactions for select to authenticated using (true);
create policy oj_reactions_write on public.oj_reactions for insert to authenticated with check (profile_id=auth.uid());
create policy oj_reactions_delete on public.oj_reactions for delete to authenticated using (profile_id=auth.uid());
create policy oj_channels_read on public.oj_chat_channels for select to authenticated using (public.oj_is_channel_member(id));
create policy oj_channel_members_read on public.oj_channel_members for select to authenticated using (public.oj_is_channel_member(channel_id));
create policy oj_messages_read on public.oj_messages for select to authenticated using (public.oj_is_channel_member(channel_id) and not public.oj_is_blocked(sender_id));
create policy oj_messages_insert on public.oj_messages for insert to authenticated with check (sender_id=auth.uid() and public.oj_is_channel_member(channel_id));
create policy oj_notifications_self on public.oj_notifications for select to authenticated using (profile_id=auth.uid());
create policy oj_notifications_update on public.oj_notifications for update to authenticated using (profile_id=auth.uid()) with check (profile_id=auth.uid());
create policy oj_statuses_read on public.oj_statuses for select to authenticated using (expires_at>now() and not public.oj_is_blocked(profile_id));
create policy oj_statuses_write on public.oj_statuses for all to authenticated using (profile_id=auth.uid()) with check (profile_id=auth.uid());

-- Tournaments / places / providers / safety
create policy oj_tournaments_read on public.oj_tournaments for select to authenticated using (true);
create policy oj_tournaments_insert on public.oj_tournaments for insert to authenticated with check (creator_id=auth.uid() and (clan_id is null or public.oj_is_clan_member(clan_id)));
create policy oj_tournaments_update on public.oj_tournaments for update to authenticated using (creator_id=auth.uid() or (clan_id is not null and public.oj_has_clan_role(clan_id,array['founder','leader','captain'])));
create policy oj_tournament_entries_read on public.oj_tournament_entries for select to authenticated using (true);
create policy oj_fixtures_read on public.oj_fixtures for select to authenticated using (true);
create policy oj_spots_read on public.oj_spots for select to authenticated using (true);
create policy oj_provider_self on public.oj_provider_activities for select to authenticated using (profile_id=auth.uid());
create policy oj_reports_insert on public.oj_reports for insert to authenticated with check (reporter_id=auth.uid());
create policy oj_reports_self_read on public.oj_reports for select to authenticated using (reporter_id=auth.uid());

-- ---------- Privileges ----------
revoke all on public.oj_xp_ledger, public.oj_clan_xp_ledger from anon, authenticated;
grant select on public.oj_xp_ledger, public.oj_clan_xp_ledger to authenticated;
revoke all on public.oj_activity_participants from authenticated;
grant select on public.oj_activity_participants to authenticated;
revoke all on public.oj_clan_members from authenticated;
grant select on public.oj_clan_members to authenticated;
revoke all on public.oj_challenge_members from authenticated;
grant select on public.oj_challenge_members to authenticated;
revoke all on public.oj_ratings, public.oj_result_confirmations from authenticated;
grant select on public.oj_ratings, public.oj_result_confirmations to authenticated;

revoke update on public.oj_profiles from authenticated;
grant update (username,full_name,avatar_url,bio,city,timezone,profile_visibility,competition_quiet,onboarding_completed) on public.oj_profiles to authenticated;
revoke update on public.oj_clans from authenticated;
grant update (slug,name,bio,city,logo_url,cover_url,brand_color,is_public) on public.oj_clans to authenticated;
revoke update on public.oj_activities from authenticated;
grant update (title,description,mode,skill_level,location_name,address,city,latitude,longitude,reveal_exact_address_after_rsvp,starts_at,ends_at,max_participants,cost_cents,currency,equipment,visibility,clan_only,waitlist_enabled,rsvp_deadline,urgent_spots,status) on public.oj_activities to authenticated;
revoke update on public.oj_notifications from authenticated;
grant update (read_at) on public.oj_notifications to authenticated;

-- RPC access
grant execute on function public.oj_join_clan(uuid) to authenticated;
grant execute on function public.oj_leave_clan(uuid) to authenticated;
grant execute on function public.oj_rsvp_activity(uuid,text) to authenticated;
grant execute on function public.oj_record_attendance(uuid,uuid,text) to authenticated;
grant execute on function public.oj_join_challenge(uuid) to authenticated;
grant execute on function public.oj_set_challenge_progress(uuid,numeric) to authenticated;
grant execute on function public.oj_get_or_create_direct_channel(uuid) to authenticated;
grant execute on function public.oj_confirm_result(uuid,boolean) to authenticated;
revoke execute on function public.oj_rollup_profile_xp() from public;
revoke execute on function public.oj_rollup_clan_xp() from public;
revoke execute on function public.oj_after_clan_insert() from public;
revoke execute on function public.oj_apply_verified_ratings(uuid) from public;

-- ---------- Seed catalog ----------
insert into public.oj_sports(slug,name,category,metrics) values
('football','Football','team','["goals","assists","wins","clean_sheets","mvps","games_played"]'),
('basketball','Basketball','team','["points","assists","rebounds","blocks","steals","wins","mvps"]'),
('running','Running','endurance','["fastest_1k","fastest_5k","fastest_10k","weekly_distance","monthly_distance","elevation"]'),
('strength','Strength Training','fitness','["bench_press","squat","deadlift","total","strength_to_bodyweight","sessions"]'),
('volleyball','Volleyball','team','["wins","aces","blocks","mvps","games_played"]'),
('tennis','Tennis','racket','["wins","losses","rating","matches_played"]'),
('badminton','Badminton','racket','["wins","losses","rating","matches_played"]'),
('cycling','Cycling','endurance','["distance","speed","elevation","longest_ride","weekly_distance"]'),
('swimming','Swimming','aquatic','["distance","fastest_times","sessions","streaks"]'),
('martial-arts','Martial Arts','combat','["sessions","streaks"]'),
('boxing','Boxing','combat','["sessions","streaks"]'),
('hiking','Hiking','outdoor','["distance","elevation","sessions"]'),
('calisthenics','Calisthenics','fitness','["sessions","streaks"]'),
('dance','Dance','movement','["sessions","streaks"]'),
('yoga','Yoga','movement','["sessions","streaks"]')
on conflict (slug) do update set name=excluded.name, category=excluded.category, metrics=excluded.metrics, active=true;

insert into public.oj_achievement_definitions(slug,name,description,icon,category,xp_reward) values
('first-touch','First Touch','Complete your first Ojoro activity.','⚡','participation',100),
('regular','Regular','Attend 10 activities.','🔥','participation',250),
('explorer','Explorer','Try five different sports.','🧭','exploration',500),
('nomad','Nomad','Participate with five clans.','🌍','community',500),
('captain','Captain','Host 10 activities.','🫡','community',700),
('centurion','Centurion','Complete 100 activities.','💯','participation',1000),
('touch-grass','Touch Grass','Complete 100 outdoor activities.','🌱','exploration',1000)
on conflict (slug) do update set name=excluded.name, description=excluded.description, icon=excluded.icon, category=excluded.category, xp_reward=excluded.xp_reward;

insert into public.oj_seasons(name,city,sport_slug,starts_at,ends_at,active)
values ('Fall 2026',null,null,'2026-09-01','2026-11-30',true)
on conflict (name,city,sport_slug) do nothing;

-- Backfill profiles for existing auth users without changing the legacy public.profiles table.
insert into public.oj_profiles(id,username,full_name)
select u.id, ('user_'||substr(u.id::text,1,8))::citext, nullif(coalesce(u.raw_user_meta_data->>'full_name',u.raw_user_meta_data->>'name'),'')
from auth.users u
on conflict (id) do nothing;
