export type ActionResult<T = undefined> =
  | { ok: true; data?: T; message?: string }
  | { ok: false; code: string; message: string; fieldErrors?: Record<string, string[]> };

export const initialActionState: ActionResult = { ok: true };
