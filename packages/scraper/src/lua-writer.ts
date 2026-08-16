import type { ArchonGearLoadout } from "./adapters/archon-gear.js";
import type { ArchonStatContexts } from "./adapters/archon-stats.js";
import type { ArchonTalentContext } from "./adapters/archon-talents.js";
import type { GearLoadout } from "./adapters/icyveins-gear.js";
import type { StatPriorityEntry } from "./adapters/icyveins-stat-priority.js";
import type { TalentBuild } from "./types.js";

export function luaString(s: string): string {
  // Belt-and-suspenders beyond the adapter's own whitespace normalization:
  // a single-line Lua string literal can't contain a raw newline/tab, so
  // escape them here too rather than trusting every future adapter to do it.
  return `"${s
    .replace(/\\/g, "\\\\")
    .replace(/"/g, '\\"')
    .replace(/\r/g, "\\r")
    .replace(/\n/g, "\\n")
    .replace(/\t/g, "\\t")}"`;
}

function renderBuild(build: TalentBuild, indent: string): string {
  const fields = [
    `context = ${luaString(build.context)}`,
    `buildLabel = ${luaString(build.buildLabel)}`,
    `exportString = ${luaString(build.exportString)}`,
  ];
  if (build.leveling) fields.push("leveling = true");
  const noteLine = build.note ? `${indent}-- ${build.note}\n` : "";
  return `${noteLine}${indent}{ ${fields.join(", ")} },`;
}

/**
 * Renders a class's spec -> builds map in the same shape and style as the
 * existing Data/<Class>/talents-icyveins.lua files, so a regenerated file
 * diffs as data changes, not a reformat. Spec order follows the iteration
 * order of `specBuilds`, which callers should derive from sources.lua so it
 * matches the class's existing spec ordering.
 */
export function renderTalentsFile(classKey: string, specBuilds: Map<string, TalentBuild[]>): string {
  const lines: string[] = [];
  lines.push("ClassCodexIcyVeinsTalentData = ClassCodexIcyVeinsTalentData or {}");
  lines.push(`ClassCodexIcyVeinsTalentData["${classKey}"] = {`);
  for (const [spec, builds] of specBuilds) {
    lines.push(`  ["${spec}"] = {`);
    lines.push(`    talents = {`);
    for (const build of builds) {
      lines.push(renderBuild(build, "      "));
    }
    lines.push(`    },`);
    lines.push(`  },`);
  }
  lines.push("}");
  lines.push("");
  return lines.join("\n");
}

/**
 * Renders a class's spec -> gear loadouts map in the same shape and style as
 * the existing Data/<Class>/gear-icyveins.lua files.
 */
export function renderGearFile(classKey: string, specGear: Map<string, GearLoadout[]>): string {
  const lines: string[] = [];
  lines.push("ClassCodexIcyVeinsData = ClassCodexIcyVeinsData or {}");
  lines.push(`ClassCodexIcyVeinsData["${classKey}"] = {`);
  for (const [spec, loadouts] of specGear) {
    lines.push(`  ["${spec}"] = {`);
    lines.push(`    bisGear = {`);
    for (const loadout of loadouts) {
      lines.push(`      { label = ${luaString(loadout.label)}, slots = {`);
      for (const s of loadout.slots) {
        const itemFields = [`itemId = ${s.item.itemId}`, `name = ${luaString(s.item.name)}`];
        if (s.item.bonusIDs && s.item.bonusIDs.length > 0) {
          itemFields.push(`bonusIDs = { ${s.item.bonusIDs.join(", ")} }`);
        }
        lines.push(
          `        { slot = ${luaString(s.slot)}, item = { ${itemFields.join(", ")} }, source = ${luaString(s.source)} },`
        );
      }
      lines.push(`      } },`);
    }
    lines.push(`    },`);
    lines.push(`  },`);
  }
  lines.push("}");
  lines.push("");
  return lines.join("\n");
}

/**
 * Renders a class's spec -> Archon best-in-slot gear map in the same shape
 * and style as the existing Data/<Class>/gear-archon.lua files.
 */
export function renderArchonGearFile(classKey: string, specGear: Map<string, ArchonGearLoadout[]>): string {
  const lines: string[] = [];
  lines.push("ClassCodexArchonGearData = ClassCodexArchonGearData or {}");
  lines.push(`ClassCodexArchonGearData["${classKey}"] = {`);
  for (const [spec, loadouts] of specGear) {
    lines.push(`  ["${spec}"] = {`);
    lines.push(`    bisGear = {`);
    for (const loadout of loadouts) {
      lines.push(`      { label = ${luaString(loadout.label)}, slots = {`);
      for (const s of loadout.slots) {
        lines.push(
          `        { item = { itemId = ${s.item.itemId}, name = ${luaString(s.item.name)} }, bis = ${s.bis} },`
        );
      }
      lines.push(`      } },`);
    }
    lines.push(`    },`);
    lines.push(`  },`);
  }
  lines.push("}");
  lines.push("");
  return lines.join("\n");
}

