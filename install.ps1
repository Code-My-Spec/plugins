# CodeMySpec CLI Installer (Windows)
# Downloads cms-windows-x64.exe from GitHub Releases and installs to
# %USERPROFILE%\.codemyspec\bin\cms.exe so it survives plugin upgrades.
#
# Usage:
#   iwr -useb https://raw.githubusercontent.com/Code-My-Spec/plugins/main/install.ps1 | iex
#   .\install.ps1              # install latest
#   .\install.ps1 -DryRun      # show what would happen
#   $env:CMS_VERSION='v1.5.4'; .\install.ps1   # pin a version

[CmdletBinding()]
param(
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$Repo       = 'Code-My-Spec/plugins'
$BinaryBase = 'cms'
$Version    = if ($env:CMS_VERSION) { $env:CMS_VERSION } else { 'latest' }

$CmsHome = Join-Path $env:USERPROFILE '.codemyspec'
$BinDir  = Join-Path $CmsHome 'bin'

function Write-Info($msg) { Write-Host ">>> $msg" -ForegroundColor Blue }
function Write-Ok($msg)   { Write-Host ">>> $msg" -ForegroundColor Green }
function Write-Err($msg)  { Write-Host ">>> $msg" -ForegroundColor Red }

function Get-PlatformBinaryName {
  $arch = (Get-CimInstance Win32_Processor | Select-Object -First 1).Architecture
  # Architecture: 0=x86, 5=ARM, 9=x64, 12=ARM64
  switch ($arch) {
    9       { return "$BinaryBase-windows-x64.exe" }
    12      { Write-Err 'Windows ARM64 builds are not yet published.'; exit 1 }
    default { Write-Err "Unsupported architecture (Win32_Processor.Architecture=$arch)."; exit 1 }
  }
}

function Get-DownloadUrl([string]$binaryFile) {
  $releaseUrl = if ($Version -eq 'latest') {
    "https://api.github.com/repos/$Repo/releases/latest"
  } else {
    "https://api.github.com/repos/$Repo/releases/tags/$Version"
  }

  $headers = @{ 'User-Agent' = 'codemyspec-installer' }
  $resp = Invoke-RestMethod -Uri $releaseUrl -Headers $headers
  $asset = $resp.assets | Where-Object { $_.name -eq $binaryFile } | Select-Object -First 1

  if (-not $asset) {
    Write-Err "Could not find $binaryFile in release $Version."
    Write-Host "  Available binaries at: https://github.com/$Repo/releases"
    exit 1
  }

  return $asset.browser_download_url
}

function Install-Binary([string]$url, [string]$dest) {
  New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

  Write-Info "Downloading $(Split-Path -Leaf $dest)..."
  Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}

Write-Host ''
Write-Host 'CodeMySpec CLI Installer' -ForegroundColor White
Write-Host ''

$binaryFile = Get-PlatformBinaryName
Write-Info "Platform: windows-x64"

$url  = Get-DownloadUrl $binaryFile
$dest = Join-Path $BinDir 'cms.exe'

if ($DryRun) {
  Write-Host "Would download from: $url"
  Write-Host "Would install to:    $dest"
  exit 0
}

Install-Binary $url $dest

Write-Host ''
Write-Ok 'Installation complete!'
Write-Host ''
Write-Host '  Next steps:'
Write-Host ''
Write-Host '  1. Install the plugin in Claude Code:'
Write-Host '     claude plugin install <path-to-extension>'
Write-Host ''
Write-Host '  2. Open Claude Code in your Phoenix project and run:'
Write-Host '     /codemyspec:authenticate'
Write-Host ''
