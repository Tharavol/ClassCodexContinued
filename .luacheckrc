std = "lua51"
-- Vendored libraries under Libs/ are not ours to lint.
exclude_files = {"Libs/**", ".luarocks/**", ".luarocks", "lua_modules/**", "packages/**"}
max_line_length = false

-- Unused-variable/argument and shadowing warnings are pre-existing throughout
-- the original addon (dead helper functions, unused constants, self/event
-- callback args, etc.) -- real cleanup, not something to silently fix as part
-- of relaunch tooling. Tracked for a future pass rather than fixed here.
--   W211/W214/W231 unused variable/loop variable/local
--   W212 unused argument
--   W411/W421/W431/W432 shadowing a local/upvalue/argument
--   W542 empty if branch
--   W581 negated comparison that could be simplified
--   W122 setting a field on a declared global (e.g. a private marker field
--        stashed on a Blizzard frame like PlayerSpellsFrame) -- standard WoW
--        addon pattern, not a bug
ignore = {"211", "212", "214", "231", "411", "421", "431", "432", "542", "581", "122"}

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

    -- Slash command registration (standard WoW global-table convention;
    -- SlashCmdList needs to be a writable global since the addon assigns
    -- SlashCmdList["CLASSCODEX"] directly rather than going through AceConsole)
    "SLASH_CLASSCODEX1", "SLASH_CLASSCODEX2", "SlashCmdList",

    -- Compendium.lua globals (pre-existing; not module-scoped locals)
    "SaveCompendiumState", "SetupClassDropdown", "SetupSpecDropdown", "SetupHeroDropdown",

    -- Pre-existing implicit globals: local declared later in the file than
    -- this write, so the write leaks a global instead of hitting the local.
    -- Not fixed here (behavior change, out of scope for this pass) -- see
    -- the "cachedRanks/equippedSpellIds leak as implicit globals" issue.
    "cachedRanks", "equippedSpellIds",
}

-- WoW API globals used across the addon (gathered by running luacheck and
-- collecting every "accessing undefined variable" it reported).
read_globals = {
    "LibStub", "StaticPopupDialogs", "StaticPopup_Show",
    "CreateFrame", "UIParent", "WorldFrame", "GameTooltip", "GameFontNormal", "GameFontHighlight",
    "UIErrorsFrame", "CharacterFrame", "PaperDollFrame", "PlayerSpellsFrame",
    "PlayerSpellsFrame_LoadUI", "TalentMicroButton", "UISpecialFrames",
    "ButtonFrameTemplate_HideButtonBar", "PanelTemplates_SetNumTabs", "PanelTemplates_SetTab",
    "ShowUIPanel", "ToggleCharacter", "RunNextFrame",
    "InCombatLockdown", "IsAddOnLoaded", "GetAddOnMetadata", "hooksecurefunc", "securecall",
    "issecurevariable", "geterrorhandler",
    "C_AddOns", "C_Timer", "C_Item", "C_Spell", "C_Traits", "C_ClassTalents",
    "C_Texture", "C_TradeSkillUI", "C_CreatureInfo", "C_SpecializationInfo",
    "C_PvP", "C_Container", "Constants", "Enum", "EventRegistry",
    "ExportUtil", "FrameUtil", "PlayerUtil", "TextureLoadingGroupMixin",
    "MinimalSliderWithSteppersMixin", "TooltipDataProcessor", "Menu", "MenuUtil", "MenuResponse",
    "GetSpecialization", "GetSpecializationInfo", "GetSpecializationInfoForClassID",
    "GetNumSpecializations", "GetInspectSpecialization", "CanInspect", "NotifyInspect",
    "UnitClass", "UnitClassBase", "UnitLevel", "UnitName", "UnitGUID",
    "UnitExists", "UnitIsPlayer", "UnitIsUnit", "UnitTokenFromGUID",
    "IsPlayerSpell", "GetPvpTalentInfoByID", "GetItemSpell", "GetItemCount",
    "GetItemInfo", "GetItemQualityColor", "GetInventoryItemLink", "IsEquippedItem",
    "GetCombatRating", "GetCombatRatingBonus", "GetCritChance", "GetHaste", "GetMasteryEffect",
    "CR_CRIT_MELEE", "CR_HASTE_MELEE", "CR_MASTERY", "CR_VERSATILITY_DAMAGE_DONE",
    "GetInstanceInfo", "IsInInstance", "IsInRaid", "GetNumGroupMembers",
    "IsModifiedClick", "IsShiftKeyDown", "ChatEdit_InsertLink", "DressUpItemLink",
    "GetLocale", "LOCALIZED_CLASS_NAMES_MALE", "RAID_CLASS_COLORS", "CLASS_ICON_TCOORDS",
    "CLOSE", "SETTINGS", "SOURCE", "SOUNDKIT", "RAID", "PLAYER_DIFFICULTY2", "PLAYER_DIFFICULTY6",
    "GetSpellInfo",
    "PlaySound", "GetTime", "date", "time",
    "wipe", "tinsert", "tremove", "tContains",
    "strsplit", "strjoin", "strtrim", "strupper", "strlower", "format",
    "Settings", "CreateSettingsListSectionHeaderInitializer",
    "EasyMenu", "UIDropDownMenu_Initialize", "UIDropDownMenu_AddButton", "ToggleDropDownMenu",
}
