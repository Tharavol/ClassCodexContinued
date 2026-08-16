# Vendored libraries

These libraries are third-party code bundled with Class Codex so the
repository can be dropped straight into `Interface/AddOns` and run. They are
**not** covered by the addon's MIT [LICENSE](../LICENSE) — each keeps its own
terms, as documented below.

| Path | Project | License |
| --- | --- | --- |
| `LibStub/` | [LibStub](https://www.wowace.com/projects/libstub) | Public Domain — declared in-file and in [LibStub/LICENSE.txt](LibStub/LICENSE.txt) |
| `CallbackHandler-1.0/` | [CallbackHandler-1.0](https://www.wowace.com/projects/callbackhandler) (Ace3 Development Team) | Limited BSD — [ACE3-LICENSE.txt](ACE3-LICENSE.txt) |
| `LibDBIcon-1.0/` | [LibDBIcon-1.0](https://www.wowace.com/projects/libdbicon-1-0) (Rabbit) | "Ace3 Style BSD" per its WowAce project page — [ACE3-LICENSE.txt](ACE3-LICENSE.txt) |
| `LibDataBroker-1.1/` | [LibDataBroker-1.1](https://github.com/tekkub/libdatabroker-1-1) (Tekkub) | **No license found.** Neither the upstream GitHub repo nor its CurseForge listing declares one (CurseForge shows the "All Rights Reserved" default it applies when a project has no stated license). Bundled here as-is, matching how the original Class Codex distributed it; if you need clearer terms, contact Tekkub or replace this library. |

## Notes

- `CallbackHandler-1.0` is normally distributed as part of the combined Ace3
  bundle, which is where its Limited BSD license comes from. `LibDBIcon-1.0`
  is a separate WowAce project by a different author, but its own project page
  states the same "Ace3 Style BSD" terms, so the same license text applies.
- `LibDataBroker-1.1`'s missing license is a pre-existing condition inherited
  from upstream, not something introduced by this fork — see
  [Credits.md](../Credits.md) for how this fork's own code is licensed.
