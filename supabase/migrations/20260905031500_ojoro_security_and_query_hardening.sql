-- Forward-only hardening for the Ojoro consumer schema.
-- Applied to Ojoro Command Centre after the initial social-platform migration.

alter table public.oj_sports enable row level security;
alter table public.oj_achievement_definitions enable row level security;
drop policy if exists oj_sports_read on public.oj_sports;
create policy oj_sports_read on public.oj_sports for select to anon, authenticated using (active = true);
drop policy if exists oj_achievements_catalog_read on public.oj_achievement_definitions;
create policy oj_achievements_catalog_read on public.oj_achievement_definitions for select to authenticated using (active = true);

alter function public.oj_level_for_xp(bigint) set search_path = public;
alter function public.oj_touch_updated_at() set search_path = public;

-- Trigger/internal functions are never callable through PostgREST roles.
revoke execute on function public.oj_after_clan_insert() from public, anon, authenticated;
revoke execute on function public.oj_apply_verified_ratings(uuid) from public, anon, authenticated;
revoke execute on function public.oj_handle_new_user() from public, anon, authenticated;
revoke execute on function public.oj_rollup_profile_xp() from public, anon, authenticated;
revoke execute on function public.oj_rollup_clan_xp() from public, anon, authenticated;

-- Authenticated RPCs intentionally use SECURITY DEFINER, but anonymous access is removed.
revoke execute on function public.oj_is_blocked(uuid) from public, anon;
revoke execute on function public.oj_is_clan_member(uuid) from public, anon;
revoke execute on function public.oj_has_clan_role(uuid,text[]) from public, anon;
revoke execute on function public.oj_is_channel_member(uuid) from public, anon;
revoke execute on function public.oj_current_season(text) from public, anon;
revoke execute on function public.oj_join_clan(uuid) from public, anon;
revoke execute on function public.oj_leave_clan(uuid) from public, anon;
revoke execute on function public.oj_rsvp_activity(uuid,text) from public, anon;
revoke execute on function public.oj_record_attendance(uuid,uuid,text) from public, anon;
revoke execute on function public.oj_join_challenge(uuid) from public, anon;
revoke execute on function public.oj_set_challenge_progress(uuid,numeric) from public, anon;
revoke execute on function public.oj_get_or_create_direct_channel(uuid) from public, anon;
revoke execute on function public.oj_confirm_result(uuid,boolean) from public, anon;

grant execute on function public.oj_is_blocked(uuid) to authenticated;
grant execute on function public.oj_is_clan_member(uuid) to authenticated;
grant execute on function public.oj_has_clan_role(uuid,text[]) to authenticated;
grant execute on function public.oj_is_channel_member(uuid) to authenticated;
grant execute on function public.oj_current_season(text) to authenticated;
grant execute on function public.oj_join_clan(uuid) to authenticated;
grant execute on function public.oj_leave_clan(uuid) to authenticated;
grant execute on function public.oj_rsvp_activity(uuid,text) to authenticated;
grant execute on function public.oj_record_attendance(uuid,uuid,text) to authenticated;
grant execute on function public.oj_join_challenge(uuid) to authenticated;
grant execute on function public.oj_set_challenge_progress(uuid,numeric) to authenticated;
grant execute on function public.oj_get_or_create_direct_channel(uuid) to authenticated;
grant execute on function public.oj_confirm_result(uuid,boolean) to authenticated;

-- Entity references must support UUID-backed entities and bigint message IDs.
alter table public.oj_reports alter column entity_id type text using entity_id::text;

-- Recent reliability only counts activity rows from the last 180 days.
create or replace view public.oj_profile_reputation with (security_invoker=true) as
select p.id as profile_id,
  count(ap.*) filter (where a.id is not null and ap.attendance_status in ('attended','late_cancel','no_show')) as considered_events,
  count(ap.*) filter (where a.id is not null and ap.attendance_status='attended') as attended_events,
  count(ap.*) filter (where a.id is not null and ap.attendance_status='late_cancel') as late_cancels,
  count(ap.*) filter (where a.id is not null and ap.attendance_status='no_show') as no_shows,
  case when count(ap.*) filter (where a.id is not null and ap.attendance_status in ('attended','late_cancel','no_show'))=0 then null
    else round(100.0 * (
      count(ap.*) filter (where a.id is not null and ap.attendance_status='attended')
      + 0.35 * count(ap.*) filter (where a.id is not null and ap.attendance_status='late_cancel')
    ) / count(ap.*) filter (where a.id is not null and ap.attendance_status in ('attended','late_cancel','no_show')))
  end as reliability_percent
from public.oj_profiles p
left join public.oj_activity_participants ap on ap.profile_id=p.id
left join public.oj_activities a on a.id=ap.activity_id and a.starts_at >= now()-interval '180 days'
group by p.id;

create index if not exists oj_activities_organizer_idx on public.oj_activities(organizer_id, starts_at desc);
create index if not exists oj_activities_team_idx on public.oj_activities(team_id, starts_at desc) where team_id is not null;
create index if not exists oj_blocks_blocked_idx on public.oj_blocks(blocked_id);
create index if not exists oj_follows_followed_idx on public.oj_follows(followed_id);
create index if not exists oj_clans_owner_idx on public.oj_clans(owner_id);
create index if not exists oj_challenges_creator_idx on public.oj_challenges(creator_id, starts_at desc);
create index if not exists oj_challenges_clan_idx on public.oj_challenges(clan_id, starts_at desc) where clan_id is not null;
create index if not exists oj_challenge_members_profile_idx on public.oj_challenge_members(profile_id, joined_at desc);
create index if not exists oj_channel_members_profile_idx on public.oj_channel_members(profile_id, joined_at desc);
create index if not exists oj_comments_post_idx on public.oj_comments(post_id, created_at);
create index if not exists oj_comments_author_idx on public.oj_comments(author_id, created_at desc);
create index if not exists oj_goals_profile_idx on public.oj_goals(profile_id, created_at desc);
create index if not exists oj_posts_author_idx on public.oj_posts(author_id, created_at desc);
create index if not exists oj_posts_activity_idx on public.oj_posts(activity_id, created_at desc) where activity_id is not null;
create index if not exists oj_reports_reporter_idx on public.oj_reports(reporter_id, created_at desc);
create index if not exists oj_statuses_profile_idx on public.oj_statuses(profile_id, expires_at desc);
create index if not exists oj_team_members_profile_idx on public.oj_team_members(profile_id);
create index if not exists oj_tournaments_creator_idx on public.oj_tournaments(creator_id, starts_at desc);
create index if not exists oj_tournaments_clan_idx on public.oj_tournaments(clan_id, starts_at desc) where clan_id is not null;
create index if not exists oj_tournament_entries_tournament_idx on public.oj_tournament_entries(tournament_id);
create index if not exists oj_fixtures_tournament_idx on public.oj_fixtures(tournament_id, starts_at);
