"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { requireViewer } from "@/lib/auth";

function safeBack(raw: FormDataEntryValue | null){ const value=String(raw??"/people"); return value.startsWith("/")?value:"/people"; }

export async function followProfileAction(formData: FormData){
 const {supabase,user}=await requireViewer(); const target=String(formData.get("profile_id")??""); const back=safeBack(formData.get("back"));
 if(!target||target===user.id) redirect(back);
 const {error}=await supabase.from("oj_follows").upsert({follower_id:user.id,followed_id:target},{onConflict:"follower_id,followed_id"});
 if(error) redirect(`${back}?error=${encodeURIComponent("Could not follow that person.")}`); revalidatePath(back); redirect(`${back}?notice=${encodeURIComponent("Following updated.")}`);
}

export async function unfollowProfileAction(formData: FormData){
 const {supabase,user}=await requireViewer(); const target=String(formData.get("profile_id")??""); const back=safeBack(formData.get("back"));
 await supabase.from("oj_follows").delete().eq("follower_id",user.id).eq("followed_id",target); revalidatePath(back); redirect(`${back}?notice=${encodeURIComponent("Unfollowed.")}`);
}

export async function startDirectMessageAction(formData: FormData){
 const {supabase}=await requireViewer(); const target=String(formData.get("profile_id")??"");
 const {data,error}=await supabase.rpc("oj_get_or_create_direct_channel",{other_profile:target});
 if(error||!data) redirect(`/people?error=${encodeURIComponent("Could not start that conversation.")}`); redirect(`/messages?channel=${encodeURIComponent(String(data))}`);
}

export async function blockProfileAction(formData: FormData){
 const {supabase,user}=await requireViewer(); const target=String(formData.get("profile_id")??""); const back=safeBack(formData.get("back"));
 if(!target||target===user.id) redirect(back);
 await supabase.from("oj_blocks").upsert({blocker_id:user.id,blocked_id:target},{onConflict:"blocker_id,blocked_id"});
 await supabase.from("oj_follows").delete().or(`and(follower_id.eq.${user.id},followed_id.eq.${target}),and(follower_id.eq.${target},followed_id.eq.${user.id})`);
 revalidatePath(back); redirect(`${back}?notice=${encodeURIComponent("Person blocked.")}`);
}

export async function unblockProfileAction(formData: FormData){
 const {supabase,user}=await requireViewer(); const target=String(formData.get("profile_id")??""); const back=safeBack(formData.get("back"));
 await supabase.from("oj_blocks").delete().eq("blocker_id",user.id).eq("blocked_id",target); revalidatePath(back); redirect(`${back}?notice=${encodeURIComponent("Block removed.")}`);
}
