const sportIcons: Record<string, string> = {
  football: "⚽", basketball: "🏀", running: "🏃", strength: "🏋️", volleyball: "🏐",
  tennis: "🎾", badminton: "🏸", cycling: "🚴", swimming: "🏊", "martial-arts": "🥋",
  boxing: "🥊", hiking: "🥾", calisthenics: "🤸", dance: "💃", yoga: "🧘"
};

export function sportEmoji(slug: string) { return sportIcons[slug] ?? "⚡"; }
export function titleCase(value: string) { return value.replaceAll("_", " ").replaceAll("-", " ").replace(/\b\w/g, c => c.toUpperCase()); }
export function formatActivityTime(iso: string) {
  return new Intl.DateTimeFormat("en-CA", { weekday: "short", month: "short", day: "numeric", hour: "numeric", minute: "2-digit" }).format(new Date(iso));
}
export function startsIn(iso: string) {
  const ms = new Date(iso).getTime() - Date.now();
  if (ms <= 0) return "Started";
  const minutes = Math.round(ms / 60000);
  if (minutes < 60) return `Starts in ${minutes} min`;
  const hours = Math.round(minutes / 60);
  if (hours < 24) return `Starts in ${hours}h`;
  return formatActivityTime(iso);
}
export function percent(value: number, max: number) { return max <= 0 ? 0 : Math.max(0, Math.min(100, Math.round(value / max * 100))); }
