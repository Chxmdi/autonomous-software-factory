import Link from "next/link";
import { ArrowUpRight } from "lucide-react";

export function EmptyState({ title, body, href, action }: { title: string; body: string; href?: string; action?: string }) {
  return <div className="empty-state"><div className="empty-orbit"/><h3>{title}</h3><p>{body}</p>{href && action && <Link className="button button-dark" href={href}>{action}<ArrowUpRight size={16}/></Link>}</div>;
}

export function QueryNotice({ error, success }: { error?: string | null; success?: string | null }) {
  if (error) return <div className="form-error" role="alert">{error}</div>;
  if (success) return <div className="form-success">{success}</div>;
  return null;
}