/**
 * Renders a class's spec -> Archon per-context talent build map in the same
 * shape and style as the existing Data/<Class>/archon-talents.lua files.
 * `specData` values carry the already-computed contextOrder alongside the
 * contexts map, mirroring the source file's own contexts/contextOrder split.
 */
export function renderArchonTalentsFile(
  classKey: string,
  specData: Map<string, { label: string; contexts: Map<string, ArchonTalentContext>; contextOrder: string[] }>
): string {
  const lines: string[] = [];
  lines.push("ClassCodexArchonData = ClassCodexArchonData or {}");
  lines.push(`ClassCodexArchonData["${classKey}"] = {`);
  for (const [spec, data] of specData) {
    lines.push(`  ["${spec}"] = {`);
    lines.push(`    label = ${luaString(data.label)},`);
    lines.push(`    contexts = {`);
    for (const [key, ctx] of data.contexts) {
      lines.push(`      [${luaString(key)}] = {`);
      lines.push(`        zoneType = ${luaString(ctx.zoneType)},`);
      lines.push(`        encounter = ${luaString(ctx.encounter)},`);
      lines.push(`        encounterLabel = ${luaString(ctx.encounterLabel)},`);
      lines.push(`        difficulty = ${luaString(ctx.difficulty)},`);
      lines.push(`        difficultyLabel = ${luaString(ctx.difficultyLabel)},`);
      lines.push(`        builds = {`);
      for (const b of ctx.builds) {
        lines.push(
          `          { heroTalent = ${luaString(b.heroTalent)}, exportString = ${luaString(b.exportString)} },`
        );
      }
      lines.push(`        },`);
      lines.push(`      },`);
    }
    lines.push(`    },`);
    lines.push(`    contextOrder = {`);
    for (const key of data.contextOrder) {
      lines.push(`      ${luaString(key)},`);
    }
    lines.push(`    },`);
    lines.push(`  },`);
  }
  lines.push("}");
  lines.push("");
  return lines.join("\n");
}

/**
 * Renders the replacement value text for one spec's `priorities` field, for
 * use with lua-patch.ts's patchSpecField -- a bare `{...}` with no trailing
 * comma, indented to match where that field already sits inside
 * Data/<Class>/guide.lua. `eol` should match the target file's actual line
 * endings (guide.lua ships CRLF on disk) so the patched region doesn't mix
 * line-ending styles with the rest of the file.
 */
export function renderPriorities(entries: StatPriorityEntry[], eol: string): string {
  const lines: string[] = ["{"];
  for (const entry of entries) {
    lines.push(`      {`);
    lines.push(`        heroTalent = ${luaString(entry.heroTalent)},`);
    lines.push(`        context = ${luaString(entry.context)},`);
    lines.push(`        stats = {`);
    for (const tier of entry.stats) {
      lines.push(`          { ${tier.map(luaString).join(", ")} },`);
    }
    lines.push(`        },`);
    lines.push(`      },`);
  }
  lines.push(`    }`);
  return lines.join(eol);
}

// Fixed order matching the existing Data/<Class>/archon-stats.lua files.
const STAT_TARGET_ORDER = ["crit", "haste", "mastery", "versatility"];

function renderTargets(targets: Record<string, number>): string {
  const parts = STAT_TARGET_ORDER.filter((key) => key in targets).map(
    (key) => `${key} = ${targets[key]}`
  );
  return `{ ${parts.join(", ")} }`;
}

/**
 * Renders a class's spec -> {Mythic+, Raid} stat-target map in the same
 * shape and style as the existing Data/<Class>/archon-stats.lua files.
 */
export function renderArchonStatsFile(
  classKey: string,
  specStats: Map<string, ArchonStatContexts>
): string {
  const lines: string[] = [];
  lines.push("ClassCodexArchonStats = ClassCodexArchonStats or {}");
  lines.push(`ClassCodexArchonStats["${classKey}"] = {`);
  for (const [spec, contexts] of specStats) {
    lines.push(`  ["${spec}"] = {`);
    if (contexts["Mythic+"]) {
      lines.push(`    ["Mythic+"] = { targets = ${renderTargets(contexts["Mythic+"])} },`);
    }
    if (contexts["Raid"]) {
      lines.push(`    ["Raid"] = { targets = ${renderTargets(contexts["Raid"])} },`);
    }
    lines.push(`  },`);
  }
  lines.push("}");
  lines.push("");
  return lines.join("\n");
}
