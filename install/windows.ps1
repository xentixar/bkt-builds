# Install bkt (Windows) — for PowerShell
# Usage: irm https://xentixar.github.io/bkt-builds/install/windows.ps1 | iex
$ErrorActionPreference = "Stop"

$BaseUrl = if ($env:BKT_BUILDS_BASE_URL) { $env:BKT_BUILDS_BASE_URL } else { "https://xentixar.github.io/bkt-builds" }
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

$urls = @(
    "$BaseUrl/dist/${BinName}-windows-${arch}.exe",
    "$BaseUrl/dist/${BinName}.exe"
)

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
$dest = Join-Path $InstallDir "$BinName.exe"
$tmp = Join-Path $env:TEMP ("bkt-install-" + [Guid]::NewGuid().ToString("n") + ".exe")

$ok = $false
foreach ($u in $urls) {
    try {
        Invoke-WebRequest -Uri $u -OutFile $tmp -UseBasicParsing
        $ok = $true
        Write-Host "Downloaded: $u"
        break
    } catch {
        continue
    }
}

if (-not $ok) {
    Write-Error "No build found for windows/$arch. Publish to $BaseUrl/dist/ (e.g. ${BinName}-windows-${arch}.exe)"
}

Move-Item -Force $tmp $dest
Write-Host ""
Write-Host "Installed $BinName -> $dest"
Write-Host "Add to PATH if needed: $InstallDir"
Write-Host ""
Write-Host "Next: $BinName version"
Write-Host "      $BinName auth login --app-password"
Write-Host ""
