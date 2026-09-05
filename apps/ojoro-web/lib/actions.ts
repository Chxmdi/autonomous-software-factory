"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { requireViewer } from "@/lib/auth";
import { activitySchema, challengeSchema, clanSchema, goalSchema, onboardingSchema } from "@/lib/schemas";

const encoded = (message: string) => encodeURIComponent(message.slice(0, 180));
function fail(path: string, message: string): never { redirect(`${path}${path.includes("?") ? "&" : "?"}error=${encoded(message)}`); }
function dbMessage(error: { message?: string } | null, fallback: string) {
  const raw = error?.message ?? "";
  if (raw.includes("CAPACITY_FULL")) return "That activity is full.";
  if (raw.includes("RSVP_CLOSED")) return "RSVPs are closed for this activity.";
  if (raw.includes("OWNER_TRANSFER_REQUIRED")) return "Transfer clan ownership before leaving.";
  if (raw.includes("FORBIDDEN")) return "You do not have permission to do that.";
  if (raw.includes("BLOCKED")) return "That interaction is not available.";
  return fallback;
}

export async function signOutAction() {
  const { supabase } = await requireViewer();
  await supabase.auth.signOut();
  redirect("/");
}

export async function completeOnboardingAction(formData: FormData) {
  const { supabase, user } = await requireViewer();
  const parsed = onboardingSchema.safeParse({
    fullName: formData.get("full_name"), username: formData.get("username"), city: formData.get("city"),
    sports: formData.getAll("sports").map(String), intents: formData.getAll("intents").map(String)
  });
  if (!parsed.success) fail("/onboarding", parsed.error.issues[0]?.message ?? "Check your profile details.");
  const v = parsed.data;
  const { error: profileError } = await supabase.from("oj_profiles").update({ full_name: v.fullName, username: v.username, city: v.city, onboarding_completed: true }).eq("id", user.id);
  if (profileError) fail("/onboarding", profileError.message.includes("duplicate") ? "That username is already taken." : "Could not save your profile.");
  await supabase.from("oj_user_sports").delete().eq("profile_id", user.id);
  const { error: sportsError } = await supabase.from("oj_user_sports").insert(v.sports.map(sport_slug => ({ profile_id: user.id, sport_slug, skill_level: "recreational" })));
  if (sportsError) fail("/onboarding", "Could not save your sports.");
  await supabase.from("oj_user_intents").delete().eq("profile_id", user.id);
  const { error: intentError } = await supabase.from("oj_user_intents").insert(v.intents.map(mode => ({ profile_id: user.id, mode })));
  if (intentError) fail("/onboarding", "Could not save how you want to use Ojoro.");
  redirect("/home");
}

export async function createActivityAction(formData: FormData) {
  const { supabase, user, profile } = await requireViewer();
  const parsed = activitySchema.safeParse({
    title: formData.get("title"), sport: formData.get("sport"), mode: formData.get("mode"), skill: formData.get("skill") || undefined,
    city: formData.get("city") || profile.city || "", location: formData.get("location"), startsAtIso: formData.get("starts_at_iso"), durationMinutes: formData.get("duration_minutes"),
    capacity: formData.get("capacity"), cost: formData.get("cost"), visibility: formData.get("visibility"), clanId: formData.get("clan_id") || "",
    description: formData.get("description") || "", equipment: formData.get("equipment") || "", urgent: formData.get("urgent") === "on"
  });
  if (!parsed.success) fail("/create?type=activity", parsed.error.issues[0]?.message ?? "Check the activity details.");
  const v = parsed.data; const starts = new Date(v.startsAtIso); const ends = new Date(starts.getTime() + v.durationMinutes * 60000);
  const { data, error } = await supabase.from("oj_activities").insert({
    organizer_id: user.id, clan_id: v.clanId || null, sport_slug: v.sport, title: v.title, description: v.description || null, mode: v.mode, skill_level: v.skill ?? null,
    location_name: v.location, city: v.city, starts_at: starts.toISOString(), ends_at: ends.toISOString(), max_participants: v.capacity,
    cost_cents: Math.round(v.cost * 100), visibility: v.visibility, clan_only: v.visibility === "members", urgent_spots: v.urgent
  }).select("id").single();
  if (error || !data) fail("/create?type=activity", dbMessage(error, "Could not create the activity."));
  redirect(`/activities/${data.id}?created=1`);
}

