local BotHelper = require("Helpers.BotHelper")
local LogHelper = require("Helpers.LogHelper")
local FileIslandQuest = require("Quests.FileIslandQuest")
local ServerContinentQuest = require("Quests.ServerContinentQuest")
local EventQuest = require("Quests.EventQuest")
local UtilityHelper = require("Helpers.UtilityHelper")

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