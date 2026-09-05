export type RsvpDecision = "going" | "waitlist" | "maybe" | "cancelled";

export function decideRsvp(desired: "going" | "maybe" | "cancelled", goingCount: number, capacity: number): RsvpDecision {
  if (desired !== "going") return desired;
  return goingCount >= capacity ? "waitlist" : "going";
}
