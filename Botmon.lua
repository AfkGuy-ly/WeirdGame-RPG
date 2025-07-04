---------------------------------------------
-- 🔹 Instance Section
---------------------------------------------
local STATUS_FILE = "Status.json"
local CONFIG_FILE = "C2.n"
local ACCOUNTS_LIST = {
	{
		username = "",
		password = "",
		server = 7,
		tamers = { 1, 2, 3, 4, 5}
	}
}
---------------------------------------------
-- 🔹 SystemHelper Functions Section
---------------------------------------------
local SystemHelper = {}
function SystemHelper.Timestamp()
	return os.date("%Y-%m-%dT%H:%M:%S")
end

function SystemHelper.TimestampKST()
	local utc = os.time(os.date("!*t"))
	local kst = utc + (9 * 60 * 60)
	return os.date("%Y-%m-%dT%H:%M:%S", kst)
end

---------------------------------------------
-- 🔹 JsonHelper Functions Section
---------------------------------------------
local JsonHelper = {}
function JsonHelper.EscapeStr(s)
	return s:gsub("\\", "\\\\")
			:gsub("\"", "\\\"")
			:gsub("\n", "\\n")
			:gsub("\r", "\\r")
			:gsub("\t", "\\t")
end

function JsonHelper.Encode(value)
	local function jsonEncode(val)
		local t = type(val)
		if t == "string" then
			return '"' .. JsonHelper.EscapeStr(val) .. '"'
		elseif t == "number" or t == "boolean" then
			return tostring(val)
		elseif t == "table" then
			local isArray = #val > 0
			local result = {}
			if isArray then
				for _, item in ipairs(val) do
					table.insert(result, jsonEncode(item))
				end
				return "[" .. table.concat(result, ",") .. "]"
			else
				for k, v in pairs(val) do
					table.insert(result, '"' .. tostring(k) .. '":' .. jsonEncode(v))
				end
				return "{" .. table.concat(result, ",") .. "}"
			end
		elseif t == "nil" then
			return "null"
		else
			--error("Unsupported type: " .. t)
		end
	end
	return jsonEncode(value)
end

function JsonHelper.Decode(json)
	local result = {}
	for objectStr in json:gmatch("{(.-)}") do
		local entry = {}
		for key, val in objectStr:gmatch('"(.-)"%s*:%s*("?.-"?)[,%}]') do
			val = val:gsub('^"', ''):gsub('"$', '') -- remove quotes
			if val == "true" then
				val = true
			elseif val == "false" then
				val = false
			elseif val == "null" then
				val = nil
			elseif tonumber(val) then
				val = tonumber(val)
			end
			entry[key] = val
		end
		table.insert(result, entry)
	end
	return result
end

---------------------------------------------
-- 🔹 StatusHelper Functions Section
---------------------------------------------
local StatusHelper = {}
function StatusHelper.StatusFilePath()
	local user = os.getenv("USERNAME") or os.getenv("USER")
	return "C:\\Users\\" .. user .. "\\Documents\\Nen\\" .. STATUS_FILE
end

function StatusHelper.UpdateTamer(tamer)
	local path = StatusHelper.StatusFilePath()
	local file = io.open(path, "r")
	local content = file and file:read("*a") or "[]"
	if file then file:close() end
	local list = JsonHelper.Decode(content)
	tamer.LastUpdated = SystemHelper.Timestamp()
	tamer.LastUpdatedKST = SystemHelper.TimestampKST()
	local updated = false
	for _, entry in ipairs(list) do
		if entry.TamerId == tamer.TamerId then
			for k, v in pairs(tamer) do entry[k] = v end
			updated = true
			break
		end
	end
	if not updated then
		table.insert(list, tamer)
	end
	local outFile = io.open(path, "w")
	outFile:write(jsonEncode(list))
	outFile:close()
	--print("✅ Status updated for TamerId:", tamer.TamerId)
end

---------------------------------------------
-- 🔹 SettingsHelper Functions Section
---------------------------------------------
local SettingsHelper = {}

function SettingsHelper.GetPath()
	local user = os.getenv("USERNAME") or os.getenv("USER")
	if not user then
		--log("❌ Could not detect username.")
		return ""
	end
	return "C:\\Users\\" .. user .. "\\Documents\\Nen\\" .. CONFIG_FILE
end

