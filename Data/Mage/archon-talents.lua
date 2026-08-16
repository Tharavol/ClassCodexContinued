ClassCodexArchonData = ClassCodexArchonData or {}
ClassCodexArchonData["MAGE"] = {
  ["arcane"] = {
    label = "Arcane Mage",
    contexts = {
      ["mythic-plus:high-keys:all-dungeons"] = {
        zoneType = "mythic-plus",
        encounter = "all-dungeons",
        encounterLabel = "All Dungeons",
        difficulty = "high-keys",
        difficultyLabel = "High Keys",
        builds = {
          { heroTalent = "Spellslinger", exportString = "C4DAAAAAAAAAAAAAAAAAAAAAAMzwYZmZmFMzQzMGAAAGAAAYmZmllZmYBAgtZMzMmNzyMzMmZMGmZmxCzMz8AzAAMAAAmZBAmZAwwA" },
        },
      },
      ["raid:heroic:all-bosses"] = {
        zoneType = "raid",
        encounter = "all-bosses",
        encounterLabel = "All Bosses",
        difficulty = "heroic",
        difficultyLabel = "Heroic",
        builds = {
          { heroTalent = "Spellslinger", exportString = "C4DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMzQzMzAAAwAAAAzMzssMzELAAsBDADGADmBLMzMjBAAAAAzsAAmBAA" },
        },
      },
    },
    contextOrder = {
      "mythic-plus:high-keys:all-dungeons",
      "raid:heroic:all-bosses",
    },
  },
  ["fire"] = {
    label = "Fire Mage",
    contexts = {
      ["mythic-plus:high-keys:all-dungeons"] = {
        zoneType = "mythic-plus",
        encounter = "all-dungeons",
        encounterLabel = "All Dungeons",
        difficulty = "high-keys",
        difficultyLabel = "High Keys",
        builds = {
          { heroTalent = "Sunfury", exportString = "C8DAAAAAAAAAAAAAAAAAAAAAAMzwYZmZmFegZGZmZGAAAGAwMz0sssMDAwmZmx2YmZGbAAAAAwiZmZGAAYMjZMzMzMbAYmBGjxgZYA" },
        },
      },
      ["raid:heroic:all-bosses"] = {
        zoneType = "raid",
        encounter = "all-bosses",
        encounterLabel = "All Bosses",
        difficulty = "heroic",
        difficultyLabel = "Heroic",
        builds = {
          { heroTalent = "Sunfury", exportString = "C8DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzsMmZGZmZGAAAGAwMz0sssMDAwmZmx2YmZGAAAAAgFzMzMAAwYGzMzMzMzCAmZAzYMwwA" },
        },
      },
      ["raid:mythic:all-bosses"] = {
        zoneType = "raid",
        encounter = "all-bosses",
        encounterLabel = "All Bosses",
        difficulty = "mythic",
        difficultyLabel = "Mythic",
        builds = {
          { heroTalent = "Sunfury", exportString = "C8DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMDZmZGAAAGAwMz0sssMDAwmZmx2YmZGLAAAAAwiZmZmBAAjZMjZmZmZBAzMAjxgZYA" },
        },
      },
    },
    contextOrder = {
      "mythic-plus:high-keys:all-dungeons",
      "raid:heroic:all-bosses",
      "raid:mythic:all-bosses",
    },
  },
  ["frost"] = {
    label = "Frost Mage",
    contexts = {
      ["mythic-plus:high-keys:all-dungeons"] = {
        zoneType = "mythic-plus",
        encounter = "all-dungeons",
        encounterLabel = "All Dungeons",
        difficulty = "high-keys",
        difficultyLabel = "High Keys",
        builds = {
          { heroTalent = "Spellslinger", exportString = "CAEAAAAAAAAAAAAAAAAAAAAAAMzwYZmZmlhZmYmxYmZmZWMzMMjZAAAgZmZWWmZaDAA2AAAAWAYbZMzMzDwsNMmZsAAAwMbAzwYAzgB" },
        },
      },
      ["raid:heroic:all-bosses"] = {
        zoneType = "raid",
        encounter = "all-bosses",
        encounterLabel = "All Bosses",
        difficulty = "heroic",
        difficultyLabel = "Heroic",
        builds = {
          { heroTalent = "Spellslinger", exportString = "CAEAAAAAAAAAAAAAAAAAAAAAAMzwYZmZmFmZmYGmZmZmZWMzMMjZAAAgZmZWWmZaDAAWAAAAWAYbbMzMDmthxMjNAAAmZDYGGDYGMA" },
        },
      },
      ["raid:mythic:all-bosses"] = {
        zoneType = "raid",
        encounter = "all-bosses",
        encounterLabel = "All Bosses",
        difficulty = "mythic",
        difficultyLabel = "Mythic",
        builds = {
          { heroTalent = "Spellslinger", exportString = "CAEAAAAAAAAAAAAAAAAAAAAAAYGGLzMzsMmZmYmZGzMzMziZmZMjZAAAgZmZWWmZaDAA2AAAA2AYbZMzMDmthxMsAAAwMbAzADYGMA" },
        },
      },
    },
    contextOrder = {
      "mythic-plus:high-keys:all-dungeons",
      "raid:heroic:all-bosses",
      "raid:mythic:all-bosses",
    },
  },
}
