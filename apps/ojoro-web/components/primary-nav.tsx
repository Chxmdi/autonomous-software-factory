"use client";
import Link from "next/link";
import { Compass, Home, Plus, Trophy, UserRound } from "lucide-react";
import { usePathname } from "next/navigation";

const items = [
  { href: "/home", label: "Home", icon: Home },
  { href: "/discover", label: "Discover", icon: Compass },
  { href: "/create", label: "Create", icon: Plus, create: true },
  { href: "/compete", label: "Compete", icon: Trophy },
  { href: "/you", label: "You", icon: UserRound }
];
export function PrimaryNav() {
  const path = usePathname();
  return <nav className="primary-nav" aria-label="Ojoro"><div className="primary-nav-items">{items.map(({href,label,icon:Icon,create}) => {
    const active = path === href || path.startsWith(`${href}/`);
    return <Link key={href} href={href} className={`nav-item ${active ? "is-active" : ""} ${create ? "nav-create" : ""}`} aria-current={active ? "page" : undefined}><span className="nav-icon"><Icon size={21}/></span><span>{label}</span></Link>;
  })}</div></nav>;
}
