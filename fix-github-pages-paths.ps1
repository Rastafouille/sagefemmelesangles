param(
  [string]$SiteDir = "docs",
  [string]$BasePath = "/sagefemmelesangles"
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path ".").Path
$target = Join-Path $root $SiteDir
$prefix = $BasePath.TrimEnd("/")
$repo = $prefix.TrimStart("/")

if (!(Test-Path $target)) {
  throw "Dossier introuvable : $target"
}

$escapedRepo = [regex]::Escape($repo)

# Uniquement les chemins absolus dans les attributs HTML / JS (pas les URL https://...)
$attrPattern = '(?<=(?:href|src|srcset|action|content|data-lazyload|data-bg|data-src|poster)\s*=\s*[''"])/(?!/)(?!' + $escapedRepo + '/)'
$jsSrcPattern = '(?<=\.src\s*=\s*[''"])/(?!/)(?!' + $escapedRepo + '/)'
$jsAttrPattern = '(?<=\.attr\s*\(\s*[''"][^''"]+[''"]\s*,\s*[''"])/(?!/)(?!' + $escapedRepo + '/)'
$quotedPathPattern = '(?<=[''"])/(?!/)(?!' + $escapedRepo + '/)'
$srcsetCommaPattern = '(?<=\d[wpx%],\s*)/(?!/)(?!' + $escapedRepo + '/)'
# url(/path) et url("/path") / url('/path')
$cssUrlPattern = 'url\(\s*(["'']?)/(?!/)(?!' + $escapedRepo + '/)'

$unquotedAttrPattern = '(?<=(?:src|href)=)/(?!/)(?!' + $escapedRepo + '/)'

$patterns = @(
  @{ Regex = $attrPattern; Replace = "${prefix}/" },
  @{ Regex = $unquotedAttrPattern; Replace = "${prefix}/" },
  @{ Regex = $jsSrcPattern; Replace = "${prefix}/" },
  @{ Regex = $jsAttrPattern; Replace = "${prefix}/" },
  @{ Regex = $quotedPathPattern; Replace = "${prefix}/" },
  @{ Regex = $srcsetCommaPattern; Replace = "${prefix}/" },
  @{ Regex = $cssUrlPattern; Replace = 'url($1' + $prefix + '/' },
  @{ Regex = '&#039;/(?!/)(?!' + $escapedRepo + '/)'; Replace = '&#039;' + $prefix + '/' },
  @{ Regex = '&quot;/(?!/)(?!' + $escapedRepo + '/)'; Replace = '&quot;' + $prefix + '/' }
)

# Ne pas toucher aux .js : le remplacement de "/..." casse les librairies minifiées (ex. owl.carousel).
$extensions = @("*.html", "*.css")
$files = Get-ChildItem -Path $target -Recurse -File -Include $extensions -ErrorAction SilentlyContinue
$changed = 0

foreach ($file in $files) {
  $content = [System.IO.File]::ReadAllText($file.FullName)
  $original = $content

  foreach ($p in $patterns) {
    $content = [regex]::Replace($content, $p.Regex, $p.Replace)
  }

  if ($content -ne $original) {
    [System.IO.File]::WriteAllText($file.FullName, $content)
    $changed++
  }
}

$noJekyll = Join-Path $target ".nojekyll"
if (!(Test-Path $noJekyll)) {
  New-Item -ItemType File -Path $noJekyll -Force | Out-Null
}

Write-Host "Fichiers modifies : $changed / $($files.Count)"
Write-Host "Base path applique : $prefix"
Write-Host "Dossier : $target"
