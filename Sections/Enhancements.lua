local _, ns = ...
ns.Sections = ns.Sections or {}

local L = ns.L

-- Enhancements section — three sub-sections (Enchants, Gems, Consumables)
-- under a single "Enhancements" tab on both surfaces. All three come from
-- Wowhead.
local Enhancements = {}
ns.Sections.Enhancements = Enhancements

-------------------------------------------------------------------------------
-- Shared helpers
-------------------------------------------------------------------------------

local function StripEnchantPrefix(name)
    if not name or name == "" then return name end
    local stripped = name:match("^Enchant [^%-]+ %- (.+)$")
    return stripped or name
end

local function ResolveDisplayName(itemRef, fallback)
    if itemRef and itemRef.name and itemRef.name ~= "" then return itemRef.name end
    return fallback or ""
end

-------------------------------------------------------------------------------
-- Panel surface
-------------------------------------------------------------------------------

local panel = {}

local function MakePanelEnchantSubRow(parent)
    local sub = CreateFrame("Frame", nil, parent)
    sub:SetHeight(ns.ROW_HEIGHT)
    local name = sub:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name:SetPoint("LEFT", 0, 0); name:SetPoint("RIGHT", 0, 0)
    name:SetJustifyH("LEFT"); name:SetWordWrap(true)
    sub.text = name
    sub:EnableMouse(true)
    sub:SetScript("OnEnter", function(self)
        if self.spellId then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(self.spellId)
            GameTooltip:Show()
        elseif self.itemId then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetItemByID(self.itemId)
            GameTooltip:Show()
        end
    end)
    sub:SetScript("OnLeave", function() GameTooltip:Hide() end)
    sub:SetScript("OnMouseUp", ns.HandleItemClick)
    sub:Hide()
    return sub
end

