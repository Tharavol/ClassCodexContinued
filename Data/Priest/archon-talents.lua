ClassCodexArchonData = ClassCodexArchonData or {}
ClassCodexArchonData["PRIEST"] = {
  ["discipline"] = {
    label = "Discipline Priest",
    contexts = {
      ["mythic-plus:high-keys:all-dungeons"] = {
        zoneType = "mythic-plus",
        encounter = "all-dungeons",
        encounterLabel = "All Dungeons",
        difficulty = "high-keys",
        difficultyLabel = "High Keys",
        builds = {
          { heroTalent = "Oracle", exportString = "CAQAAAAAAAAAAAAAAAAAAAAAAADsNzDwyMjxMzgZbmtZmxMmZAAAAAAAAAAMMLzgZmZYGmBbmmJGgZWwQYMLDwYwCAAMzMzMGMDwMzAM" },
        },
      },
      ["raid:heroic:all-bosses"] = {
        zoneType = "raid",
        encounter = "all-bosses",
        encounterLabel = "All Bosses",
        difficulty = "heroic",
        difficultyLabel = "Heroic",
        builds = {
          { heroTalent = "Oracle", exportString = "CAQAAAAAAAAAAAAAAAAAAAAAAADsMGWmZmBDmZbmtZmZmxMDAAAAAAAAAgZYZGMzMDzYmBMNTzMAzsghwYWGgxgFAAYMmZMYGgZmBYA" },
        },
      },
      ["raid:mythic:all-bosses"] = {
        zoneType = "raid",
        encounter = "all-bosses",
        encounterLabel = "All Bosses",
        difficulty = "mythic",
        difficultyLabel = "Mythic",
        builds = {
          { heroTalent = "Oracle", exportString = "CAQAAAAAAAAAAAAAAAAAAAAAAADsAz2MzMYmhZbmtZmZmhZAAAAAAAAAAMDLzgZmZwMmBMNTzMAzshhwYWGgxgFAAYMmZMYGgZmZMDD" },
        },
      },
    },
    contextOrder = {
      "mythic-plus:high-keys:all-dungeons",
      "raid:heroic:all-bosses",
      "raid:mythic:all-bosses",
    },
  },
  ["holy"] = {
    label = "Holy Priest",
    contexts = {
      ["mythic-plus:high-keys:all-dungeons"] = {
        zoneType = "mythic-plus",
        encounter = "all-dungeons",
        encounterLabel = "All Dungeons",
        difficulty = "high-keys",
        difficultyLabel = "High Keys",
        builds = {
          { heroTalent = "Oracle", exportString = "CEQAAAAAAAAAAAAAAAAAAAAAAwYAAAAAAAbGzYWGzwMjhZYsMzMzAAAAYYWmhZmZGmhZAMTBwMLYIMmlBYMwiZmBAzYmxYYmBYmZGYA" },
        },
      },
      ["raid:heroic:all-bosses"] = {
        zoneType = "raid",
        encounter = "all-bosses",
        encounterLabel = "All Bosses",
        difficulty = "heroic",
        difficultyLabel = "Heroic",
        builds = {
          { heroTalent = "Archon", exportString = "CEQAAAAAAAAAAAAAAAAAAAAAAwYAAAAAAAgZmlxYMzMDzMzYZGmBAAAwMmlZwMzMMDzAYmaAgZWMDziBAGD2MzMLAaGjxYYmZbZAmBG" },
        },
      },
      ["raid:mythic:all-bosses"] = {
        zoneType = "raid",
        encounter = "all-bosses",
        encounterLabel = "All Bosses",
        difficulty = "mythic",
        difficultyLabel = "Mythic",
        builds = {
          { heroTalent = "Archon", exportString = "CEQAAAAAAAAAAAAAAAAAAAAAAwYAAAAAAAgZmlxYMzMDzMzYZGmBAAAwMmlZwMzMMDzAYmaAgZWMDziBAGD2MzMLAaGjxYYmZbZAmBG" },
        },
      },
    },
    contextOrder = {
      "mythic-plus:high-keys:all-dungeons",
      "raid:heroic:all-bosses",
      "raid:mythic:all-bosses",
    },
  },
  ["shadow"] = {
    label = "Shadow Priest",
    contexts = {
      ["mythic-plus:high-keys:all-dungeons"] = {
        zoneType = "mythic-plus",
        encounter = "all-dungeons",
        encounterLabel = "All Dungeons",
        difficulty = "high-keys",
        difficultyLabel = "High Keys",
        builds = {
          { heroTalent = "Voidweaver", exportString = "CIQAAAAAAAAAAAAAAAAAAAAAAMjZMGAAAAAAAAAAAAjZZmxYZmxMz2MDDz2MzYmZGbIDLmpxAzMzAABY2mtNwsxAADGzMzY2GzgZGMDGA" },
        },
      },
      ["raid:heroic:all-bosses"] = {
        zoneType = "raid",
        encounter = "all-bosses",
        encounterLabel = "All Bosses",
        difficulty = "heroic",
        difficultyLabel = "Heroic",
        builds = {
          { heroTalent = "Archon", exportString = "CIQAAAAAAAAAAAAAAAAAAAAAAMMjZGAAAAAAAAAAAgxMMjxyMDzsNzwMsNzMmZmxGyMWMTDwMAzsZGmNDAZMWAwMAjZmZMbjZ2WGgZwA" },
        },
      },
      ["raid:mythic:all-bosses"] = {
        zoneType = "raid",
        encounter = "all-bosses",
        encounterLabel = "All Bosses",
        difficulty = "mythic",
        difficultyLabel = "Mythic",
        builds = {
          { heroTalent = "Archon", exportString = "CIQAAAAAAAAAAAAAAAAAAAAAAMMjZGAAAAAAAAAAAgxMMjx2MDzsNzwMjtZMmZmBmMwMNzAzAMzmZY2MAkxYBAzAMmZmxsNmZbZAmBD" },
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
