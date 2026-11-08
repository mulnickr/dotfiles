# Link config folders from this repo into place on Windows.
#
#   powershell -ExecutionPolicy Bypass -File install.ps1
#
# Uses directory junctions (no admin or Developer Mode needed).
# Anything already at a target is renamed to <target>.bak-<timestamp>; nothing is deleted.
# Safe to re-run: targets that already point at this repo are left alone.
# Apps that aren't installed (no matching command on PATH) are skipped.

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

$links = @(
  @{ Source = 'nvim';    Command = 'nvim';    Target = Join-Path $env:LOCALAPPDATA 'nvim' },
  @{ Source = 'wezterm'; Command = 'wezterm'; Target = Join-Path $HOME '.config\wezterm' }
)

# Old single-file configs that the links above replace
$retire = @(
  @{ Source = 'wezterm'; Command = 'wezterm'; Path = Join-Path $HOME '.wezterm.lua' }
)

function Test-Installed([string]$cmd) {
  return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Backup-Path([string]$path) {
  $bak = "$path.bak-$stamp"
  # Move-Item on a junction renames the link itself, not its target
  Move-Item -LiteralPath $path -Destination $bak
  Write-Host "  backed up $path -> $bak"
  return $bak
}

foreach ($l in $links) {
  $src = Join-Path $repo $l.Source
  $dst = $l.Target
  if (-not (Test-Path -LiteralPath $src)) { continue }
  if (-not (Test-Installed $l.Command)) {
    Write-Host "skip    $dst ($($l.Command) not installed)"
    continue
  }

  $item = Get-Item -LiteralPath $dst -Force -ErrorAction SilentlyContinue
  if ($item -and $item.LinkType -eq 'Junction' -and ([string]$item.Target).TrimEnd('\') -ieq $src.TrimEnd('\')) {
    Write-Host "ok      $dst"
    continue
  }
  $bak = $null
  if ($item) { $bak = Backup-Path $dst }

  try {
    New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
    New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
  } catch {
    # Put the original back rather than leaving nothing in place
    if ($bak) { Move-Item -LiteralPath $bak -Destination $dst; Write-Host "  restored $dst" }
    throw
  }
  Write-Host "linked  $dst -> $src"
}

foreach ($r in $retire) {
  if ((Test-Path -LiteralPath (Join-Path $repo $r.Source)) -and (Test-Installed $r.Command) -and (Test-Path -LiteralPath $r.Path)) {
    Backup-Path $r.Path | Out-Null
    Write-Host "  restart open WezTerm windows: they still watch the old file and will show a config error"
  }
}
