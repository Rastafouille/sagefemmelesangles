param(
  [string]$BaseUrl = "https://www.sagefemmelesangles.fr/",
  [string]$OutDir = "public",
  [int]$MaxPages = 200
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$base = [Uri]$BaseUrl
$root = (Resolve-Path ".").Path
$outRoot = Join-Path $root $OutDir

if (!(Test-Path $outRoot)) {
  New-Item -ItemType Directory -Path $outRoot | Out-Null
}

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$headers = @{
  "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 static-mirror/1.0"
}

function Convert-ToLocalPath([Uri]$uri, [bool]$isHtml) {
  $path = [Uri]::UnescapeDataString($uri.AbsolutePath)
  if ([string]::IsNullOrWhiteSpace($path) -or $path -eq "/") {
    return "index.html"
  }

  $path = $path.TrimStart("/")
  if ($isHtml -and !(Split-Path $path -Leaf).Contains(".")) {
    return (Join-Path $path "index.html")
  }

  if ($isHtml -and $path.EndsWith("/")) {
    return (Join-Path $path "index.html")
  }

  return $path
}

function Resolve-Url([string]$url, [Uri]$context) {
  if ([string]::IsNullOrWhiteSpace($url)) { return $null }
  $clean = $url.Trim().Trim("'`"")
  if ($clean.StartsWith("#") -or $clean.StartsWith("mailto:") -or $clean.StartsWith("tel:") -or $clean.StartsWith("javascript:") -or $clean.StartsWith("data:")) {
    return $null
  }
  if ($clean.StartsWith("//")) {
    $clean = $context.Scheme + ":" + $clean
  }
  try {
    return [Uri]::new($context, $clean)
  } catch {
    return $null
  }
}

function Is-SameSite([Uri]$uri) {
  return $uri -and $uri.Host.ToLowerInvariant() -eq $base.Host.ToLowerInvariant()
}

function Is-CrawlablePage([Uri]$uri) {
  if (!(Is-SameSite $uri)) { return $false }

  if ($uri.AbsoluteUri -match "(&#|%26|%23|&quot;|%5D)") { return $false }
  $path = $uri.AbsolutePath
  $decoded = [Uri]::UnescapeDataString($path)
  if ($decoded -match "(&#|`"|'\)|\]$|^/i$|^/t$|/i$|/t$)") { return $false }
  if ($path -match "(?i)(^/wp-json/|^/xmlrpc\.php|/feed/?$|^/comments/feed/?$)") { return $false }
  if ($path -match "(?i)\.(css|js|png|jpe?g|gif|webp|svg|ico|woff2?|ttf|eot|mp4|webm|pdf|json|xml)$") { return $false }

  return $true
}

function Add-StaticBackgroundImages([string]$html) {
  return [regex]::Replace(
    $html,
    'data-bg="([^"]+)"([^>]*?)style="([^"]*)"',
    {
      param($match)
      $bg = $match.Groups[1].Value
      $between = $match.Groups[2].Value
      $style = $match.Groups[3].Value

      if ($style -notmatch 'background-image\s*:') {
        $style = $style.TrimEnd()
        if ($style.Length -gt 0 -and !$style.EndsWith(";")) {
          $style += ";"
        }
        $style += "background-image:url('$bg');"
      }

      return "data-bg=`"$bg`"$between style=`"$style`""
    }
  )
}

function Optimize-StaticHtml([string]$html) {
  $staticCss = @'
<style id="static-mirror-fixes">
  .fusion-animated,
  [data-animationtype],
  [data-animation-duration],
  [data-animation-offset],
  [data-animation-delay],
  .fusion-column-wrapper,
  .fusion-layout-column,
  .fusion-fullwidth {
    visibility: visible !important;
    opacity: 1 !important;
    animation-delay: 0s !important;
    animation-duration: 0.01s !important;
    transition-delay: 0s !important;
  }
  .fusion-animated,
  [data-animationtype] {
    transform: none !important;
  }
  .owl-carousel,
  .owl-carousel .owl-stage,
  .owl-carousel .owl-item,
  .sa_hover_container {
    visibility: visible !important;
    opacity: 1 !important;
    transition-delay: 0s !important;
    animation-delay: 0s !important;
  }
  .owl-carousel .owl-stage {
    transition-duration: 0ms !important;
  }
</style>
'@

  if ($html -notmatch 'id="static-mirror-fixes"') {
    $html = $html -replace '</head>', "$staticCss</head>"
  }

  $html = $html -replace '<script>\(\(\)=>\{class RocketLazyLoadScripts[\s\S]*?RocketLazyLoadScripts\.run\(\)\}\)\(\);</script>', ''
  $html = $html -replace '<script type="rocketlazyloadscript"', '<script type="text/javascript"'
  $html = $html -replace ' data-rocket-type="text/javascript"', ''
  $html = $html -replace " data-rocket-type='text/javascript'", ''
  $html = $html -replace ' data-rocket-defer', ''
  $html = $html -replace ' data-rocket-src="([^"]+)"', ' src="$1"'
  $html = $html -replace '\s*data-animationType="[^"]*"', ''
  $html = $html -replace '\s*data-animationtype="[^"]*"', ''
  $html = $html -replace '\s*data-animationDuration="[^"]*"', ''
  $html = $html -replace '\s*data-animationduration="[^"]*"', ''
  $html = $html -replace '\s*data-animationOffset="[^"]*"', ''
  $html = $html -replace '\s*data-animationoffset="[^"]*"', ''
  $html = $html -replace '\s*data-animation-delay="[^"]*"', ''
  $html = $html -replace '\s*data-animation =[^ >]*', ''
  $html = [regex]::Replace($html, '<img([^>]*?)\s+src="data:image/svg\+xml[^"]*"([^>]*?)\s+data-lazy-src="([^"]+)"([^>]*)>', '<img$1 src="$3"$2$4>')
  $html = $html -replace '\s+data-lazy-srcset="([^"]+)"', ' srcset="$1"'
  $html = $html -replace '\s+data-lazy-sizes="([^"]+)"', ' sizes="$1"'
  $html = $html -replace 'style=''visibility:hidden;''', 'style=''visibility:visible;'''
  $html = $html -replace 'smartSpeed : 400', 'smartSpeed : 0'
  $html = $html -replace 'fluidSpeed : 400', 'fluidSpeed : 0'
  $html = $html -replace 'autoplaySpeed : 400', 'autoplaySpeed : 0'
  $html = $html -replace 'navSpeed : 400', 'navSpeed : 0'
  $html = $html -replace 'dotsSpeed : 400', 'dotsSpeed : 0'

  return $html
}

function Get-UrlsFromText([string]$text, [Uri]$context) {
  $urls = New-Object System.Collections.Generic.List[Uri]
  $patterns = @(
    '(?i)\b(?:href|src|data-src|data-lazy-src|data-lazyload|data-thumb|data-rocket-src)=["'']([^"'']+)["'']',
    '(?i)\b(?:srcset|data-srcset|data-lazy-srcset)=["'']([^"'']+)["'']',
    '(?i)url\(([^)]+)\)'
  )

  foreach ($pattern in $patterns) {
    foreach ($match in [regex]::Matches($text, $pattern)) {
      $raw = $match.Groups[1].Value
      if ($pattern -like "*srcset*") {
        foreach ($part in $raw.Split(",")) {
          $candidate = $part.Trim().Split(" ")[0]
          $resolved = Resolve-Url $candidate $context
          if ($resolved) { $urls.Add($resolved) }
        }
      } else {
        $resolved = Resolve-Url $raw $context
        if ($resolved) { $urls.Add($resolved) }
      }
    }
  }

  return $urls
}

function Save-Response([Uri]$uri, [string]$targetPath) {
  $dir = Split-Path $targetPath -Parent
  if (!(Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
  }

  Invoke-WebRequest -Uri $uri.AbsoluteUri -Headers $headers -WebSession $session -UseBasicParsing -OutFile $targetPath
}

$queuedPages = New-Object System.Collections.Generic.Queue[Uri]
$queuedAssets = New-Object System.Collections.Generic.Queue[Uri]
$seenPages = New-Object System.Collections.Generic.HashSet[string]
$seenAssets = New-Object System.Collections.Generic.HashSet[string]

$queuedPages.Enqueue($base)

while ($queuedPages.Count -gt 0 -and $seenPages.Count -lt $MaxPages) {
  $uri = $queuedPages.Dequeue()
  $key = $uri.GetLeftPart([UriPartial]::Path).TrimEnd("/")
  if (!$seenPages.Add($key)) { continue }

  $localRel = Convert-ToLocalPath $uri $true
  $target = Join-Path $outRoot $localRel
  Write-Host "PAGE  $($uri.AbsoluteUri)"

  try {
    Save-Response $uri $target
  } catch {
    Write-Warning "Page skipped: $($uri.AbsoluteUri) - $($_.Exception.Message)"
    continue
  }

  $html = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($target))
  $html = $html -replace [regex]::Escape($base.Scheme + "://" + $base.Host), ""
  $html = $html -replace [regex]::Escape("http://" + $base.Host), ""
  $html = $html -replace [regex]::Escape("//" + $base.Host), ""
  $html = Add-StaticBackgroundImages $html
  $html = Optimize-StaticHtml $html
  [System.IO.File]::WriteAllText($target, $html, [System.Text.UTF8Encoding]::new($false))

  foreach ($found in Get-UrlsFromText $html $uri) {
    if (!(Is-SameSite $found)) { continue }
    $path = $found.AbsolutePath
    $looksLikeAsset = $path -match '\.(css|js|png|jpe?g|gif|webp|svg|ico|woff2?|ttf|eot|mp4|webm|pdf|json|xml)(\?.*)?$'
    if ($looksLikeAsset) {
      $assetKey = $found.GetLeftPart([UriPartial]::Path)
      if ($seenAssets.Add($assetKey)) { $queuedAssets.Enqueue($found) }
    } else {
      if (!(Is-CrawlablePage $found)) { continue }
      $pageKey = $found.GetLeftPart([UriPartial]::Path).TrimEnd("/")
      if (!$seenPages.Contains($pageKey) -and $seenPages.Count + $queuedPages.Count -lt $MaxPages) {
        $queuedPages.Enqueue($found)
      }
    }
  }
}

while ($queuedAssets.Count -gt 0) {
  $uri = $queuedAssets.Dequeue()
  $localRel = Convert-ToLocalPath $uri $false
  $target = Join-Path $outRoot $localRel
  if (Test-Path $target) { continue }

  Write-Host "ASSET $($uri.AbsoluteUri)"
  try {
    Save-Response $uri $target
  } catch {
    Write-Warning "Asset skipped: $($uri.AbsoluteUri) - $($_.Exception.Message)"
  }
}

Write-Host "Done. Pages: $($seenPages.Count), assets: $($seenAssets.Count), output: $outRoot"
