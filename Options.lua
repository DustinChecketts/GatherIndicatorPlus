local _, GIP = ...
local panel = CreateFrame("Frame", "GatherIndicatorPlusOptionsPanel")
panel.name = "GatherIndicatorPlus"
local scroll = CreateFrame("ScrollFrame", "GIPOptionsScrollFrame", panel, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 0, 0)
scroll:SetPoint("BOTTOMRIGHT", -28, 0)
local content = CreateFrame("Frame", nil, scroll)
content:SetSize(520, 720)
scroll:SetScrollChild(content)
local controls, radios, sliders = {}, {}, {}
local function font(text, template, x, y, width)
    local f = content:CreateFontString(nil, "ARTWORK", template)
    f:SetPoint("TOPLEFT", x, y)
    if width then f:SetWidth(width); f:SetJustifyH("LEFT") end
    f:SetText(text)
    return f
end
font("GatherIndicatorPlus", "GameFontNormalLarge", 16, -16)
font("Gathering minimap settings | Diagnostic prototype v0.2.0", "GameFontHighlightSmall", 16, -42)
local function heading(text, y) font(text, "GameFontNormal", 16, y) end
local function checkbox(label, key, y, supported)
    local c = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    c:SetPoint("TOPLEFT", 16, y)
    local t = c.Text or c.text
    if t then t:SetText(label) end
    c:SetScript("OnClick", function(self)
        if GIP.db then GIP.db[key] = self:GetChecked() and true or false end
    end)
    if not supported then c:Disable() end
    controls[key] = c
end
local function radio(label, key, value, y, supported)
    local c = CreateFrame("CheckButton", nil, content, "UIRadioButtonTemplate")
    c:SetPoint("TOPLEFT", 24, y)
    local t = font(label, "GameFontHighlight", 54, y - 5, 390)
    if not supported then c:Disable(); t:SetTextColor(0.5, 0.5, 0.5) end
    c:SetScript("OnClick", function()
        if not GIP.db then return end
        GIP.db[key] = value
        if GIP.RefreshOptions then GIP.RefreshOptions() end
    end)
    radios[#radios + 1] = { control = c, key = key, value = value }
end
local function slider(label, key, minimum, maximum, step, y, supported, suffix)
    local s = CreateFrame("Slider", "GIPSlider" .. key, panel, "OptionsSliderTemplate")
    s:SetPoint("TOPLEFT", 22, y)
    s:SetSize(235, 16)
    s:SetMinMaxValues(minimum, maximum)
    s:SetValueStep(step)
    if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
    local labelRegion = _G[s:GetName() .. "Text"]
    local low = _G[s:GetName() .. "Low"]
    local high = _G[s:GetName() .. "High"]
    if low then low:SetText(tostring(minimum)) end
    if high then high:SetText(tostring(maximum)) end
    s:SetScript("OnValueChanged", function(self, value)
        local rounded = math.floor(value / step + 0.5) * step
        if GIP.db and supported then GIP.db[key] = rounded end
        if labelRegion then labelRegion:SetText(label .. ": " .. tostring(rounded) .. (suffix or "")) end
    end)
    if not supported then s:Disable() end
    sliders[#sliders + 1] = { control = s, key = key }
end
local function button(label, x, y, width, callback)
    local b = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    b:SetSize(width, 24)
    b:SetPoint("TOPLEFT", x, y)
    b:SetText(label)
    b:SetScript("OnClick", callback)
end
heading("General", -70)
checkbox("Enable GatherIndicatorPlus", "enabled", -90, true)
heading("Node appearance (pending API feasibility)", -132)
radio("Resource icons", "markerMode", "icon", -154, false)
radio("Blizzard tracking dots", "markerMode", "dot", -180, false)
slider("Icon size", "iconSize", 8, 32, 1, -218, false, " px")
slider("Scale", "scale", 50, 200, 5, -268, false, "%")
slider("Opacity", "opacity", 20, 100, 5, -318, false, "%")
heading("Skill difficulty (pending API feasibility)", -364)
radio("Chevrons / minus", "indicatorMode", "chevrons", -386, false)
radio("Color-coded marker", "indicatorMode", "color", -412, false)
radio("Both", "indicatorMode", "both", -438, false)
radio("Off", "indicatorMode", "none", -464, false)
heading("Diagnostics", -504)
checkbox("Enable diagnostic event logging", "debug", -526, true)
button("Report APIs", 16, -565, 110, function() if GIP.Report then GIP.Report() end end)
button("Scan Minimap", 136, -565, 120, function() if GIP.Scan then GIP.Scan() end end)
button("Defaults", 16, -604, 96, function()
    if GIP.ResetDefaults then GIP.ResetDefaults() end
    if GIP.RefreshOptions then GIP.RefreshOptions() end
end)
font("Gray: minus | Green: 1 chevron | Yellow: 2 | Orange: 3 | Red: minus", "GameFontHighlightSmall", 16, -640, 500)
font("Visual controls are disabled until node access is verified. Preferences are stored in GIPDB.", "GameFontHighlightSmall", 16, -664, 500)
function GIP.RefreshOptions()
    if not GIP.db then return end
    for key, c in pairs(controls) do c:SetChecked(GIP.db[key]) end
    for _, r in ipairs(radios) do r.control:SetChecked(GIP.db[r.key] == r.value) end
    for _, s in ipairs(sliders) do s.control:SetValue(GIP.db[s.key] or 0) end
end
panel:SetScript("OnShow", GIP.RefreshOptions)
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
        GIP.Print("Options registration unavailable.")
    end
end
