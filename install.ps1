# CodeMySpec — standalone Windows installer
#
# Installs the cms binary as a Windows service supervised by Shawl
# (https://github.com/mtkennerly/shawl). Shawl IS the service entry point; it
# runs `cms.exe server`, restarts it on a nonzero exit, and forwards the
# service stop into a ctrl-C. cms auto-updates itself in place (swap binary,
# exit nonzero, Shawl relaunches the new one).
#
# Fully decoupled from the Claude Code plugin — the plugin only talks to the
# server on http://localhost:4003.
#
# The service runs as YOUR user account (so it can read/write your project
# files), which requires your Windows password. Registering a service requires
# Administrator; the script self-elevates with a UAC prompt.
#
# Usage:
#   iwr -useb https://raw.githubusercontent.com/Code-My-Spec/plugins/main/install.ps1 -OutFile install.ps1; .\install.ps1
#   .\install.ps1
#   $env:CMS_VERSION='v1.5.14'; .\install.ps1     # pin a release
#   .\install.ps1 -Uninstall                       # remove the service

[CmdletBinding()]
param(
  [switch]$Uninstall,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$Repo        = 'Code-My-Spec/plugins'
$CmsAsset    = 'cms-windows-x64.exe'
$ShawlAsset  = 'shawl-windows-x64.exe'
$Version     = if ($env:CMS_VERSION) { $env:CMS_VERSION } else { 'latest' }
$ServiceName = 'CodeMySpec'

# Service runs as the user, so the data dir is the user's profile — same path
# whether resolved by the service or by a user shell running `cms`.
$DataDir = Join-Path $env:USERPROFILE '.codemyspec'
$BinDir  = Join-Path $DataDir 'bin'
$LogDir  = Join-Path $DataDir 'shawl'
$CmsExe  = Join-Path $BinDir 'cms.exe'
$ShawlExe = Join-Path $BinDir 'shawl.exe'

function Write-Info($m) { Write-Host ">>> $m" -ForegroundColor Blue }
function Write-Ok($m)   { Write-Host ">>> $m" -ForegroundColor Green }
function Write-Err($m)  { Write-Host ">>> $m" -ForegroundColor Red }

function Test-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  $p  = New-Object Security.Principal.WindowsPrincipal($id)
  return $p.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Invoke-SelfElevate {
  Write-Info 'Elevation required — relaunching as Administrator…'
  $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"")
  if ($Uninstall) { $argList += '-Uninstall' }
  if ($DryRun)    { $argList += '-DryRun' }
  $env:CMS_VERSION = $Version
  Start-Process -FilePath 'powershell.exe' -ArgumentList $argList -Verb RunAs
  exit 0
}

if (-not (Test-Admin)) {
  if ($PSCommandPath) {
    Invoke-SelfElevate
  } else {
    Write-Err 'Administrator privileges required. Save the script and run it from an elevated PowerShell:'
    Write-Host '  iwr -useb https://raw.githubusercontent.com/Code-My-Spec/plugins/main/install.ps1 -OutFile install.ps1; .\install.ps1'
    exit 1
  }
}

Write-Host ''
Write-Host 'CodeMySpec Windows service installer' -ForegroundColor White
Write-Host ''

# --- uninstall ---------------------------------------------------------------

if ($Uninstall) {
  if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
    Write-Info "Stopping + removing service $ServiceName…"
    if (-not $DryRun) {
      Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
      & sc.exe delete $ServiceName | Out-Null
    }
    Write-Ok "Service removed. Binary + data left at $DataDir"
  } else {
    Write-Err "Service $ServiceName is not installed."
  }
  exit 0
}

# --- download ----------------------------------------------------------------

function Get-DownloadUrl([string]$assetName) {
  $releaseUrl = if ($Version -eq 'latest') {
    "https://api.github.com/repos/$Repo/releases/latest"
  } else {
    "https://api.github.com/repos/$Repo/releases/tags/$Version"
  }
  $headers = @{ 'User-Agent' = 'codemyspec-installer' }
  $resp = Invoke-RestMethod -Uri $releaseUrl -Headers $headers
  $asset = $resp.assets | Where-Object { $_.name -eq $assetName } | Select-Object -First 1
  if (-not $asset) {
    Write-Err "Could not find $assetName in release $Version (https://github.com/$Repo/releases)."
    exit 1
  }
  return $asset.browser_download_url
}

