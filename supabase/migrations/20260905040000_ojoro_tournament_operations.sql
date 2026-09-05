create unique index if not exists oj_tournament_entry_team_unique on public.oj_tournament_entries(tournament_id,team_id) where team_id is not null;
create unique index if not exists oj_tournament_entry_clan_unique on public.oj_tournament_entries(tournament_id,clan_id) where clan_id is not null;
alter table public.oj_fixtures add column if not exists round_number integer not null default 1 check (round_number > 0);
alter table public.oj_fixtures add column if not exists match_number integer not null default 1 check (match_number > 0);
create unique index if not exists oj_fixture_round_match_unique on public.oj_fixtures(tournament_id,round_number,match_number);

create or replace function public.oj_register_tournament_entry(target_tournament uuid,target_team uuid)
returns uuid language plpgsql security definer set search_path=public as $$
declare t public.oj_tournaments%rowtype; tm public.oj_teams%rowtype; eid uuid; entry_count integer;
begin
 if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
 select * into t from public.oj_tournaments where id=target_tournament for update; if not found then raise exception 'NOT_FOUND'; end if;
 if t.status<>'registration' or t.starts_at<=now() then raise exception 'REGISTRATION_CLOSED'; end if;
 select * into tm from public.oj_teams where id=target_team; if not found then raise exception 'TEAM_NOT_FOUND'; end if;
 if tm.sport_slug<>t.sport_slug then raise exception 'SPORT_MISMATCH'; end if;
 if not public.oj_has_clan_role(tm.clan_id,array['founder','leader','captain','coach']) and not exists(select 1 from public.oj_team_members where team_id=target_team and profile_id=auth.uid() and is_captain) then raise exception 'FORBIDDEN'; end if;
 select count(*) into entry_count from public.oj_tournament_entries where tournament_id=target_tournament;
 if t.max_entries is not null and entry_count>=t.max_entries then raise exception 'TOURNAMENT_FULL'; end if;
 insert into public.oj_tournament_entries(tournament_id,team_id,clan_id,display_name) values(target_tournament,target_team,tm.clan_id,tm.name)
 on conflict(tournament_id,team_id) where team_id is not null do update set display_name=excluded.display_name returning id into eid;
 return eid;
end $$;
revoke execute on function public.oj_register_tournament_entry(uuid,uuid) from public,anon;
grant execute on function public.oj_register_tournament_entry(uuid,uuid) to authenticated;

create or replace function public.oj_can_manage_tournament(target_tournament uuid)
returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.oj_tournaments t where t.id=target_tournament and (t.creator_id=auth.uid() or (t.clan_id is not null and public.oj_has_clan_role(t.clan_id,array['founder','leader','captain']))));
$$;
revoke execute on function public.oj_can_manage_tournament(uuid) from public,anon;
grant execute on function public.oj_can_manage_tournament(uuid) to authenticated;

create or replace function public.oj_generate_tournament_fixtures(target_tournament uuid)
returns integer language plpgsql security definer set search_path=public as $$
declare t public.oj_tournaments%rowtype; entries uuid[]; labels text[]; n integer; i integer; j integer; m integer:=0; start_at timestamptz;
begin
 if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
 if not public.oj_can_manage_tournament(target_tournament) then raise exception 'FORBIDDEN'; end if;
 select * into t from public.oj_tournaments where id=target_tournament for update; if not found then raise exception 'NOT_FOUND'; end if;
 if exists(select 1 from public.oj_fixtures where tournament_id=target_tournament and status in('live','completed')) then raise exception 'FIXTURES_LOCKED'; end if;
 select array_agg(id order by seed nulls last,joined_at,id), array_agg(display_name order by seed nulls last,joined_at,id) into entries,labels from public.oj_tournament_entries where tournament_id=target_tournament;
 n:=coalesce(array_length(entries,1),0); if n<2 then raise exception 'NOT_ENOUGH_ENTRIES'; end if;
 delete from public.oj_fixtures where tournament_id=target_tournament; start_at:=t.starts_at;
 if t.format in('round_robin','league','group_knockout') then
   for i in 1..n-1 loop for j in i+1..n loop m:=m+1; insert into public.oj_fixtures(tournament_id,round_label,round_number,match_number,home_entry_id,away_entry_id,starts_at,status) values(target_tournament,case when t.format='group_knockout' then 'Group stage' else 'Round robin' end,1,m,entries[i],entries[j],start_at+((m-1)*interval '90 minutes'),'scheduled'); end loop; end loop;
 elsif t.format='ladder' then
   i:=1; while i<n loop m:=m+1; insert into public.oj_fixtures(tournament_id,round_label,round_number,match_number,home_entry_id,away_entry_id,starts_at,status) values(target_tournament,'Ladder round',1,m,entries[i],entries[i+1],start_at+((m-1)*interval '90 minutes'),'scheduled'); i:=i+2; end loop;
 else
   i:=1; while i<=n loop m:=m+1; insert into public.oj_fixtures(tournament_id,round_label,round_number,match_number,home_entry_id,away_entry_id,starts_at,status) values(target_tournament,'Round 1',1,m,entries[i],case when i+1<=n then entries[i+1] else null end,start_at+((m-1)*interval '90 minutes'),'scheduled'); i:=i+2; end loop;
 end if;
 update public.oj_tournaments set status='active' where id=target_tournament and status='registration'; return m;
