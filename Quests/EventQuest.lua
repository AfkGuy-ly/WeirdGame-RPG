local BotHelper = require("Helpers.BotHelper")
local LogHelper = require("Helpers.LogHelper")
local QuestHelper = require("Helpers.QuestHelper")
local UtilityHelper = require("Helpers.UtilityHelper")

local EventQuest = {}
function EventQuest.CheckProgress()
    local allCompleted = true
    local quests = { 6280, 6686 }
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
        [6683] = function()
            LogHelper.LogMessage("[EVENT] Assisting with Quest 6683: GateKeeper of Balance!")
            QuestHelper.SummonBoss(153368, 99184, nil, nil, false)
            QuestHelper.SummonBoss(153369, 99182, nil, nil, false)
            QuestHelper.SummonBoss(153370, 99183, nil, nil, false)
            QuestHelper.SummonBoss(153371, 99181, nil, nil, false)
            Sleep(5)
        end,
    }
    for questId, handler in pairs(quests) do
        if BotHelper.IsQuestOnGoing(questId) then
            handler()
        end
    end
end
return EventQuest
