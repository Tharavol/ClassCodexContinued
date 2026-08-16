export interface TalentBuild {
  context: string;
  buildLabel: string;
  exportString: string;
  leveling?: true;
  /** Rendered as a Lua comment above the entry -- used to flag substitutions/caveats. */
  note?: string;
}
