export type ScoreInputs = {
  attended90d: number;
  organized90d: number;
  challengesCompleted90d: number;
  distinctSports90d: number;
  activeWeeks12: number;
  noShows90d: number;
  communityContributions90d: number;
};

export function levelForXp(xp: number): number {
  if (!Number.isFinite(xp) || xp <= 0) return 1;
  return Math.max(1, Math.floor(Math.sqrt(xp / 250)) + 1);
}

export function reliabilityPercent(attended: number, lateCancels: number, noShows: number): number | null {
  const considered = attended + lateCancels + noShows;
  if (considered === 0) return null;
  const earned = attended + lateCancels * 0.35;
  return Math.max(0, Math.min(100, Math.round((earned / considered) * 100)));
}

export function ojoroScore(input: ScoreInputs): number {
  const participation = Math.min(260, input.attended90d * 16);
  const consistency = Math.min(220, input.activeWeeks12 * 22);
  const exploration = Math.min(130, input.distinctSports90d * 32);
  const contribution = Math.min(190, input.organized90d * 28 + input.communityContributions90d * 16);
  const challenges = Math.min(120, input.challengesCompleted90d * 30);
  const showUpGuardrail = Math.min(80, input.noShows90d * 22);
  return Math.max(0, Math.min(1000, Math.round(participation + consistency + exploration + contribution + challenges - showUpGuardrail)));
}

export function eloDelta(playerRating: number, opponentRating: number, score: 0 | 0.5 | 1, k = 24): number {
  const expected = 1 / (1 + Math.pow(10, (opponentRating - playerRating) / 400));
  return Math.round(k * (score - expected));
}
