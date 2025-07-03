---------------------------------------------
-- 🔹 BotHelper Functions Section
---------------------------------------------
local BotHelper = {}

function BotHelper.IsInMap()
	return IsInMap()
end

function BotHelper.GetTamer()
	return GetTamer()
end

function BotHelper.MoveTo(x, y)
	return GoToPosition(x, y)
end

function BotHelper.AutoFarmClearMonsters()
	return AutoFarmClearMonsters()
end

function BotHelper.AutoFarmClearHuntPositions()
	return AutoFarmClearHuntPositions()
end

function BotHelper.AutoFarmAddMonster(monsterId)
	return AutoFarmAddMonster(monsterId)
end

function BotHelper.AutoFarmAddHuntPosition(x,y)
	return AutoFarmAddHuntPosition(x,y)
end

function BotHelper.AutoFarmSetHuntRange(range)
	return AutoFarmSetHuntRange(range)
end

function BotHelper.AutoFarmToggle(state)
	return AutoFarmToggle(state)
end

function BotHelper.AutoFarmToggleUseHuntPositions(state)
	return AutoFarmToggleUseHuntPositions(state)
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

---------------------------------------------
-- 🔹 LogHelper Functions Section
---------------------------------------------
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


---------------------------------------------
-- 🔹 UtilityHelper Functions Section
---------------------------------------------
local UtilityHelper = {}

function UtilityHelper.WaitForMap(maxWait)
	local waited = 0
	maxWait = maxWait or 10
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

---------------------------------------------
-- 🔹 QuestHelper Functions Section
---------------------------------------------
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
		--UtilityHelper.SafeCall(BotHelper.AutoLootToggle, true)
		--UtilityHelper.SafeCall(BotHelper.AutoLootToggleLootBits, true)
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

function QuestHelper.MoveTo(TargetX, TargetY, MapId, QuestId)
	if UtilityHelper.WaitForMap() then
		--Check If Map Is Correct
		UtilityHelper.SafeCall(BotHelper.AutoQuestToggle, false)
		local hasNotArrived = true
		while hasNotArrived do
			local pos = BotHelper.GetTamer():Position()
			local distance = math.sqrt((pos.x - TargetX)^2 + (pos.y - TargetY)^2)
			---- Check if quest is still ongoing
			if not BotHelper.IsQuestOnGoing(QuestId) then
				LogHelper.LogMessage("Quest 1324 no longer ongoing, stopping wait.")
				break
			end
			if distance <= 10 then
				hasNotArrived = false
				break
			end
			Sleep(1)
		end
		UtilityHelper.SafeCall(BotHelper.AutoQuestToggle, true)
	end
end


