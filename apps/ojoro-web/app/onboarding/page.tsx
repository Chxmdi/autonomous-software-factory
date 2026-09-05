import { redirect } from "next/navigation";
import { requireViewer } from "@/lib/auth";
import { completeOnboardingAction } from "@/lib/actions";
import { sportEmoji } from "@/lib/format";

export default async function OnboardingPage({ searchParams }: { searchParams: Promise<Record<string,string|string[]|undefined>> }) {
  const { supabase, profile } = await requireViewer();
  if (profile.onboarding_completed) redirect("/home");
  const query = await searchParams; const error = typeof query.error === "string" ? query.error : null;
  const { data: sports } = await supabase.from("oj_sports").select("slug,name").eq("active",true).order("name");
  return <main className="onboarding-page"><div className="onboarding-card">
    <div className="eyebrow">60-second setup</div><h1>Make Ojoro yours.</h1><p>Choose enough for us to make the first screen useful. You can change everything later.</p>
    {error && <div className="form-error" role="alert">{error}</div>}
    <form action={completeOnboardingAction} className="form-stack">
      <div className="form-grid-2"><div className="field"><label htmlFor="full_name">Your name</label><input id="full_name" name="full_name" defaultValue={profile.full_name ?? ""} required/></div><div className="field"><label htmlFor="username">Username</label><input id="username" name="username" defaultValue={String(profile.username)} required pattern="[A-Za-z0-9_.-]{3,30}"/></div></div>
      <div className="field"><label htmlFor="city">City</label><input id="city" name="city" defaultValue={profile.city ?? "Montreal"} required/><small>We use your city for discovery. Your home address is never required.</small></div>
      <fieldset className="choice-field"><legend>What do you want to do?</legend><div className="choice-grid">{sports?.map(s => <label className="sport-choice" key={s.slug}><input type="checkbox" name="sports" value={s.slug}/><span>{sportEmoji(s.slug)}</span><strong>{s.name}</strong></label>)}</div></fieldset>
      <fieldset className="choice-field"><legend>What kind of experience do you want?</legend><div className="intent-grid">{[["social","Meet people"],["fitness","Stay active"],["competitive","Compete"],["learning","Learn something"]].map(([value,label]) => <label className="intent-choice" key={value}><input type="checkbox" name="intents" value={value}/><span><strong>{label}</strong><small>{value === "competitive" ? "Rankings when you want them." : value === "learning" ? "Beginner-friendly discovery." : value === "social" ? "People first, score optional." : "Consistency and progress."}</small></span></label>)}</div></fieldset>
      <button className="button button-brand button-lg" type="submit">Show me what I can do</button>
    </form>
  </div></main>;
}
