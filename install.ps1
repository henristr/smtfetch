$ErrorActionPreference = "Stop"

$Repo = "henristr/smtfetch"
$Binary = "smtfetch.exe"
$InstallDir = "$env:LOCALAPPDATA\Programs\smtfetch"

switch ($env:PROCESSOR_ARCHITECTURE) {
    "AMD64" {
        $GoArch = "amd64"
    }

    "ARM64" {
        $GoArch = "arm64"
    }

    default {
        Write-Error "Unsupported architecture: $env:PROCESSOR_ARCHITECTURE"
        exit 1
    }
}

$Release = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest"
$Version = $Release.tag_name

$Url = "https://github.com/$Repo/releases/download/$Version/smtfetch_${Version}_windows_${GoArch}.zip"

$TempDir = Join-Path $env:TEMP "smtfetch-install"
$ZipFile = Join-Path $TempDir "smtfetch.zip"

Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $TempDir | Out-Null

Write-Host "Downloading smtfetch $Version..."

Invoke-WebRequest `
    -Uri $Url `
    -OutFile $ZipFile

Expand-Archive `
    -Path $ZipFile `
    -DestinationPath $TempDir `
    -Force

New-Item `
    -ItemType Directory `
    -Path $InstallDir `
    -Force | Out-Null

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
Write-Host "smtfetch $Version successfully installed!"
Write-Host ""

& (Join-Path $InstallDir $Binary)