---------------------------------------------
-- 🔹 FileIslandQuest Functions Section
---------------------------------------------
local FileIslandQuest = {}
local function _FileIslandHandleQuest()
	local quests = {
		[7015] = function()
			LogHelper.LogMessage("[FILE ISLAND] Assisting with Quest 7015: Wake Up, Leomon!")
			QuestHelper.SummonBoss(154003, 99100, nil, nil, true)
			Sleep(5)
		end,
		[7034] = function()
			LogHelper.LogMessage("[FILE ISLAND] Assisting with Quest 7034: Final Battle: Monochromon!")
			QuestHelper.SummonBoss(154004, 99101, nil, nil, true)
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
		_FileIslandHandleQuest()
	end
	return allCompleted
end

---------------------------------------------
-- 🔹 FileIslandQuest Functions Section
---------------------------------------------
local ServerContinentQuest = {}
local function _ServerContinentHandleQuest()
	local quests = {
		[1289] = function()
			LogHelper.LogMessage("[SERVER CONTINENT] Assisting with Quest: Battle Etemon!")
			QuestHelper.SummonBoss(154005, 99102, nil, nil, true)
			Sleep(5)
		end,
		[1324] = function()
			LogHelper.LogMessage("[SERVER CONTINENT] Assisting with Quest: Desert In Danger!")
			QuestHelper.SummonBoss(154007, 99104, nil, nil, true)
			Sleep(5)
		end,
		[1276] = function()
			LogHelper.LogMessage("[SERVER CONTINENT] Assisting with Quest 7015: Wake Up, Leomon!")
			QuestHelper.MoveTo(25185, 20211, 0)
			Sleep(5)
		end,
	}
	for questId, handler in pairs(quests) do
		if BotHelper.IsQuestOnGoing(questId) then
			handler()
		end
	end
end

function ServerContinentQuest.CheckProgress()
	local allCompleted = true
	local quests = { 1071, 1265, 1266, 1421 }
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
		_ServerContinentHandleQuest()
	end
	return allCompleted
end


---------------------------------------------
-- 🔹 EventQuest Functions Section
---------------------------------------------
local EventQuest = {}
local function _EventHandleQuest()
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
		_EventHandleQuest()
	end
	return allCompleted
end

---------------------------------------------
-- 🔹 Main Function Section
---------------------------------------------
function main()
	local tamer = BotHelper.GetTamer()
	local level = tamer:Level()
	local questGroups = {
		{
			name = "[Daily Event]",
			tamerLevel = 1,
			checkFn = EventQuest.CheckProgress,
		},
		--{
		--	name = "[Weekly Event]",
		--	tamerLevel = 140,
		--	checkFn = EventQuest.CheckProgress,
		--},
		{
			name = "[File Island]",
			tamerLevel = 1,
			checkFn = FileIslandQuest.CheckProgress,
		},
		{
			name = "[Server Continent]",
			tamerLevel = 70,
			checkFn = ServerContinentQuest.CheckProgress,
		},
		--{
		--	name = "[Shinjuku Part 1]",
		--	tamerLevel = 70,
		--	checkFn = EventQuest.CheckProgress,
		--},
		--{
		--	name = "[Odaiba]",
		--	tamerLevel = 80,
		--	checkFn = EventQuest.CheckProgress,
		--},
		--{
		--	name = "[Shinjuku Part 2]",
		--	tamerLevel = 90,
		--	checkFn = EventQuest.CheckProgress,
		--},
		--{
		--	name = "[Spiral Mountain]",
		--	tamerLevel = 90,
		--	checkFn = EventQuest.CheckProgress,
		--},
		--{
		--	name = "[Verdandi Part 1]",
		--	tamerLevel = 80,
		--	checkFn = EventQuest.CheckProgress,
		--},
		--{
		--	name = "[Verdandi Part 2]",
		--	tamerLevel = 80,
		--	checkFn = EventQuest.CheckProgress,
		--},
	}
	local currentGroupIndex = 1
	while ScriptRun() do
		if currentGroupIndex > #questGroups then
			LogHelper.LogMessage("All quests are completed. Stopping script.")
			break
		end
		local group = questGroups[currentGroupIndex]
		if level < group.tamerLevel then
			LogHelper.LogMessage(group.name .. ": Tamer level is below " .. group.tamerLevel .. ". skipping.")
			currentGroupIndex = currentGroupIndex + 1
		else
			local completed = group.checkFn()
			if completed then
				LogHelper.LogMessage(group.name .. ": Quests Are Completed!")
				currentGroupIndex = currentGroupIndex + 1
			else
				LogHelper.LogMessage(group.name .. ": Quests Ongoing!")
			end
		end
		Sleep(15)
	end
end

function handler(err)
	LogHelper.LogMessage("Error caught: " .. tostring(err))
	Cleanup()
end

function Cleanup()
	LogHelper.LogMessage("Performing cleanup before shutdown...")
	UtilityHelper.SafeCall(BotHelper.AutoFarmToggle, false)
	UtilityHelper.SafeCall(BotHelper.AutoBoxToggle, false)
	UtilityHelper.SafeCall(BotHelper.AutoQuestToggle, false)
end

xpcall(main, handler)
Cleanup()