const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36";

// Same __NEXT_DATA__ SSG JSON as archon-stats.ts -- no DOM scraping.
const NEXT_DATA_RE = /<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)<\/script>/;

export interface ArchonTalentBuild {
  heroTalent: string;
  exportString: string;
}

export interface ArchonTalentContext {
  zoneType: "mythic-plus" | "raid";
  encounter: string;
  encounterLabel: string;
  difficulty: string;
  difficultyLabel: string;
  builds: ArchonTalentBuild[];
}

export interface ArchonTalentsResult {
  label: string;
  contexts: Map<string, ArchonTalentContext>;
  contextOrder: string[];
}

// Section titles read e.g. "Recommended <Styled type='DeathKnight'>Blood
// Death Knight</Styled> Talent Tree Build" -- the human spec label the
// existing archon-talents.lua files store is the <Styled> inner text.
const STYLED_LABEL_RE = /<Styled[^>]*>([^<]+)<\/Styled>/;

// sources.lua only records the Mythic+ (high-keys/all-dungeons) build URL.
// The Raid equivalent swaps the zone-type/difficulty/encounter segments --
// verified live: heroic and mythic each 200 with genuinely different builds.
function deriveRaidUrl(mythicPlusUrl: string, difficulty: "heroic" | "mythic"): string {
  return mythicPlusUrl.replace(
    "/mythic-plus/overview/high-keys/all-dungeons/",
    `/raid/overview/${difficulty}/all-bosses/`
  );
}

// This round only covers the overview-level context per zone/difficulty
// (Archon's single "most recommended" build for "All Dungeons" / "All
// Bosses"). Per-dungeon and per-boss granularity -- which the existing
// Data/<Class>/archon-talents.lua schema already supports via its
// contexts/contextOrder keying -- needs a live, current-season list of
// dungeon/boss slugs to scrape against; tracked as a follow-up once Season 2
// (2026-08-18) is live and that list is knowable.
const OVERVIEW_CONTEXTS: Array<{
  key: string;
  zoneType: "mythic-plus" | "raid";
  encounter: string;
  encounterLabel: string;
  difficulty: string;
  difficultyLabel: string;
  urlFor: (mythicPlusUrl: string) => string;
}> = [
  {
    key: "mythic-plus:high-keys:all-dungeons",
    zoneType: "mythic-plus",
    encounter: "all-dungeons",
    encounterLabel: "All Dungeons",
    difficulty: "high-keys",
    difficultyLabel: "High Keys",
    urlFor: (url) => url,
  },
  {
    key: "raid:heroic:all-bosses",
    zoneType: "raid",
    encounter: "all-bosses",
    encounterLabel: "All Bosses",
    difficulty: "heroic",
    difficultyLabel: "Heroic",
    urlFor: (url) => deriveRaidUrl(url, "heroic"),
  },
  {
    key: "raid:mythic:all-bosses",
    zoneType: "raid",
    encounter: "all-bosses",
    encounterLabel: "All Bosses",
    difficulty: "mythic",
    difficultyLabel: "Mythic",
    urlFor: (url) => deriveRaidUrl(url, "mythic"),
  },
];

async function fetchTopBuild(url: string): Promise<{ build: ArchonTalentBuild; label: string } | null> {
  const res = await fetch(url, { headers: { "User-Agent": USER_AGENT } });
  if (!res.ok) throw new Error(`${url}: HTTP ${res.status}`);
  const html = await res.text();
  const match = html.match(NEXT_DATA_RE);
  if (!match) throw new Error(`${url}: __NEXT_DATA__ not found`);

  const data = JSON.parse(match[1]!);
  const page = data?.props?.pageProps?.page;
  const sections = page?.sections;
  if (!Array.isArray(sections)) throw new Error(`${url}: unexpected __NEXT_DATA__ shape (no sections)`);

  const talentsSection = sections.find((s: any) => s.component === "BuildsTalentTreeBuildSection");
  if (!talentsSection) return null;

  const alternatives = talentsSection.props?.talentTreeBuildSets?.[0]?.alternatives;
  if (!Array.isArray(alternatives) || alternatives.length === 0) return null;

  const top = alternatives.find((a: any) => a.isDefaultSelection) ?? alternatives[0];
  const exportString = top?.talentTree?.exportCodeParams?.exportCode;
  if (typeof exportString !== "string" || exportString.length === 0) return null;

  // Hero talent display name: dehydratedBuild.heroSpecId is a numeric ID
  // resolved against page.talentTreeBlueprints[`${class}_${spec}_${changeSetId}`].heroTrees.
  let heroTalent = "";
  const dehydrated = top?.talentTree?.dehydratedBuild;
  const changeSet = dehydrated?.changeSet;
  if (changeSet && typeof dehydrated.heroSpecId === "number") {
    const blueprintKey = `${changeSet.className}_${changeSet.specName}_${changeSet.changeSetId}`;
    const heroTrees = page?.talentTreeBlueprints?.[blueprintKey]?.heroTrees;
    if (Array.isArray(heroTrees)) {
      const heroTree = heroTrees.find((h: any) => h.id === dehydrated.heroSpecId);
      if (heroTree?.name) heroTalent = heroTree.name;
    }
  }

  const labelMatch = typeof talentsSection.props?.title === "string" && talentsSection.props.title.match(STYLED_LABEL_RE);
  const label = labelMatch ? labelMatch[1]! : "";

  return { build: { heroTalent, exportString }, label };
}

export async function fetchArchonTalents(mythicPlusUrl: string): Promise<ArchonTalentsResult> {
  const contexts = new Map<string, ArchonTalentContext>();
  const contextOrder: string[] = [];
  let label = "";

  for (const ctx of OVERVIEW_CONTEXTS) {
    const result = await fetchTopBuild(ctx.urlFor(mythicPlusUrl));
    if (result) {
      if (!label) label = result.label;
      contexts.set(ctx.key, {
        zoneType: ctx.zoneType,
        encounter: ctx.encounter,
        encounterLabel: ctx.encounterLabel,
        difficulty: ctx.difficulty,
        difficultyLabel: ctx.difficultyLabel,
        builds: [result.build],
      });
      contextOrder.push(ctx.key);
    }
  }

  return { label, contexts, contextOrder };
}