-- opts.parent = ns.contentFrame, opts.collapsedKeys = saved collapse state, opts.refresh
function Enhancements.InitPanel(opts)
    local parent = opts.parent
    local iconSize = ns.ICON_SIZE_GEAR or 16

    -- Enchants
    panel.enchSection = CreateFrame("Frame", nil, parent)
    panel.enchSection:SetHeight(ns.SECTION_HEADER_HEIGHT)
    panel.enchHeader = ns.CreateSectionHeader(panel.enchSection, L["tab.enchants"])
    panel.enchContent = CreateFrame("Frame", nil, panel.enchSection)
    panel.enchContent:SetPoint("TOPLEFT", panel.enchHeader, "BOTTOMLEFT", 0, 0)
    panel.enchContent:SetPoint("RIGHT", 0, 0)
    panel.enchCollapsed = false
    ns.SetCollapsed(panel.enchContent, panel.enchHeader, panel.enchCollapsed)
    panel.enchHeader:SetScript("OnClick", function()
        panel.enchCollapsed = not panel.enchCollapsed
        ns.SetCollapsed(panel.enchContent, panel.enchHeader, panel.enchCollapsed)
        if ClassCodexCharDB and ClassCodexCharDB.collapsed then
            ClassCodexCharDB.collapsed.enchants = panel.enchCollapsed
        end
        if opts.refresh then opts.refresh() end
    end)

    panel.enchRows = {}
    for i = 1, ns.MAX_ENCHANT_ROWS do
        local row = CreateFrame("Frame", nil, panel.enchContent)
        row:SetHeight(ns.ROW_HEIGHT)
        ns.CreateRowIcon(row)
        row.icon:ClearAllPoints()
        row.icon:SetPoint("LEFT", row, "LEFT", 2, 0)
        local slot = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        slot:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
        slot:SetWidth(50); slot:SetJustifyH("LEFT"); slot:SetTextColor(0.6, 0.6, 0.6)
        row.slotText = slot
        local bestSub = MakePanelEnchantSubRow(row)
        bestSub:SetPoint("TOPLEFT", row, "TOPLEFT", 2 + iconSize + 4 + 50 + 2, 0)
        bestSub:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        row.bestSub = bestSub
        local altSub = MakePanelEnchantSubRow(row)
        altSub:SetPoint("TOPLEFT", bestSub, "BOTTOMLEFT", 0, 0)
        altSub:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        row.altSub = altSub
        row:Hide()
        panel.enchRows[i] = row
    end

    -- Source dropdown lives ABOVE the enchant section header (parented to
    -- the panel contentFrame, not enchContent). Only Wowhead remains as a
    -- source now, so RenderPanel below never actually shows this, but the
    -- widget stays since GearingSections.lua's layout pass positions it
    -- unconditionally.
    panel.sourceDropdown = ns.CreateOptionDropdown("ClassCodexDockEnhancementsSourceDropdown", parent)
    panel.sourceDropdown:Hide()

    -- Gems
    panel.gemSection = CreateFrame("Frame", nil, parent)
    panel.gemSection:SetHeight(ns.SECTION_HEADER_HEIGHT)
    panel.gemHeader = ns.CreateSectionHeader(panel.gemSection, L["tab.gems"])
    panel.gemContent = CreateFrame("Frame", nil, panel.gemSection)
    panel.gemContent:SetPoint("TOPLEFT", panel.gemHeader, "BOTTOMLEFT", 0, 0)
    panel.gemContent:SetPoint("RIGHT", 0, 0)
    panel.gemCollapsed = false
    ns.SetCollapsed(panel.gemContent, panel.gemHeader, panel.gemCollapsed)
    panel.gemHeader:SetScript("OnClick", function()
        panel.gemCollapsed = not panel.gemCollapsed
        ns.SetCollapsed(panel.gemContent, panel.gemHeader, panel.gemCollapsed)
        if ClassCodexCharDB and ClassCodexCharDB.collapsed then
            ClassCodexCharDB.collapsed.gems = panel.gemCollapsed
        end
        if opts.refresh then opts.refresh() end
    end)
    panel.gemRows = {}
    for i = 1, ns.MAX_GEM_ROWS do
        local row = CreateFrame("Frame", nil, panel.gemContent)
        row:SetHeight(ns.ROW_HEIGHT)
        ns.CreateRowIcon(row)
        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
        label:SetWidth(65); label:SetJustifyH("LEFT"); label:SetTextColor(0.6, 0.6, 0.6)
        row.labelText = label
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", label, "RIGHT", 4, 0)
        name:SetPoint("RIGHT", 0, 0); name:SetJustifyH("LEFT")
        row.itemText = name
        ns.SetupItemTooltip(row)
        row:Hide()
        panel.gemRows[i] = row
    end

    -- Consumables
    panel.consumSection = CreateFrame("Frame", nil, parent)
    panel.consumSection:SetHeight(ns.SECTION_HEADER_HEIGHT)
    panel.consumHeader = ns.CreateSectionHeader(panel.consumSection, L["tab.consumables"])
    panel.consumContent = CreateFrame("Frame", nil, panel.consumSection)
    panel.consumContent:SetPoint("TOPLEFT", panel.consumHeader, "BOTTOMLEFT", 0, 0)
    panel.consumContent:SetPoint("RIGHT", 0, 0); panel.consumContent:Show()
    panel.consumCollapsed = false
    ns.SetCollapsed(panel.consumContent, panel.consumHeader, panel.consumCollapsed)
    panel.consumHeader:SetScript("OnClick", function()
        panel.consumCollapsed = not panel.consumCollapsed
        ns.SetCollapsed(panel.consumContent, panel.consumHeader, panel.consumCollapsed)
        if ClassCodexCharDB and ClassCodexCharDB.collapsed then
            ClassCodexCharDB.collapsed.consumables = panel.consumCollapsed
        end
        if opts.refresh then opts.refresh() end
    end)
    panel.consumRows = {}
    for i = 1, ns.MAX_CONSUMABLE_ROWS do
        local row = CreateFrame("Frame", nil, panel.consumContent)
        row:SetHeight(ns.ROW_HEIGHT)
        ns.CreateRowIcon(row)
        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
        label:SetWidth(90); label:SetJustifyH("LEFT"); label:SetTextColor(0.6, 0.6, 0.6)
        row.labelText = label
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", label, "RIGHT", 4, 0)
        name:SetPoint("RIGHT", 0, 0); name:SetJustifyH("LEFT")
        row.itemText = name
        ns.SetupItemTooltip(row)
        row:Hide()
        panel.consumRows[i] = row
    end

    return {
        enchSection = panel.enchSection,
        gemSection = panel.gemSection,
        consumSection = panel.consumSection,
        sourceDropdown = panel.sourceDropdown,
    }
