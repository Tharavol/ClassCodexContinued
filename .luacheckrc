std = "lua51"
-- Vendored libraries under Libs/ are not ours to lint.
exclude_files = {"Libs/**", ".luarocks/**", ".luarocks", "lua_modules/**", "packages/**"}
max_line_length = false

globals = {
    -- SavedVariables (declared in ClassCodex.toc)
    "ClassCodexDB", "ClassCodexCharDB",

    -- Data globals, one per Data/<Class>/*.lua file (assigned via `X = X or {}`)
    "ClassCodexData", "ClassCodexGearData", "ClassCodexIcyVeinsData",
    "ClassCodexIcyVeinsTalentData", "ClassCodexArchonData", "ClassCodexArchonGearData",
    "ClassCodexArchonStats", "ClassCodexBnetPvpTalents", "ClassCodexMurlokPvp",
    "ClassCodexCraftingData", "ClassCodexSources", "ClassCodexEmbellishmentEffects",
    "ClassCodex_LastScrape",

    -- AddonCompartmentFunc handlers referenced by name from ClassCodex.toc
    "ClassCodex_OnAddonCompartmentClick", "ClassCodex_OnAddonCompartmentEnter",
    "ClassCodex_OnAddonCompartmentLeave",

    -- Slash command registration (standard WoW global-table convention)
    "SLASH_CLASSCODEX1", "SLASH_CLASSCODEX2",

    -- Compendium.lua globals (pre-existing; not module-scoped locals)
    "SaveCompendiumState", "SetupClassDropdown", "SetupSpecDropdown", "SetupHeroDropdown",
}

-- WoW API globals used across the addon.
read_globals = {
    "LibStub", "SlashCmdList", "StaticPopupDialogs", "StaticPopup_Show",
    "CreateFrame", "UIParent", "GameTooltip", "GameFontNormal", "GameFontHighlight",
    "InCombatLockdown", "IsAddOnLoaded", "hooksecurefunc", "securecall",
    "C_AddOns", "C_Timer", "C_Item", "C_Spell", "C_Traits", "C_ClassTalents",
    "C_Texture", "C_TradeSkillUI", "C_CreatureInfo", "C_SpecializationInfo",
    "C_PvP", "C_Container",
    "GetSpecialization", "GetSpecializationInfo", "GetNumSpecializations",
    "UnitClass", "UnitClassBase", "UnitLevel", "UnitName", "UnitGUID",
    "PlaySound", "GetTime", "date", "time",
    "wipe", "tinsert", "tremove", "tContains",
    "strsplit", "strjoin", "strtrim", "strupper", "strlower", "format",
    "Settings", "CreateSettingsListSectionHeaderInitializer",
    "EasyMenu", "UIDropDownMenu_Initialize", "UIDropDownMenu_AddButton", "ToggleDropDownMenu",
}
