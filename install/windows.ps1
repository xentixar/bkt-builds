# Install bkt (Windows) — for PowerShell
# Usage: irm https://xentixar.github.io/bkt-builds/install/windows.ps1 | iex
$ErrorActionPreference = "Stop"

$ReleaseRepo = if ($env:BKT_RELEASE_REPO) { $env:BKT_RELEASE_REPO } else { "xentixar/bkt-builds" }
$ApiBase = if ($env:GH_API_BASE) { $env:GH_API_BASE } else { "https://api.github.com" }
$InstallDir = if ($env:BKT_INSTALL_DIR) { $env:BKT_INSTALL_DIR } else { "$env:USERPROFILE\.local\bin" }
$BinName = if ($env:BKT_BIN_NAME) { $env:BKT_BIN_NAME } else { "bkt" }

if (-not ($env:OS -like "*Windows*")) {
    Write-Error "This installer is for Windows."
}

$arch = switch ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture) {
    X64 { "amd64" }
    Arm64 { "arm64" }
    default { throw "Unsupported architecture: $_" }
}

$assetName = "${BinName}-windows-${arch}.exe"
$releaseApi = "$ApiBase/repos/$ReleaseRepo/releases/latest"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
$dest = Join-Path $InstallDir "$BinName.exe"
$tmp = Join-Path $env:TEMP ("bkt-install-" + [Guid]::NewGuid().ToString("n") + ".exe")

$ok = $false
try {
    $release = Invoke-RestMethod -Uri $releaseApi -UseBasicParsing
    $asset = $release.assets | Where-Object { $_.name -eq $assetName } | Select-Object -First 1
    if ($null -ne $asset -and $asset.browser_download_url) {
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tmp -UseBasicParsing
        $ok = $true
        Write-Host "Downloaded: $($asset.browser_download_url)"
    }
} catch {
    $ok = $false
}

if (-not $ok) {
    Write-Error "No release asset found for $assetName in $ReleaseRepo. Check: https://github.com/$ReleaseRepo/releases"
}

Move-Item -Force $tmp $dest
Write-Host ""
Write-Host "Installed $BinName -> $dest"
Write-Host "Add to PATH if needed: $InstallDir"
Write-Host ""
Write-Host "Next: $BinName version"
Write-Host "      $BinName auth login --app-password"
Write-Host ""
