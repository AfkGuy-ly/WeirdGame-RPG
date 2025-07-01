function WaitForMap(maxWait)
	local waited = 0
	maxWait = maxWait or 30
	while not IsInMap() and waited < maxWait do
		LogMessage("Waiting for map to load...")
		Sleep(3)
		waited = waited + 1
	end
	return IsInMap()
end

function SafeCall(fn, ...)
	if IsInMap() then
		return fn(...)
	else
		LogMessage("Skipped function call: not in map.")
	end
end

function CheckFileIsLandProgress()
	local finalQuestId = 1032 -- Preparation for Revenge
	local hasCompleted = IsQuestComplete(finalQuestId)
	if not hasCompleted then
		if WaitForMap() then
			SafeCall(AutoQuestAddQuest, finalQuestId)
			SafeCall(AutoQuestToggle, true)
			CheckOnCurrentQuest()
		end
	end
	return hasCompleted
end

function CheckEventQuests()
	local allCompleted = true
	local quests = { 6280, 6686 }
	for _, questId in ipairs(quests) do
		if not IsQuestComplete(questId) then
			allCompleted = false
			if WaitForMap() then
				SafeCall(AutoQuestAddQuest, questId)
			end
		end
	end
	if WaitForMap() then
		SafeCall(AutoQuestToggle, true)
	end
	if not allCompleted then
		CheckOnCurrentQuest()
	end
	return allCompleted
end

function CheckOnCurrentQuest()
	local quests = {
		[6683] = function()
			LogMessage("[EVENT] Assisting with Quest 6683: GateKeeper of Balance!")
			SummonBoss(153368, 99184, nil, nil, false)
			SummonBoss(153369, 99182, nil, nil, false)
			SummonBoss(153370, 99183, nil, nil, false)
			SummonBoss(153371, 99181, nil, nil, false)
			Sleep(5)
		end,
		[7015] = function()
			LogMessage("[FILE ISLAND] Assisting with Quest 7015: Wake Up, Leomon!")
			SummonBoss(154003, 99100, true)
			Sleep(5)
		end,
		[7034] = function()
			LogMessage("[FILE ISLAND] Assisting with Quest 7034: Final Battle: Monochromon!")
			SummonBoss(154004, 99101, true)
			Sleep(5)
		end,
		[1032] = function()
			LogMessage("[FILE ISLAND] Assisting with Quest 1034: Preparation for revenge!")
			local items = {
				{ itemId = 80680, name = "Imperfect Black Cogwheels", quantity = 20 }
			}
			local digimons = { 51619, 40289, 41027, 50444 }
			local huntPositions = {
				{x = 15174, y = 19899},
				{x = 19788, y = 20331},
				{x = 19810, y = 14567},
			}
			SafeCall(AutoQuestToggle, false)
			FarmItem(items, digimons, nil, huntPositions)
			SafeCall(AutoQuestToggle, true)
		end,
	}
	for questId, handler in pairs(quests) do
		if IsQuestOnGoing(questId) then
			handler()
		end
	end
end

function SummonBoss(SummonItem, DigimonId, MapId, Position, ShouldClear)
	if WaitForMap() then
		if ShouldClear then
			SafeCall(AutoFarmClearMonsters)
			Sleep(1)
		end
		SafeCall(AutoFarmAddMonster, DigimonId)
		SafeCall(AutoFarmSetHuntRange, 9500)
		SafeCall(AutoFarmToggle, true)
		Sleep(10)
		if GetItemQuantity(SummonItem) > 0 then
			SafeCall(AutoBoxToggle, true)
			SafeCall(AutoBoxSetBoxID, SummonItem)
			Sleep(1)
		end
		Sleep(60)
		SafeCall(AutoFarmToggle, false)
	end
end

function FarmItem(ItemsToFarm, DigimonsToKill, StartPosition, HuntPositions)
	if WaitForMap() then
		SafeCall(AutoFarmClearMonsters)
		Sleep(1)
		for _, digimonId in ipairs(DigimonsToKill) do
			SafeCall(AutoFarmAddMonster, digimonId)
		end
		if StartPosition ~= nil then
			-- Move to StartPosition
		end
		-- Check if currently using whitelist to add all itemstofarm & location
		if HuntPositions ~= nil then
			AutoFarmClearHuntPositions()
			Sleep(1)
			AutoFarmToggleUseHuntPositions(true)
			for _, position in ipairs(HuntPositions) do
				AutoFarmAddHuntPosition(position.x, position.y)
            end
        end
		SafeCall(AutoFarmSetHuntRange, 9500)
		SafeCall(AutoFarmToggle, true)
		local lastQuantities = {}
		while ScriptRun() do
        local allItemsReady = true
        for _, item in ipairs(ItemsToFarm) do
            local currentQty = GetItemQuantity(item.itemId)
            if currentQty < item.quantity then
                allItemsReady = false
            end
			 if lastQuantities[item.itemId] ~= currentQty then
                LogMessage("Item [" .. item.name .. "] Progress: " .. currentQty .. "/" .. item.quantity)
                lastQuantities[item.itemId] = currentQty
            end
        end
        if allItemsReady then
            LogMessage("All required items have been collected!")
			SafeCall(AutoFarmToggle, false)
			if HuntPositions ~= nil then
				SafeCall(AutoFarmToggleUseHuntPositions, false)
			end
            break
        end
        Sleep(15)  -- Wait before checking again
    end
	end
end

function LogMessage(Message)
	local currentTime = os.date("%H:%M:%S")
	log("[" .. currentTime .. "] " .. Message)
end

function main()
    local tamer = GetTamer()
    local level = tamer:Level()

    if level < 2 then
        LogMessage("Tamer level is below 2. Stopping script.")
        ScriptStop()
        return
    end

    local questGroups = {
        {name = "File Island", checkFn = CheckFileIsLandProgress},
        {name = "Daily Event", checkFn = CheckEventQuests},
    }

    local currentGroupIndex = 1
    while ScriptRun() do
        if currentGroupIndex > #questGroups then
            LogMessage("All quests are completed. Stopping script.")
            break
        end

        local group = questGroups[currentGroupIndex]
        local completed = group.checkFn()

        if completed then
            LogMessage(group.name .. ": Quests Are Completed!")
            currentGroupIndex = currentGroupIndex + 1
        else
            LogMessage(group.name .. ": Quests Ongoing!")
        end
        Sleep(15) -- Wait 15 seconds before checking this group again
    end
    SafeCall(AutoFarmToggle, false)
    SafeCall(AutoBoxToggle, false)
    SafeCall(AutoQuestToggle, false)
    ScriptStop()
end

local function handler(err)
    LogMessage("Error caught: " .. tostring(err))
    Cleanup()
end

function Cleanup()
    LogMessage("Performing cleanup before shutdown...")
    AutoQuestToggle(false)
    AutoFarmToggle(false)
end

xpcall(main, handler)
Cleanup() 