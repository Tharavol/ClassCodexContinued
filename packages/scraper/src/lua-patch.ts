import luaparse from "luaparse";

interface SpecFieldRange {
  spec: string;
  start: number;
  end: number;
}

/**
 * Finds the source-text byte range of GlobalName["classKey"][spec][fieldName]
 * for every spec in the file, via the parsed AST -- not string matching, so
 * it's exact regardless of nested braces/quotes in surrounding fields.
 */
function findSpecFieldRanges(
  source: string,
  globalName: string,
  classKey: string,
  fieldName: string
): SpecFieldRange[] {
  const ast = luaparse.parse(source, { ranges: true, encodingMode: "pseudo-latin1", comments: false });
  const ranges: SpecFieldRange[] = [];

  for (const stmt of ast.body) {
    if (stmt.type !== "AssignmentStatement") continue;
    const variable = stmt.variables[0] as any;
    const init = stmt.init[0] as any;
    if (!variable || !init) continue;
    if (variable.type !== "IndexExpression") continue;
    if (variable.base.type !== "Identifier" || variable.base.name !== globalName) continue;
    if (variable.index.type !== "StringLiteral" || variable.index.value !== classKey) continue;
    if (init.type !== "TableConstructorExpression") continue;

    for (const specField of init.fields) {
      if (specField.type !== "TableKey" && specField.type !== "TableKeyString") continue;
      const specKeyNode = (specField as any).key;
      const specName = specField.type === "TableKeyString" ? specKeyNode.name : specKeyNode.value;
      const specTable = (specField as any).value;
      if (specTable.type !== "TableConstructorExpression") continue;

      for (const f of specTable.fields) {
        if (f.type !== "TableKey" && f.type !== "TableKeyString") continue;
        const fKeyNode = (f as any).key;
        const key = f.type === "TableKeyString" ? fKeyNode.name : fKeyNode.value;
        if (key !== fieldName) continue;
        const [start, end] = (f as any).value.range;
        ranges.push({ spec: specName, start, end });
      }
    }
  }
  return ranges;
}

/**
 * Replaces GlobalName["classKey"][spec][fieldName]'s value text for every
 * spec present in `replacements`, leaving everything else in the file --
 * including the rest of each spec's table -- byte-for-byte untouched.
 * `replacements` maps spec -> the new Lua source for the field's value
 * (a bare `{...}`, no trailing comma; the comma already in the source is
 * outside the replaced range).
 */
export function patchSpecField(
  source: string,
  globalName: string,
  classKey: string,
  fieldName: string,
  replacements: Map<string, string>
): string {
  const ranges = findSpecFieldRanges(source, globalName, classKey, fieldName);
  const toApply = ranges.filter((r) => replacements.has(r.spec)).sort((a, b) => b.start - a.start);

  let result = source;
  for (const r of toApply) {
    result = result.slice(0, r.start) + replacements.get(r.spec)! + result.slice(r.end);
  }
  return result;
}
