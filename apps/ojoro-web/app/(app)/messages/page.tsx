import Link from "next/link";
import { MessageCircle, Users } from "lucide-react";
import { AppHeader } from "@/components/app-header";
import { EmptyState } from "@/components/empty-state";
import { requireViewer } from "@/lib/auth";
import { messageSnapshot, unreadNotificationCount } from "@/lib/data";
import { sendMessageAction } from "@/lib/actions";
import { titleCase } from "@/lib/format";

export default async function MessagesPage({searchParams}:{searchParams:Promise<Record<string,string|string[]|undefined>>}){
 const q=await searchParams; const selected=typeof q.channel==="string"?q.channel:undefined; const {supabase,user}=await requireViewer(); const [snapshot,unread]=await Promise.all([messageSnapshot(supabase,user.id,selected),unreadNotificationCount(supabase,user.id)]);
 const channel=snapshot.channels.find((c:any)=>c.id===snapshot.selected);
 return <div className="page-wrap"><AppHeader title="Messages" eyebrow="Coordinate the real world" unread={unread} actions={<Link href="/people" className="button button-ghost desktop-action"><Users size={16}/>Find people</Link>}/>{snapshot.channels.length?<div className="messages-layout"><aside className="channel-list">{snapshot.channels.map((c:any)=><Link className={c.id===snapshot.selected?"active":""} href={`/messages?channel=${c.id}`} key={c.id}><MessageCircle size={17}/><div><strong>{c.name||titleCase(c.kind)}</strong><small>{titleCase(c.kind)}</small></div></Link>)}</aside><section className="chat-panel"><div className="chat-heading"><div><span className="section-kicker">{channel?titleCase(channel.kind):"Conversation"}</span><h2>{channel?.name||"Messages"}</h2></div></div><div className="message-stream">{snapshot.messages.length?snapshot.messages.map((m:any)=>{const author=snapshot.authors.get(m.sender_id);return <article className={`message-bubble ${m.sender_id===user.id?"mine":""}`} key={m.id}><strong>{m.sender_id===user.id?"You":author?.full_name||author?.username||"Member"}</strong><p>{m.deleted_at?"Message removed":m.body}</p><small>{new Date(m.created_at).toLocaleString("en-CA")}</small></article>}):<p className="muted">No messages yet. Start with the one thing people need to know to show up.</p>}</div>{snapshot.selected&&<form className="message-composer" action={sendMessageAction}><input type="hidden" name="channel_id" value={snapshot.selected}/><textarea name="body" maxLength={4000} required aria-label="Message" placeholder="Write a message…"/><button className="button button-primary">Send</button></form>}</section></div>:<EmptyState title="No conversations yet" body="Join a clan or activity, or find a person to start a direct conversation." href="/discover" action="Discover communities"/>}</div>;
}
