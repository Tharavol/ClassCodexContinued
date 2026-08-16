ClassCodexIcyVeinsTalentData = ClassCodexIcyVeinsTalentData or {}
ClassCodexIcyVeinsTalentData["PALADIN"] = {
  ["holy"] = {
    talents = {
      { context = "Raid", buildLabel = "Herald of the Sun Raiding - HeraldoftheSun", exportString = "CEEAAAAAAAAAAAAAAAAAAAAAAAAAALAwMAAw2MzMjZMzYxYmZYZwMLmpJGzYmZYMbZAYADbgNWmxMLz2Mzs1AAAAsAAbGGzYGmBAwMDzghB" },
      { context = "Mythic+", buildLabel = "Herald of the Sun Mythic+ - HeraldoftheSun", exportString = "CEEAAAAAAAAAAAAAAAAAAAAAAAAAgZBAmBAA2GzMzMjZmZBmZYZsZmFjmYWmxMzwY2yAwAwGYjlZmZWmtZmZrBAAAYBMD2AGGMDAgZGmxYYA" },
      { context = "Mythic+", buildLabel = "Lightsmith Mythic+ - Lightsmith", exportString = "CEEAAAAAAAAAAAAAAAAAAAAAAAAAgZBAmBAA2GzMzMjZmZBmZYZsZmFjmYWmxMzwY2yAwAwGYjlZmBAAAmZ22WsNzwGYGsBMMYGAzMAMjxoB" },
    },
  },
  ["protection"] = {
    talents = {
      { context = "Raid", buildLabel = "Raid / Single Target - Templar", exportString = "CIEAAAAAAAAAAAAAAAAAAAAAAsZmtZbmZMzMzMWGjxw2MGAAAAAAAAINGmxMzYMbtBgBMwMYbAAgZm2mZWmBAYjNMAGjZYMAALzAmZGwYB" },
      { context = "Mythic+", buildLabel = "AoE / Mythic+ - Templar (Weekly Keys)", exportString = "CIEAAAAAAAAAAAAAAAAAAAAAAsZmlZbMjZmZmZZbMGjZZGDAAAAAAAA00MDzYmhxs1GAGAYGsNAAwMTbzMLzAAsxCGAjxMMGAglZAzMDYsA" },
      { context = "Mythic+", buildLabel = "AoE / Mythic+ - Templar (High Keys)", exportString = "CIEAAAAAAAAAAAAAAAAAAAAAAsZmtZbMjZmZmZZbMGjZZGDAAAAAAAA00MDzYmhxs1GAGAYGsNAAwMTbzMLzAAsxCGAjxMMGAglZAzMDYsA" },
      { context = "Mythic+", buildLabel = "Delves - Templar", exportString = "CIEAAAAAAAAAAAAAAAAAAAAAAsZmlZbMjZmZmZZbMGjZZGDAAAAAAAA00MDzYmhxs1GAGAYGsNAAwMTbzMLzAAsxCGAjxMMGAglZAzMDYsA" },
      -- No Leveling build published on Icy Veins as of this scrape -- substituting the Delves build.
      { context = "Leveling", buildLabel = "Delves - Templar (used as Leveling substitute)", exportString = "CIEAAAAAAAAAAAAAAAAAAAAAAsZmlZbMjZmZmZZbMGjZZGDAAAAAAAA00MDzYmhxs1GAGAYGsNAAwMTbzMLzAAsxCGAjxMMGAglZAzMDYsA", leveling = true },
    },
  },
  ["retribution"] = {
    talents = {
      { context = "Raid", buildLabel = "Retribution Single Target - Templar", exportString = "CYEAAAAAAAAAAAAAAAAAAAAAAAAAAAANbbzMzywMDAAAAAAzUGzwMjtxsNMz2MGjZGmxCbDAAgZm2mZ2mBAsBYAwYGmBzYMbYbGMMmxgB" },
      { context = "AoE", buildLabel = "Retribution AoE - Templar", exportString = "CYEAAAAAAAAAAAAAAAAAAAAAAAAAAAwoZbbmZWGzMzAAAAAAYmyYGmZsNmthZ2mxYMGmxGbAAAMz02Mz2MAgNADAGzwAzYmZDLzghxMGMA" },
      { context = "Mythic+", buildLabel = "Retribution Delves - Templar", exportString = "CYEAAAAAAAAAAAAAAAAAAAAAAAAAAAwoZbbmZWGjZmBAAAAAYmyYGMjtZmthZ2mxYMzwM2YDAAgZm2mZ2mBAsBYAAzwAzYGbYZGMmxMGMA" },
      -- No Leveling build published on Icy Veins as of this scrape -- substituting the Delves build.
      { context = "Leveling", buildLabel = "Retribution Delves - Templar (used as Leveling substitute)", exportString = "CYEAAAAAAAAAAAAAAAAAAAAAAAAAAAwoZbbmZWGjZmBAAAAAYmyYGMjtZmthZ2mxYMzwM2YDAAgZm2mZ2mBAsBYAAzwAzYGbYZGMmxMGMA", leveling = true },
    },
  },
}
