import Link from "next/link";
import { Bell, CheckCircle2 } from "lucide-react";
import { AppHeader } from "@/components/app-header";
import { EmptyState } from "@/components/empty-state";
import { requireViewer } from "@/lib/auth";
import { unreadNotificationCount } from "@/lib/data";
import { markNotificationReadAction } from "@/lib/actions";
import { titleCase } from "@/lib/format";

export default async function NotificationsPage(){
 const {supabase,user}=await requireViewer(); const [{data:items},unread]=await Promise.all([supabase.from("oj_notifications").select("id,kind,title,body,href,read_at,created_at").eq("profile_id",user.id).order("created_at",{ascending:false}).limit(100),unreadNotificationCount(supabase,user.id)]);
 return <div className="page-wrap"><AppHeader title="Notifications" eyebrow="Only things that help you act" unread={unread}/>{items?.length?<div className="notification-list">{items.map(n=><article className={`notification-item ${n.read_at?"":"unread"}`} key={n.id}><div className="notification-icon">{n.read_at?<CheckCircle2/>:<Bell/>}</div><div><span className="section-kicker">{titleCase(n.kind)}</span><h3>{n.title}</h3><p>{n.body}</p><small>{new Date(n.created_at).toLocaleString("en-CA")}</small></div><form action={markNotificationReadAction}><input type="hidden" name="notification_id" value={n.id}/><input type="hidden" name="href" value={n.href||"/notifications"}/><button className="button button-small">{n.href?"Open":"Mark read"}</button></form></article>)}</div>:<EmptyState title="You’re caught up" body="Invites, waitlist promotions, upcoming activities and meaningful progress will show up here." href="/home" action="Back home"/>}<div className="quiet-note"><strong>Notification philosophy</strong><p>Ojoro should help you show up, not train you to stare at your phone. Low-value engagement notifications stay out.</p><Link href="/you">Manage your profile</Link></div></div>;
}
