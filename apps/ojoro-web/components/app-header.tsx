import Link from "next/link";
import { Bell, MessageCircle } from "lucide-react";

export function AppHeader({ title, eyebrow, unread = 0, actions }: { title: string; eyebrow?: string; unread?: number; actions?: React.ReactNode }) {
  return <header className="app-header"><div><div className="page-eyebrow">{eyebrow}</div><h1>{title}</h1></div><div className="app-header-actions">{actions}<Link className="icon-control" href="/messages" aria-label="Messages"><MessageCircle size={20}/></Link><Link className="icon-control notification-control" href="/notifications" aria-label={`${unread} unread notifications`}><Bell size={20}/>{unread > 0 && <span>{Math.min(unread,99)}</span>}</Link></div></header>;
}
