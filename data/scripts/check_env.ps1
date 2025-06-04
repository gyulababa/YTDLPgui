# Ensure folders exist
$folders = @(
    "$PSScriptRoot\..\..\output",
    "$PSScriptRoot\..\..\tools\ffmpeg",
    "$PSScriptRoot\..\..\tools\scripts"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
        Write-Host "Created missing folder: $folder"
    }
}

# Check if ffmpeg is in PATH
$ffmpegInPath = $env:Path -split ';' | Where-Object { $_ -match "ffmpeg" }
if (-not $ffmpegInPath) {
    Write-Warning "⚠ FFmpeg folder is not in PATH. Add tools\ffmpeg to system PATH."
}
