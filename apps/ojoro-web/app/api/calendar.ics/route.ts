import { NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";

function escapeIcs(value: string) {
  return value.replaceAll("\\", "\\\\").replaceAll("\n", "\\n").replaceAll(",", "\\,").replaceAll(";", "\\;");
}
function icsDate(value: string) {
  return new Date(value).toISOString().replace(/[-:]/g, "").replace(/\.\d{3}Z$/, "Z");
}

export async function GET() {
  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "Authentication required" }, { status: 401 });

  const { data: participation } = await supabase
    .from("oj_activity_participants")
    .select("activity_id,rsvp_status")
    .eq("profile_id", user.id)
    .in("rsvp_status", ["going", "maybe", "waitlist"]);
  const ids = (participation ?? []).map((row) => row.activity_id);
  let activities: Array<{id:string;title:string;description:string|null;location_name:string;city:string;starts_at:string;ends_at:string}> = [];
  if (ids.length) {
    const { data } = await supabase
      .from("oj_activities")
      .select("id,title,description,location_name,city,starts_at,ends_at")
      .in("id", ids)
      .gte("ends_at", new Date().toISOString())
      .order("starts_at")
      .limit(250);
    activities = data ?? [];
  }
  const state = new Map((participation ?? []).map((row) => [row.activity_id, row.rsvp_status]));
  const events = activities.map((activity) => [
    "BEGIN:VEVENT",
    `UID:${activity.id}@ojoro.app`,
    `DTSTAMP:${icsDate(new Date().toISOString())}`,
    `DTSTART:${icsDate(activity.starts_at)}`,
    `DTEND:${icsDate(activity.ends_at)}`,
    `SUMMARY:${escapeIcs(activity.title)}`,
    `LOCATION:${escapeIcs(`${activity.location_name}, ${activity.city}`)}`,
    `DESCRIPTION:${escapeIcs(`${activity.description ?? "Ojoro activity"}\nRSVP: ${state.get(activity.id) ?? "going"}`)}`,
    `URL:${escapeIcs(`/activities/${activity.id}`)}`,
    "END:VEVENT"
  ].join("\r\n")).join("\r\n");
  const body = ["BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//Ojoro//Movement Calendar//EN", "CALSCALE:GREGORIAN", "METHOD:PUBLISH", events, "END:VCALENDAR"].join("\r\n");
  return new NextResponse(body, {
    headers: {
      "Content-Type": "text/calendar; charset=utf-8",
      "Content-Disposition": "attachment; filename=ojoro-calendar.ics",
      "Cache-Control": "private, no-store"
    }
  });
}
