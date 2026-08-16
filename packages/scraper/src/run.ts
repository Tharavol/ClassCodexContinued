import { existsSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fetchArchonStats, type ArchonStatContexts } from "./adapters/archon-stats.js";
import { fetchIcyVeinsGear, type GearLoadout } from "./adapters/icyveins-gear.js";
import { fetchIcyVeinsTalents } from "./adapters/icyveins-talents.js";
import { renderArchonStatsFile, renderGearFile, renderTalentsFile } from "./lua-writer.js";
import { findClassDirs, readSpecSources } from "./sources.js";
import type { TalentBuild } from "./types.js";

// packages/scraper/src -> packages/scraper -> packages -> repo root
const DATA_DIR = path.resolve(import.meta.dirname, "../../../Data");

// Be polite to the source sites: one request in flight at a time, with a gap
// between them, rather than hammering them with parallel requests.
const REQUEST_DELAY_MS = 500;
const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

function writeIfChanged(outPath: string, content: string): boolean {
  const existing = existsSync(outPath) ? readFileSync(outPath, "utf8") : null;
  if (existing === content) return false;
  writeFileSync(outPath, content, "utf8");
  console.log(`Updated ${path.relative(process.cwd(), outPath)}`);
  return true;
}

async function main() {
  const classDirs = findClassDirs();
  let changedCount = 0;
  let errorCount = 0;

  for (const classDir of classDirs) {
    const specs = readSpecSources(classDir);
    if (specs.length === 0) continue;
    const classKey = specs[0]!.classKey;

    const talentBuilds = new Map<string, TalentBuild[]>();
    const gearLoadouts = new Map<string, GearLoadout[]>();
    const archonStats = new Map<string, ArchonStatContexts>();

    for (const spec of specs) {
      const tag = `${classDir}/${spec.spec}`;

      try {
        const builds = await fetchIcyVeinsTalents(spec.talentsUrl);
        if (builds.length > 0) talentBuilds.set(spec.spec, builds);
        else console.warn(`[${tag}] talents: no export strings found`);
      } catch (err) {
        errorCount++;
        console.error(`[${tag}] talents: ${(err as Error).message}`);
      }
      await sleep(REQUEST_DELAY_MS);

      if (spec.bisUrl) {
        try {
          const loadouts = await fetchIcyVeinsGear(spec.bisUrl);
          if (loadouts.length > 0) gearLoadouts.set(spec.spec, loadouts);
          else console.warn(`[${tag}] gear: no items found`);
        } catch (err) {
          errorCount++;
          console.error(`[${tag}] gear: ${(err as Error).message}`);
        }
        await sleep(REQUEST_DELAY_MS);
      }

      if (spec.archonBuildUrl) {
        try {
          const stats = await fetchArchonStats(spec.archonBuildUrl);
          if (Object.keys(stats).length > 0) archonStats.set(spec.spec, stats);
          else console.warn(`[${tag}] archon-stats: no stats found`);
        } catch (err) {
          errorCount++;
          console.error(`[${tag}] archon-stats: ${(err as Error).message}`);
        }
        await sleep(REQUEST_DELAY_MS);
      }
    }

    if (talentBuilds.size > 0) {
      const changed = writeIfChanged(
        path.join(DATA_DIR, classDir, "talents-icyveins.lua"),
        renderTalentsFile(classKey, talentBuilds)
      );
      if (changed) changedCount++;
    }
    if (gearLoadouts.size > 0) {
      const changed = writeIfChanged(
        path.join(DATA_DIR, classDir, "gear-icyveins.lua"),
        renderGearFile(classKey, gearLoadouts)
      );
      if (changed) changedCount++;
    }
    if (archonStats.size > 0) {
      const changed = writeIfChanged(
        path.join(DATA_DIR, classDir, "archon-stats.lua"),
        renderArchonStatsFile(classKey, archonStats)
      );
      if (changed) changedCount++;
    }
  }

  console.log(`Done. ${changedCount} file(s) changed, ${errorCount} error(s).`);
  // A partial run (some specs failed) still exits 0 -- the errors are logged
  // above and a human reviews the resulting diff either way. Only a total
  // failure to produce anything is worth failing the workflow over.
  if (errorCount > 0 && changedCount === 0) process.exitCode = 1;
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
