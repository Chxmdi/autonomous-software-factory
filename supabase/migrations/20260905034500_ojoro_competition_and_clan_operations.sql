-- Authorized competition and clan/team operational commands.

create or replace function public.oj_assign_match_side(target_activity uuid,target_profile uuid,new_side text,new_position text default null)
returns void language plpgsql security definer set search_path=public as $$
declare a public.oj_activities%rowtype;
begin
 if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
 if new_side not in('home','away') then raise exception 'VALIDATION_ERROR'; end if;
 select * into a from public.oj_activities where id=target_activity; if not found then raise exception 'NOT_FOUND'; end if;
 if a.mode<>'competitive' then raise exception 'NOT_COMPETITIVE'; end if;
 if a.organizer_id<>auth.uid() and (a.clan_id is null or not public.oj_has_clan_role(a.clan_id,array['founder','leader','captain','coach','event_organizer'])) then raise exception 'FORBIDDEN'; end if;
 update public.oj_activity_participants set team_side=new_side,position=nullif(trim(new_position),'') where activity_id=target_activity and profile_id=target_profile and rsvp_status='going';
 if not found then raise exception 'NOT_FOUND'; end if;
end $$;
revoke execute on function public.oj_assign_match_side(uuid,uuid,text,text) from public,anon;
grant execute on function public.oj_assign_match_side(uuid,uuid,text,text) to authenticated;

create or replace function public.oj_submit_match_result(target_activity uuid,home_label text,away_label text,home_points integer,away_points integer,mvp uuid default null)
returns uuid language plpgsql security definer set search_path=public as $$
declare a public.oj_activities%rowtype; rid uuid;
begin
 if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
 if home_points<0 or away_points<0 or char_length(trim(home_label))<1 or char_length(trim(away_label))<1 then raise exception 'VALIDATION_ERROR'; end if;
 select * into a from public.oj_activities where id=target_activity; if not found then raise exception 'NOT_FOUND'; end if;
 if a.mode<>'competitive' then raise exception 'NOT_COMPETITIVE'; end if;
 if a.organizer_id<>auth.uid() and (a.clan_id is null or not public.oj_has_clan_role(a.clan_id,array['founder','leader','captain','coach','event_organizer'])) then raise exception 'FORBIDDEN'; end if;
 insert into public.oj_match_results(activity_id,submitted_by,home_name,away_name,home_score,away_score,mvp_profile_id,status)
 values(target_activity,auth.uid(),trim(home_label),trim(away_label),home_points,away_points,mvp,'submitted')
 on conflict(activity_id) do update set submitted_by=auth.uid(),home_name=excluded.home_name,away_name=excluded.away_name,home_score=excluded.home_score,away_score=excluded.away_score,mvp_profile_id=excluded.mvp_profile_id,status='submitted',verified_at=null,rating_applied_at=null
 where public.oj_match_results.status in('submitted','disputed') returning id into rid;
 if rid is null then raise exception 'RESULT_LOCKED'; end if;
 delete from public.oj_result_confirmations where result_id=rid;
 return rid;
end $$;
revoke execute on function public.oj_submit_match_result(uuid,text,text,integer,integer,uuid) from public,anon;
grant execute on function public.oj_submit_match_result(uuid,text,text,integer,integer,uuid) to authenticated;

create or replace function public.oj_create_team(target_clan uuid,target_sport text,team_name text,team_description text default null)
returns uuid language plpgsql security definer set search_path=public as $$
declare tid uuid; cid uuid; team_slug text;
begin
 if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
 if not public.oj_has_clan_role(target_clan,array['founder','leader','captain','coach']) then raise exception 'FORBIDDEN'; end if;
 if not exists(select 1 from public.oj_sports where slug=target_sport and active) then raise exception 'INVALID_SPORT'; end if;
 if char_length(trim(team_name))<2 or char_length(trim(team_name))>80 then raise exception 'VALIDATION_ERROR'; end if;
 team_slug:=trim(both '-' from lower(regexp_replace(trim(team_name),'[^a-zA-Z0-9]+','-','g')));
 if exists(select 1 from public.oj_teams where clan_id=target_clan and slug=team_slug::citext) then team_slug:=team_slug||'-'||substr(replace(gen_random_uuid()::text,'-',''),1,5); end if;
 insert into public.oj_teams(clan_id,sport_slug,slug,name,description,created_by) values(target_clan,target_sport,team_slug,trim(team_name),nullif(trim(team_description),''),auth.uid()) returning id into tid;
 insert into public.oj_team_members(team_id,profile_id,is_captain) values(tid,auth.uid(),true) on conflict do nothing;
 insert into public.oj_chat_channels(kind,team_id,name,created_by) values('team',tid,trim(team_name),auth.uid()) returning id into cid;
 insert into public.oj_channel_members(channel_id,profile_id) values(cid,auth.uid()) on conflict do nothing;
 return tid;
