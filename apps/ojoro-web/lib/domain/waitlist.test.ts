import { describe, expect, it } from "vitest";
import { decideRsvp } from "./waitlist";

describe("waitlist decision", () => {
  it("joins when capacity exists", () => expect(decideRsvp("going", 13, 14)).toBe("going"));
  it("waitlists when full", () => expect(decideRsvp("going", 14, 14)).toBe("waitlist"));
  it("preserves maybe and cancelled", () => {
    expect(decideRsvp("maybe", 99, 1)).toBe("maybe");
    expect(decideRsvp("cancelled", 0, 1)).toBe("cancelled");
  });
});
