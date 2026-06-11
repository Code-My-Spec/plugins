# Claude Code hook router (Windows / PowerShell).
# Parse event, then POST the payload to the right /api/hooks/* endpoint.
#
# The cms server runs as a standalone Windows service (installed out-of-band
# via installers/windows/install.ps1, supervised by Shawl, self-updating).
# The plugin does NOT install, start, or update the binary — it only talks to
# the running service on its port. If the service is down the POST simply
# fails and the hook is a no-op.
#
# All errors are swallowed — a misbehaving hook should never break Claude
# Code itself, just produce no hook response.

$ErrorActionPreference = 'SilentlyContinue'

$port = if ($env:CODEMYSPEC_PORT) { $env:CODEMYSPEC_PORT } else { '4003' }

# Read all of stdin once; we need it for both event detection and the
# forwarded POST body.
$stdin = [Console]::In.ReadToEnd()

$event = $null
try {
  $event = ($stdin | ConvertFrom-Json).hook_event_name
} catch { }

if (-not $event) { exit 0 }

$endpoint = switch ($event) {
  'SessionStart'  { '/api/hooks/session-start' }
  'PreToolUse'    { '/api/hooks/pre-tool-use' }
  'PostToolUse'   { '/api/hooks/post-tool-use' }
  'Stop'          { '/api/hooks/stop' }
  'SubagentStart' { '/api/hooks/subagent-start' }
  'SubagentStop'  { '/api/hooks/subagent-stop' }
  default         { exit 0 }
}

# Forward to the local server. Print the response body so Claude Code can
# consume the hook reply. Any failure is silent — hooks shouldn't block.
try {
  $resp = Invoke-WebRequest -Uri "http://localhost:$port$endpoint" `
    -Method Post `
    -Headers @{
      'Content-Type'  = 'application/json'
      'X-Working-Dir' = (Get-Location).Path
    } `
    -Body $stdin `
    -UseBasicParsing `
    -TimeoutSec 30
  Write-Output $resp.Content
} catch { }
