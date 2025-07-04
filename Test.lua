local possibleSetters = {
    "AutoFarmToggle", "AutoFarmSetAttackBack", "AutoFarmSetReturnPosition", "AutoFarmSetBossPriorize",
    "AutoFarmSetForceChannel", "AutoFarmSetHuntRange", "AutoFarmSetLootRange", "AutoFarmSetReturnMap",
    "AutoFarmSetUseOnlySkills", "AutoFarmSetUseF1", "AutoFarmSetUseF2", "AutoFarmSetUseF3", "AutoFarmSetUseF4", "AutoFarmSetUseF5",
    "AutoFarmSetUseTamerF1", "AutoFarmSetUseTamerF2", "AutoFarmSetUseTamerF3", "AutoFarmSetUseTamerF4", "AutoFarmSetUseTamerF5",

    "AutoHealToggle", "AutoHealSetDigiHPPerc1", "AutoHealSetDigiHPPerc2", "AutoHealSetTamerHPPerc1", "AutoHealSetTamerHPPerc2",
    "AutoHealSetDigiDSPerc1", "AutoHealSetDigiDSPerc2", "AutoHealSetTamerDSPerc1", "AutoHealSetTamerDSPerc2",
    "AutoHealSetFatiguePerc", "AutoHealSetFatigueLogout",

    "AutoLoginToggle", "AutoLoginSetUsername", "AutoLoginSetPassword", "AutoLoginSetPassword2", "AutoLoginSetServer", "AutoLoginSetTamer",

    "AutoQuestToggle", "AutoQuestSetIDs",

    "AutoLootToggle", "AutoLootSetItems", "AutoLootSetMode", "AutoLootSetBits",

    "AutoBuffToggle", "AutoBuffSetBuffClasses", "AutoBuffSetOnlyDG",

    "AutoDropToggle", "AutoDropSetItemIDs", "AutoDropSetMinSlot",

    "AutoDGToggle", "AutoDGSetRunCount", "AutoDGSetHPThreshold", "AutoDGSetReEnterDelay", "AutoDGSetUnlimitedRun",

    "AutoEvoToggle", "AutoEvoSetDigimonID", "AutoEvoSetEvoType", "AutoEvoSetUseDigimonID",

    "AutoReturnToggle", "AutoReturnSetItemIDs", "AutoReturnSetMinSlot"
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
