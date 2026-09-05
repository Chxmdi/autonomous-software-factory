import { redirect } from "next/navigation";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function requireViewer() {
  const supabase = await createSupabaseServerClient();
  const { data: { user }, error } = await supabase.auth.getUser();
  if (error || !user) redirect("/login");

  const { data: profile } = await supabase
    .from("oj_profiles")
    .select("id,username,full_name,avatar_url,bio,city,timezone,profile_visibility,competition_quiet,onboarding_completed,lifetime_xp,level,verified_organizer")
    .eq("id", user.id)
    .maybeSingle();

  if (!profile) {
    await supabase.from("oj_profiles").insert({ id: user.id, username: `user_${user.id.slice(0, 8)}`, full_name: user.user_metadata?.full_name ?? null });
    const { data: created } = await supabase.from("oj_profiles").select("*").eq("id", user.id).single();
    if (!created) throw new Error("Unable to initialize Ojoro profile.");
    return { supabase, user, profile: created };
  }
  return { supabase, user, profile };
}
