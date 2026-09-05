import { redirect } from "next/navigation";
import { AppShell } from "@/components/app-shell";
import { requireViewer } from "@/lib/auth";

export default async function AuthenticatedLayout({ children }: { children: React.ReactNode }) {
  const { profile } = await requireViewer();
  if (!profile.onboarding_completed) redirect("/onboarding");
  return <AppShell profile={profile}>{children}</AppShell>;
}
