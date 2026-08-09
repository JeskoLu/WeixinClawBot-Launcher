' Hermes Gateway Watchdog (portable version)
' Checks every 30s if the Hermes gateway process is alive, restarts it if dead.
' Auto-starts via the Windows Registry Run key or a scheduled task.
' Requires HERMES_HOME to be set (or falls back to the standard install location).
Option Explicit

Dim fso, logDir, logFile, hermesHome
Set fso = CreateObject("Scripting.FileSystemObject")

' --- Resolve HERMES_HOME (no hardcoded user paths) ---
hermesHome = GetEnv("HERMES_HOME")
If hermesHome = "" Or Not fso.FolderExists(hermesHome) Then
    hermesHome = fso.BuildPath(fso.GetSpecialFolder(0), "AppData\Local\hermes")
    If Not fso.FolderExists(hermesHome) Then
        hermesHome = fso.BuildPath(fso.GetSpecialFolder(0), ".hermes")
    End If
End If

logDir = fso.BuildPath(hermesHome, "logs")
If Not fso.FolderExists(logDir) Then fso.CreateFolder(logDir)
logFile = fso.BuildPath(logDir, "watchdog.log")

Dim gatewayCmd, pythonPath
pythonPath = fso.BuildPath(hermesHome, "hermes-agent\venv\Scripts\python.exe")
gatewayCmd = """" & pythonPath & """ -m hermes_cli.main gateway run"

Do
    If Not IsGatewayRunning() Then
        StartGateway
    End If
    WScript.Sleep 30000
Loop

Function GetEnv(name)
    Dim sh
    Set sh = CreateObject("WScript.Shell")
    GetEnv = sh.ExpandEnvironmentStrings("%" & name & "%")
    If GetEnv = "%" & name & "%" Then GetEnv = ""
End Function

' Returns True if a python/hermes process with "gateway run" exists
Function IsGatewayRunning()
    Dim wmi, col, proc, exe
    IsGatewayRunning = False
    On Error Resume Next
    Set wmi = GetObject("winmgmts:\\.\root\cimv2")
    Set col = wmi.ExecQuery("SELECT ProcessId, Name, CommandLine FROM Win32_Process WHERE CommandLine LIKE '%gateway run%'")
    If Err.Number <> 0 Then
        Err.Clear
        IsGatewayRunning = True
        Exit Function
    End If
    For Each proc In col
        exe = LCase(proc.Name)
        If InStr(exe, "python") > 0 Or InStr(exe, "hermes") > 0 Then
            IsGatewayRunning = True
            Exit For
        End If
    Next
    Set wmi = Nothing
End Function

Sub StartGateway()
    Dim sh, env, existing_pp, pyPath, ppPrefix
    Set sh = CreateObject("WScript.Shell")
    Set env = sh.Environment("PROCESS")
    env.Item("HERMES_HOME") = hermesHome
    env.Item("PYTHONIOENCODING") = "utf-8"
    env.Item("HERMES_GATEWAY_DETACHED") = "1"
    env.Item("VIRTUAL_ENV") = fso.BuildPath(hermesHome, "hermes-agent\venv")
    ppPrefix = fso.BuildPath(hermesHome, "hermes-agent")
    existing_pp = env.Item("PYTHONPATH")
    If Len(existing_pp) > 0 Then
        env.Item("PYTHONPATH") = ppPrefix & ";" & existing_pp
    Else
        env.Item("PYTHONPATH") = ppPrefix
    End If
    sh.CurrentDirectory = hermesHome
    sh.Run gatewayCmd, 0, False
    Dim f
    Set f = fso.OpenTextFile(logFile, 8, True)
    f.WriteLine Now & " [watchdog] Gateway was DOWN, restarting..."
    f.Close
End Sub
