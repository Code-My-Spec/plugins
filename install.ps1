# CodeMySpec — standalone Windows installer
#
# Installs the cms binary as a Windows service supervised by Shawl. This is
# fully decoupled from the Claude Code plugin: it installs a machine service
# that runs the local Phoenix/MCP server on :4003. The plugin only talks to
# that port.
#
# Requires Administrator (registering a service does). The script
# self-elevates with a UAC prompt if you launch it unelevated.
#
# Usage (from an elevated PowerShell, or let it elevate itself):
#   iwr -useb https://raw.githubusercontent.com/Code-My-Spec/plugins/main/install.ps1 | iex
#   .\install.ps1
#   $env:CMS_VERSION='v1.5.14'; .\install.ps1     # pin a release
#   .\install.ps1 -Uninstall                       # remove the service

[CmdletBinding()]
param(
  [switch]$Uninstall,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$Repo    = 'Code-My-Spec/plugins'
$Binary  = 'cms-windows-x64.exe'
$Version = if ($env:CMS_VERSION) { $env:CMS_VERSION } else { 'latest' }

$DataDir = 'C:\ProgramData\CodeMySpec'
$BinDir  = Join-Path $DataDir 'bin'
$CmsExe  = Join-Path $BinDir 'cms.exe'

function Write-Info($m) { Write-Host ">>> $m" -ForegroundColor Blue }
function Write-Ok($m)   { Write-Host ">>> $m" -ForegroundColor Green }
function Write-Err($m)  { Write-Host ">>> $m" -ForegroundColor Red }

function Test-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  $p  = New-Object Security.Principal.WindowsPrincipal($id)
  return $p.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Re-launch self elevated, preserving args + pinned version, then exit.
function Invoke-SelfElevate {
  Write-Info 'Elevation required — relaunching as Administrator…'
  $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"")
  if ($Uninstall) { $argList += '-Uninstall' }
  if ($DryRun)    { $argList += '-DryRun' }
  $env:CMS_VERSION = $Version
  Start-Process -FilePath 'powershell.exe' -ArgumentList $argList -Verb RunAs
  exit 0
}

# When piped via `iwr | iex` there is no $PSCommandPath to relaunch, so we
# can only self-elevate when running from a file on disk.
if (-not (Test-Admin)) {
  if ($PSCommandPath) {
    Invoke-SelfElevate
  } else {
    Write-Err 'Administrator privileges required. Open an elevated PowerShell and re-run:'
    Write-Host '  iwr -useb https://raw.githubusercontent.com/Code-My-Spec/plugins/main/install.ps1 -OutFile install.ps1; .\install.ps1'
    exit 1
  }
}

Write-Host ''
Write-Host 'CodeMySpec Windows service installer' -ForegroundColor White
Write-Host ''

if ($Uninstall) {
  if (Test-Path $CmsExe) {
    Write-Info 'Uninstalling service…'
    if (-not $DryRun) { & $CmsExe service uninstall }
    Write-Ok 'Service removed. Binary + data left in place at:'
    Write-Host "  $DataDir"
  } else {
    Write-Err "cms.exe not found at $CmsExe — nothing to uninstall."
  }
  exit 0
}

function Get-DownloadUrl {
  $releaseUrl = if ($Version -eq 'latest') {
    "https://api.github.com/repos/$Repo/releases/latest"
  } else {
    "https://api.github.com/repos/$Repo/releases/tags/$Version"
  }
  $headers = @{ 'User-Agent' = 'codemyspec-installer' }
  $resp = Invoke-RestMethod -Uri $releaseUrl -Headers $headers
  $asset = $resp.assets | Where-Object { $_.name -eq $Binary } | Select-Object -First 1
  if (-not $asset) {
    Write-Err "Could not find $Binary in release $Version."
    Write-Host "  Releases: https://github.com/$Repo/releases"
    exit 1
  }
  return $asset.browser_download_url
}

$url = Get-DownloadUrl

if ($DryRun) {
  Write-Host "Would download: $url"
  Write-Host "Would install:  $CmsExe"
  Write-Host "Would run:      cms service install"
  exit 0
}

New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

Write-Info "Downloading $Binary…"
Invoke-WebRequest -Uri $url -OutFile $CmsExe -UseBasicParsing

Write-Info 'Registering the Windows service (downloads Shawl on first run)…'
& $CmsExe service install
if ($LASTEXITCODE -ne 0) {
  Write-Err "Service install failed (exit $LASTEXITCODE)."
  exit $LASTEXITCODE
}

Write-Host ''
Write-Ok 'CodeMySpec is installed and running as a service on http://localhost:4003'
Write-Host ''
Write-Host '  Manage it with:'
Write-Host '    cms service status'
Write-Host '    cms service stop | start | restart'
Write-Host '    cms service uninstall'
Write-Host ''
Write-Host "  Data + logs: $DataDir"
Write-Host ''
