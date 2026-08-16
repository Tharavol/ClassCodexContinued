import luaparse from "luaparse";

export type LuaValue =
  | string
  | number
  | boolean
  | null
  | LuaValue[]
  | { [key: string]: LuaValue };

function evalExpr(node: any): LuaValue {
  switch (node.type) {
    case "StringLiteral":
    case "NumericLiteral":
    case "BooleanLiteral":
      return node.value;
    case "NilLiteral":
      return null;
    case "UnaryExpression":
      if (node.operator === "-") return -(evalExpr(node.argument) as number);
      throw new Error(`Unsupported unary operator: ${node.operator}`);
    case "TableConstructorExpression": {
      const obj: Record<string, LuaValue> = {};
      let arrayIndex = 1;
      let sawKeyedField = false;
      for (const field of node.fields) {
        if (field.type === "TableKeyString") {
          obj[field.key.name] = evalExpr(field.value);
          sawKeyedField = true;
        } else if (field.type === "TableKey") {
          obj[String(evalExpr(field.key))] = evalExpr(field.value);
          sawKeyedField = true;
        } else if (field.type === "TableValue") {
          obj[String(arrayIndex++)] = evalExpr(field.value);
        }
      }
      if (!sawKeyedField) {
        return Object.keys(obj)
          .sort((a, b) => Number(a) - Number(b))
          .map((k) => obj[k]!);
      }
      return obj;
    }
    default:
      throw new Error(`Unsupported Lua expression node: ${node.type}`);
  }
}

/**
 * Reads a Class Codex Data/<Class>/*.lua file of the form
 *   GlobalName = GlobalName or {}
 *   GlobalName["SOME_KEY"] = { ... }
 * and returns the evaluated table assigned to GlobalName["SOME_KEY"].
 * Returns undefined if no such assignment exists in the file.
 */
export function extractIndexedTable(
  source: string,
  globalName: string,
  index: string
): LuaValue | undefined {
  const ast = luaparse.parse(source, {
    encodingMode: "pseudo-latin1",
    comments: false,
  });
  for (const stmt of ast.body) {
    if (stmt.type !== "AssignmentStatement") continue;
    const variable = stmt.variables[0] as any;
    const init = stmt.init[0] as any;
    if (!variable || !init) continue;
    if (variable.type !== "IndexExpression") continue;
    if (variable.base.type !== "Identifier" || variable.base.name !== globalName) continue;
    if (variable.index.type !== "StringLiteral" || variable.index.value !== index) continue;
    return evalExpr(init);
  }
  return undefined;
}
