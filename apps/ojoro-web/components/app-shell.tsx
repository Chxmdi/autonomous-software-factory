import Link from "next/link";
import { LogOut, MessageCircle } from "lucide-react";
import { PrimaryNav } from "@/components/primary-nav";
import { Wordmark } from "@/components/wordmark";
import { signOutAction } from "@/lib/actions";

export function AppShell({ children, profile }: { children: React.ReactNode; profile: { username: string; full_name: string | null; avatar_url: string | null; level: number } }) {
  const initial = (profile.full_name?.[0] ?? String(profile.username)[0] ?? "O").toUpperCase();
  return <div className="app-shell"><aside className="desktop-rail"><Wordmark href="/home"/><PrimaryNav/><div className="rail-spacer"/><Link href="/messages" className="rail-utility"><MessageCircle size={18}/> Messages</Link><div className="rail-profile"><div className="avatar avatar-sm">{initial}</div><div><strong>{profile.full_name ?? profile.username}</strong><small>Level {profile.level}</small></div><form action={signOutAction}><button type="submit" className="icon-bare" aria-label="Sign out"><LogOut size={17}/></button></form></div></aside><main className="app-content">{children}</main><div className="mobile-nav-wrap"><PrimaryNav/></div></div>;
}