function SettingsHelper.Update(FileName, Changes)
	local filePath = SettingsHelper.GetPath(FileName .. ".n")
	local file, err = io.open(filePath, "r")
	if not file then
		--log("❌ Failed to open file: " .. tostring(err))
		return false
	end
	local content = file:read("*all")
	file:close()
	local totalChanges = 0
	for key, newValue in pairs(Changes) do
		local pattern = key .. "%s*=%s*[%d%.%a\"]+"  -- Matches key = value (value can be number, float, string)
		local replacement = key .. " = " .. tostring(newValue)
		local newContent, count = content:gsub(pattern, replacement)
		if count > 0 then
			--log("✅ Replaced '" .. key .. "' with value '" .. newValue .. "' (" .. count .. " times)")
			content = newContent
			totalChanges = totalChanges + count
		else
			log("⚠️ No match found for key: " .. key)
		end
	end

	-- Save back if anything changed
	if totalChanges > 0 then
		file, err = io.open(filePath, "w")
		if not file then
			--log("❌ Failed to open file for writing: " .. tostring(err))
			return
		end
		file:write(content)
		file:close()
		--log("✅ File updated successfully: " .. filePath)
	else
		--log("ℹ️ No changes made to file.")
	end
end


---------------------------------------------
-- 🔹 BotHelper Functions Section
---------------------------------------------
local BotHelper = {}

function BotHelper.IsInMap()
	return IsInMap()
end

function BotHelper.SwitchCharacter(SettingsFile, Slot)
	local waited = 0
	maxWait = maxWait or 5
	while not BotHelper.IsInMap() and waited < maxWait do
		SettingsHelper.Update(SettingsFile, {
			TamerSlot = Slot,
		})
		LoadBotConfig(SettingsFile)
		GoToServerSelection()
		Sleep(3)
		waited = waited + 1
	end
end

function BotHelper.UpdateTamerStatus()
	local tamer = GetTamer()
	StatusHelper.UpdateTamer({
		TamerId = tamer.UID(),
		TamerName = tamer.Name(),
		TamerLevel = tamer.Level,
		DigimonType = "Agumon",
		DigimonLevel = 22,
		FileIslandQuests = true,
		ServerContinentQuests = true,
		OdaibaQuests = false,
		ShinjukuQuests = false,
	})
	Sleep(1)
end

--function BotHelper.SwitchAccount(SettingsFile, Account)
--	local waited = 0
--	maxWait = maxWait or 5
--	while not BotHelper.IsInMap() and waited < maxWait do
--		SettingsHelper.Update(SettingsFile, {
--			TamerSlot = Slot,
--		})
--		LoadBotConfig(SettingsFile)
--		GoToServerSelection()
--		Sleep(3)
--		waited = waited + 1
--	end
--end

--function BotHelper.SwitchAccount()
--	AutoLoginToggle(false)
--	GoToLoginScreen()
--	AutoLoginSetUsername("")
--	AutoLoginSetPassword("")
--	AutoLoginSetPassword2("")
--	AutoLoginSetServer()
--end

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
			UtilityHelper.SafeCall(BotHelper.MoveTo, TargetX, TargetY)
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

function QuestHelper.UseItem(ItemId, TargetX, TargetY, MapId, QuestId)
	if UtilityHelper.WaitForMap() then
		LogHelper.LogMessage("Quantity: " .. BotHelper.GetItemQuantity(ItemId))
		if BotHelper.GetItemQuantity(ItemId) > 0 then
			if TargetX ~= nil or TargetX ~=nil then
				--Check If Map Is Correct
				UtilityHelper.SafeCall(BotHelper.AutoQuestToggle, false)
				local hasNotArrived = true
				while hasNotArrived do
					local pos = BotHelper.GetTamer():Position()
					local distance = math.sqrt((pos.x - TargetX)^2 + (pos.y - TargetY)^2)
					UtilityHelper.SafeCall(BotHelper.MoveTo, TargetX, TargetY)
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
			UtilityHelper.SafeCall(BotHelper.AutoBoxToggle, true)
			UtilityHelper.SafeCall(BotHelper.AutoBoxSetBoxID, ItemId)
			Sleep(1)
		end
	end
end

