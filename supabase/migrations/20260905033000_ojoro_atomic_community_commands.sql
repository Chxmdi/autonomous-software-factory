-- Atomic community creation and channel lifecycle.

create or replace function public.oj_after_clan_insert()
returns trigger language plpgsql security definer set search_path = public as $$
declare v_channel uuid;
begin
  insert into public.oj_clan_members(clan_id,profile_id,role,status) values(new.id,new.owner_id,'founder','active')
  on conflict(clan_id,profile_id) do update set role='founder',status='active';
  insert into public.oj_xp_ledger(profile_id,amount,source_kind,source_id,reason) values(new.owner_id,250,'clan',new.id,'created_clan') on conflict do nothing;
  insert into public.oj_clan_xp_ledger(clan_id,amount,source_kind,source_id,reason) values(new.id,250,'clan',new.id,'founded') on conflict do nothing;
  insert into public.oj_chat_channels(kind,clan_id,name,created_by) values('clan',new.id,'General',new.owner_id) returning id into v_channel;
  insert into public.oj_channel_members(channel_id,profile_id) values(v_channel,new.owner_id) on conflict do nothing;
  return new;
end $$;
revoke execute on function public.oj_after_clan_insert() from public,anon,authenticated;

create or replace function public.oj_after_activity_insert()
returns trigger language plpgsql security definer set search_path = public as $$
declare v_channel uuid;
begin
  insert into public.oj_chat_channels(kind,activity_id,name,created_by) values('activity',new.id,new.title,new.organizer_id) returning id into v_channel;
  insert into public.oj_channel_members(channel_id,profile_id) values(v_channel,new.organizer_id) on conflict do nothing;
  return new;
end $$;
revoke execute on function public.oj_after_activity_insert() from public,anon,authenticated;
drop trigger if exists oj_activity_channel on public.oj_activities;
create trigger oj_activity_channel after insert on public.oj_activities for each row execute function public.oj_after_activity_insert();

create or replace function public.oj_create_clan(clan_name text,clan_bio text,clan_city text,clan_public boolean,sport_slugs text[])
returns uuid language plpgsql security definer set search_path = public as $$
declare v_id uuid; v_slug text; v_suffix text;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if char_length(trim(clan_name))<2 or char_length(trim(clan_name))>80 then raise exception 'VALIDATION_ERROR'; end if;
  if char_length(trim(clan_city))<2 or char_length(trim(clan_city))>100 then raise exception 'VALIDATION_ERROR'; end if;
  v_slug:=trim(both '-' from lower(regexp_replace(trim(clan_name),'[^a-zA-Z0-9]+','-','g')));
  if v_slug='' then v_slug:='clan'; end if;
  if exists(select 1 from public.oj_clans where slug=v_slug::citext) then v_suffix:=substr(replace(gen_random_uuid()::text,'-',''),1,6); v_slug:=v_slug||'-'||v_suffix; end if;
  insert into public.oj_clans(owner_id,slug,name,bio,city,is_public) values(auth.uid(),v_slug,trim(clan_name),nullif(trim(clan_bio),''),trim(clan_city),clan_public) returning id into v_id;
  if sport_slugs is not null and cardinality(sport_slugs)>0 then
    insert into public.oj_clan_sports(clan_id,sport_slug,is_primary)
    select v_id,s,row_number() over()=1 from unnest(sport_slugs) s where exists(select 1 from public.oj_sports os where os.slug=s and os.active) on conflict do nothing;
  end if;
  return v_id;
end $$;
revoke execute on function public.oj_create_clan(text,text,text,boolean,text[]) from public,anon;
grant execute on function public.oj_create_clan(text,text,text,boolean,text[]) to authenticated;

create or replace function public.oj_join_clan(target_clan uuid)
returns text language plpgsql security definer set search_path = public as $$
declare v_public boolean; v_status public.oj_membership_status;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  select is_public into v_public from public.oj_clans where id=target_clan; if not found then raise exception 'NOT_FOUND'; end if;
  v_status:=case when v_public then 'active'::public.oj_membership_status else 'pending'::public.oj_membership_status end;
  insert into public.oj_clan_members(clan_id,profile_id,role,status) values(target_clan,auth.uid(),'member',v_status)
  on conflict(clan_id,profile_id) do update set status=excluded.status,updated_at=now();
  if v_status='active' then
    insert into public.oj_channel_members(channel_id,profile_id) select id,auth.uid() from public.oj_chat_channels where kind='clan' and clan_id=target_clan and name='General' on conflict do nothing;
  end if;
  return v_status::text;
