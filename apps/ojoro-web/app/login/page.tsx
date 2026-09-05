import Link from "next/link";
import { redirect } from "next/navigation";
import { Wordmark } from "@/components/wordmark";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { authAction } from "./actions";

export default async function LoginPage({ searchParams }: { searchParams: Promise<Record<string,string|string[]|undefined>> }) {
  const query = await searchParams; const mode = query.mode === "signup" ? "signup" : "signin"; const error = typeof query.error === "string" ? query.error : null; const notice = typeof query.notice === "string" ? query.notice : null;
  const supabase = await createSupabaseServerClient(); const { data: { user } } = await supabase.auth.getUser(); if (user) redirect("/home");
  return <main className="auth-page">
    <section className="auth-art"><Wordmark href="/"/><div className="auth-quote">Your next good story probably starts outside.</div><p>Find the people. Make the plan. Show up.</p></section>
    <section className="auth-form-shell"><div className="auth-card">
      <div className="eyebrow">{mode === "signup" ? "Create your Ojoro identity" : "Welcome back"}</div>
      <h1>{mode === "signup" ? "Get moving." : "Good to see you."}</h1>
      <p>{mode === "signup" ? "Your sports résumé starts with the first thing you show up for." : "See what your people are doing next."}</p>
      {error && <div className="form-error" role="alert">{error}</div>}{notice && <div className="form-success">{notice}</div>}
      <form action={authAction} className="form-stack"><input type="hidden" name="mode" value={mode}/>
        {mode === "signup" && <div className="field"><label htmlFor="full_name">Name</label><input id="full_name" name="full_name" autoComplete="name" required maxLength={100}/></div>}
        <div className="field"><label htmlFor="email">Email</label><input id="email" name="email" type="email" autoComplete="email" required/></div>
        <div className="field"><label htmlFor="password">Password</label><input id="password" name="password" type="password" autoComplete={mode === "signup" ? "new-password" : "current-password"} required minLength={8}/></div>
        <button className="button button-brand button-lg button-full" type="submit">{mode === "signup" ? "Join Ojoro" : "Sign in"}</button>
      </form>
      <p className="auth-switch">{mode === "signup" ? <>Already in? <Link href="/login">Sign in</Link></> : <>New here? <Link href="/login?mode=signup">Create your account</Link></>}</p>
    </div></section>
  </main>;
}
