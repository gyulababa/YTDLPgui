chcp 65001
Write-Host "🔄 ffmpeg frissítése..."

$tempZip = "$env:TEMP\ffmpeg.zip"
$targetDir = Join-Path $PSScriptRoot "..\ffmpeg"
$dlUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"

Invoke-WebRequest -Uri $dlUrl -OutFile $tempZip -UseBasicParsing
Write-Host "📦 ffmpeg ZIP letöltve. Kibontás..."

Expand-Archive -Path $tempZip -DestinationPath $env:TEMP\ffmpeg_temp -Force

# Al-mappát megkeressük, ami tartalmazza a bin mappát
$ffmpegFolder = Get-ChildItem "$env:TEMP\ffmpeg_temp" -Directory | Select-Object -First 1

# Régi törlése, új másolása
Remove-Item -Recurse -Force $targetDir -ErrorAction SilentlyContinue
Move-Item -Path $ffmpegFolder.FullName -Destination $targetDir

Write-Host "✅ ffmpeg sikeresen frissítve: $targetDir"
Remove-Item $tempZip -Force
