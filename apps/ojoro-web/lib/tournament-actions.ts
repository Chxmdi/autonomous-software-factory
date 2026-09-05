"use server";
import { redirect } from "next/navigation";
import { requireViewer } from "@/lib/auth";

export async function createTournamentAction(formData: FormData) {
  const {supabase,user,profile}=await requireViewer();
  const name=String(formData.get("name")??"").trim(); const sport=String(formData.get("sport")??""); const city=String(formData.get("city")??profile.city??"").trim(); const format=String(formData.get("format")??"round_robin");
  const startsIso=String(formData.get("starts_at_iso")??""); const days=Math.max(1,Math.min(90,Number(formData.get("days")??1))); const maxEntries=Math.max(2,Math.min(256,Number(formData.get("max_entries")??8)));
  if(name.length<3||name.length>120||!sport||!city||!startsIso||!["knockout","round_robin","group_knockout","league","ladder"].includes(format)) redirect(`/create?type=tournament&error=${encodeURIComponent("Check the tournament details.")}`);
  const starts=new Date(startsIso); if(Number.isNaN(starts.getTime())) redirect(`/create?type=tournament&error=${encodeURIComponent("Choose a valid start time.")}`); const ends=new Date(starts.getTime()+days*86400000);
  const {data,error}=await supabase.from("oj_tournaments").insert({creator_id:user.id,sport_slug:sport,name,city,format,starts_at:starts.toISOString(),ends_at:ends.toISOString(),max_entries:maxEntries,status:"registration"}).select("id").single();
  if(error||!data) redirect(`/create?type=tournament&error=${encodeURIComponent("Could not create the tournament.")}`);
  redirect(`/compete?tournament=${data.id}`);
}
