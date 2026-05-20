param(
  [string]$SiteDir = "docs",
  [string]$LiveBase = "https://www.sagefemmelesangles.fr"
)

$ErrorActionPreference = "Stop"
$root = Join-Path (Resolve-Path ".").Path $SiteDir

function Test-JsCorrupted([string]$text) {
  if ($text -notmatch "sagefemmelesangles") { return $false }
  if ($text -match "/sagefemmelesangles/") { return $true }
  if ($text -match 'itemElement\+"/sagefemmelesangles') { return $true }
  return $false
}

function Get-LiveUrl([string]$relativePath) {
  $p = $relativePath -replace "\\", "/"
  if ($p -match "^cache/min/1/(.+)$") {
    return "$LiveBase/$($Matches[1])"
  }
  return "$LiveBase/$p"
}

$jsFiles = Get-ChildItem -Path $root -Recurse -Filter "*.js" -File
$fixed = 0
$failed = @()

foreach ($file in $jsFiles) {
  $content = [System.IO.File]::ReadAllText($file.FullName)
  if (-not (Test-JsCorrupted $content)) { continue }

  $rel = $file.FullName.Substring($root.Length).TrimStart("\", "/")
  $url = Get-LiveUrl $rel
  Write-Host "Restore $rel"

  try {
    Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $file.FullName
    $fixed++
  } catch {
    $failed += "$rel -> $url : $($_.Exception.Message)"
    Write-Warning "Echec: $url"
  }
}

Write-Host "Fichiers JS restaures : $fixed"
if ($failed.Count -gt 0) {
  Write-Host "Echecs :"
  $failed | ForEach-Object { Write-Host "  $_" }
}
