local _, GIP = ...
local function yes(value) return value and "yes" or "no" end
local function safeCall(func, ...)
    if type(func) ~= "function" then return "unavailable" end
    local ok, value = pcall(func, ...)
    if not ok then return "error (protected or incompatible)" end
    if value == nil then return "nil" end
    if type(issecretvalue) == "function" then
        local checkOK, secret = pcall(issecretvalue, value)
        if not checkOK or secret then return "protected" end
    end
    if type(value) == "boolean" or type(value) == "number" or type(value) == "string" then
        return tostring(value)
    end
    return type(value)
end
local function countChildren(frame)
    if not frame or type(frame.GetChildren) ~= "function" then return "unavailable" end
    local ok, children = pcall(function() return {frame:GetChildren()} end)
    if not ok then return "protected" end
    return #children
end
function GIP.Report()
    GIP.Print("Build: " .. safeCall(GetBuildInfo))\n    GIP.Print("Minimap.UpdateMouseoverAtPoint: " .. yes(Minimap and type(Minimap.UpdateMouseoverAtPoint) == "function"))\n    GIP.Print("GetMouseFoci: " .. yes(type(GetMouseFoci) == "function"))
    GIP.Print("Project ID: " .. safeCall(function() return WOW_PROJECT_ID end))
    GIP.Print("Minimap present: " .. yes(Minimap ~= nil))
    GIP.Print("C_Minimap: " .. yes(type(C_Minimap) == "table"))
    GIP.Print("C_Minimap.GetNumTrackingTypes: " .. yes(type(C_Minimap) == "table" and type(C_Minimap.GetNumTrackingTypes) == "function"))
    GIP.Print("GetNumTrackingTypes: " .. yes(type(GetNumTrackingTypes) == "function"))
    GIP.Print("GetTrackingInfo: " .. yes(type(GetTrackingInfo) == "function"))
    GIP.Print("C_Minimap.GetTrackingInfo: " .. yes(type(C_Minimap) == "table" and type(C_Minimap.GetTrackingInfo) == "function"))
    GIP.Print("C_Minimap.GetViewRadius: " .. yes(type(C_Minimap) == "table" and type(C_Minimap.GetViewRadius) == "function"))
    GIP.Print("C_Map.GetBestMapForUnit: " .. yes(type(C_Map) == "table" and type(C_Map.GetBestMapForUnit) == "function"))
end
function GIP.Scan()
    if not Minimap then GIP.Print("No minimap frame."); return end
    GIP.Print("Minimap children: " .. tostring(countChildren(Minimap)))
    GIP.Print("Tracking type count (legacy): " .. safeCall(GetNumTrackingTypes))
    if type(C_Minimap) == "table" then
        GIP.Print("Tracking type count (C_Minimap): " .. safeCall(C_Minimap.GetNumTrackingTypes))
    end
    GIP.Print("Minimap zoom: " .. safeCall(function() return Minimap:GetZoom() end))
    GIP.Print("Minimap rotation: " .. safeCall(function() return Minimap:GetRotation() end))
    GIP.Print("Player map ID: " .. safeCall(function() return C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player") end))
    GIP.Print("Native tracking dots are not modified by this build.")
end

-- Non-invasive probe: never moves the minimap, cursor, or tracking state.
local function safeValue(value)
    if value == nil then return "nil" end
    if type(issecretvalue) == "function" then
        local ok, secret = pcall(issecretvalue, value)
        if not ok or secret then return "protected" end
    end
    if type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
        return tostring(value)
    end
    return type(value)
end
local function inspectTooltip(tooltip)
    if not tooltip then return "unavailable" end
    local lines = {}
    local ok, count = pcall(tooltip.NumLines, tooltip)
    if not ok or type(count) ~= "number" then return "unavailable" end
    for i = 1, math.min(count, 5) do
        local region = _G[tooltip:GetName() .. "TextLeft" .. i]
        if region then
            local success, value = pcall(region.GetText, region)
            if success and value ~= nil then
                lines[#lines + 1] = safeValue(value)
            end
        end
    end
    return table.concat(lines, " / ")
end
function GIP.Probe()
    if not Minimap then GIP.Print("Probe: minimap unavailable"); return end
    GIP.Print("Probe: stand with mouse directly over a yellow gathering dot before running this command.")
    GIP.Print("UpdateMouseoverAtPoint: " .. yes(type(Minimap.UpdateMouseoverAtPoint) == "function"))
    GIP.Print("GetMouseFoci: " .. yes(type(GetMouseFoci) == "function"))
    GIP.Print("GameTooltip: " .. inspectTooltip(GameTooltip))
    GIP.Print("Minimap children: " .. tostring(countChildren(Minimap)))
    GIP.Print("Minimap regions: " .. safeCall(function() return Minimap:GetNumRegions() end))
    GIP.Print("Cursor x: " .. safeCall(function() local x = GetCursorPosition(); return x end))
    GIP.Print("No mouse movement or tracking changes performed.")
end
