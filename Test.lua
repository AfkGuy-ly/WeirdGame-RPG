local possibleSetters = {
    "AutoFarmToggle", "AutoHealToggle", "AutoLoginToggle", "AutoQuestToggle",
    "AutoLootToggle", "AutoBuffToggle", "AutoDropToggle", "AutoDGToggle",
    "AutoEvoToggle", "AutoReturnToggle",

    "AutoFarmSetHuntRange", "AutoFarmSetLootRange", "AutoFarmSetForceChannel", "AutoFarmSetReturnMap",
    "AutoLoginSetUsername", "AutoLoginSetPassword", "AutoLoginSetPassword2", "AutoLoginSetServer", "AutoLoginSetTamer",
    "AutoDGSetRunCount", "AutoDGSetHPThreshold", "AutoDGSetReEnterDelay", "AutoDGSetUnlimitedRun",
    "AutoEvoSetDigimonID", "AutoEvoSetEvoType", "AutoEvoSetUseDigimonID",
    "AutoHealSetDigiHPPerc1", "AutoHealSetDigiHPPerc2", "AutoHealSetTamerHPPerc1", "AutoHealSetTamerHPPerc2",
    "AutoHealSetDigiDSPerc1", "AutoHealSetDigiDSPerc2", "AutoHealSetTamerDSPerc1", "AutoHealSetTamerDSPerc2",
    "AutoHealSetFatiguePerc", "AutoHealSetFatigueLogout",
    "AutoFarmAddHuntPosition", "AutoFarmClearHuntPositions",
    "AutoQuestAddQuest", "AutoQuestClearQuests",
    "AutoDropAddItemID", "AutoDropClearItemIDs",
    "AutoLootSetItems", "AutoLootSetMode", "AutoLootSetBits",
    "AutoBuffSetBuffClasses"
}

local foundFunctions = {}

for _, funcName in ipairs(possibleSetters) do
    local exists = _G[funcName]
    if type(exists) == "function" then
        log("[FOUND] Function exists: " .. funcName)
        table.insert(foundFunctions, funcName)
    else
        log("[NOT FOUND] No function: " .. funcName)
    end
end

-- Print ready-to-copy Lua table
local output = "local foundFunctions = {\n"
for _, name in ipairs(foundFunctions) do
    output = output .. string.format('    "%s",\n', name)
end
output = output .. "}\n"

log("✅ Function probe completed!")
log(output)
