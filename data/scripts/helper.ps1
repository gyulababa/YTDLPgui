chcp 65001

Write-Host "📁 Mappastruktúra ellenőrzése..."

$root = $PSScriptRoot
$output = Join-Path $root "..\..\output"
$tools = Join-Path $root ".."
$ffmpeg = Join-Path $tools "ffmpeg\bin\ffmpeg.exe"
$yt = Join-Path $tools "yt-dlp.exe"

if (-not (Test-Path $output)) {
    New-Item -ItemType Directory -Path $output | Out-Null
    Write-Host "✅ output mappa létrehozva."
} else {
    Write-Host "✅ output mappa már létezik."
}

if (-not (Test-Path $yt)) {
    Write-Host "❌ Figyelem: yt-dlp.exe hiányzik a tools mappából!"
} else {
    Write-Host "✅ yt-dlp.exe megtalálva."
}

if (-not (Test-Path $ffmpeg)) {
    Write-Host "❌ Figyelem: ffmpeg.exe hiányzik a tools\\ffmpeg\\bin mappából!"
} else {
    Write-Host "✅ ffmpeg.exe megtalálva."
}

# PATH-hoz hozzáadva van-e az ffmpeg
$envPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($envPath -like "*ffmpeg*") {
    Write-Host "ℹ️ ffmpeg elérési útvonal már szerepel a PATH-ban."
} else {
    Write-Host "⚠️ ffmpeg elérési útvonal nem szerepel a PATH-ban. Hozzáadás javasolt:"
    Write-Host "`n[Environment]::SetEnvironmentVariable(`"Path`", `"$envPath;<teljes elérési út ffmpeg/bin>`", `"User`")`n"
}