$cmsUrl   = Get-DownloadUrl $CmsAsset
$shawlUrl = Get-DownloadUrl $ShawlAsset

# --- credentials -------------------------------------------------------------

# The service must log on as the current user to access their project files.
$defaultUser = "$env:USERDOMAIN\$env:USERNAME"
Write-Info "The service will run as: $defaultUser"
$cred = if (-not $DryRun) {
  Get-Credential -UserName $defaultUser -Message 'Enter your Windows password so the service can run as you'
} else { $null }

# Shawl's service binPath — Shawl is the entry point, cms is the wrapped
# command. --kill-process-tree tears down Burrito's BEAM child on stop; no
# --restart so Shawl uses its default (restart on nonzero exit), which revives
# crashes but stays down on a clean `sc stop`.
$binPath = "`"$ShawlExe`" run --name $ServiceName --kill-process-tree --stop-timeout 20000 " +
           "--cwd `"$DataDir`" --log-dir `"$LogDir`" " +
           "--env `"CMS_HOME=$DataDir`" " +
           "-- `"$CmsExe`" server"

if ($DryRun) {
  Write-Host "Would download cms:   $cmsUrl"
  Write-Host "Would download shawl: $shawlUrl"
  Write-Host "Would install to:     $BinDir"
  Write-Host "Service binPath:      $binPath"
  Write-Host "Run as:               $defaultUser"
  exit 0
}

New-Item -ItemType Directory -Force -Path $BinDir, $LogDir | Out-Null

Write-Info "Downloading $CmsAsset…"
Invoke-WebRequest -Uri $cmsUrl -OutFile $CmsExe -UseBasicParsing
Write-Info "Downloading $ShawlAsset…"
Invoke-WebRequest -Uri $shawlUrl -OutFile $ShawlExe -UseBasicParsing

# --- grant "Log on as a service" --------------------------------------------

# A service account needs SeServiceLogonRight or service start fails with
# error 1069. New-Service -Credential does not grant it, so do it via secedit.
function Grant-LogonAsService([string]$account) {
  $ntAccount = New-Object System.Security.Principal.NTAccount($account)
  $sid = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value

  $cfg = [System.IO.Path]::GetTempFileName()
  $db  = [System.IO.Path]::GetTempFileName()
  & secedit.exe /export /cfg $cfg /areas USER_RIGHTS | Out-Null

  $content = Get-Content $cfg
  if ($content -match '^SeServiceLogonRight') {
    if ($content -notmatch [regex]::Escape($sid)) {
      $content = $content -replace '^(SeServiceLogonRight.*)', "`$1,*$sid"
    }
  } else {
    $content = $content -replace '(\[Privilege Rights\])', "`$1`r`nSeServiceLogonRight = *$sid"
  }
  Set-Content -Path $cfg -Value $content

  & secedit.exe /configure /db $db /cfg $cfg /areas USER_RIGHTS | Out-Null
  Remove-Item $cfg, $db -ErrorAction SilentlyContinue
}

Write-Info "Granting '$($cred.UserName)' the right to log on as a service…"
Grant-LogonAsService $cred.UserName

# --- register + start --------------------------------------------------------

if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
  Write-Info 'Service already exists — recreating to apply current settings…'
  Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
  & sc.exe delete $ServiceName | Out-Null
  Start-Sleep -Seconds 2
}

Write-Info 'Registering the service…'
New-Service -Name $ServiceName `
  -BinaryPathName $binPath `
  -DisplayName 'CodeMySpec Local Server' `
  -Description 'CodeMySpec local server (Phoenix + MCP) on port 4003, supervised by Shawl.' `
  -StartupType Automatic `
  -Credential $cred | Out-Null

Write-Info 'Starting the service…'
Start-Service -Name $ServiceName

Write-Host ''
Write-Ok 'CodeMySpec is installed and running as a service on http://localhost:4003'
Write-Host ''
Write-Host '  Manage it with the built-in service tools:'
Write-Host "    Get-Service $ServiceName"
Write-Host "    Restart-Service $ServiceName"
Write-Host "    .\install.ps1 -Uninstall"
Write-Host ''
Write-Host "  Data + logs: $DataDir"
Write-Host "  Shawl logs:  $LogDir"
Write-Host ''
