local BotHelper = require("Helpers.BotHelper")
local LogHelper = require("Helpers.LogHelper")

local UtilityHelper = {}

function UtilityHelper.WaitForMap(maxWait)
    local waited = 0
    maxWait = maxWait or 30
    while not BotHelper.IsInMap() and waited < maxWait do
        LogHelper.LogMessage("Waiting for map to load...")
        Sleep(3)
        waited = waited + 1
    end
    return BotHelper.IsInMap()
end

function UtilityHelper.SafeCall(fn, ...)
    if BotHelper.IsInMap() then
        return fn(...)
    else
        LogHelper.LogMessage("Skipped function call: not in map.")
    end
end

return UtilityHelper