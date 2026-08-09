# -*- coding: utf-8 -*-
"""
Hermes Weixin Bot One-Click Launcher
Double-click to run -> clean old watchdogs -> check gateway -> start if down -> show result dialog.

Requirements: Hermes Agent installed on Windows (https://hermes-agent.nousresearch.com)
The gateway connects Hermes to WeChat via Tencent iLink Bot API (personal WeChat).
"""
import subprocess
import os
import time
import tkinter as tk
from tkinter import messagebox


def detect_hermes_home():
    """Locate the Hermes home directory (no hardcoded user paths)."""
    env = os.environ.get("HERMES_HOME")
    if env and os.path.isdir(env):
        return env
    # Common install locations
    candidates = [
        os.path.expanduser(r"~\AppData\Local\hermes"),
        os.path.expanduser(r"~\.hermes"),
    ]
    for c in candidates:
        if os.path.isdir(c):
            return c
    return None


HERMES_HOME = detect_hermes_home()
WATCHDOG_STARTUP = os.path.join(HERMES_HOME, "gateway-service", "Hermes_Gateway_Startup.vbs") if HERMES_HOME else None
NO_WINDOW = subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0


def run_hidden(cmd):
    """Run a command with no console window, return combined stdout+stderr."""
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=25,
                           creationflags=NO_WINDOW)
        return (r.stdout or "") + (r.stderr or "")
    except Exception:
        return ""


def gateway_running():
    """Return True if a python.exe process with 'gateway run' in its command line exists."""
    out = run_hidden([
        "powershell", "-NoProfile", "-Command",
        "Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'python.exe' -and $_.CommandLine -match 'gateway run' } | Measure-Object | Select-Object -ExpandProperty Count"
    ])
    out = out.strip()
    if not out:
        return False
    try:
        return int(out.split()[-1]) > 0
    except ValueError:
        return False


def kill_old_watchdogs():
    """Kill all existing watchdog script instances to avoid duplicates."""
    run_hidden([
        "powershell", "-NoProfile", "-Command",
        "Get-CimInstance Win32_Process | Where-Object { ($_.Name -eq 'wscript.exe' -or $_.Name -eq 'cscript.exe') -and $_.CommandLine -match 'Watchdog' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"
    ])


def start_watchdog():
    """Start the watchdog script silently in the background."""
    try:
        subprocess.Popen(["wscript.exe", WATCHDOG_STARTUP],
                         creationflags=NO_WINDOW, shell=False)
        return True
    except Exception:
        return False


def main():
    root = tk.Tk()
    root.withdraw()

    if not HERMES_HOME:
        messagebox.showerror(
            "Weixin Bot - Not Found",
            "Could not locate the Hermes home directory.\n\n"
            "Please set the HERMES_HOME environment variable and try again.",
        )
        root.destroy()
        return

    kill_old_watchdogs()
    time.sleep(1)

    if not gateway_running():
        start_watchdog()
        # Wait up to 60s for the watchdog to bring the gateway up
        for _ in range(20):
            time.sleep(3)
            if gateway_running():
                break

    if gateway_running():
        messagebox.showinfo(
            "Weixin Bot - Connected",
            "WeixinClawBot is connected!\n\n"
            "You can now chat with the bot from your WeChat app.\n\n"
            "Tip: the gateway auto-starts at login; this tool is a manual fallback.",
        )
    else:
        messagebox.showerror(
            "Weixin Bot - Connection Failed",
            "Could not connect the Weixin bot.\n\n"
            "Please check:\n"
            "1. Is your computer online?\n"
            "2. Run 'hermes gateway run' manually in a terminal\n"
            "3. Check the log: <HERMES_HOME>/logs/gateway.log",
        )
    root.destroy()


if __name__ == "__main__":
    main()