end

-- Accessors for the layout pass.
function Enhancements.GetPanelFrames()
    return {
        enchSection = panel.enchSection, enchContent = panel.enchContent, enchCollapsed = panel.enchCollapsed,
        gemSection = panel.gemSection, gemContent = panel.gemContent, gemCollapsed = panel.gemCollapsed,
        consumSection = panel.consumSection, consumContent = panel.consumContent, consumCollapsed = panel.consumCollapsed,
        sourceDropdown = panel.sourceDropdown,
    }
end

function Enhancements.RestorePanelCollapsedState(saved)
    if not saved then return end
    panel.enchCollapsed = saved.enchants or false
    panel.gemCollapsed = saved.gems or false
    panel.consumCollapsed = saved.consumables or false
    ns.SetCollapsed(panel.enchContent, panel.enchHeader, panel.enchCollapsed)
    ns.SetCollapsed(panel.gemContent, panel.gemHeader, panel.gemCollapsed)
    ns.SetCollapsed(panel.consumContent, panel.consumHeader, panel.consumCollapsed)
end

function Enhancements.HidePanelSourceDropdown()
    panel.sourceDropdown:Hide()
end

-- Active source on the docked Enhancements tab, as a registry key. Used by
-- the tab-title attribution button. Always Wowhead now.
function Enhancements.GetActiveSourceKey()
    return "wowhead"
end

