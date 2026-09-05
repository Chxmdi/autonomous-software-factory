"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { requireViewer } from "@/lib/auth";

function go(id: string, key: string, message: string): never {
  redirect(`/activities/${id}?${key}=${encodeURIComponent(message.slice(0, 180))}`);
}

function dbMessage(error: { message?: string } | null, fallback: string) {
  const raw = error?.message ?? "";
  if (raw.includes("FORBIDDEN")) return "You do not have permission to manage this activity.";
  if (raw.includes("NOT_COMPETITIVE")) return "This action is only available for competitive activities.";
  if (raw.includes("RESULT_LOCKED")) return "That verified result is locked. Create a dispute instead of overwriting it.";
  if (raw.includes("NOT_FOUND")) return "That participant or activity could not be found.";
  return fallback;
}

export async function recordAttendanceAction(formData: FormData) {
  const { supabase } = await requireViewer();
  const activityId = String(formData.get("activity_id") ?? "");
  const profileId = String(formData.get("profile_id") ?? "");
  const state = String(formData.get("attendance") ?? "");
  if (!activityId || !profileId || !["attended", "excused", "late_cancel", "no_show"].includes(state)) go(activityId || "unknown", "error", "Invalid attendance update.");
  const { error } = await supabase.rpc("oj_record_attendance", { target_activity: activityId, target_profile: profileId, new_state: state });
  if (error) go(activityId, "error", dbMessage(error, "Could not update attendance."));
  revalidatePath(`/activities/${activityId}`); revalidatePath("/you");
  go(activityId, "notice", "Attendance saved.");
}

export async function assignMatchSideAction(formData: FormData) {
  const { supabase } = await requireViewer();
  const activityId = String(formData.get("activity_id") ?? "");
  const profileId = String(formData.get("profile_id") ?? "");
  const side = String(formData.get("side") ?? "");
  const position = String(formData.get("position") ?? "").slice(0, 40);
  const { error } = await supabase.rpc("oj_assign_match_side", { target_activity: activityId, target_profile: profileId, new_side: side, new_position: position || null });
  if (error) go(activityId, "error", dbMessage(error, "Could not assign that player."));
  revalidatePath(`/activities/${activityId}`); go(activityId, "notice", "Lineup updated.");
}

export async function submitMatchResultAction(formData: FormData) {
  const { supabase } = await requireViewer();
  const activityId = String(formData.get("activity_id") ?? "");
  const homeName = String(formData.get("home_name") ?? "Home").trim().slice(0, 80);
  const awayName = String(formData.get("away_name") ?? "Away").trim().slice(0, 80);
  const homeScore = Number(formData.get("home_score"));
  const awayScore = Number(formData.get("away_score"));
  const mvp = String(formData.get("mvp_profile_id") ?? "") || null;
  if (!activityId || !homeName || !awayName || !Number.isInteger(homeScore) || homeScore < 0 || !Number.isInteger(awayScore) || awayScore < 0) go(activityId || "unknown", "error", "Check the result details.");
  const { error } = await supabase.rpc("oj_submit_match_result", { target_activity: activityId, home_label: homeName, away_label: awayName, home_points: homeScore, away_points: awayScore, mvp });
  if (error) go(activityId, "error", dbMessage(error, "Could not submit the result."));
  revalidatePath(`/activities/${activityId}`); revalidatePath("/compete");
  go(activityId, "notice", "Result submitted for participant confirmation.");
}

export async function confirmMatchResultAction(formData: FormData) {
  const { supabase } = await requireViewer();
  const activityId = String(formData.get("activity_id") ?? "");
  const resultId = String(formData.get("result_id") ?? "");
  const agrees = formData.get("agrees") === "true";
  const { data, error } = await supabase.rpc("oj_confirm_result", { target_result: resultId, agrees_with_result: agrees });
  if (error) go(activityId, "error", dbMessage(error, "Could not record your confirmation."));
  revalidatePath(`/activities/${activityId}`); revalidatePath("/compete");
  go(activityId, "notice", data === "verified" ? "Result verified. Competitive ratings were updated." : data === "disputed" ? "Result marked disputed." : "Your confirmation was recorded.");
}

export async function createActivityRecapAction(formData: FormData) {
  const { supabase, user } = await requireViewer();
  const activityId = String(formData.get("activity_id") ?? "");
  const body = String(formData.get("body") ?? "").trim().slice(0, 3000);
  if (!activityId || !body) go(activityId || "unknown", "error", "Add a recap before publishing.");
  const { data: activity } = await supabase.from("oj_activities").select("organizer_id,clan_id").eq("id", activityId).single();
  if (!activity || activity.organizer_id !== user.id) go(activityId, "error", "Only the organizer can publish the official recap.");
  const { error } = await supabase.from("oj_posts").insert({ author_id: user.id, clan_id: activity.clan_id, activity_id: activityId, kind: "recap", body });
  if (error) go(activityId, "error", "Could not publish the recap.");
  revalidatePath(`/activities/${activityId}`); revalidatePath("/home");
  go(activityId, "notice", "Afterglow recap published.");
}
