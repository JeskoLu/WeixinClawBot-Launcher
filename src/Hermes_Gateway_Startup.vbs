' Hermes Gateway Watchdog - startup bootstrap
' Launches the watchdog hidden. Called from the Registry Run key / scheduled task.
Option Explicit
Dim sh, hermesHome
Set sh = CreateObject("WScript.Shell")
hermesHome = sh.ExpandEnvironmentStrings("%HERMES_HOME%")
If hermesHome = "%HERMES_HOME%" Then hermesHome = sh.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\hermes"
sh.Run "wscript.exe """ & hermesHome & "\gateway-service\Hermes_Gateway_Watchdog.vbs""", 0, False