end $$;
revoke execute on function public.oj_join_clan(uuid) from public,anon;
grant execute on function public.oj_join_clan(uuid) to authenticated;

create or replace function public.oj_leave_clan(target_clan uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if exists(select 1 from public.oj_clans where id=target_clan and owner_id=auth.uid()) then raise exception 'OWNER_TRANSFER_REQUIRED'; end if;
  update public.oj_clan_members set status='left',updated_at=now() where clan_id=target_clan and profile_id=auth.uid();
  delete from public.oj_channel_members cm using public.oj_chat_channels c where cm.channel_id=c.id and cm.profile_id=auth.uid() and c.kind='clan' and c.clan_id=target_clan;
end $$;
revoke execute on function public.oj_leave_clan(uuid) from public,anon;
grant execute on function public.oj_leave_clan(uuid) to authenticated;

create or replace function public.oj_rsvp_activity(target_activity uuid,desired text)
returns text language plpgsql security definer set search_path = public as $$
declare v_activity public.oj_activities%rowtype; v_going integer; v_status public.oj_rsvp_status; v_promote uuid;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if desired not in('going','maybe','cancelled') then raise exception 'VALIDATION_ERROR'; end if;
  select * into v_activity from public.oj_activities where id=target_activity for update; if not found then raise exception 'NOT_FOUND'; end if;
  if v_activity.status<>'scheduled' or v_activity.starts_at<=now() then raise exception 'RSVP_CLOSED'; end if;
  if v_activity.rsvp_deadline is not null and v_activity.rsvp_deadline<now() then raise exception 'RSVP_CLOSED'; end if;
  if (v_activity.visibility<>'public' or v_activity.clan_only) and v_activity.clan_id is not null and not public.oj_is_clan_member(v_activity.clan_id) and v_activity.organizer_id<>auth.uid() then raise exception 'FORBIDDEN'; end if;
  if desired='going' then
    select count(*) into v_going from public.oj_activity_participants where activity_id=target_activity and rsvp_status='going';
    if v_going>=v_activity.max_participants then if not v_activity.waitlist_enabled then raise exception 'CAPACITY_FULL'; end if; v_status:='waitlist'; else v_status:='going'; end if;
  elsif desired='maybe' then v_status:='maybe'; else v_status:='cancelled'; end if;
  insert into public.oj_activity_participants(activity_id,profile_id,rsvp_status,cancelled_at) values(target_activity,auth.uid(),v_status,case when v_status='cancelled' then now() else null end)
  on conflict(activity_id,profile_id) do update set rsvp_status=excluded.rsvp_status,cancelled_at=excluded.cancelled_at;
  if v_status in('going','maybe','waitlist') then
    insert into public.oj_channel_members(channel_id,profile_id) select id,auth.uid() from public.oj_chat_channels where kind='activity' and activity_id=target_activity on conflict do nothing;
  else
    delete from public.oj_channel_members cm using public.oj_chat_channels c where cm.channel_id=c.id and cm.profile_id=auth.uid() and c.kind='activity' and c.activity_id=target_activity and v_activity.organizer_id<>auth.uid();
    select profile_id into v_promote from public.oj_activity_participants where activity_id=target_activity and rsvp_status='waitlist' order by joined_at asc limit 1 for update skip locked;
    if v_promote is not null then
      update public.oj_activity_participants set rsvp_status='going' where activity_id=target_activity and profile_id=v_promote;
      insert into public.oj_channel_members(channel_id,profile_id) select id,v_promote from public.oj_chat_channels where kind='activity' and activity_id=target_activity on conflict do nothing;
      insert into public.oj_notifications(profile_id,kind,title,body,href) values(v_promote,'waitlist_promoted','You’re in','A spot opened up and you moved off the waitlist.','/activities/'||target_activity::text);
    end if;
  end if;
  return v_status::text;
end $$;
revoke execute on function public.oj_rsvp_activity(uuid,text) from public,anon;
grant execute on function public.oj_rsvp_activity(uuid,text) to authenticated;

create index if not exists oj_chat_channels_clan_idx on public.oj_chat_channels(clan_id) where clan_id is not null;
create index if not exists oj_chat_channels_activity_idx on public.oj_chat_channels(activity_id) where activity_id is not null;
