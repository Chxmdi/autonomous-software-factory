import type { SupabaseClient } from "@supabase/supabase-js";
import type { ActivitySummary } from "@/components/activity-card";
import type { ClanSummary } from "@/components/clan-card";

export async function hydrateActivities(supabase: SupabaseClient, rows: any[] | null | undefined, viewerId?: string): Promise<ActivitySummary[]> {
  const activities = rows ?? []; if (!activities.length) return [];
  const ids = activities.map(a => a.id);
  const { data: participation } = await supabase.from("oj_activity_participants").select("activity_id,profile_id,rsvp_status").in("activity_id", ids);
  const counts = new Map<string, number>(); const viewer = new Map<string,string>();
  for (const p of participation ?? []) {
    if (p.rsvp_status === "going") counts.set(p.activity_id, (counts.get(p.activity_id) ?? 0) + 1);
    if (viewerId && p.profile_id === viewerId) viewer.set(p.activity_id, p.rsvp_status);
  }
  return activities.map(a => ({ ...a, going_count: counts.get(a.id) ?? 0, viewer_rsvp: viewer.get(a.id) ?? null })) as ActivitySummary[];
}

export async function hydrateClans(supabase: SupabaseClient, rows: any[] | null | undefined): Promise<ClanSummary[]> {
  const clans = rows ?? []; if (!clans.length) return [];
  const ids = clans.map(c => c.id);
  const [{ data: members }, { data: sports }] = await Promise.all([
    supabase.from("oj_clan_members").select("clan_id,status").in("clan_id",ids).eq("status","active"),
    supabase.from("oj_clan_sports").select("clan_id,sport_slug").in("clan_id",ids)
  ]);
  const counts = new Map<string,number>(); const sportMap = new Map<string,string[]>();
  for (const m of members ?? []) counts.set(m.clan_id,(counts.get(m.clan_id) ?? 0)+1);
  for (const s of sports ?? []) sportMap.set(s.clan_id,[...(sportMap.get(s.clan_id) ?? []),s.sport_slug]);
  return clans.map(c => ({ ...c, member_count: counts.get(c.id) ?? 0, sports: sportMap.get(c.id) ?? [] })) as ClanSummary[];
}

export async function unreadNotificationCount(supabase: SupabaseClient, userId: string) {
  const { count } = await supabase.from("oj_notifications").select("id",{ count:"exact",head:true }).eq("profile_id",userId).is("read_at",null);
  return count ?? 0;
}

export async function homeSnapshot(supabase: SupabaseClient, userId: string, city: string | null) {
  const now = new Date().toISOString();
  const { data: ownParticipation } = await supabase.from("oj_activity_participants").select("activity_id,rsvp_status").eq("profile_id",userId).in("rsvp_status",["going","maybe","waitlist"]);
  const ownIds = (ownParticipation ?? []).map(p => p.activity_id);
  let upcomingRows: any[] = [];
  if (ownIds.length) {
    const { data } = await supabase.from("oj_activities").select("id,title,sport_slug,mode,skill_level,city,location_name,starts_at,max_participants,cost_cents,urgent_spots").in("id",ownIds).gte("starts_at",now).eq("status","scheduled").order("starts_at").limit(8);
    upcomingRows = data ?? [];
  }
  let suggestedQuery = supabase.from("oj_activities").select("id,title,sport_slug,mode,skill_level,city,location_name,starts_at,max_participants,cost_cents,urgent_spots").gte("starts_at",now).eq("status","scheduled").eq("visibility","public").order("urgent_spots",{ascending:false}).order("starts_at").limit(8);
  if (city) suggestedQuery = suggestedQuery.eq("city",city);
  const { data: suggestedRows } = await suggestedQuery;
  const { data: memberships } = await supabase.from("oj_clan_members").select("clan_id,role").eq("profile_id",userId).eq("status","active");
  const clanIds = (memberships ?? []).map(m => m.clan_id); let clanRows: any[] = [];
  if (clanIds.length) { const { data } = await supabase.from("oj_clans").select("id,slug,name,bio,city,level,lifetime_xp,verified_state").in("id",clanIds).limit(6); clanRows = data ?? []; }
  const [{ data: goals }, { data: feed }, { data: statuses }] = await Promise.all([
    supabase.from("oj_goals").select("id,title,metric,target_value,current_value,completed_at").eq("profile_id",userId).is("completed_at",null).order("created_at",{ascending:false}).limit(3),
    supabase.from("oj_posts").select("id,author_id,kind,body,created_at,clan_id,activity_id").order("created_at",{ascending:false}).limit(12),
    city ? supabase.from("oj_statuses").select("id,profile_id,sport_slug,message,expires_at").eq("city",city).gt("expires_at",now).order("created_at",{ascending:false}).limit(6) : Promise.resolve({data:[] as any[]}) as any
  ]);
  const authorIds = [...new Set([...(feed ?? []).map(p=>p.author_id),...(statuses ?? []).map(s=>s.profile_id)])]; let authors: any[]=[];
  if (authorIds.length) { const { data } = await supabase.from("oj_profiles").select("id,username,full_name,avatar_url").in("id",authorIds); authors=data??[]; }
  const authorMap = new Map(authors.map(a=>[a.id,a]));
  return {
    upcoming: await hydrateActivities(supabase,upcomingRows,userId), suggestions: await hydrateActivities(supabase,suggestedRows,userId), clans: await hydrateClans(supabase,clanRows), goals: goals ?? [],
    feed: (feed ?? []).map(p=>({...p,author:authorMap.get(p.author_id)??null})), statuses:(statuses ?? []).map(s=>({...s,profile:authorMap.get(s.profile_id)??null}))
  };
}

