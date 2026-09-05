"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { requireViewer } from "@/lib/auth";

function back(slug: string, key: string, message: string): never { redirect(`/clans/${slug}?${key}=${encodeURIComponent(message.slice(0,180))}`); }
function dbMessage(error: { message?: string } | null, fallback: string) {
  const raw=error?.message??"";
  if(raw.includes("FORBIDDEN")) return "Your clan role does not allow that action.";
  if(raw.includes("NOT_CLAN_MEMBER")) return "That person must join the clan before joining a team.";
  if(raw.includes("OWNER_ROLE_LOCKED")) return "The founder role cannot be changed here.";
  return fallback;
}

export async function leaveClanAction(formData: FormData){
  const {supabase}=await requireViewer(); const id=String(formData.get("clan_id")??""); const slug=String(formData.get("slug")??"");
  const {error}=await supabase.rpc("oj_leave_clan",{target_clan:id}); if(error) back(slug,"error",dbMessage(error,"Could not leave the clan."));
  revalidatePath(`/clans/${slug}`); redirect("/home?left=clan");
}

export async function reviewClanRequestAction(formData: FormData){
  const {supabase}=await requireViewer(); const id=String(formData.get("clan_id")??""); const slug=String(formData.get("slug")??""); const profile=String(formData.get("profile_id")??""); const approve=formData.get("decision")==="approve";
  const {error}=await supabase.rpc("oj_review_clan_request",{target_clan:id,target_profile:profile,approve}); if(error) back(slug,"error",dbMessage(error,"Could not review that request."));
  revalidatePath(`/clans/${slug}`); back(slug,"notice",approve?"Member approved.":"Request declined.");
}

export async function setClanRoleAction(formData: FormData){
  const {supabase}=await requireViewer(); const id=String(formData.get("clan_id")??""); const slug=String(formData.get("slug")??""); const profile=String(formData.get("profile_id")??""); const role=String(formData.get("role")??"");
  const {error}=await supabase.rpc("oj_set_clan_role",{target_clan:id,target_profile:profile,new_role:role}); if(error) back(slug,"error",dbMessage(error,"Could not change that role."));
  revalidatePath(`/clans/${slug}`); back(slug,"notice","Role updated.");
}

export async function createTeamAction(formData: FormData){
  const {supabase}=await requireViewer(); const clan=String(formData.get("clan_id")??""); const slug=String(formData.get("slug")??""); const sport=String(formData.get("sport")??""); const name=String(formData.get("name")??"").trim(); const description=String(formData.get("description")??"").trim().slice(0,500);
  if(name.length<2||name.length>80||!sport) back(slug,"error","Check the team details.");
  const {error}=await supabase.rpc("oj_create_team",{target_clan:clan,target_sport:sport,team_name:name,team_description:description||null}); if(error) back(slug,"error",dbMessage(error,"Could not create that team."));
  revalidatePath(`/clans/${slug}`); back(slug,"notice","Team created.");
}

export async function addTeamMemberAction(formData: FormData){
  const {supabase}=await requireViewer(); const team=String(formData.get("team_id")??""); const slug=String(formData.get("slug")??""); const profile=String(formData.get("profile_id")??"");
  const {error}=await supabase.rpc("oj_add_team_member",{target_team:team,target_profile:profile}); if(error) back(slug,"error",dbMessage(error,"Could not add that member to the team."));
  revalidatePath(`/clans/${slug}`); back(slug,"notice","Team roster updated.");
}
