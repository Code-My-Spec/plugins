@echo off
rem Claude Code hook router (Windows). Bridges to hook.ps1 for the real
rem logic (JSON parse, ensure-running, POST). PowerShell ships with every
rem supported Windows; cmd alone is too anemic for stdin replay + JSON.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0hook.ps1"