export async function discoverSnapshot(supabase: SupabaseClient, viewerId: string, filters: { city?: string; sport?: string; mode?: string; rightNow?: boolean; urgent?: boolean }) {
  const now = new Date(); const max = new Date(now.getTime() + 4*60*60*1000);
  let query = supabase.from("oj_activities").select("id,title,sport_slug,mode,skill_level,city,location_name,starts_at,max_participants,cost_cents,urgent_spots").eq("status","scheduled").eq("visibility","public").gte("starts_at",now.toISOString()).order("urgent_spots",{ascending:false}).order("starts_at").limit(30);
  if (filters.city) query=query.eq("city",filters.city); if (filters.sport) query=query.eq("sport_slug",filters.sport); if (filters.mode) query=query.eq("mode",filters.mode); if (filters.rightNow) query=query.lte("starts_at",max.toISOString()); if (filters.urgent) query=query.eq("urgent_spots",true);
  const { data: activityRows } = await query;
  let clanQuery = supabase.from("oj_clans").select("id,slug,name,bio,city,level,lifetime_xp,verified_state").eq("is_public",true).order("lifetime_xp",{ascending:false}).limit(20);
  if (filters.city) clanQuery=clanQuery.eq("city",filters.city);
  const { data: clanRows } = await clanQuery;
  return { activities:await hydrateActivities(supabase,activityRows,viewerId), clans:await hydrateClans(supabase,clanRows) };
}

export async function competeSnapshot(supabase: SupabaseClient, userId: string) {
  const now = new Date().toISOString();
  const [{data:sports},{data:challenges},{data:memberships},{data:seasons}] = await Promise.all([
    supabase.from("oj_user_sports").select("sport_slug").eq("profile_id",userId),
    supabase.from("oj_challenges").select("id,title,description,scope,metric,target_value,xp_reward,ends_at").eq("status","active").gte("ends_at",now).order("ends_at").limit(20),
    supabase.from("oj_challenge_members").select("challenge_id,progress,completed_at").eq("profile_id",userId),
    supabase.from("oj_seasons").select("id,name,sport_slug,starts_at,ends_at").eq("active",true).lte("starts_at",new Date().toISOString().slice(0,10)).gte("ends_at",new Date().toISOString().slice(0,10))
  ]);
  const primarySport = sports?.[0]?.sport_slug ?? null; let leaderboard:any[]=[];
  if (primarySport) { const {data}=await supabase.from("oj_sport_leaderboard").select("profile_id,username,full_name,avatar_url,rating,games_played,wins,draws,losses,season_id").eq("sport_slug",primarySport).order("rating",{ascending:false}).limit(25); leaderboard=data??[]; }
  const memberMap=new Map((memberships??[]).map(m=>[m.challenge_id,m]));
  return { primarySport, leaderboard, seasons:seasons??[], challenges:(challenges??[]).map(c=>({...c,membership:memberMap.get(c.id)??null})) };
}

export async function profileSnapshot(supabase: SupabaseClient, userId: string) {
  const [{data:sports},{data:goals},{data:passport},{data:reputation},{data:achievements},{data:ratings},{data:memberships}] = await Promise.all([
    supabase.from("oj_user_sports").select("sport_slug,skill_level,wants_to_learn").eq("profile_id",userId),
    supabase.from("oj_goals").select("id,title,metric,target_value,current_value,completed_at").eq("profile_id",userId).order("created_at",{ascending:false}).limit(10),
    supabase.from("oj_passport").select("sport_slug,first_played_at,activities").eq("profile_id",userId),
    supabase.from("oj_profile_reputation").select("considered_events,attended_events,late_cancels,no_shows,reliability_percent").eq("profile_id",userId).maybeSingle(),
    supabase.from("oj_user_achievements").select("achievement_slug,earned_at").eq("profile_id",userId).order("earned_at",{ascending:false}),
    supabase.from("oj_ratings").select("sport_slug,rating,games_played,wins,draws,losses").eq("profile_id",userId),
    supabase.from("oj_clan_members").select("clan_id,role").eq("profile_id",userId).eq("status","active")
  ]);
  return {sports:sports??[],goals:goals??[],passport:passport??[],reputation,achievements:achievements??[],ratings:ratings??[],memberships:memberships??[]};
}

export async function messageSnapshot(supabase: SupabaseClient, userId: string, selected?: string) {
  const {data:memberRows}=await supabase.from("oj_channel_members").select("channel_id,last_read_at").eq("profile_id",userId);
  const ids=(memberRows??[]).map(m=>m.channel_id); if(!ids.length) return {channels:[],messages:[],selected:null,authors:new Map<string,any>()};
  const {data:channels}=await supabase.from("oj_chat_channels").select("id,kind,name,clan_id,team_id,activity_id,created_at").in("id",ids).order("created_at",{ascending:false});
  const selectedId=selected&&ids.includes(selected)?selected:channels?.[0]?.id??null; let messages:any[]=[]; let authors:any[]=[];
  if(selectedId){const {data}=await supabase.from("oj_messages").select("id,sender_id,body,created_at,deleted_at").eq("channel_id",selectedId).order("created_at").limit(100);messages=data??[];const authorIds=[...new Set(messages.map(m=>m.sender_id))];if(authorIds.length){const {data:a}=await supabase.from("oj_profiles").select("id,username,full_name").in("id",authorIds);authors=a??[];}}
  return {channels:channels??[],messages,selected:selectedId,authors:new Map(authors.map(a=>[a.id,a]))};
}
