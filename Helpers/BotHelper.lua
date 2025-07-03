
local BotHelper = {}

function BotHelper.IsInMap()
    return IsInMap()
end

function BotHelper.GetTamer()
    return GetTamer()
end

function BotHelper.AutoFarmClearMonsters()
    return AutoFarmClearMonsters()
end

function BotHelper.AutoFarmAddMonster(monsterId)
    return AutoFarmAddMonster(monsterId)
end

function BotHelper.AutoFarmSetHuntRange(range)
    return AutoFarmSetHuntRange(range)
end

function BotHelper.AutoFarmToggle(state)
    return AutoFarmToggle(state)
end

function BotHelper.AutoQuestAddQuest(questId)
    return AutoQuestAddQuest(questId)
end

function BotHelper.AutoQuestToggle(state)
    return AutoQuestToggle(state)
end

function BotHelper.IsQuestOnGoing(questId)
    return IsQuestOnGoing(questId)
end

function BotHelper.IsQuestComplete(questId)
    return IsQuestComplete(questId)
end

function BotHelper.AutoBoxToggle(state)
    return AutoBoxToggle(state)
end

function BotHelper.AutoBoxSetBoxID(boxId)
    return AutoBoxSetBoxID(boxId)
end

function BotHelper.GetItemQuantity(itemId)
    return GetItemQuantity(itemId)
end

function BotHelper.AutoExpansionToggle(state)
    return AutoExpansionToggle(state)
end

function BotHelper.AutoExpansionSetExpansionID(itemId)
    return AutoExpansionSetExpansionID(itemId)
end

function BotHelper.ScriptRun()
    return ScriptRun()
end

function BotHelper.ScriptStop()
    return ScriptStop()
end

function BotHelper.log(Message)
    return log(Message)
end

return BotHelper
