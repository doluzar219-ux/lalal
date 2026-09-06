#NoEnv
#SingleInstance Force
#NoTrayIcon
#MaxHotkeysPerInterval 200
#MaxThreadsPerHotkey 2
SetBatchLines, -1
ListLines, Off
SetWinDelay, 0
SendMode Input
SetWorkingDir %A_ScriptDir%

; ============================================================
; CONFIGURATION & CREDENTIALS
; ============================================================
global BinID    := "6a9c1d41da38895dfe3c66e3"
global ApiKey   := "$2a$10$PJ/OKs8LNA4ZqX1qRmEae.Kb0Qi17yjkfp4ieCOSLFCwoBGbwIb1e"
global Endpoint := "https://api.jsonbin.io/v3/b/" . BinID . "/latest"

global Macros := {}

; Initial fetch on script start
FetchMacros()

; Background Auto-Sync (Every 5 seconds)
SetTimer, AutoSyncTimer, 5000
return

; ============================================================
; AUTO-SYNC TIMER
; ============================================================
AutoSyncTimer:
    FetchMacros()
return

; ============================================================
; HOTKEY CONTROL BUTTONS ($j, $z, Esc)
; ============================================================

; Pause / Resume Toggle
$j::
    Pause, Toggle, 1
return

; Emergency Reset / Reload
$z::
    Sleep, 100
    Reload
return

; Exit Script
Esc::
    ExitApp
return

; ============================================================
; MACRO HOTKEYS
; ============================================================
$2:: SendMacro("KEY2")
$3:: SendMacro("KEY3")
$4:: SendMacro("KEY4")
$5:: SendMacro("KEY5")
$6:: SendMacro("KEY6")
$7:: SendMacro("KEY7")
$8:: SendMacro("KEY8")
$9:: SendMacro("KEY9")

*Numpad2:: SendMacro("KEY2")
*Numpad3:: SendMacro("KEY3")
*Numpad4:: SendMacro("KEY4")
*Numpad5:: SendMacro("KEY5")
*Numpad6:: SendMacro("KEY6")
*Numpad7:: SendMacro("KEY7")
*Numpad8:: SendMacro("KEY8")
*Numpad9:: SendMacro("KEY9")

; ============================================================
; CORE FUNCTIONS
; ============================================================

FetchMacros() {
    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    http.Open("GET", Endpoint, false)
    http.SetRequestHeader("X-Master-Key", ApiKey)
    http.SetRequestHeader("Content-Type", "application/json")
    
    try {
        http.Send()
        if (http.Status == 200) {
            ParseJSONNative(http.ResponseText)
        }
    } catch e {
    }
}

ParseJSONNative(jsonString) {
    doc := ComObjCreate("htmlfile")
    doc.write("<meta http-equiv='X-UA-Compatible' content='IE=9'>")
    
    try {
        parsed := doc.parentWindow.JSON.parse(jsonString)
        record := parsed.record
        
        Loop, 9 {
            if (A_Index < 2)
                continue
            
            kName := "KEY" . A_Index
            val := record[kName]
            Macros[kName] := (val != "" && val != doc.parentWindow.undefined) ? val : ""
        }
    } catch e {
    }
}

; Pure Unicode Stream Injection (Passes paste blockers & preserves special symbols)
SendMacro(keyName) {
    if (!Macros.HasKey(keyName) || Macros[keyName] == "") {
        return
    }

    textToType := Macros[keyName]
    SendInput, {Text}%textToType%
}