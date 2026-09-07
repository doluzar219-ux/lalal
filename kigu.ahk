#NoEnv
#SingleInstance Force
#NoTrayIcon
#MaxHotkeysPerInterval 200
#MaxThreadsPerHotkey 2
SetBatchLines, -1
ListLines, Off
SetWinDelay, 0
SetKeyDelay, -1, -1   ; Maximum speed with zero character drop
SendMode Input
SetWorkingDir %A_ScriptDir%

; ============================================================
; CONFIGURATION & CREDENTIALS
; ============================================================
global BinID    := "6a9c1d41da38895dfe3c66e3"
global ApiKey   := "$2a$10$PJ/OKs8LNA4ZqX1qRmEae.Kb0Qi17yjkfp4ieCOSLFCwoBGbwIb1e"
global Endpoint := "https://api.jsonbin.io/v3/b/" . BinID . "/latest"

; Local Memory Object (0% Lag, Local Storage)
global Macros := {}

; Script start hone par single initial fetch
FetchMacros()
return

; ============================================================
; CONTROLS
; ============================================================

; Press 'j' (or Ctrl + Shift + R) to Fetch/Refresh latest code from JSONBin
$j::
^+r::
    FetchMacros()
return

; Press 'z' to Pause / Unpause script
$z::
    Pause, Toggle, 1
return

; Press Esc to Exit
Esc::
    ExitApp
return

; ============================================================
; MACRO KEYS (100% Offline Local Paste)
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
    try {
        http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        http.SetTimeouts(2000, 2000, 2000, 2000) ; Max 2s timeout
        http.Open("GET", Endpoint, false)
        http.SetRequestHeader("X-Master-Key", ApiKey)
        http.SetRequestHeader("Content-Type", "application/json")
        http.Send()

        if (http.Status == 200) {
            ParseJSONNative(http.ResponseText)
            SoundBeep, 750, 100 ; Beep on successful sync
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

; Raw Unicode Stream Engine (Preserves Indentation, Newlines, Brackets & Quotes)
SendMacro(keyName) {
    if (!Macros.HasKey(keyName) || Macros[keyName] == "") {
        return
    }

    textToType := Macros[keyName]
    
    ; Bypasses paste blockers while keeping tabs, spaces, and brackets 100% intact
    SendInput, {Text}%textToType%
}