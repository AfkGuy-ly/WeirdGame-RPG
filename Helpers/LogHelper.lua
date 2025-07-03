local BotHelper = require("Helpers.BotHelper")

local LogHelper = {}
function LogHelper.LogMessage(message)
    local currentTime = os.date("%H:%M:%S")
    BotHelper.log("[" .. currentTime .. "] " .. message)
end

function LogInformation(Message)
    local currentTime = os.date("%H:%M:%S")
    BotHelper.log("[" .. currentTime .. "] " .. Message)
end

function LogWarning(Message)
    local currentTime = os.date("%H:%M:%S")
    BotHelper.log("[" .. currentTime .. "] " .. Message)
end

function LogError(Message)
    local currentTime = os.date("%H:%M:%S")
    BotHelper.log("[" .. currentTime .. "] " .. Message)
end
return LogHelper