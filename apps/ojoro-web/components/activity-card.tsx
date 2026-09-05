import Link from "next/link";
import { MapPin, Users } from "lucide-react";
import { formatActivityTime, sportEmoji, startsIn, titleCase } from "@/lib/format";

export type ActivitySummary = {
  id: string; title: string; sport_slug: string; mode: string; skill_level: string | null; city: string; location_name: string;
  starts_at: string; max_participants: number; cost_cents: number; urgent_spots: boolean; going_count: number; viewer_rsvp?: string | null;
};

export function ActivityCard({ activity, compact = false }: { activity: ActivitySummary; compact?: boolean }) {
  const spots = Math.max(0, activity.max_participants - activity.going_count);
  return <Link href={`/activities/${activity.id}`} className={`activity-card ${compact ? "is-compact" : ""}`}>
    <div className="activity-card-top"><span className="activity-sport-icon">{sportEmoji(activity.sport_slug)}</span><div className="activity-time"><strong>{startsIn(activity.starts_at)}</strong><small>{formatActivityTime(activity.starts_at)}</small></div>{activity.urgent_spots && <span className="rescue-pill">Needs players</span>}</div>
    <div className="activity-card-body"><h3>{activity.title}</h3><div className="pill-row"><span className="soft-pill">{titleCase(activity.mode)}</span>{activity.skill_level && <span className="soft-pill">{titleCase(activity.skill_level)}</span>}{activity.viewer_rsvp && activity.viewer_rsvp !== "cancelled" && <span className="soft-pill is-strong">{titleCase(activity.viewer_rsvp)}</span>}</div></div>
    <div className="activity-card-meta"><span><MapPin size={15}/>{activity.location_name}, {activity.city}</span><span><Users size={15}/>{spots > 0 ? `${spots} spot${spots === 1 ? "" : "s"} left` : "Full"}</span>{activity.cost_cents > 0 ? <span>${(activity.cost_cents/100).toFixed(0)}</span> : <span>Free</span>}</div>
  </Link>;
}
