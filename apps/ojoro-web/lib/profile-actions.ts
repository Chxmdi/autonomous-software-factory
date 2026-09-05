"use server";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { requireViewer } from "@/lib/auth";

export async function setCompetitionQuietAction(formData: FormData) {
  const {supabase,user}=await requireViewer(); const enabled=formData.get("enabled")==="true";
  const {error}=await supabase.from("oj_profiles").update({competition_quiet:enabled}).eq("id",user.id);
  if(error) redirect(`/you?error=${encodeURIComponent("Could not update competition preference.")}`);
  revalidatePath("/compete"); revalidatePath("/you"); redirect(`/you?competition=${enabled?"quiet":"visible"}`);
}

export async function updateProfileAction(formData: FormData) {
  const {supabase,user}=await requireViewer();
  const fullName=String(formData.get("full_name")??"").trim().slice(0,100); const bio=String(formData.get("bio")??"").trim().slice(0,600); const city=String(formData.get("city")??"").trim().slice(0,100);
  if(fullName.length<2||city.length<2) redirect(`/you?error=${encodeURIComponent("Name and city are required.")}`);
  const {error}=await supabase.from("oj_profiles").update({full_name:fullName,bio:bio||null,city}).eq("id",user.id);
  if(error) redirect(`/you?error=${encodeURIComponent("Could not update your profile.")}`);
  revalidatePath("/you"); redirect("/you?saved=1");
}
