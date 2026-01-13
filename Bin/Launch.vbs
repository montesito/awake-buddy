Set objShell = CreateObject("WScript.Shell")
strScriptPath = "..\AwakeBuddy.ps1"
objShell.Run "powershell -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File """ & strScriptPath & """", 0, False
