import { z } from "zod";

export const loginSchema = z.object({ email: z.string().email(), password: z.string().min(8).max(128) });
export const onboardingSchema = z.object({
  fullName: z.string().trim().min(2).max(100),
  username: z.string().trim().regex(/^[a-zA-Z0-9_.-]{3,30}$/),
  city: z.string().trim().min(2).max(100),
  sports: z.array(z.string()).min(1).max(12),
  intents: z.array(z.enum(["social","fitness","competitive","learning"])).min(1)
});
export const activitySchema = z.object({
  title: z.string().trim().min(3).max(120), sport: z.string().min(1), mode: z.enum(["social","fitness","competitive","learning"]),
  skill: z.enum(["beginner","recreational","intermediate","competitive","elite"]).optional(), city: z.string().trim().min(2).max(100),
  location: z.string().trim().min(2).max(160), startsAtIso: z.string().datetime(), durationMinutes: z.coerce.number().int().min(15).max(1440),
  capacity: z.coerce.number().int().min(1).max(10000), cost: z.coerce.number().min(0).max(100000), visibility: z.enum(["public","members","private"]),
  clanId: z.string().uuid().optional().or(z.literal("")), description: z.string().trim().max(2000).optional(), equipment: z.string().trim().max(600).optional(), urgent: z.boolean().default(false)
});
export const clanSchema = z.object({
  name: z.string().trim().min(2).max(80), bio: z.string().trim().max(1000).default(""), city: z.string().trim().min(2).max(100),
  isPublic: z.boolean(), sports: z.array(z.string()).min(1).max(20)
});
export const challengeSchema = z.object({
  title: z.string().trim().min(3).max(120), description: z.string().trim().max(1200).default(""), metric: z.string().trim().min(2).max(80),
  target: z.coerce.number().positive().max(1000000), reward: z.coerce.number().int().min(0).max(5000), scope: z.enum(["personal","friends","clan","city","global"]), days: z.coerce.number().int().min(1).max(365)
});
export const goalSchema = z.object({ title: z.string().trim().min(2).max(120), metric: z.string().trim().min(2).max(80), target: z.coerce.number().positive().max(1000000) });
