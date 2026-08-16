import { existsSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fetchIcyVeinsTalents } from "./adapters/icyveins-talents.js";
import { renderTalentsFile } from "./lua-writer.js";
import { findClassDirs, readSpecSources } from "./sources.js";
import type { TalentBuild } from "./types.js";

// packages/scraper/src -> packages/scraper -> packages -> repo root
const DATA_DIR = path.resolve(import.meta.dirname, "../../../Data");

// Be polite to Icy Veins: one request in flight at a time, with a gap
// between them, rather than hammering the site with parallel requests.
const REQUEST_DELAY_MS = 500;
const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

async function main() {
  const classDirs = findClassDirs();
  let changedCount = 0;
  let errorCount = 0;

  for (const classDir of classDirs) {
    const specs = readSpecSources(classDir);
    if (specs.length === 0) continue;

    const specBuilds = new Map<string, TalentBuild[]>();
    for (const spec of specs) {
      try {
        const builds = await fetchIcyVeinsTalents(spec.talentsUrl);
        if (builds.length > 0) {
          specBuilds.set(spec.spec, builds);
        } else {
          console.warn(`[${classDir}/${spec.spec}] no export strings found at ${spec.talentsUrl}`);
        }
      } catch (err) {
        errorCount++;
        console.error(`[${classDir}/${spec.spec}] ${(err as Error).message}`);
      }
      await sleep(REQUEST_DELAY_MS);
    }

    if (specBuilds.size === 0) continue;

    const classKey = specs[0]!.classKey;
    const content = renderTalentsFile(classKey, specBuilds);
    const outPath = path.join(DATA_DIR, classDir, "talents-icyveins.lua");
    const existing = existsSync(outPath) ? readFileSync(outPath, "utf8") : null;
    if (existing !== content) {
      writeFileSync(outPath, content, "utf8");
      changedCount++;
      console.log(`Updated ${path.relative(process.cwd(), outPath)}`);
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
