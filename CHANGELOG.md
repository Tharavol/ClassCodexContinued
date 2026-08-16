# Class Codex Continued

## Unreleased

### Changed
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
