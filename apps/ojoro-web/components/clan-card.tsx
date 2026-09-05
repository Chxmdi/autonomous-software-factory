import Link from "next/link";
import { MapPin, ShieldCheck, Users } from "lucide-react";

export type ClanSummary = { id: string; slug: string; name: string; bio: string | null; city: string; level: number; lifetime_xp: number; verified_state: string; member_count: number; sports?: string[] };

export function ClanCard({ clan }: { clan: ClanSummary }) {
  return <Link href={`/clans/${clan.slug}`} className="clan-card"><div className="clan-badge">{clan.name.slice(0,2).toUpperCase()}</div><div className="clan-card-copy"><div className="clan-name-line"><h3>{clan.name}</h3>{clan.verified_state === "verified" && <ShieldCheck size={17} aria-label="Verified clan"/>}</div><p>{clan.bio || "A community built around showing up and moving together."}</p><div className="clan-meta"><span><MapPin size={14}/>{clan.city}</span><span><Users size={14}/>{clan.member_count} members</span><span>Level {clan.level}</span></div>{clan.sports?.length ? <div className="pill-row">{clan.sports.slice(0,4).map(s => <span className="soft-pill" key={s}>{s.replaceAll("-"," ")}</span>)}</div> : null}</div></Link>;
}
