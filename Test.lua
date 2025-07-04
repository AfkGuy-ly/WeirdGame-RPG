local logoutFunctions = {
    "GoBackToLogin", "Logout", "Disconnect", "ForceLogout", "ReturnToLogin", "BackToLogin",
    "ClientLogout", "ClientDisconnect", "ClientRestart", "ClientExit", "GameLogout", "GameDisconnect",
    "ForceReturnToLogin", "Relog", "ReLogin", "Reconnect", "ExitGame", "StopGame", "StopSession",
    "TerminateSession", "EndSession", "LogOff", "LogOut", "LeaveGame", "LeaveWorld", "LeaveServer",
    "RestartGame", "RestartSession", "SessionEnd", "ReturnLogin", "BackLogin", "ToLogin",
    "RestartLogin", "LoginScreen", "AutoLogout", "AutoLogOut", "AutoDisconnect", "AutoExit",
    "QuitGame", "QuitSession", "QuitClient", "QuitNow", "ForceExit", "ForceQuit", "ForceDisconnect",
    "KickSelf", "KickMe", "SendLogout", "SendDisconnect", "GameStop", "GameExit", "ReturnToMenu",
    "GoToLogin", "GoToMenu", "RestartBot", "StopBot", "StopScript", "ScriptStop", "StopAutomation",
    "StopAll", "TerminateBot", "ShutdownBot", "ShutdownClient", "ShutdownGame", "RestartAutomation",
    "SessionStop", "DisconnectGame", "DisconnectClient", "DisconnectNow", "ImmediateLogout",
    "ImmediateDisconnect", "ImmediateExit", "HardDisconnect", "HardLogout", "SoftLogout", "SoftDisconnect",
    "GameLeave", "BackToSelect", "ReturnCharacterSelect", "ReturnCharSelect", "ToCharacterSelect",
    "ToCharSelect", "GotoCharSelect", "GotoCharacterSelect", "RestartCharacter", "RestartChar",
    "EndCharSession", "ForceCharLogout", "LeaveNow", "GoNow", "StopNow", "InstantLogout",
    "InstantDisconnect", "ForceRelog", "ForceReLogin", "ManualLogout", "ManualDisconnect",
    "ManualExit", "ExitNow", "ExitBot", "TerminateNow", "EndBot", "EndAutomation", "BreakScript",
    "BreakBot", "BreakSession", "BreakClient", "CloseClient", "CloseBot", "CloseAutomation",
    "CloseGame", "CloseSession", "ExitAutomation", "ReturnToStart", "ReturnToBase", "ReturnToLobby",
    "GoToLobby", "LobbyReturn", "LobbyDisconnect", "LobbyExit", "LobbyLeave", "LobbyStop",
    "BackToLobby", "CharSelectLogout", "CharSelectDisconnect", "CharSelectReturn", "CharSelectStop",
    "CharSelectExit", "CharSelectLeave", "StopCharacter", "StopChar", "EndChar", "EndCharacter",
    "KickFromGame", "KickFromSession", "KickFromServer", "KickOut", "KickBot", "DropBot",
    "DropConnection", "DropSession", "DropGame", "DropClient", "DropNow", "DropAutomation",
    "LeaveAutomation", "LeaveBot", "LeaveScript", "EndScript", "CancelScript", "CancelBot",
    "CancelAutomation", "StopModule", "StopEngine", "StopKernel", "EndKernel", "EndModule",
    "StopProcess", "TerminateProcess", "ExitProcess", "AbortScript", "AbortBot", "AbortAutomation",
    "AbortSession", "AbortClient", "AbortGame", "AbortNow"
}

for _, funcName in ipairs(logoutFunctions) do
    local exists = _G[funcName]
    if type(exists) == "function" then
        log("[FOUND] Logout-related function: " .. funcName)
    else
        log("[NOT FOUND] No function: " .. funcName)
    end
end
