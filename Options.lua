local _, GIP = ...
local panel = CreateFrame("Frame", "GatherIndicatorPlusOptionsPanel")
panel.name = "GatherIndicatorPlus"
local controls, radios, sliders = {}, {}, {}

local function font(text, template, x, y, width)
    local f = panel:CreateFontString(nil, "ARTWORK", template)
    f:SetPoint("TOPLEFT", x, y)
    if width then f:SetWidth(width); f:SetJustifyH("LEFT") end
    f:SetText(text)
    return f
end
local function heading(text, x, y)
    font(text, "GameFontNormal", x, y)
end
local function checkbox(label, key, x, y)
    local c = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    c:SetPoint("TOPLEFT", x, y)
    local t = c.Text or c.text
    if t then t:SetText(label) end
    c:SetScript("OnClick", function(self)
        if GIP.db then GIP.db[key] = self:GetChecked() and true or false end
    end)
    controls[key] = c
end
local function radio(label, key, value, x, y)
    local c = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
    c:SetPoint("TOPLEFT", x, y)
    local t = font(label, "GameFontHighlight", x + 30, y - 5, 240)
    c:Disable()
    t:SetTextColor(0.5, 0.5, 0.5)
    radios[#radios + 1] = { control = c, key = key, value = value }
end
local function slider(label, key, minimum, maximum, step, x, y, suffix)
    local s = CreateFrame("Slider", "GIPSlider" .. key, panel, "OptionsSliderTemplate")
    s:SetPoint("TOPLEFT", x, y)
    s:SetSize(230, 16)
    s:SetMinMaxValues(minimum, maximum)
    s:SetValueStep(step)
    if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
    local labelRegion = _G[s:GetName() .. "Text"]
    local low = _G[s:GetName() .. "Low"]
    local high = _G[s:GetName() .. "High"]
    if low then low:SetText(tostring(minimum)) end
    if high then high:SetText(tostring(maximum)) end
    s:SetScript("OnValueChanged", function(_, value)
        local rounded = math.floor(value / step + 0.5) * step
        if labelRegion then labelRegion:SetText(label .. ": " .. tostring(rounded) .. (suffix or "")) end
    end)
    s:Disable()
    sliders[#sliders + 1] = { control = s, key = key }
end
local function button(label, x, y, width, callback)
    local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    b:SetSize(width, 24)
    b:SetPoint("TOPLEFT", x, y)
    b:SetText(label)
    b:SetScript("OnClick", callback)
end

font("GatherIndicatorPlus", "GameFontNormalLarge", 16, -16)
font("Gathering minimap settings | Diagnostic prototype v0.2.2", "GameFontHighlightSmall", 16, -42)

-- Two-column layout. All widgets share panel as their parent: no scroll frame.
heading("General", 16, -78)
checkbox("Enable GatherIndicatorPlus", "enabled", 16, -100)

heading("Node appearance (pending API feasibility)", 16, -154)
radio("Resource icons", "markerMode", "icon", 20, -180)
radio("Blizzard tracking dots", "markerMode", "dot", 20, -210)
slider("Icon size", "iconSize", 8, 32, 1, 26, -276, " px")
slider("Scale", "scale", 50, 200, 5, 26, -344, "%")
slider("Opacity", "opacity", 20, 100, 5, 26, -412, "%")

local right = 370
heading("Skill difficulty (pending API feasibility)", right, -78)
radio("Chevrons / minus", "indicatorMode", "chevrons", right + 4, -106)
radio("Color-coded marker", "indicatorMode", "color", right + 4, -136)
radio("Both", "indicatorMode", "both", right + 4, -166)
radio("Off", "indicatorMode", "none", right + 4, -196)
font("Blizzard profession colors", "GameFontHighlightSmall", right + 4, -242, 280)
font("Gray: minus  |  Green: 1 chevron", "GameFontHighlightSmall", right + 4, -262, 300)
font("Yellow: 2  |  Orange: 3  |  Red: minus", "GameFontHighlightSmall", right + 4, -280, 310)

heading("Diagnostics", right, -330)
checkbox("Enable diagnostic event logging", "debug", right, -352)
button("Report APIs", right + 4, -405, 110, function() if GIP.Report then GIP.Report() end end)
button("Scan Minimap", right + 124, -405, 120, function() if GIP.Scan then GIP.Scan() end end)
button("Probe Dot", right + 4, -444, 110, function() if GIP.Probe then GIP.Probe() end end)
button("Defaults", 16, -485, 96, function()
    if GIP.ResetDefaults then GIP.ResetDefaults() end
    if GIP.RefreshOptions then GIP.RefreshOptions() end
end)
font("Visual controls are disabled until node access is verified.", "GameFontHighlightSmall", 130, -490, 490)

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
