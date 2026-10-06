$ErrorActionPreference = "Stop"

$Repo = "henristr/smtfetch"
$Binary = "smtfetch.exe"
$InstallDir = "$env:LOCALAPPDATA\Programs\smtfetch"

switch ($env:PROCESSOR_ARCHITECTURE) {
    "AMD64" {
        $GoArch = "x86_64"
    }

    "ARM64" {
        $GoArch = "arm64"
    }

    default {
        Write-Error "Unsupported architecture: $env:PROCESSOR_ARCHITECTURE"
        exit 1
    }
}

$Url = "https://github.com/$Repo/releases/latest/download/${Binary}_Windows_${GoArch}.zip"

$TempDir = Join-Path $env:TEMP "smtfetch-install"
$ZipFile = Join-Path $TempDir "smtfetch.zip"

Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $TempDir | Out-Null

Write-Host "Downloading latest smtfetch..."

Invoke-WebRequest -Uri $Url -OutFile $ZipFile

Expand-Archive -Path $ZipFile -DestinationPath $TempDir -Force

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

Copy-Item `
    (Join-Path $TempDir $Binary) `
    (Join-Path $InstallDir $Binary) `
    -Force

$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$UserPath;$InstallDir",
        "User"
    )

    $env:Path += ";$InstallDir"
}

Write-Host ""
Write-Host "smtfetch successfully installed!"
Write-Host ""

& (Join-Path $InstallDir $Binary)