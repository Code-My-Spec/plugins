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

param([string]$Endpoint)

$ErrorActionPreference = 'SilentlyContinue'

$port = if ($env:CODEMYSPEC_PORT) { $env:CODEMYSPEC_PORT } else { '4003' }

# Read all of stdin once; we need it for both event detection and the
# forwarded POST body.
$stdin = [Console]::In.ReadToEnd()

# The endpoint, named by the caller when it knows it. Same reasoning as the bash
# router: `ask-user-question` is a PreToolUse with a matcher, so it arrives
# indistinguishable from the generic one and no amount of sniffing the event
# name can separate them. `hooks.json` knows, and passes it.
if (-not $Endpoint) {
  $event = $null
  try {
    $event = ($stdin | ConvertFrom-Json).hook_event_name
  } catch { }

  if (-not $event) { exit 0 }

  $Endpoint = switch ($event) {
    'SessionStart'      { '/api/hooks/session-start' }
    'PreToolUse'        { '/api/hooks/pre-tool-use' }
    'PostToolUse'       { '/api/hooks/post-tool-use' }
    'Stop'              { '/api/hooks/stop' }
    'SubagentStart'     { '/api/hooks/subagent-start' }
    'SubagentStop'      { '/api/hooks/subagent-stop' }
    'PermissionRequest' { '/api/permissions/request' }
    default             { exit 0 }
  }
}

$endpoint = $Endpoint

# Which working copy this is, read at request time. Same reasoning as the bash
# router beside this file, which carries the long version: a published plugin
# serves every checkout, so it can neither bake an id into its URLs nor take one
# from the environment, and without it the server guesses from a path.
#
# Walking up because a hook's cwd is wherever the agent is, not necessarily the
# checkout root. `ConvertFrom-Json` rather than a regex, since PowerShell has it
# and the bash side only avoids `jq` because jq is not guaranteed present.
function Get-HarnessId {
  $dir = (Get-Location).Path
  while ($dir) {
    $file = Join-Path $dir '.cms_harness.json'
    if (Test-Path $file) {
      try { return (Get-Content $file -Raw | ConvertFrom-Json).harness_id } catch { return $null }
    }
    $parent = Split-Path $dir -Parent
    if ($parent -eq $dir) { break }
    $dir = $parent
  }
  return $null
}

# The id, and no directory. The server resolves the working copy from the id
# alone now — a path on the wire did not fail when wrong, it succeeded against
# the wrong disk — so a checkout with no .cms_harness.json gets a refusal naming
# `mix cms.harness.onboard` rather than a hook that ran against another one.
$headers = @{
  'Content-Type' = 'application/json'
  'X-Harness-Id' = Get-HarnessId
}

# Forward to the local server. Print the response body so Claude Code can
# consume the hook reply. Any failure is silent — hooks shouldn't block.
try {
  $resp = Invoke-WebRequest -Uri "http://localhost:$port$endpoint" `
    -Method Post `
    -Headers $headers `
    -Body $stdin `
    -UseBasicParsing `
    -TimeoutSec 30
  Write-Output $resp.Content
} catch { }