export async function rsvpActivityAction(formData: FormData) {
  const { supabase } = await requireViewer(); const id = String(formData.get("activity_id") ?? ""); const desired = String(formData.get("desired") ?? "");
  if (!/^[0-9a-f-]{36}$/i.test(id) || !["going","maybe","cancelled"].includes(desired)) fail("/discover", "Invalid RSVP request.");
  const { data, error } = await supabase.rpc("oj_rsvp_activity", { target_activity: id, desired });
  if (error) fail(`/activities/${id}`, dbMessage(error, "Could not update your RSVP."));
  revalidatePath(`/activities/${id}`); revalidatePath("/home");
  redirect(`/activities/${id}?rsvp=${encodeURIComponent(String(data))}`);
}

export async function createClanAction(formData: FormData) {
  const { supabase } = await requireViewer();
  const parsed = clanSchema.safeParse({ name: formData.get("name"), bio: formData.get("bio") || "", city: formData.get("city"), isPublic: formData.get("visibility") !== "private", sports: formData.getAll("sports").map(String) });
  if (!parsed.success) fail("/create?type=clan", parsed.error.issues[0]?.message ?? "Check the clan details.");
  const v = parsed.data;
  const { data, error } = await supabase.rpc("oj_create_clan", { clan_name: v.name, clan_bio: v.bio, clan_city: v.city, clan_public: v.isPublic, sport_slugs: v.sports });
  if (error || !data) fail("/create?type=clan", dbMessage(error, "Could not create the clan."));
  const { data: clan } = await supabase.from("oj_clans").select("slug").eq("id", data).single();
  redirect(clan?.slug ? `/clans/${clan.slug}?created=1` : "/home");
}

export async function joinClanAction(formData: FormData) {
  const { supabase } = await requireViewer(); const id = String(formData.get("clan_id") ?? ""); const slug = String(formData.get("slug") ?? "");
  const { data, error } = await supabase.rpc("oj_join_clan", { target_clan: id });
  if (error) fail(`/clans/${slug}`, dbMessage(error, "Could not join this clan."));
  revalidatePath(`/clans/${slug}`); redirect(`/clans/${slug}?membership=${encodeURIComponent(String(data))}`);
}

export async function createChallengeAction(formData: FormData) {
  const { supabase, user } = await requireViewer();
  const parsed = challengeSchema.safeParse({ title: formData.get("title"), description: formData.get("description") || "", metric: formData.get("metric"), target: formData.get("target"), reward: formData.get("reward"), scope: formData.get("scope"), days: formData.get("days") });
  if (!parsed.success) fail("/create?type=challenge", parsed.error.issues[0]?.message ?? "Check the challenge details.");
  const v = parsed.data; const starts = new Date(); const ends = new Date(starts.getTime() + v.days * 86400000);
  const { data, error } = await supabase.from("oj_challenges").insert({ creator_id: user.id, title: v.title, description: v.description || null, scope: v.scope, metric: v.metric, target_value: v.target, xp_reward: v.reward, starts_at: starts.toISOString(), ends_at: ends.toISOString(), status: "active" }).select("id").single();
  if (error || !data) fail("/create?type=challenge", "Could not create the challenge.");
  await supabase.rpc("oj_join_challenge", { target_challenge: data.id });
  redirect("/compete?created=challenge");
}