-- args = {
--   wowheadEnchants, wowheadGems, consumables,  -- Wowhead-sourced records
--   showSourceDropdown,                         -- bool: only on Enhancements tab
--   specKey,                                    -- "MAGE-frost" etc.
--   onChange,                                   -- callback for refresh
-- }
-- Returns { enchHeight, gemCount, consumCount } for the layout pass.
function Enhancements.RenderPanel(args)
    panel.sourceDropdown:Hide()

    local activeEnchants = args.wowheadEnchants
    local activeGems = args.wowheadGems

    -- Enchants
    for i = 1, ns.MAX_ENCHANT_ROWS do panel.enchRows[i]:Hide() end
    local enchHeight = 0
    if activeEnchants and #activeEnchants > 0 then
        local count = math.min(#activeEnchants, ns.MAX_ENCHANT_ROWS)
        local yOff = 0
        for i = 1, count do
            local e = activeEnchants[i]
            local row = panel.enchRows[i]
            row.slotText:SetText(e.slot)
            ns.SetRowIcon(row, e.best.itemId, e.best.spellId)
            row.bestSub.text:SetText(ns.FormatItem(e.best, StripEnchantPrefix(ns.GetItemName(e.best))))
            row.bestSub.itemId = e.best.itemId
            row.bestSub.spellId = e.best.spellId
            row.bestSub:Show()
            local rowH = ns.ROW_HEIGHT
            if e.alternate then
                row.altSub.text:SetText(ns.FormatItem(e.alternate, StripEnchantPrefix(ns.GetItemName(e.alternate))))
                row.altSub.itemId = e.alternate.itemId
                row.altSub.spellId = e.alternate.spellId
                row.altSub:Show()
                rowH = ns.ROW_HEIGHT * 2
            else
                row.altSub:Hide()
            end
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, yOff)
            row:SetPoint("RIGHT", 0, 0)
            row:SetHeight(rowH)
            yOff = yOff - rowH
            row:Show()
        end
        enchHeight = math.abs(yOff)
        panel.enchSection:Show()
    else
        panel.enchSection:Hide()
    end

    -- Gems
    for i = 1, ns.MAX_GEM_ROWS do panel.gemRows[i]:Hide() end
    local gemCount = 0
    if activeGems then
        local idx = 0
        if activeGems.primary then
            idx = idx + 1
            local row = panel.gemRows[idx]
            row.labelText:SetText(L["gem.primary"])
            row.itemText:SetText(ns.FormatItem(activeGems.primary))
            row.itemId = activeGems.primary.itemId
            row.altItemId = nil; row.embItemId = nil
            ns.SetRowIcon(row, activeGems.primary.itemId)
            row:ClearAllPoints(); row:SetPoint("TOPLEFT", 0, 0); row:SetPoint("RIGHT", 0, 0)
            row:Show()
        end
        if activeGems.secondary then
            for _, gem in ipairs(activeGems.secondary) do
                idx = idx + 1
                if idx > ns.MAX_GEM_ROWS then break end
                local row = panel.gemRows[idx]
                row.labelText:SetText(L["gem.secondary"])
                row.itemText:SetText(ns.FormatItem(gem))
                row.itemId = gem.itemId
                row.altItemId = nil; row.embItemId = nil
                ns.SetRowIcon(row, gem.itemId)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", 0, -(idx - 1) * ns.ROW_HEIGHT)
                row:SetPoint("RIGHT", 0, 0)
                row:Show()
            end
        end
        gemCount = idx
        if idx > 0 then panel.gemSection:Show() else panel.gemSection:Hide() end
    else
        panel.gemSection:Hide()
    end

    -- Consumables (Wowhead only)
    for i = 1, ns.MAX_CONSUMABLE_ROWS do panel.consumRows[i]:Hide() end
    local consumCount = 0
    if args.consumables then
        local idx = 0
        for _, key in ipairs(ns.CONSUMABLE_ORDER) do
            local item = args.consumables[key]
            if item then
                idx = idx + 1
                if idx > ns.MAX_CONSUMABLE_ROWS then break end
                local row = panel.consumRows[idx]
                row.labelText:SetText(ns.CONSUMABLE_LABELS[key] or key)
                row.itemText:SetText(ns.FormatItem(item))
                row.itemId = item.itemId
                row.altItemId = nil; row.embItemId = nil
                ns.SetRowIcon(row, item.itemId)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", 0, -(idx - 1) * ns.ROW_HEIGHT)
                row:SetPoint("RIGHT", 0, 0)
                row:Show()
            end
        end
        consumCount = idx
        if idx > 0 then panel.consumSection:Show() else panel.consumSection:Hide() end
    else
        panel.consumSection:Hide()
    end

    return enchHeight, gemCount, consumCount
end

-------------------------------------------------------------------------------
-- Compendium surface
-------------------------------------------------------------------------------

local comp = {}

-- Active source on the Compendium Enhancements section, as a registry key.
-- Always Wowhead now.
function Enhancements.GetCompendiumSourceKey()
    return "wowhead"
end

local function MakeCompendiumEnchantSubRow(parent)
    local sub = CreateFrame("Button", nil, parent)
    sub:SetHeight(ns.ROW_HEIGHT)
    sub:RegisterForClicks("LeftButtonUp")
    local text = sub:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", 0, 0); text:SetPoint("RIGHT", 0, 0)
    text:SetJustifyH("LEFT"); text:SetWordWrap(false)
    sub.text = text
    sub:SetScript("OnEnter", function(self)
        if self.itemId then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:SetItemByID(self.itemId); GameTooltip:Show()
        elseif self.spellId then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:SetSpellByID(self.spellId); GameTooltip:Show()
        end
    end)
    sub:SetScript("OnLeave", function() GameTooltip:Hide() end)
    sub:SetScript("OnClick", function(self)
        if not self.itemId then return end
        local _, link = C_Item.GetItemInfo(self.itemId)
        if not link then return end
        if IsModifiedClick("CHATLINK") then ChatEdit_InsertLink(link)
        elseif IsModifiedClick("DRESSUP") then DressUpItemLink(link) end
    end)
    sub:Hide()
    return sub
