import { readFileSync, readdirSync } from "node:fs";
import path from "node:path";
import { extractIndexedTable, type LuaValue } from "./lua-eval.js";

// packages/scraper/src -> packages/scraper -> packages -> repo root
const DATA_DIR = path.resolve(import.meta.dirname, "../../../Data");

export interface SpecSource {
  /** Data/<class> directory name, e.g. "DeathKnight" */
  class: string;
  /** WoW class token used as the Lua table key, e.g. "DEATHKNIGHT" */
  classKey: string;
  /** spec key, e.g. "blood" */
  spec: string;
  talentsUrl: string;
}

function isTable(value: LuaValue | undefined): value is Record<string, LuaValue> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/** Every Data/<Class>/ directory that has a sources.lua file. */
export function findClassDirs(): string[] {
  return readdirSync(DATA_DIR, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name)
    .filter((name) => {
      try {
        readFileSync(path.join(DATA_DIR, name, "sources.lua"), "utf8");
        return true;
      } catch {
        return false;
      }
    });
}

/**
 * Reads Data/<classDir>/sources.lua and returns the Icy Veins talent-build
 * URL for every spec that has one. This file is the single source of truth
 * for which URL each spec's data comes from -- see README.md.
 */
export function readSpecSources(classDir: string): SpecSource[] {
  const sourcesPath = path.join(DATA_DIR, classDir, "sources.lua");
  const source = readFileSync(sourcesPath, "utf8");
  const classKey = classDir.toUpperCase();
  const table = extractIndexedTable(source, "ClassCodexSources", classKey);
  if (!isTable(table)) {
    throw new Error(`Could not find ClassCodexSources["${classKey}"] in ${sourcesPath}`);
  }

  const specs: SpecSource[] = [];
  for (const [spec, specData] of Object.entries(table)) {
    if (!isTable(specData)) continue;
    const icyveins = specData.icyveins;
    if (!isTable(icyveins)) continue;
    const talentsUrl = icyveins.talents;
    if (typeof talentsUrl !== "string") continue;
    specs.push({ class: classDir, classKey, spec, talentsUrl });
  }
  return specs;
}
