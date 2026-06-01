# Claude Code hook router (Windows / PowerShell).
# Mirrors bin/hook: parse event, on SessionStart ensure cms is installed +
# running, then POST the payload to the right /api/hooks/* endpoint.
#
# All errors are swallowed — a misbehaving hook should never break Claude
# Code itself, just produce no hook response.

$ErrorActionPreference = 'SilentlyContinue'

$port = if ($env:CODEMYSPEC_PORT) { $env:CODEMYSPEC_PORT } else { '4004' }

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

$cmsBin = Join-Path $env:USERPROFILE '.codemyspec\bin\cms.exe'

# Inline first-install — kept tiny so the heavier update path can live
# inside the binary (`cms self-update`). Obviously can't call that if
# the binary isn't on disk yet.
function Install-CmsFirstTime {
  $repo = 'Code-My-Spec/plugins'
  $binary = 'cms-windows-x64.exe'
  try {
    $resp = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest" `
      -Headers @{ 'User-Agent' = 'codemyspec-hook' } `
      -TimeoutSec 5
    $asset = $resp.assets | Where-Object { $_.name -eq $binary } | Select-Object -First 1
    if (-not $asset) { return }
    $binDir = Split-Path $cmsBin -Parent
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $cmsBin -UseBasicParsing -TimeoutSec 120
  } catch { }
}

# Only manage the burrito binary when this plugin is pointed at the prod
# port. On any other port we assume the developer is running the dev
# server themselves.
if ($event -eq 'SessionStart' -and $port -eq '4003') {
  if (-not (Test-Path $cmsBin)) {
    Install-CmsFirstTime
  } else {
    # Fire-and-forget self-update — runs while the user works. The binary
    # halts/restarts itself if a new version actually downloaded.
    Start-Process -FilePath $cmsBin -ArgumentList 'self-update' -WindowStyle Hidden | Out-Null
  }

  if (Test-Path $cmsBin) {
    # Idempotent: cms start no-ops if the server is already up.
    & $cmsBin start *> $null
  }
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
