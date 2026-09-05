"use server";
import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { loginSchema } from "@/lib/schemas";

const withError = (mode: string, message: string) => `/login?mode=${mode}&error=${encodeURIComponent(message.slice(0,180))}`;

async function applicationOrigin() {
  if (process.env.NEXT_PUBLIC_APP_URL) return process.env.NEXT_PUBLIC_APP_URL.replace(/\/$/, "");
  const requestHeaders = await headers();
  const host = requestHeaders.get("x-forwarded-host") ?? requestHeaders.get("host");
  if (!host) return "http://localhost:3000";
  const protocol = requestHeaders.get("x-forwarded-proto") ?? (host.startsWith("localhost") ? "http" : "https");
  return `${protocol}://${host}`;
}

export async function authAction(formData: FormData) {
  const mode = formData.get("mode") === "signup" ? "signup" : "signin";
  const parsed = loginSchema.safeParse({ email: formData.get("email"), password: formData.get("password") });
  if (!parsed.success) redirect(withError(mode, parsed.error.issues[0]?.message ?? "Check your email and password."));
  const supabase = await createSupabaseServerClient();
  if (mode === "signup") {
    const fullName = String(formData.get("full_name") ?? "").trim().slice(0,100);
    const appUrl = await applicationOrigin();
    const { data, error } = await supabase.auth.signUp({ email: parsed.data.email, password: parsed.data.password, options: { data: { full_name: fullName }, emailRedirectTo: `${appUrl}/auth/callback` } });
    if (error) redirect(withError(mode, error.message));
    if (!data.session) redirect(`/login?mode=signin&notice=${encodeURIComponent("Check your email to confirm your account, then sign in.")}`);
    redirect("/onboarding");
  }
  const { error } = await supabase.auth.signInWithPassword(parsed.data);
  if (error) redirect(withError(mode, "Email or password is incorrect."));
  redirect("/home");
}