export async function joinChallengeAction(formData: FormData) {
  const { supabase } = await requireViewer(); const id = String(formData.get("challenge_id") ?? "");
  const { error } = await supabase.rpc("oj_join_challenge", { target_challenge: id });
  if (error) fail("/compete", "Could not join that challenge.");
  revalidatePath("/compete"); redirect("/compete?joined=1");
}

export async function saveGoalAction(formData: FormData) {
  const { supabase, user } = await requireViewer(); const parsed = goalSchema.safeParse({ title: formData.get("title"), metric: formData.get("metric"), target: formData.get("target") });
  if (!parsed.success) fail("/you", parsed.error.issues[0]?.message ?? "Check the goal details.");
  const { error } = await supabase.from("oj_goals").insert({ profile_id: user.id, title: parsed.data.title, metric: parsed.data.metric, target_value: parsed.data.target });
  if (error) fail("/you", "Could not save your goal."); revalidatePath("/you"); redirect("/you?goal=created");
}

export async function setStatusAction(formData: FormData) {
  const { supabase, user, profile } = await requireViewer(); const message = String(formData.get("message") ?? "").trim().slice(0,280); const sport = String(formData.get("sport") ?? "") || null;
  if (!message) fail("/home", "Add a short status first.");
  const expires = new Date(Date.now() + 12 * 60 * 60 * 1000);
  const { error } = await supabase.from("oj_statuses").insert({ profile_id: user.id, kind: "available", sport_slug: sport, city: profile.city, message, expires_at: expires.toISOString() });
  if (error) fail("/home", "Could not publish your status."); revalidatePath("/home"); redirect("/home?status=published");
}

export async function createPostAction(formData: FormData) {
  const { supabase, user } = await requireViewer(); const body = String(formData.get("body") ?? "").trim(); const clanId = String(formData.get("clan_id") ?? "") || null; const activityId = String(formData.get("activity_id") ?? "") || null;
  if (!body || body.length > 3000) fail("/home", "Post must be between 1 and 3,000 characters.");
  const { error } = await supabase.from("oj_posts").insert({ author_id: user.id, clan_id: clanId, activity_id: activityId, body, kind: "post" });
  if (error) fail("/home", "Could not publish the post."); revalidatePath("/home"); redirect("/home?post=published");
}

export async function sendMessageAction(formData: FormData) {
  const { supabase, user } = await requireViewer(); const channelId = String(formData.get("channel_id") ?? ""); const body = String(formData.get("body") ?? "").trim();
  if (!body || body.length > 4000) fail("/messages", "Message must be between 1 and 4,000 characters.");
  const { error } = await supabase.from("oj_messages").insert({ channel_id: channelId, sender_id: user.id, body });
  if (error) fail(`/messages?channel=${encoded(channelId)}`, dbMessage(error, "Could not send your message."));
  revalidatePath("/messages"); redirect(`/messages?channel=${encodeURIComponent(channelId)}`);
}

export async function markNotificationReadAction(formData: FormData) {
  const { supabase, user } = await requireViewer(); const id = String(formData.get("notification_id") ?? ""); const href = String(formData.get("href") ?? "/notifications");
  await supabase.from("oj_notifications").update({ read_at: new Date().toISOString() }).eq("id", id).eq("profile_id", user.id);
  revalidatePath("/notifications"); redirect(href.startsWith("/") ? href : "/notifications");
}

export async function reportEntityAction(formData: FormData) {
  const { supabase, user } = await requireViewer(); const kind = String(formData.get("entity_kind") ?? ""); const id = String(formData.get("entity_id") ?? ""); const reason = String(formData.get("reason") ?? "").trim(); const back = String(formData.get("back") ?? "/home");
  if (!reason || !["profile","clan","activity","post","message"].includes(kind)) fail(back, "Choose a valid report reason.");
  const { error } = await supabase.from("oj_reports").insert({ reporter_id: user.id, entity_kind: kind, entity_id: id, reason });
  if (error) fail(back, "Could not submit the report."); redirect(`${back}${back.includes("?") ? "&" : "?"}reported=1`);
}
