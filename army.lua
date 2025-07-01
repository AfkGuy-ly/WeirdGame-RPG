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
	local finalQuestId = 1034 -- Preparation for Revenge
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
			LogMessage("Assisting with Quest 6683: GateKeeper of Balance!")
			SummonBoss(153368, 99184, false)
			SummonBoss(153369, 99182, false)
			SummonBoss(153370, 99183, false)
			SummonBoss(153371, 99181, false)
			Sleep(5)
		end,
		[7015] = function()
			LogMessage("Assisting with Quest 7015: Wake Up, Leomon!")
			SummonBoss(154003, 99100, true)
			Sleep(5)
		end,
		[7034] = function()
			LogMessage("Assisting with Quest 7034: Final Battle: Monochromon!")
			SummonBoss(154004, 99101, true)
			Sleep(5)
		end,
	}
	for questId, handler in pairs(quests) do
		if IsQuestOnGoing(questId) then
			handler()
		end
	end
end

function SummonBoss(SummonItem, DigimonId, ShouldClear)
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

function CheckInventoryExpansion()
	local expansionItemIds = { 5507, 6507, 9007 }
	local used = false
	SafeCall(AutoExpansionToggle, false)
	for _, itemId in ipairs(expansionItemIds) do
		if GetItemQuantity(itemId) > 0 and WaitForMap() then
			SafeCall(AutoExpansionToggle, true)
			SafeCall(AutoExpansionSetExpansionID, itemId)
			used = true
			Sleep(1)
		end
	end
	return used
end

function CheckInventoryExpansion()
	local expansionItemIds = { 5507, 6507, 9007 }
	local used = false
	SafeCall(AutoExpansionToggle, false)
	for _, itemId in ipairs(expansionItemIds) do
		if GetItemQuantity(itemId) > 0 and WaitForMap() then
			SafeCall(AutoExpansionToggle, true)
			SafeCall(AutoExpansionSetExpansionID, itemId)
			while GetItemQuantity(itemId) > 0 do
				Sleep(1)
			end
			used = true
			SafeCall(AutoExpansionToggle, false)  -- Turn off after finishing one item type
		end
	end
	
	return used
end

function CheckWarehouseExpansion()
	local expansionItemIds = { 5508, 6508, 9008 }
	local used = false
	SafeCall(AutoExpansionToggle, false)
	for _, itemId in ipairs(expansionItemIds) do
		if GetItemQuantity(itemId) > 0 and WaitForMap() then
			SafeCall(AutoExpansionToggle, true)
			SafeCall(AutoExpansionSetExpansionID, itemId)
			used = true
			Sleep(1)
		end
	end
	return used
end

function CheckArchiveExpansion()
	local expansionItemIds = { 5004, 6004, 9006, 9413, 10250, 10251 }
	local used = false
	SafeCall(AutoExpansionToggle, false)
	for _, itemId in ipairs(expansionItemIds) do
		if GetItemQuantity(itemId) > 0 and WaitForMap() then
			SafeCall(AutoExpansionToggle, true)
			SafeCall(AutoExpansionSetExpansionID, itemId)
			Sleep(1)
			used = true
		end
	end
	return used
end

function OpenLevelBox()
	local tamer = GetTamer()
	local level = tamer:Level()
	local used = false
	local boxes = {
		{70051, 1}, {70052, 2}, {70053, 3}, {70054, 4}, {70055, 5},
		{70056, 6}, {70057, 7}, {70058, 8}, {70059, 9}, {70060, 10},
		{70061, 11}, {70062, 12}, {70063, 13}, {70064, 14}, {70065, 15},
		{70066, 16}, {70067, 17}, {70068, 18}, {70069, 19}, {70070, 20},
		{70071, 21}, {70072, 22}, {70073, 23}, {70074, 24}, {70075, 25},
		{70076, 26}, {70077, 27}, {70078, 28}, {70079, 29}, {70080, 30},
		{70081, 31}, {70082, 32}, {70083, 33}, {70084, 34}, {70085, 35},
		{70086, 36}, {70087, 37}, {70088, 38}, {70089, 39}, {70090, 40},
		{70091, 45}, {70092, 50}, {70093, 55}, {70094, 60}, {70095, 70},
		{70096, 80}, {70097, 90}, {70098, 99}
	}
	for _, box in ipairs(boxes) do
		local itemId, requiredLevel = box[1], box[2]
		if CheckLevelAndOpen(level, itemId, requiredLevel) then
			used = true
		end
	end
	SafeCall(AutoBoxToggle, false)
	return used
end

function CheckLevelAndOpen(CurrentLevel, ItemId, RequiredLevel)
	if CurrentLevel >= RequiredLevel and GetItemQuantity(ItemId) > 0 and WaitForMap() then
		SafeCall(AutoBoxToggle, true)
		SafeCall(AutoBoxSetBoxID, ItemId)
		Sleep(1)
		return true
	end
	return false
end

function CheckExpansionPack(level)
	if level >= 10 then
		if OpenLevelBox() then LogMessage("LevelUp GiftBox used.") end
		if CheckWarehouseExpansion() then LogMessage("Warehouse expansion items used.") end
		if CheckInventoryExpansion() then LogMessage("Inventory expansion items used.") end
		if CheckArchiveExpansion() then LogMessage("Archive expansion items used.") end
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

        -- Check expansions on every loop
        if WaitForMap() then
            CheckExpansionPack(level)
        end

        Sleep(15) -- Wait 15 seconds before checking this group again
    end

    SafeCall(AutoFarmToggle, false)
    SafeCall(AutoBoxToggle, false)
    SafeCall(AutoQuestToggle, false)
    ScriptStop()
end

main()