end

-- opts.parent + opts.headerFactory + opts.rowFactory + opts.refresh + opts.iconSize
function Enhancements.InitCompendium(opts)
    local iconSize = opts.iconSize or 16

    -- Enchants section
    comp.enchSection = CreateFrame("Frame", nil, opts.parent)
    comp.enchHeader = opts.headerFactory(comp.enchSection, L["tab.enchants"], true)
    comp.enchContent = CreateFrame("Frame", nil, comp.enchSection)
    comp.enchContent:SetPoint("TOPLEFT", comp.enchHeader, "BOTTOMLEFT", 0, -2)
    comp.enchContent:SetPoint("RIGHT", 0, 0)

    comp.sourceDropdown = CreateFrame(
        "DropdownButton", "ClassCodexCompEnhancementsSourceDD",
        opts.parent, "WowStyle1DropdownTemplate"
    )
    comp.sourceDropdown:SetHeight(24); comp.sourceDropdown:Hide()

    comp.enchRows = {}; comp.enchCollapsed = false
    for i = 1, ns.MAX_ENCHANT_ROWS do
        local row = CreateFrame("Frame", nil, comp.enchContent)
        row:SetHeight(ns.ROW_HEIGHT)
        ns.CreateRowIcon(row)
        row.icon:ClearAllPoints(); row.icon:SetPoint("LEFT", row, "LEFT", 2, 0)
        local slot = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        slot:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
        slot:SetWidth(55); slot:SetJustifyH("LEFT"); slot:SetTextColor(0.6, 0.6, 0.6)
        row.slot = slot
        local bestSub = MakeCompendiumEnchantSubRow(row)
        bestSub:SetPoint("TOPLEFT", row, "TOPLEFT", 2 + iconSize + 4 + 55 + 2, 0)
        bestSub:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        row.bestSub = bestSub
        local altSub = MakeCompendiumEnchantSubRow(row)
        altSub:SetPoint("TOPLEFT", bestSub, "BOTTOMLEFT", 0, 0)
        altSub:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        row.altSub = altSub
        comp.enchRows[i] = row
    end
    comp.pvpFallback = comp.enchContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    comp.pvpFallback:SetTextColor(0.5, 0.5, 0.5); comp.pvpFallback:Hide()
    comp.enchHeader:SetScript("OnClick", function()
        comp.enchCollapsed = not comp.enchCollapsed
        ns.SetCollapsed(comp.enchContent, comp.enchHeader, comp.enchCollapsed)
        if opts.refresh then opts.refresh() end
    end)

    -- Gems
    comp.gemSection = CreateFrame("Frame", nil, opts.parent)
    comp.gemHeader = opts.headerFactory(comp.gemSection, L["tab.gems"], true)
    comp.gemContent = CreateFrame("Frame", nil, comp.gemSection)
    comp.gemContent:SetPoint("TOPLEFT", comp.gemHeader, "BOTTOMLEFT", 0, -2)
    comp.gemContent:SetPoint("RIGHT", 0, 0)
    comp.gemRows = {}; comp.gemCollapsed = false
    for i = 1, ns.MAX_GEM_ROWS do
        local row = opts.rowFactory(comp.gemContent)
        ns.CreateRowIcon(row)
        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
        label:SetWidth(65); label:SetJustifyH("LEFT"); label:SetTextColor(0.6, 0.6, 0.6)
        row.label = label
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", label, "RIGHT", 4, 0); name:SetPoint("RIGHT", 0, 0)
        name:SetJustifyH("LEFT")
        row.name = name
        comp.gemRows[i] = row
    end
    comp.gemHeader:SetScript("OnClick", function()
        comp.gemCollapsed = not comp.gemCollapsed
        ns.SetCollapsed(comp.gemContent, comp.gemHeader, comp.gemCollapsed)
        if opts.refresh then opts.refresh() end
    end)

    -- Consumables (non-collapsible)
    comp.consumSection = CreateFrame("Frame", nil, opts.parent)
    comp.consumHeader = opts.headerFactory(comp.consumSection, L["tab.consumables"], false)
    comp.consumContent = CreateFrame("Frame", nil, comp.consumSection)
    comp.consumContent:SetPoint("TOPLEFT", comp.consumHeader, "BOTTOMLEFT", 0, -2)
    comp.consumContent:SetPoint("RIGHT", 0, 0)
    comp.consumRows = {}; comp.consumCollapsed = false
    for i = 1, ns.MAX_CONSUMABLE_ROWS do
        local row = opts.rowFactory(comp.consumContent)
        ns.CreateRowIcon(row)
        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
        label:SetWidth(90); label:SetJustifyH("LEFT"); label:SetTextColor(0.6, 0.6, 0.6)
        row.label = label
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", label, "RIGHT", 4, 0); name:SetPoint("RIGHT", 0, 0); name:SetJustifyH("LEFT")
        row.name = name
        comp.consumRows[i] = row
    end

    return {
        enchSection = comp.enchSection, enchHeader = comp.enchHeader, enchContent = comp.enchContent,
        gemSection = comp.gemSection, gemHeader = comp.gemHeader, gemContent = comp.gemContent,
        consumSection = comp.consumSection, consumHeader = comp.consumHeader, consumContent = comp.consumContent,
        sourceDropdown = comp.sourceDropdown,
    }
