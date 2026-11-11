local _, GIP = ...
local panel = CreateFrame("Frame", "GatherIndicatorPlusOptionsPanel")
panel.name = "GatherIndicatorPlus"
local controls = {}
local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("GatherIndicatorPlus")
local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetText("Gathering minimap enhancements | Diagnostic prototype v0.1.1")
local function checkbox(label, key, y)
    local button = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    button:SetPoint("TOPLEFT", 16, y)
    local labelRegion = button.Text or button.text
    if labelRegion then labelRegion:SetText(label) end
    controls[key] = button
    button:SetScript("OnClick", function(self)
        if not GIP.db then return end
        GIP.db[key] = self:GetChecked() and true or false
        if key == "debug" then GIP.Print("Diagnostic logging " .. (GIP.db.debug and "enabled" or "disabled")) end
    end)
end
local function heading(text, y)
    local font = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    font:SetPoint("TOPLEFT", 16, y)
    font:SetText(text)
end
heading("General", -66)
checkbox("Enable GatherIndicatorPlus", "enabled", -88)
checkbox("Show gathering difficulty indicators (when supported)", "showIndicators", -118)
heading("Diagnostics", -160)
checkbox("Enable diagnostic logging", "debug", -182)
local note = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
note:SetPoint("TOPLEFT", 20, -218)
note:SetWidth(460)
note:SetJustifyH("LEFT")
note:SetText("Diagnostic logging is off by default. Manual reports and scans are always available below. This prototype does not yet alter minimap dots.")
local function button(label, x, y, width, callback)
    local control = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    control:SetSize(width, 24)
    control:SetPoint("TOPLEFT", x, y)
    control:SetText(label)
    control:SetScript("OnClick", callback)
end
button("Report APIs", 16, -282, 110, function() if GIP.Report then GIP.Report() end end)
button("Scan Minimap", 136, -282, 120, function() if GIP.Scan then GIP.Scan() end end)
button("Defaults", 16, -334, 96, function()
    if GIP.ResetDefaults then GIP.ResetDefaults() end
    for key, control in pairs(controls) do control:SetChecked(GIP.db and GIP.db[key]) end
end)
panel:SetScript("OnShow", function()
    for key, control in pairs(controls) do control:SetChecked(GIP.db and GIP.db[key]) end
end)
local category
if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
    category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
end
function GIP.OpenOptions()
    if category and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(category.GetID and category:GetID() or category.ID)
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    else
        GIP.Print("Options panel registration is unavailable on this client.")
    end
end