function QuestHelper.EnterDG(Id)

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
-- 🔹 ServerContinentQuest Functions Section
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
			LogHelper.LogMessage("[SERVER CONTINENT] Assisting with Quest: Town 2!")
			QuestHelper.MoveTo(25185, 20211, 0, 1276)
			Sleep(5)
		end,
		[1280] = function()
			LogHelper.LogMessage("[SERVER CONTINENT] Assisting with Quest: Trace!")
			QuestHelper.MoveTo(11521, 23680, 0, 1280)
			Sleep(5)
		end,
		[1306] = function()
			--BUGGED UNABLE TO USE ITEM HERE WILL HAVE TO FIND ANOTHERWAY AROUND
			LogHelper.LogMessage("[SERVER CONTINENT] Assisting with Quest: Twinkling Kido!")
			--QuestHelper.UseItem(80743, nil, nil, nil, 1306)
			Sleep(5)
		end,
		[1307] = function()
			LogHelper.LogMessage("[SERVER CONTINENT] Assisting with Quest: Collosium!")
			QuestHelper.MoveTo(80697, 15189, 0, 1307)
			Sleep(5)
		end,
		[1416] = function()
			LogHelper.LogMessage("[SERVER CONTINENT] Assisting with Quest: Clash With Etemon!")
			QuestHelper.MoveTo(31999, 15893, 0, 1416)
			QuestHelper.SummonBoss(80793, 45346, nil, nil, true)
			Sleep(5)
		end,
		[1417] = function()
			LogHelper.LogMessage("[SERVER CONTINENT] Assisting with Quest: Nano Maze!")
			Sleep(5)
		end,
		[1420] = function()
			LogHelper.LogMessage("[SERVER CONTINENT] Assisting with Quest: Final Battle with Etemon!")
			QuestHelper.SummonBoss(154008, 99105, nil, nil, true)
			Sleep(5)
		end,
		[3401] = function()
			LogHelper.LogMessage("[SERVER CONTINENT] Assisting with Quest: Link to real world!")
			QuestHelper.MoveTo(33506, 23440, 0, 3401)
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
	local quests = { 1071, 1265, 1266, 1421, 3411 }
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
-- 🔹 ShinjukuQuest Functions Section
---------------------------------------------
local ShinjukuQuest = {}
local function _ShinjukuHandleQuest()
	local quests = {
		[4503] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			QuestHelper.MoveTo(17465, 33281, 0, 4503)
			QuestHelper.MoveTo(24450, 33973, 0, 4503)
			QuestHelper.MoveTo(42200, 29583, 0, 4503)
			QuestHelper.MoveTo(36680, 17075, 0, 4503)
			Sleep(5)
		end,
		[4506] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			QuestHelper.MoveTo(12822, 13300, 0, 4506)
			QuestHelper.MoveTo(17503, 27497, 0, 4506)
			QuestHelper.MoveTo(33366, 28780, 0, 4506)
			QuestHelper.MoveTo(39709, 35705, 0, 4506)
			Sleep(5)
		end,
		[4507] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			QuestHelper.MoveTo(26646, 54561, 0, 4507)
			Sleep(5)
		end,
		[4515] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			QuestHelper.MoveTo(7378, 30303, 0, 4515)
			QuestHelper.MoveTo(15220, 22546, 0, 4515)
			Sleep(5)
		end,
		[4518] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			QuestHelper.MoveTo(32196, 28328, 0, 4518)
			QuestHelper.MoveTo(29412, 38214, 0, 4518)
			QuestHelper.MoveTo(40279, 37153, 0, 4518)
			Sleep(5)
		end,
		[4521] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			QuestHelper.MoveTo(36164, 46560, 0, 4521)
			Sleep(5)
		end,
		[4522] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			QuestHelper.MoveTo(27075, 32855, 0, 4522)
			Sleep(5)
		end,
		[4530] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			QuestHelper.MoveTo(37963, 41960, 0, 4530)
			Sleep(5)
		end,
		[4537] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			Sleep(5) --Waiting For MapJump
			QuestHelper.MoveTo(40154, 39908, 0, 4537) --Western Area Night
			QuestHelper.MoveTo(35958, 28650, 0, 4537)
			QuestHelper.MoveTo(36198, 14943, 0, 4537)
			QuestHelper.MoveTo(38606, 14791, 0, 4537)
			Sleep(5)
		end,
		[4541] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			QuestHelper.MoveTo(19438, 26821, 0, 4541)
			Sleep(5)
		end,
		[4542] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			--ANOTHER BUGGED QUEST ITEM
			--QuestHelper.UseItem(80913, 16627, 32229, nil, 4542)
			Sleep(5)
		end,
		[4544] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			Sleep(5) --Waiting For MapJump
			QuestHelper.MoveTo(34505, 32343, 0, 4544) --Western Area Night
			Sleep(5)
		end,
		[4546] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			QuestHelper.MoveTo(34505, 32343, 0, 4546) --Western Area Night
			Sleep(5)
		end,
		[4550] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			--QuestHelper.UseItem(80913, 39447, 40327, nil, 4542) -- Western Day
			--QuestHelper.UseItem(80913, 35117, 26189, nil, 4542) -- Western Day
			--QuestHelper.UseItem(80913, 36071, 15024, nil, 4542) -- Western Day
			--QuestHelper.UseItem(80913, 40573, 15003, nil, 4542) -- Western Day

			Sleep(5)
		end,
		[4553] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			--Farm 5 Allomon(72510) + use 1 Item
			--QuestHelper.UseItem(80913, 22579, 28243, nil, 4553) -- Western Day (1Item)
			-- Farm 5 goblimon(72501) + 1 ogremon (72502)
			--QuestHelper.UseItem(80913, 41476, 14865, nil, 4553) -- Western Night (1Item)
			Sleep(5)
		end,
		[4561] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			QuestHelper.MoveTo(17558, 30633, 0, 4561) --East Night
			Sleep(5)
		end,
		[4561] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			--Jump Channels check for Timer with less time For Devidra ()
			Sleep(5)
		end,
		[4567] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			--QuestHelper.MoveTo(17558, 30633, 0, 4561) --Western Day
			Sleep(5)
		end,
		[4583] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			QuestHelper.MoveTo(36348, 41955, 0, 4583) --East Day
			QuestHelper.MoveTo(45962, 33555, 0, 4583) --East Day
			QuestHelper.MoveTo(45962, 33555, 0, 4583) --East Day
			QuestHelper.MoveTo(35784, 16598, 0, 4583) --East Day
			QuestHelper.MoveTo(41003, 45859, 0, 4583) --East Day
			Sleep(5)
		end,
		[4591] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			--QuestHelper.MoveTo(36348, 41955, 0, 4591) --East Day
			Sleep(5)
		end,
		[4593] = function()
			LogHelper.LogMessage("[Shinjuku Quests] Assisting with Quest: Check Area!")
			QuestHelper.MoveTo(24964, 29915, 0, 4593) --East Night
			Sleep(5)
		end,

	}
	for questId, handler in pairs(quests) do
		if BotHelper.IsQuestOnGoing(questId) then
			handler()
		end
	end
