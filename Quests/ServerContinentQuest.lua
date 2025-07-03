local BotHelper = require("Helpers.BotHelper")
local LogHelper = require("Helpers.LogHelper")
local QuestHelper = require("Helpers.QuestHelper")
local UtilityHelper = require("Helpers.UtilityHelper")

local ServerContinentQuest = {}
function ServerContinentQuest.CheckProgress()
    local allCompleted = true
    local quests = { 1071, 1265, 1266 }
    for _, questId in ipairs(quests) do
        if not BotHelper.IsQuestComplete(questId) then
            allCompleted = false
            if UtilityHelper.WaitForMap() then
                UtilityHelper.SafeCall(BotHelper.AutoQuestAddQuest, questId)
            end
        end
    end
    if UtilityHelper.WaitForMap() then
        UtilityHelper.SafeCall(BotHelper.AutoQuestToggle, true)
    end
    if not allCompleted then
        _HandleQuest()
    end
    return allCompleted
end

local function _HandleQuest()
    local quests = {
        [70150] = function()
            LogHelper.LogMessage("[SERVER CONTINENT] Assisting with Quest 7015: Wake Up, Leomon!")
            QuestHelper.SummonBoss(154003, 99100, true)
            Sleep(5)
        end,
    }
    for questId, handler in pairs(quests) do
        if BotHelper.IsQuestOnGoing(questId) then
            handler()
        end
    end
end
return ServerContinentQuest