const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36";

const NEXT_DATA_RE = /<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)<\/script>/;

// Matches archon-stats.ts: sources.lua only records the Mythic+ URL, and the
// Raid equivalent is always the Mythic difficulty page (no Heroic/Mythic
// split for gear -- the existing Data/<Class>/gear-archon.lua files never
// had one either).
function deriveRaidUrl(mythicPlusUrl: string): string {
  return mythicPlusUrl.replace(
    "/mythic-plus/overview/high-keys/all-dungeons/",
    "/raid/overview/mythic/all-bosses/"
  );
}

export interface ArchonGearSlot {
  item: { itemId: number; name: string };
  bis: boolean;
}

export interface ArchonGearLoadout {
  label: "Mythic+" | "Raid";
  slots: ArchonGearSlot[];
}

// Archon embeds each gear entry's item as a stringified pseudo-JSX call. Most
// are plain: `<GearIcon id={249970} icon='...' ...>Relentless Rider's Crown</GearIcon>`.
// Items Wowhead's separate BiS guide also confirms get wrapped instead:
// `<GearIcon ...><a ...><Tooltip ...><BadgeLabel>BiS</BadgeLabel></Tooltip></a>
// <span>&nbsp;Spellbreaker's Bracers</span></GearIcon>` -- the badge is the
// real "is this BiS" signal (matches the page's own "Best in Slot data
// provided by Wowhead's ... guide" description), not just "Archon's top pick
// for this slot" (every entry here is that, badge or not).
const ITEM_ID_RE = /id=\{(\d+)\}/;
const BIS_BADGE_RE = /<BadgeLabel>BiS<\/BadgeLabel>/;

// The item name is whatever text sits in the last non-empty ">text<" segment
// of the icon string -- directly inside <GearIcon> for the plain case, or
// inside the trailing <span> for the badge-wrapped case.
function extractName(icon: string): string | null {
  const segments = [...icon.matchAll(/>([^<]*)</g)]
    .map((m) => m[1]!)
    .filter((s) => s.trim().length > 0);
  if (segments.length === 0) return null;
  return segments[segments.length - 1]!.replace(/&nbsp;/g, " ").trim();
}

async function fetchGearFromPage(url: string): Promise<ArchonGearSlot[] | null> {
  const res = await fetch(url, { headers: { "User-Agent": USER_AGENT } });
  if (!res.ok) throw new Error(`${url}: HTTP ${res.status}`);
  const html = await res.text();
  const match = html.match(NEXT_DATA_RE);
  if (!match) throw new Error(`${url}: __NEXT_DATA__ not found`);

  const data = JSON.parse(match[1]!);
  const sections = data?.props?.pageProps?.page?.sections;
  if (!Array.isArray(sections)) throw new Error(`${url}: unexpected __NEXT_DATA__ shape (no sections)`);

  const gearSection = sections.find((s: any) => s.component === "BuildsBestInSlotGearSection");
  if (!gearSection) return null;

  const slots: ArchonGearSlot[] = [];
  for (const entry of gearSection.props?.gear ?? []) {
    const icon = entry?.icon;
    if (typeof icon !== "string") continue;
    const idMatch = icon.match(ITEM_ID_RE);
    const name = extractName(icon);
    if (!idMatch || !name) continue;
    slots.push({ item: { itemId: Number(idMatch[1]), name }, bis: BIS_BADGE_RE.test(icon) });
  }
  return slots.length > 0 ? slots : null;
}

export async function fetchArchonGear(mythicPlusUrl: string): Promise<ArchonGearLoadout[]> {
  const result: ArchonGearLoadout[] = [];

  const mythicPlus = await fetchGearFromPage(mythicPlusUrl);
  if (mythicPlus) result.push({ label: "Mythic+", slots: mythicPlus });

  const raid = await fetchGearFromPage(deriveRaidUrl(mythicPlusUrl));
  if (raid) result.push({ label: "Raid", slots: raid });

  return result;
}
