import * as cheerio from "cheerio";

const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36";

function cleanText(s: string): string {
  return s.replace(/\s+/g, " ").trim();
}

export interface GearItem {
  itemId: number;
  name: string;
  bonusIDs?: number[];
}

export interface GearSlot {
  slot: string;
  item: GearItem;
  source: string;
}

export interface GearLoadout {
  label: string;
  slots: GearSlot[];
}

// Icy Veins renders three BiS tabs per gear page, in fixed DOM ids
// bis_0_0/bis_0_1/bis_0_2 -- verified against a live page during planning.
// Order and labels match the existing Data/<Class>/gear-icyveins.lua
// `label` field exactly.
const TAB_LABELS = ["Overall", "Mythic+", "Raid"];

export async function fetchIcyVeinsGear(url: string): Promise<GearLoadout[]> {
  const res = await fetch(url, { headers: { "User-Agent": USER_AGENT } });
  if (!res.ok) throw new Error(`${url}: HTTP ${res.status}`);
  const html = await res.text();
  const $ = cheerio.load(html);

  const loadouts: GearLoadout[] = [];
  for (let i = 0; i < TAB_LABELS.length; i++) {
    const content = $(`#bis_0_${i}`);
    if (content.length === 0) continue;

    const slots: GearSlot[] = [];
    content.find(".bis_item").each((_, el) => {
      const iconSpan = $(el).find(".spell_icon_span[data-wowhead]").first();
      const dataWowhead = iconSpan.attr("data-wowhead");
      if (!dataWowhead) return; // placeholder slot (e.g. an empty Off Hand for a 2H spec) -- skip

      const itemMatch = dataWowhead.match(/item=(\d+)/);
      const itemId = itemMatch ? parseInt(itemMatch[1]!, 10) : 0;
      if (!itemId) return;

      const bonusMatch = dataWowhead.match(/bonus=([\d:]+)/);
      const bonusIDs = bonusMatch ? bonusMatch[1]!.split(":").map(Number) : undefined;

      const name = cleanText(iconSpan.text());
      const slot = cleanText($(el).find(".bis_item_slot").first().text());
      const source = cleanText($(el).find(".bis_item_drop").first().text());
      if (!name || !slot) return;

      slots.push({ slot, item: { itemId, name, bonusIDs }, source });
    });

    // "Shirt"/"Tabard" are cosmetic placeholder slots Icy Veins always
    // renders even though nothing is ever recommended for them -- they
    // never produce a valid data-wowhead item, so they're already filtered
    // out above rather than needing a slot-name denylist here.
    if (slots.length > 0) loadouts.push({ label: TAB_LABELS[i]!, slots });
  }
  return loadouts;
}
