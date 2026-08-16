ClassCodexIcyVeinsTalentData = ClassCodexIcyVeinsTalentData or {}
ClassCodexIcyVeinsTalentData["MAGE"] = {
  ["arcane"] = {
    talents = {
      { context = "Raid", buildLabel = "Arcane Raid - Sunfury", exportString = "C4DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMDamZGAAAGAwMz0sssMDAgNAAAzMDbWmxMLzYMzMzMsxMmZmBAYAAAGgZGwMAYYmZA" },
      { context = "Mythic+", buildLabel = "Arcane Mythic+ - Sunfury", exportString = "C4DAAAAAAAAAAAAAAAAAAAAAAMzwYZmZmFMzQzMzAAAwAAmZmmlllZAAsBAwGMzMsZZGzsMjxMzMzwGzYGzAAMAAADwMDMzAghZmB" },
      { context = "Mythic+", buildLabel = "Arcane Delves - Sunfury", exportString = "C4DAAAAAAAAAAAAAAAAAAAAAAMzwYZGzsYzMDNzYGAAADAYmZaWWWmBAwGAAbwMzwmlZMzyMGzMzMDbMjZMDAwAAAMAzMwMDAGmZG" },
      -- No Leveling build published on Icy Veins as of this scrape -- substituting the Delves build.
      { context = "Leveling", buildLabel = "Arcane Delves - Sunfury (used as Leveling substitute)", exportString = "C4DAAAAAAAAAAAAAAAAAAAAAAMzwYZGzsYzMDNzYGAAADAYmZaWWWmBAwGAAbwMzwmlZMzyMGzMzMDbMjZMDAwAAAMAzMwMDAGmZG", leveling = true },
    },
  },
  ["fire"] = {
    talents = {
      { context = "Raid", buildLabel = "Fire Raid - Sunfury", exportString = "C8DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMDZmZGAAAGAwMz0sstMDAwmZmx2MzMzYDAAAAAbmZMzAAgZMmZmZMzsMAMzAMGwMMGA" },
      { context = "Mythic+", buildLabel = "Fire Mythic+ - Sunfury", exportString = "C8DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzsgZGZmZGAAAAAmZmmltlZAA2MzM2mZmZGbAAAAAYzMjZGAAMjxMzMjZmlBgZGMjxAmhxA" },
      { context = "Mythic+", buildLabel = "Fire Delves - Sunfury", exportString = "C8DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzsgZGZmZGAAAAAmZmmltlZAA2MzM2mZmZGbAAAAAYzMjZGAAMjxMzMjZmlBgZGMjxAmhxA" },
      -- No Leveling build published on Icy Veins as of this scrape -- substituting the Delves build.
      { context = "Leveling", buildLabel = "Fire Delves - Sunfury (used as Leveling substitute)", exportString = "C8DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzsgZGZmZGAAAAAmZmmltlZAA2MzM2mZmZGbAAAAAYzMjZGAAMjxMzMjZmlBgZGMjxAmhxA", leveling = true },
    },
  },
  ["frost"] = {
    talents = {
      { context = "Raid", buildLabel = "Frost Single Target", exportString = "CAEAAAAAAAAAAAAAAAAAAAAAAYGGLzMzsMmZmYmZGjZMziZmZmZMDAAAMzMzyyMTbAAAAAAwGAbbjZmZwsNPgxMsAAAwMbAzADYGMMA" },
      { context = "Raid", buildLabel = "Frost Light Cleave/Raid", exportString = "CAEAAAAAAAAAAAAAAAAAAAAAAYGGLzMzsMmZmYmZGzMzMziZmZMjZAAAgZmZWWmZaDAAAAAA2AYbbMzMDmthxMsAAAwMbAzADYGMMA" },
      { context = "AoE", buildLabel = "Frost AoE", exportString = "CAEAAAAAAAAAAAAAAAAAAAAAAYGGLzMzsMmZmYmZGzMzMWMzMzMzYmlZamZZWAAAgFAAAAAAYBgttxMzMY2mxMzYbBAAAMzgZgBMDwA" },
    },
  },
}
