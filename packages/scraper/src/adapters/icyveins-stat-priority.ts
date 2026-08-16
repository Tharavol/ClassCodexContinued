import * as cheerio from "cheerio";

const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36";

function cleanText(s: string): string {
  return s.replace(/\s+/g, " ").trim();
}

/**
 * The Stats page URL isn't recorded in sources.lua (only the BiS gear page
 * is). Every guide's sub-pages share a "<slug>-pve-<role>-" prefix though --
 * verified against a live page during planning -- so it's derived from the
 * BiS URL by swapping its suffix rather than needing a new sources.lua field.
 */
export function deriveStatPriorityUrl(bisUrl: string): string {
  return bisUrl.replace(/-gear-best-in-slot$/, "-stat-priority");
}

export interface StatPriorityEntry {
  heroTalent: string;
  context: "General";
  /** Tiers in priority order; stats within a tier are considered roughly equal. */
  stats: string[][];
}

// Matches the exact stat-name vocabulary Data/<Class>/guide.lua and
// ClassCodex.lua's stat-priority tooltip renderer already use (see
// ClassCodex.lua's STAT_CRITICAL_STRIKE/STAT_HASTE/etc. key table) --
// "Crit" on the page has to become "Critical Strike", not stay as-is.
const STAT_NAME_MAP: Record<string, string> = {
  Haste: "Haste",
  Crit: "Critical Strike",
  Mastery: "Mastery",
  Versatility: "Versatility",
};

// Strength/Agility/Intellect are always first on the page but were never
// part of this addon's priority-tier data (guide.lua and archon-stats.lua
// both omit primary stats) -- dropped rather than mapped.
const PRIMARY_STATS = new Set(["Strength", "Agility", "Intellect"]);

function parseWidgetTiers($: cheerio.CheerioAPI, widget: any): string[][] {
  const tiers: string[][] = [];
  let tiedWithPrevious = false;

  const children = $(widget).find(".stat-priority-widget-inner").first().children();
  children.each((_, el) => {
    const $el = $(el);
    if ($el.hasClass("stat-container")) {
      const rawName = cleanText($el.find(".stat-name").first().text());
      if (PRIMARY_STATS.has(rawName)) {
        tiedWithPrevious = false;
        return;
      }
      const mapped = STAT_NAME_MAP[rawName];
      if (!mapped) return; // unrecognized stat name -- skip defensively rather than guess
      if (tiedWithPrevious && tiers.length > 0) {
        tiers[tiers.length - 1]!.push(mapped);
      } else {
        tiers.push([mapped]);
      }
      tiedWithPrevious = false;
    } else if ($el.hasClass("stat-separator")) {
      // "greater-equal" renders as a ">=" icon (tie); anything else is a
      // strict ">" (new tier boundary).
      tiedWithPrevious = $el.find(".separator-icon").hasClass("greater-equal");
    }
  });
  return tiers;
}

/**
 * Fetches one spec's Icy Veins Stats page and returns one priority-tier
 * entry per hero talent the page documents (San'layn/Deathbringer etc. each
 * get their own `.stat-priority-widget`). Falls back to a single "All"
 * entry if the page has no hero-talent-specific breakdown.
 */
export async function fetchIcyVeinsStatPriority(url: string): Promise<StatPriorityEntry[]> {
  const res = await fetch(url, { headers: { "User-Agent": USER_AGENT } });
  if (!res.ok) throw new Error(`${url}: HTTP ${res.status}`);
  const html = await res.text();
  const $ = cheerio.load(html);

  const headings = $('h3[id$="-stat-priority"]').toArray();
  const widgets = $(".stat-priority-widget").toArray();

  const entries: StatPriorityEntry[] = [];
  if (headings.length > 0 && headings.length === widgets.length) {
    headings.forEach((h3, i) => {
      const heroTalent = cleanText($(h3).text()).replace(/\s*Stat Priority$/i, "");
      const stats = parseWidgetTiers($, widgets[i]);
      if (heroTalent && stats.length > 0) entries.push({ heroTalent, context: "General", stats });
    });
  } else if (widgets.length > 0) {
    // No per-hero-talent breakdown on this page -- one flat ranking.
    const stats = parseWidgetTiers($, widgets[0]);
    if (stats.length > 0) entries.push({ heroTalent: "All", context: "General", stats });
  }
  return entries;
}
