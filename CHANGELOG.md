# Class Codex Continued

## Unreleased

### Changed
- Bump `## Interface` to 120100 for WoW 12.1 (Curse of Ula'tek, live
  2026-08-11); audited the patch's removed/renamed APIs against this codebase
  and none are used
- Add Icy Veins gear (`gear-icyveins.lua`) and Archon.gg stat-target
  (`archon-stats.lua`) adapters to `packages/scraper`, plus an Icy Veins
  stat-priority adapter that surgically patches only the `priorities` field
  inside `guide.lua`, leaving `talents`/`rotation` untouched
- Add Archon.gg gear (`gear-archon.lua`) and talent-build
  (`archon-talents.lua`, overview-level contexts only) adapters. Archon
  embeds a ready-to-use WoW export string directly in its page data, so no
  talent-string encoding was needed; per-dungeon/per-boss granularity is
  tracked separately (#21)
- Remove PvP entirely: no live-data source (Icy Veins, Archon.gg) covers it,
  and Murlok.io/Battle.net aren't scrapable without their own dedicated
  integration work. Removed `Shared/PvPData.lua`, all PvP branches across
  `TalentPaneDropdown.lua`, `Compendium.lua`, `LoadoutDock.lua`,
  `GearingSections.lua`, five `Sections/*.lua` files, and the
  `bnet-pvp-talents.lua`/`murlok-pvp.lua` data files and TOC load lines
- Fix `cachedRanks`/`equippedSpellIds` leaking as implicit globals: each had a
  real `local` declared later in the same file than a function that wrote to
  it, so the invalidation silently missed the actual cache (#9)
- Remove `packages/bot/` (Discord server setup script) -- dead code with no
  path to running, not part of this project's direction
- Add `packages/scraper`, rebuilding the data-refresh pipeline one source at a
  time: an Icy Veins talent-build adapter regenerates
  `Data/<Class>/talents-icyveins.lua` from live pages, and
  `.github/workflows/data-refresh.yml` runs it weekly and opens a PR with the
  diff rather than pushing to `main` (#5, #6)
- Fork point: diverged from jfstn's Class Codex v0.36.3 after its CurseForge
  listing (project ID 1480030) went down. Renamed to Class Codex Continued;
  added Tharavol and Claude to the Author list
- Add a second MIT copyright line for the continuation; original jfstn
  copyright retained
- Add license files for the vendored libraries under `Libs/` that shipped
  without any (CallbackHandler-1.0 and LibDBIcon-1.0 under the Ace3 Limited
  BSD license, LibStub in the public domain), plus `Libs/README.md` documenting
  that LibDataBroker-1.1 ships with no license found upstream
- Add `Credits.md`
- Remove `## X-Curse-Project-ID` and the CurseForge `## X-Website` — that
  project ID belongs to the deleted listing under jfstn's account, not this
  fork; `## X-Website` now points at this repository. Add `## X-License: MIT`
- Add CI (luacheck + packager dry-run) and release/prerelease automation via
  the BigWigs packager, plus a daily `## Interface` auto-bump workflow

### Documentation
- README rewritten for the fork: not-ready-for-use banner, project structure,
  and the data-refresh pipeline plan (see `v0.38.0` milestone)
