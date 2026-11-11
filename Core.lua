local addonName, GIP = ...
_G.GIP = GIP
GIP.version = "0.1.0"
GIP.defaults = { enabled = true, showIndicators = true, iconSize = 14, debug = false }
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
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
SLASH_GATHERINDICATORPLUS1 = "/gip"
SlashCmdList.GATHERINDICATORPLUS = function(input)
    local command = (input or ""):match("^%s*(%S*)")
    command = command and command:lower() or ""
    if command == "scan" then
        if GIP.Scan then GIP.Scan() end
    elseif command == "report" then
        if GIP.Report then GIP.Report() end
    elseif command == "debug" then
        GIP.db.debug = not GIP.db.debug
        printMessage("Debug: " .. tostring(GIP.db.debug))
    elseif command == "reset" then
        GIPDB = {}
        copyDefaults()
        printMessage("Settings reset.")
    elseif command == "on" or command == "off" then
        GIP.db.enabled = command == "on"
        printMessage("Enabled: " .. tostring(GIP.db.enabled))
    else
        printMessage("v" .. GIP.version .. " | /gip report | /gip scan | /gip debug | /gip on | /gip off | /gip reset")
    end
end
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        copyDefaults()
    elseif event == "PLAYER_LOGIN" then
        if not GIP.db then copyDefaults() end
        printMessage("Diagnostic ready. Enable Find Herbs or Find Minerals, then /gip report and /gip scan.")
    end
end)
