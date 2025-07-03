local BotHelper = require("Helpers.BotHelper")
local LogHelper = require("Helpers.LogHelper")
local QuestHelper = require("Helpers.QuestHelper")
local UtilityHelper = require("Helpers.UtilityHelper")

local FileIslandQuest = {}
function FileIslandQuest.CheckProgress()
    local allCompleted = true
    local quests = { 1032, 1033, 1035 }
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
        [7015] = function()
            LogHelper.LogMessage("[FILE ISLAND] Assisting with Quest 7015: Wake Up, Leomon!")
            QuestHelper.SummonBoss(154003, 99100, true)
            Sleep(5)
        end,
        [7034] = function()
            LogHelper.LogMessage("[FILE ISLAND] Assisting with Quest 7034: Final Battle: Monochromon!")
            QuestHelper.SummonBoss(154004, 99101, true)
            Sleep(5)
        end,
        [1032] = function()
            LogHelper.LogMessage("[FILE ISLAND] Assisting with Quest 1034: Preparation for revenge!")
            local items = {
                { itemId = 80680, name = "Imperfect Black Cogwheels", quantity = 20 }
            }
            local digimons = { 51619, 40289, 41027, 50444 }
            local huntPositions = {
                {x = 15174, y = 19899},
                {x = 19788, y = 20331},
                {x = 19810, y = 14567},
            }
            UtilityHelper.SafeCall(BotHelper.AutoQuestToggle, false)
            QuestHelper.FarmItem(items, digimons, nil, huntPositions)
            UtilityHelper.SafeCall(BotHelper.AutoQuestToggle, true)
        end,
    }
    for questId, handler in pairs(quests) do
        if BotHelper.IsQuestOnGoing(questId) then
            handler()
        end
    end
end
return FileIslandQuest