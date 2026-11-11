local addonName, GIP = ...
_G.GIP = GIP
GIP.version = "0.2.2"
GIP.defaults = { enabled = true, showIndicators = true, iconSize = 18, scale = 100, opacity = 90, markerMode = "icon", indicatorMode = "chevrons", indicatorPosition = "bottom-right", debug = false }
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("MINIMAP_UPDATE_TRACKING")
frame:RegisterEvent("SKILL_LINES_CHANGED")
local function printMessage(message)
    print("|cff00ccffGIP|r: " .. tostring(message))
end
GIP.Print = printMessage
local function copyDefaults()
    if type(GIPDB) ~= "table" then GIPDB = {} end
    for key, value in pairs(GIP.defaults) do
        if GIPDB[key] == nil then GIPDB[key] = value end
    end
    GIP.db = GIPDB
end
function GIP.ResetDefaults()
    GIPDB = {}
    copyDefaults()
    printMessage("Settings reset.")
end
SLASH_GATHERINDICATORPLUS1 = "/gip"
SlashCmdList.GATHERINDICATORPLUS = function(input)
    local command = (input or ""):match("^%s*(%S*)")
    command = command and command:lower() or ""
    if command == "options" or command == "config" or command == "" then
        if GIP.OpenOptions then GIP.OpenOptions() end
    elseif command == "scan" then
        if GIP.Scan then GIP.Scan() end
    elseif command == "probe" then
        if GIP.Probe then GIP.Probe() end
    elseif command == "report" then
        if GIP.Report then GIP.Report() end
    elseif command == "debug" then
        GIP.db.debug = not GIP.db.debug
        printMessage("Debug: " .. tostring(GIP.db.debug))
    elseif command == "reset" then
        GIP.ResetDefaults()
    elseif command == "on" or command == "off" then
        GIP.db.enabled = command == "on"
        printMessage("Enabled: " .. tostring(GIP.db.enabled))
    else
        printMessage("v" .. GIP.version .. " | /gip report | /gip scan | /gip probe | /gip debug | /gip on | /gip off | /gip reset | /gip options")
    end
end
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        copyDefaults()
    elseif event == "PLAYER_LOGIN" then
        if not GIP.db then copyDefaults() end
        printMessage("Diagnostic ready. Enable Find Herbs or Find Minerals, then /gip report and /gip scan.")
    elseif GIP.db and GIP.db.debug then
        printMessage("Event: " .. event)
    end
end)