end $$;
revoke execute on function public.oj_create_team(uuid,text,text,text) from public,anon;
grant execute on function public.oj_create_team(uuid,text,text,text) to authenticated;

create or replace function public.oj_add_team_member(target_team uuid,target_profile uuid)
returns void language plpgsql security definer set search_path=public as $$
declare c uuid; channel_id uuid;
begin
 if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
 select clan_id into c from public.oj_teams where id=target_team; if not found then raise exception 'NOT_FOUND'; end if;
 if not public.oj_has_clan_role(c,array['founder','leader','captain','coach']) then raise exception 'FORBIDDEN'; end if;
 if not exists(select 1 from public.oj_clan_members where clan_id=c and profile_id=target_profile and status='active') then raise exception 'NOT_CLAN_MEMBER'; end if;
 insert into public.oj_team_members(team_id,profile_id) values(target_team,target_profile) on conflict do nothing;
 select id into channel_id from public.oj_chat_channels where kind='team' and team_id=target_team limit 1;
 if channel_id is not null then insert into public.oj_channel_members(channel_id,profile_id) values(channel_id,target_profile) on conflict do nothing; end if;
end $$;
revoke execute on function public.oj_add_team_member(uuid,uuid) from public,anon;
grant execute on function public.oj_add_team_member(uuid,uuid) to authenticated;

create or replace function public.oj_review_clan_request(target_clan uuid,target_profile uuid,approve boolean)
returns text language plpgsql security definer set search_path=public as $$
declare new_status public.oj_membership_status; channel_id uuid;
begin
 if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
 if not public.oj_has_clan_role(target_clan,array['founder','leader']) then raise exception 'FORBIDDEN'; end if;
 if not exists(select 1 from public.oj_clan_members where clan_id=target_clan and profile_id=target_profile and status='pending') then raise exception 'NOT_FOUND'; end if;
 new_status:=case when approve then 'active'::public.oj_membership_status else 'removed'::public.oj_membership_status end;
 update public.oj_clan_members set status=new_status,updated_at=now() where clan_id=target_clan and profile_id=target_profile;
 if approve then select id into channel_id from public.oj_chat_channels where kind='clan' and clan_id=target_clan and name='General' limit 1; if channel_id is not null then insert into public.oj_channel_members(channel_id,profile_id) values(channel_id,target_profile) on conflict do nothing; end if; end if;
 return new_status::text;
end $$;
revoke execute on function public.oj_review_clan_request(uuid,uuid,boolean) from public,anon;
grant execute on function public.oj_review_clan_request(uuid,uuid,boolean) to authenticated;

create or replace function public.oj_set_clan_role(target_clan uuid,target_profile uuid,new_role text)
returns void language plpgsql security definer set search_path=public as $$
declare actor_role text; owner_profile uuid;
begin
 if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
 if new_role not in('leader','captain','coach','event_organizer','moderator','member') then raise exception 'VALIDATION_ERROR'; end if;
 select owner_id into owner_profile from public.oj_clans where id=target_clan; if not found then raise exception 'NOT_FOUND'; end if;
 if target_profile=owner_profile then raise exception 'OWNER_ROLE_LOCKED'; end if;
 select role::text into actor_role from public.oj_clan_members where clan_id=target_clan and profile_id=auth.uid() and status='active';
 if actor_role='founder' then null; elsif actor_role='leader' and new_role in('captain','coach','event_organizer','moderator','member') then null; else raise exception 'FORBIDDEN'; end if;
 update public.oj_clan_members set role=new_role::public.oj_clan_role,updated_at=now() where clan_id=target_clan and profile_id=target_profile and status='active'; if not found then raise exception 'NOT_FOUND'; end if;
end $$;
revoke execute on function public.oj_set_clan_role(uuid,uuid,text) from public,anon;
grant execute on function public.oj_set_clan_role(uuid,uuid,text) to authenticated;

create index if not exists oj_chat_channels_team_idx on public.oj_chat_channels(team_id) where team_id is not null;
