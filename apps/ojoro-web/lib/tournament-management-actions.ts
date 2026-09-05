"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { requireViewer } from "@/lib/auth";

function back(id:string,key:string,message:string):never{redirect(`/tournaments/${id}?${key}=${encodeURIComponent(message.slice(0,180))}`);}

export async function registerTournamentTeamAction(formData:FormData){
 const {supabase,user}=await requireViewer(); const id=String(formData.get("tournament_id")??""); const team=String(formData.get("team_id")??"")||null; const clan=String(formData.get("clan_id")??"")||null; const label=String(formData.get("label")??"").trim().slice(0,80);
 if(!id||(!team&&!clan&&!label)) back(id||"unknown","error","Choose a team, clan or entry name.");
 const {error}=await supabase.from("oj_tournament_entries").insert({tournament_id:id,team_id:team,clan_id:clan,label:label||null,registered_by:user.id,status:"registered"});
 if(error) back(id,"error","Could not register that entry. Registration may be closed or the entry already exists."); revalidatePath(`/tournaments/${id}`); back(id,"notice","Tournament entry registered.");
}

export async function updateTournamentStatusAction(formData:FormData){
 const {supabase,user}=await requireViewer(); const id=String(formData.get("tournament_id")??""); const status=String(formData.get("status")??"");
 if(!["registration","active","completed","cancelled"].includes(status)) back(id,"error","Invalid tournament state.");
 const {data:t}=await supabase.from("oj_tournaments").select("creator_id").eq("id",id).single(); if(!t||t.creator_id!==user.id) back(id,"error","Only the tournament creator can change its status.");
 const {error}=await supabase.from("oj_tournaments").update({status}).eq("id",id).eq("creator_id",user.id); if(error) back(id,"error","Could not update tournament status."); revalidatePath(`/tournaments/${id}`); back(id,"notice","Tournament status updated.");
}
