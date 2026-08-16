import type { TalentBuild } from "./types.js";

function luaString(s: string): string {
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
