@echo off
rem Claude Code hook router (Windows). Bridges to hook.ps1 for the real
rem logic (JSON parse, ensure-running, POST). PowerShell ships with every
rem supported Windows; cmd alone is too anemic for stdin replay + JSON.
rem %* forwards the endpoint hooks.json passes. Without it the router falls back
rem to sniffing hook_event_name, which cannot tell `ask-user-question` (a
rem PreToolUse with a matcher) from the generic PreToolUse beside it.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0hook.ps1" %*
