import { describe, expect, it } from "vitest";
import { eloDelta, levelForXp, ojoroScore, reliabilityPercent } from "./scoring";

describe("progression rules", () => {
  it("never returns a level below one", () => expect(levelForXp(-100)).toBe(1));
  it("level increases with lifetime xp", () => expect(levelForXp(10000)).toBeGreaterThan(levelForXp(1000)));
  it("keeps Ojoro Score in the 0-1000 range", () => {
    expect(ojoroScore({ attended90d: 999, organized90d: 999, challengesCompleted90d: 999, distinctSports90d: 99, activeWeeks12: 99, noShows90d: 0, communityContributions90d: 999 })).toBe(920);
    expect(ojoroScore({ attended90d: 0, organized90d: 0, challengesCompleted90d: 0, distinctSports90d: 0, activeWeeks12: 0, noShows90d: 99, communityContributions90d: 0 })).toBe(0);
  });
  it("treats no activity history as unknown reliability", () => expect(reliabilityPercent(0, 0, 0)).toBeNull());
  it("penalizes no-shows more than late cancellations", () => expect(reliabilityPercent(8, 2, 0)).toBeGreaterThan(reliabilityPercent(8, 0, 2)!));
  it("rewards an upset more than an expected win", () => expect(eloDelta(1200, 1500, 1)).toBeGreaterThan(eloDelta(1500, 1200, 1)));
});
