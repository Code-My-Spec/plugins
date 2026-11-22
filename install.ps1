# CodeMySpec — Windows installer (bootstrap).
#
# Downloads cms-setup-x64.msi from the latest release and runs it. The MSI lays
# down the plain `mix release` folder (ERTS + start.boot on disk — no runtime
# self-extraction) and registers the CodeMySpec service (Shawl wrapping the
# release launcher). Updates: re-run this (a newer MSI upgrades in place).
#
# Requires Administrator (installing a service does); self-elevates via UAC.
#
# Usage:
#   iwr -useb https://raw.githubusercontent.com/Code-My-Spec/plugins/main/install.ps1 -OutFile install.ps1; .\install.ps1
#   .\install.ps1
#   $env:CMS_VERSION='v1.5.23'; .\install.ps1     # pin a release
#   .\install.ps1 -Uninstall

[CmdletBinding()]
param(
  [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$Repo    = 'Code-My-Spec/plugins'
$Msi     = 'cms-setup-x64.msi'
$Version = if ($env:CMS_VERSION) { $env:CMS_VERSION } else { 'latest' }

function Write-Info($m) { Write-Host ">>> $m" -ForegroundColor Blue }
function Write-Ok($m)   { Write-Host ">>> $m" -ForegroundColor Green }
function Write-Err($m)  { Write-Host ">>> $m" -ForegroundColor Red }

function Test-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole(
    [Security.Principal.WindowsBuiltinRole]::Administrator)
}

if (-not (Test-Admin)) {
  if ($PSCommandPath) {
    Write-Info 'Elevation required — relaunching as Administrator…'
    $a = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
    if ($Uninstall) { $a += '-Uninstall' }
    if ($env:CMS_VERSION) { $env:CMS_VERSION = $env:CMS_VERSION }
    Start-Process powershell.exe -ArgumentList $a -Verb RunAs
    exit 0
  } else {
    Write-Err 'Run from an elevated PowerShell (save the script first):'
    Write-Host '  iwr -useb https://raw.githubusercontent.com/Code-My-Spec/plugins/main/install.ps1 -OutFile install.ps1; .\install.ps1'
    exit 1
  }
}

if ($Uninstall) {
  Write-Info 'Uninstalling CodeMySpec…'
  $p = Get-CimInstance Win32_Product -Filter "Name='CodeMySpec'" -ErrorAction SilentlyContinue
  if ($p) { msiexec /x $p.IdentifyingNumber /quiet | Out-Null; Write-Ok 'Uninstalled.' }
  else { Write-Err 'CodeMySpec is not installed.' }
  exit 0
}

# Resolve the MSI download URL from the release.
$releaseUrl = if ($Version -eq 'latest') {
  "https://api.github.com/repos/$Repo/releases/latest"
} else {
  "https://api.github.com/repos/$Repo/releases/tags/$Version"
}
$resp  = Invoke-RestMethod -Uri $releaseUrl -Headers @{ 'User-Agent' = 'codemyspec-installer' }
$asset = $resp.assets | Where-Object { $_.name -eq $Msi } | Select-Object -First 1
if (-not $asset) {
  Write-Err "No $Msi in release $Version (https://github.com/$Repo/releases)."
  exit 1
}

$dest = Join-Path $env:TEMP $Msi
Write-Info "Downloading $Msi…"
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $dest -UseBasicParsing

Write-Info 'Running the installer…'
$log = Join-Path $env:TEMP 'cms-install.log'
$proc = Start-Process msiexec.exe -ArgumentList @('/i', "`"$dest`"", '/qb', '/l*v', "`"$log`"") -Wait -PassThru
if ($proc.ExitCode -ne 0) {
  Write-Err "Install failed (exit $($proc.ExitCode)). Log: $log"
  exit $proc.ExitCode
}

Write-Host ''
Write-Ok 'CodeMySpec installed and running as a service on http://localhost:4003'
Write-Host '  Manage: Get-Service CodeMySpec | Restart-Service CodeMySpec'
Write-Host '  Remove: .\install.ps1 -Uninstall'
Write-Host '  Data + logs: C:\ProgramData\CodeMySpec'
Write-Host ''
