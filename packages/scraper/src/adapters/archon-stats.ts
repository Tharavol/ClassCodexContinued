const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36";

// Archon build pages are Next.js SSG: the exact props used to render the
// page are embedded as JSON in this script tag, so there's no DOM-scraping
// involved -- just parse it out and JSON.parse.
const NEXT_DATA_RE = /<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)<\/script>/;

// sources.lua only records the Mythic+ build URL. The Raid equivalent is the
// same URL with its zone-type/difficulty/encounter segments swapped --
// verified against a live page during planning (both return 200 with real,
// different stat data).
function deriveRaidUrl(mythicPlusUrl: string): string {
  return mythicPlusUrl.replace(
    "/mythic-plus/overview/high-keys/all-dungeons/",
    "/raid/overview/mythic/all-bosses/"
  );
}

// Archon's stat names -> the keys the existing Data/<Class>/archon-stats.lua
// files use. Primary stats (Strength/Agility/Intellect) aren't in this map
// on purpose: Archon lists them with value 0 (order 1, informational only,
// not a rating target) and the existing data never included them.
const STAT_KEY_MAP: Record<string, string> = {
  Crit: "crit",
  "Critical Strike": "crit",
  Haste: "haste",
  Mastery: "mastery",
  Vers: "versatility",
  Versatility: "versatility",
};

async function fetchStatsFromPage(url: string): Promise<Record<string, number> | null> {
  const res = await fetch(url, { headers: { "User-Agent": USER_AGENT } });
  if (!res.ok) throw new Error(`${url}: HTTP ${res.status}`);
  const html = await res.text();
  const match = html.match(NEXT_DATA_RE);
  if (!match) throw new Error(`${url}: __NEXT_DATA__ not found`);

  const data = JSON.parse(match[1]!);
  const sections = data?.props?.pageProps?.page?.sections;
  if (!Array.isArray(sections)) throw new Error(`${url}: unexpected __NEXT_DATA__ shape (no sections)`);

  const statsSection = sections.find((s: any) => s.component === "BuildsStatPrioritySection");
  if (!statsSection) return null;

  const targets: Record<string, number> = {};
  for (const stat of statsSection.props?.stats ?? []) {
    const key = STAT_KEY_MAP[stat.name];
    if (!key) continue;
    if (typeof stat.value === "number" && stat.value > 0) targets[key] = stat.value;
  }
  return Object.keys(targets).length > 0 ? targets : null;
}

export interface ArchonStatContexts {
  "Mythic+"?: Record<string, number>;
  Raid?: Record<string, number>;
}

export async function fetchArchonStats(mythicPlusUrl: string): Promise<ArchonStatContexts> {
  const result: ArchonStatContexts = {};

  const mythicPlus = await fetchStatsFromPage(mythicPlusUrl);
  if (mythicPlus) result["Mythic+"] = mythicPlus;

  const raid = await fetchStatsFromPage(deriveRaidUrl(mythicPlusUrl));
  if (raid) result["Raid"] = raid;

  return result;
}
