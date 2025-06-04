chcp 65001
Write-Host "🔄 yt-dlp.exe frissítése..."

$ytPath = Join-Path $PSScriptRoot "..\yt-dlp.exe"
$dlUrl = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"

Invoke-WebRequest -Uri $dlUrl -OutFile $ytPath -UseBasicParsing
Write-Host "✅ yt-dlp.exe sikeresen frissítve."
