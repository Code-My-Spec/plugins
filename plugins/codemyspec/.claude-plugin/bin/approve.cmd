@echo off
rem Claude Code PermissionRequest hook (Windows).
rem Mirrors ./approve — forwards stdin to the cms server's long-polling
rem permissions endpoint and prints the hook response. Falls back to "ask"
rem so Claude Code uses its built-in prompt if anything goes wrong.
setlocal
if not defined CODEMYSPEC_PORT set "CODEMYSPEC_PORT=4003"
curl.exe -sf -X POST "http://localhost:%CODEMYSPEC_PORT%/api/permissions/request" ^
  -H "Content-Type: application/json" ^
  -H "X-Working-Dir: %CD%" ^
  --data-binary @-
if errorlevel 1 echo {"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"ask"}}}
endlocal
