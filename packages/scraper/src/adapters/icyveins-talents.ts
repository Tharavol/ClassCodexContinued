import * as cheerio from "cheerio";
import type { TalentBuild } from "../types.js";

// Plain fetch with no UA gets served a different (thinner) page by some WoW
// fan sites; a real browser UA has been enough for Icy Veins in testing.
const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36";

// Icy Veins wraps some titles across a line break in the markup (e.g.
// "Arcane Raid -<br>Sunfury"), which cheerio's .text() turns into a literal
// embedded newline. Collapse all whitespace runs to a single space so that
// never ends up inside a single-line Lua string.
function cleanText(s: string): string {
  return s.replace(/\s+/g, " ").trim();
}

/**
 * Classifies a build's raw title into the coarse `context` buckets the
 * existing Data/<Class>/talents-icyveins.lua files use. This is a heuristic,
 * not a real parse -- Icy Veins doesn't use consistent title vocabulary
 * across specs (compare Death Knight's "Blood Single Target - San'layn" to
 * Mage's "Frost Light Cleave/Raid"). Getting a spec's context wrong here
 * shows up as a readable diff in the review PR, not a silent bad ship.
 */
function classifyContext(title: string): { context: string; leveling?: true } {
  // Normalize hyphens/underscores to spaces so "Single-Target" and
  // "Single Target" match the same keyword checks below.
  const t = title.toLowerCase().replace(/[-_]/g, " ");
  if (t.includes("leveling")) return { context: "Leveling", leveling: true };
  if (t.includes("mythic+") || t.includes("m+") || t.includes("delve")) return { context: "Mythic+" };
  if (t.includes("aoe")) return { context: "AoE" };
  if (t.includes("raid") || t.includes("single target") || t.includes("cleave")) return { context: "Raid" };
  return { context: "General" };
}

/**
 * Per your instruction: if a spec has no build that classified as Leveling,
 * fall back to its Delves build (if any) for the leveling slot rather than
 * shipping without one -- but mark it clearly as a substitute rather than
 * pretending it's a real leveling build.
 */
function withLevelingFallback(builds: TalentBuild[]): TalentBuild[] {
  if (builds.some((b) => b.leveling)) return builds;
  const delves = builds.find((b) => /delves?/i.test(b.buildLabel));
  if (!delves) return builds;
  return [
    ...builds,
    {
      context: "Leveling",
      buildLabel: `${delves.buildLabel} (used as Leveling substitute)`,
      exportString: delves.exportString,
      leveling: true,
      note: "No Leveling build published on Icy Veins as of this scrape -- substituting the Delves build.",
    },
  ];
}

export async function fetchIcyVeinsTalents(url: string): Promise<TalentBuild[]> {
  const res = await fetch(url, { headers: { "User-Agent": USER_AGENT } });
  if (!res.ok) throw new Error(`${url}: HTTP ${res.status}`);
  const html = await res.text();
  const $ = cheerio.load(html);

  const builds: TalentBuild[] = [];
  $(".export-string-wrapper").each((_, el) => {
    const title = cleanText($(el).find(".export-string__title").first().text());
    const exportString = cleanText($(el).find(".export-string__code").first().text());
    if (!title || !exportString) return;
    const { context, leveling } = classifyContext(title);
    builds.push({ context, buildLabel: title, exportString, leveling });
  });

  return withLevelingFallback(builds);
}