end

function ShinjukuQuest.CheckPartOneProgress()
	local allCompleted = true
	local quests = { 4614 }
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
		_ShinjukuHandleQuest()
	end
	return allCompleted
end

function ShinjukuQuest.CheckPartTwoProgress()
	local allCompleted = true
	local quests = { 4633 }
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
		_ShinjukuHandleQuest()
	end
	return allCompleted
end

---------------------------------------------
-- 🔹 OdaibaQuest Functions Section
---------------------------------------------
local OdaibaQuest = {}
local function _OdaibaHandleQuest()
	local quests = {
		[7015] = function()
			LogHelper.LogMessage("[FILE ISLAND] Assisting with Quest 7015: Wake Up, Leomon!")
			QuestHelper.SummonBoss(154003, 99100, nil, nil, true)
			Sleep(5)
		end,
	}
	for questId, handler in pairs(quests) do
		if BotHelper.IsQuestOnGoing(questId) then
			handler()
		end
	end
end

function OdaibaQuest.CheckProgress()
	local allCompleted = true
	local quests = { 4014 }
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
		_OdaibaHandleQuest()
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
		{
			name = "[Shinjuku Part 1]",
			tamerLevel = 70,
			checkFn = ShinjukuQuest.CheckPartOneProgress,
		},
		{
			name = "[Odaiba]",
			tamerLevel = 80,
			checkFn = OdaibaQuest.CheckProgress,
		},
		{
			name = "[Shinjuku Part 2]",
			tamerLevel = 90,
			checkFn = ShinjukuQuest.CheckPartTwoProgress,
		},
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