end $$;
revoke execute on function public.oj_generate_tournament_fixtures(uuid) from public,anon;
grant execute on function public.oj_generate_tournament_fixtures(uuid) to authenticated;

create or replace function public.oj_record_fixture_result(target_fixture uuid,home_points integer,away_points integer)
returns void language plpgsql security definer set search_path=public as $$
declare f public.oj_fixtures%rowtype;
begin
 if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
 if home_points<0 or away_points<0 then raise exception 'VALIDATION_ERROR'; end if;
 select * into f from public.oj_fixtures where id=target_fixture; if not found then raise exception 'NOT_FOUND'; end if;
 if not public.oj_can_manage_tournament(f.tournament_id) then raise exception 'FORBIDDEN'; end if;
 if f.home_entry_id is null or f.away_entry_id is null then raise exception 'INCOMPLETE_FIXTURE'; end if;
 update public.oj_fixtures set home_score=home_points,away_score=away_points,status='completed' where id=target_fixture;
end $$;
revoke execute on function public.oj_record_fixture_result(uuid,integer,integer) from public,anon;
grant execute on function public.oj_record_fixture_result(uuid,integer,integer) to authenticated;

create or replace function public.oj_advance_knockout_round(target_tournament uuid)
returns integer language plpgsql security definer set search_path=public as $$
declare t public.oj_tournaments%rowtype; current_round integer; winners uuid[]; n integer; i integer; m integer:=0; next_round integer; start_at timestamptz;
begin
 if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
 if not public.oj_can_manage_tournament(target_tournament) then raise exception 'FORBIDDEN'; end if;
 select * into t from public.oj_tournaments where id=target_tournament for update; if not found then raise exception 'NOT_FOUND'; end if;
 if t.format not in('knockout','group_knockout') then raise exception 'NOT_KNOCKOUT'; end if;
 select max(round_number) into current_round from public.oj_fixtures where tournament_id=target_tournament; if current_round is null then raise exception 'NO_FIXTURES'; end if;
 if exists(select 1 from public.oj_fixtures where tournament_id=target_tournament and round_number=current_round and status<>'completed' and away_entry_id is not null) then raise exception 'ROUND_INCOMPLETE'; end if;
 if t.format='group_knockout' and current_round=1 then
   with scores as (select e.id,sum(case when f.home_entry_id=e.id then case when f.home_score>f.away_score then 3 when f.home_score=f.away_score then 1 else 0 end when f.away_entry_id=e.id then case when f.away_score>f.home_score then 3 when f.away_score=f.home_score then 1 else 0 end else 0 end) points,sum(case when f.home_entry_id=e.id then coalesce(f.home_score,0)-coalesce(f.away_score,0) when f.away_entry_id=e.id then coalesce(f.away_score,0)-coalesce(f.home_score,0) else 0 end) diff from public.oj_tournament_entries e join public.oj_fixtures f on f.tournament_id=e.tournament_id and (f.home_entry_id=e.id or f.away_entry_id=e.id) where e.tournament_id=target_tournament and f.round_number=1 and f.status='completed' group by e.id)
   select array_agg(id order by points desc,diff desc,id) into winners from (select * from scores order by points desc,diff desc,id limit 4) q;
 else
   select array_agg(case when away_entry_id is null then home_entry_id when home_score>=away_score then home_entry_id else away_entry_id end order by match_number) into winners from public.oj_fixtures where tournament_id=target_tournament and round_number=current_round;
 end if;
 n:=coalesce(array_length(winners,1),0); if n<=1 then update public.oj_tournaments set status='completed' where id=target_tournament; return 0; end if;
 next_round:=current_round+1; if exists(select 1 from public.oj_fixtures where tournament_id=target_tournament and round_number=next_round) then raise exception 'NEXT_ROUND_EXISTS'; end if;
 start_at:=greatest(now(),t.starts_at)+interval '1 day'; i:=1; while i<=n loop m:=m+1; insert into public.oj_fixtures(tournament_id,round_label,round_number,match_number,home_entry_id,away_entry_id,starts_at,status) values(target_tournament,case when n<=2 then 'Final' when n<=4 then 'Semi-final' else 'Round '||next_round end,next_round,m,winners[i],case when i+1<=n then winners[i+1] else null end,start_at+((m-1)*interval '90 minutes'),'scheduled'); i:=i+2; end loop; return m;
end $$;
revoke execute on function public.oj_advance_knockout_round(uuid) from public,anon;
grant execute on function public.oj_advance_knockout_round(uuid) to authenticated;
