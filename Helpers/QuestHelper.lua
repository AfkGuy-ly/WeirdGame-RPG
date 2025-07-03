local BotHelper = require("Helpers.BotHelper")
local LogHelper = require("Helpers.LogHelper")
local UtilityHelper = require("Helpers.UtilityHelper")

local QuestHelper = {}

function QuestHelper.SummonBoss(SummonItem, DigimonId, MapId, Position, ShouldClear)
    if UtilityHelper.WaitForMap() then
        if ShouldClear then
            UtilityHelper.SafeCall(BotHelper.AutoFarmClearMonsters)
            Sleep(1)
        end
        UtilityHelper.SafeCall(BotHelper.AutoFarmAddMonster, DigimonId)
        UtilityHelper.SafeCall(BotHelper.AutoFarmSetHuntRange, 9500)
        UtilityHelper.SafeCall(BotHelper.AutoFarmToggle, true)
        Sleep(10)
        if BotHelper.GetItemQuantity(SummonItem) > 0 then
            UtilityHelper.SafeCall(BotHelper.AutoBoxToggle, true)
            UtilityHelper.SafeCall(BotHelper.AutoBoxSetBoxID, SummonItem)
            Sleep(1)
        end
        Sleep(60)
        UtilityHelper.SafeCall(BotHelper.AutoFarmToggle, false)
    end
end

function QuestHelper.FarmItem(ItemsToFarm, DigimonsToKill, StartPosition, HuntPositions)
    if UtilityHelper.WaitForMap() then
        UtilityHelper.SafeCall(BotHelper.AutoFarmClearMonsters)
        Sleep(1)
        for _, digimonId in ipairs(DigimonsToKill) do
            UtilityHelper.SafeCall(BotHelper.AutoFarmAddMonster, digimonId)
        end
        if StartPosition ~= nil then
            -- Move to StartPosition
        end
        -- Check if currently using whitelist to add all itemstofarm & location

        UtilityHelper.SafeCall(BotHelper.AutoLootToggle, true)
        UtilityHelper.SafeCall(BotHelper.AutoLootToggleLootBits, true)
        --
        if HuntPositions ~= nil then
            UtilityHelper.SafeCall(BotHelper.AutoFarmClearHuntPositions)
            Sleep(1)
            UtilityHelper.SafeCall(BotHelper.AutoFarmToggleUseHuntPositions, true)
            for _, position in ipairs(HuntPositions) do
                UtilityHelper.SafeCall(BotHelper.AutoFarmAddHuntPosition, position.x, position.y)
            end
        end
        UtilityHelper.SafeCall(BotHelper.AutoFarmSetHuntRange, 9500)
        UtilityHelper.SafeCall(BotHelper.AutoFarmToggle, true)
        local lastQuantities = {}
        while ScriptRun() do
            local allItemsReady = true
            for _, item in ipairs(ItemsToFarm) do
                local currentQty = BotHelper.GetItemQuantity(item.itemId)
                if currentQty < item.quantity then
                    allItemsReady = false
                end
                if lastQuantities[item.itemId] ~= currentQty then
                    LogHelper.LogMessage("Item [" .. item.name .. "] Progress: " .. currentQty .. "/" .. item.quantity)
                    lastQuantities[item.itemId] = currentQty
                end
            end
            if allItemsReady then
                LogHelper.LogMessage("All required items have been collected!")
                UtilityHelper.SafeCall(BotHelper.AutoFarmToggle, false)
                if HuntPositions ~= nil then
                    UtilityHelper.SafeCall(BotHelper.AutoFarmToggleUseHuntPositions, false)
                end
                break
            end
            Sleep(15)  -- Wait before checking again
        end
    end
end
return QuestHelper