end

function Enhancements.GetCompendiumFrames()
    return {
        enchSection = comp.enchSection, enchContent = comp.enchContent, enchCollapsed = comp.enchCollapsed,
        gemSection = comp.gemSection, gemContent = comp.gemContent, gemCollapsed = comp.gemCollapsed,
        consumSection = comp.consumSection, consumContent = comp.consumContent, consumCollapsed = comp.consumCollapsed,
        sourceDropdown = comp.sourceDropdown,
        enchRows = comp.enchRows, gemRows = comp.gemRows, consumRows = comp.consumRows,
        pvpFallback = comp.pvpFallback,
    }
end

-- args = { wowheadEnchants, wowheadGems, consumables, specKey, getDisplayName, refresh }
function Enhancements.RenderCompendiumEnchantsGems(args)
    comp.pvpFallback:Hide()
    comp.sourceDropdown:Hide()
    if not args.wowheadEnchants and not args.wowheadGems then return end

    local activeEnchants, activeGems = args.wowheadEnchants, args.wowheadGems

    if activeEnchants then
        for i = 1, ns.MAX_ENCHANT_ROWS do comp.enchRows[i]:Hide() end
        local count = math.min(#activeEnchants, ns.MAX_ENCHANT_ROWS)
        local yOff = 0
        local getName = args.getDisplayName or function(ref) return ResolveDisplayName(ref) end
        for i = 1, count do
            local e = activeEnchants[i]
            local row = comp.enchRows[i]
            row.slot:SetText(e.slot or "")
            ns.SetRowIcon(row, e.best and e.best.itemId, e.best and e.best.spellId)
            local bestName = StripEnchantPrefix(getName(e.best))
            row.bestSub.text:SetText(ns.FormatItem(e.best, bestName))
            row.bestSub.itemId = e.best and e.best.itemId
            row.bestSub.spellId = e.best and e.best.spellId
            row.bestSub:Show()
            local rowH = ns.ROW_HEIGHT
            if e.alternate then
                local altName = StripEnchantPrefix(getName(e.alternate))
                row.altSub.text:SetText(ns.FormatItem(e.alternate, altName))
                row.altSub.itemId = e.alternate.itemId
                row.altSub.spellId = e.alternate.spellId
                row.altSub:Show()
                rowH = ns.ROW_HEIGHT * 2
            else
                row.altSub:Hide()
            end
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", comp.enchContent, "TOPLEFT", 0, yOff)
            row:SetPoint("RIGHT", comp.enchContent, "RIGHT", 0, 0)
            row:SetHeight(rowH)
            yOff = yOff - rowH
            row:Show()
        end
        comp.enchContent:SetHeight(math.abs(yOff))
        comp.enchSection:Show()
    end

    if activeGems then
        for i = 1, ns.MAX_GEM_ROWS do comp.gemRows[i]:Hide() end
        local gIdx = 0
        if activeGems.primary then
            gIdx = gIdx + 1
            local row = comp.gemRows[gIdx]
            row.label:SetText(L["gem.primary"])
            row.name:SetText(ns.FormatItem(activeGems.primary))
            row.itemId = activeGems.primary.itemId
            ns.SetRowIcon(row, activeGems.primary.itemId)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", comp.gemContent, "TOPLEFT", 0, 0)
            row:SetPoint("RIGHT", comp.gemContent, "RIGHT", 0, 0)
            row:Show()
        end
        if activeGems.secondary then
            for _, gem in ipairs(activeGems.secondary) do
                gIdx = gIdx + 1
                if gIdx > ns.MAX_GEM_ROWS then break end
                local row = comp.gemRows[gIdx]
                row.label:SetText(L["gem.secondary"])
                row.name:SetText(ns.FormatItem(gem))
                row.itemId = gem.itemId
                ns.SetRowIcon(row, gem.itemId)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", comp.gemContent, "TOPLEFT", 0, -(gIdx - 1) * ns.ROW_HEIGHT)
                row:SetPoint("RIGHT", comp.gemContent, "RIGHT", 0, 0)
                row:Show()
            end
        end
        comp.gemContent:SetHeight(gIdx * ns.ROW_HEIGHT)
        comp.gemSection:Show()
    end
end

function Enhancements.RenderCompendiumConsumables(args)
    if not args.consumables then return end
    for i = 1, ns.MAX_CONSUMABLE_ROWS do comp.consumRows[i]:Hide() end
    local idx = 0
    for _, key in ipairs(ns.CONSUMABLE_ORDER) do
        local c = args.consumables[key]
        if c then
            idx = idx + 1
            if idx > ns.MAX_CONSUMABLE_ROWS then break end
            local row = comp.consumRows[idx]
            row.label:SetText(ns.CONSUMABLE_LABELS[key] or key)
            row.name:SetText(ns.FormatItem(c))
            row.itemId = c.itemId
            ns.SetRowIcon(row, c.itemId)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", comp.consumContent, "TOPLEFT", 0, -(idx - 1) * ns.ROW_HEIGHT)
            row:SetPoint("RIGHT", comp.consumContent, "RIGHT", 0, 0)
            row:Show()
        end
    end
    comp.consumContent:SetHeight(idx * ns.ROW_HEIGHT)
    comp.consumSection:Show()
end

function Enhancements.GetCompendiumEnchantHeight()
    local h = 0
    for i = 1, ns.MAX_ENCHANT_ROWS do
        if comp.enchRows[i]:IsShown() then h = h + comp.enchRows[i]:GetHeight() end
    end
    if comp.pvpFallback:IsShown() then h = h + 20 end
    return h
end

function Enhancements.GetCompendiumGemHeight()
    local h = 0
    for i = 1, ns.MAX_GEM_ROWS do
        if comp.gemRows[i]:IsShown() then h = h + ns.ROW_HEIGHT end
    end
    return h
end

function Enhancements.GetCompendiumConsumHeight()
    local h = 0
    for i = 1, ns.MAX_CONSUMABLE_ROWS do
        if comp.consumRows[i]:IsShown() then h = h + ns.ROW_HEIGHT end
    end
    return h
end
