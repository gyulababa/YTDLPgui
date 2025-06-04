Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Gyökér elérési út (egy szinttel feljebb mint scripts)
$rootPath = Split-Path -Parent $PSScriptRoot
$ytDlpPath = Join-Path $rootPath "yt-dlp.exe"
$ffmpegPath = Join-Path $rootPath "ffmpeg\bin\ffmpeg.exe"
$outputPath = Join-Path (Split-Path $rootPath -Parent) "output"

# Ellenőrzés
if (-not (Test-Path $ytDlpPath)) {
    [System.Windows.Forms.MessageBox]::Show("❌ A yt-dlp.exe hiányzik a tools mappából.`nEllenőrizd, hogy a fájl a megfelelő helyen van.")
    exit
}

if (-not (Test-Path $ffmpegPath)) {
    [System.Windows.Forms.MessageBox]::Show("❌ Az ffmpeg.exe hiányzik a tools\\ffmpeg\\bin mappából.")
    exit
}



# GUI form
$form = New-Object Windows.Forms.Form
$form.Text = "Apunak MP3 Letöltő"
$form.Size = New-Object Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"

# URL input
$labelUrls = New-Object Windows.Forms.Label
$labelUrls.Text = "YouTube linkek (egy sor = egy link):"
$labelUrls.AutoSize = $true
$labelUrls.Location = New-Object Drawing.Point(10,10)

$textUrls = New-Object Windows.Forms.TextBox
$textUrls.Multiline = $true
$textUrls.ScrollBars = "Vertical"
$textUrls.Size = New-Object Drawing.Size(560, 150)
$textUrls.Location = New-Object Drawing.Point(10,30)

# Format dropdown
$labelFormat = New-Object Windows.Forms.Label
$labelFormat.Text = "Formátum:"
$labelFormat.AutoSize = $true
$labelFormat.Location = New-Object Drawing.Point(10,190)

$comboFormat = New-Object Windows.Forms.ComboBox
$comboFormat.Location = New-Object Drawing.Point(80,185)
$comboFormat.Size = New-Object Drawing.Size(200,30)
$comboFormat.Items.AddRange(@(
    "MP3 (audio only)",
    "MP4 (best quality video)",
    "Best audio (original format)"
))
$comboFormat.SelectedIndex = 0

# Output label
$labelOutput = New-Object Windows.Forms.Label
$labelOutput.Text = "Letöltési mappa: $outputPath"
$labelOutput.AutoSize = $true
$labelOutput.Location = New-Object Drawing.Point(10,220)

# Download button
$btnDownload = New-Object Windows.Forms.Button
$btnDownload.Text = "Letöltés"
$btnDownload.Location = New-Object Drawing.Point(10,250)
$btnDownload.Size = New-Object Drawing.Size(100,30)

# Log box
$textLog = New-Object Windows.Forms.TextBox
$textLog.Multiline = $true
$textLog.ReadOnly = $true
$textLog.ScrollBars = "Vertical"
$textLog.Size = New-Object Drawing.Size(560,120)
$textLog.Location = New-Object Drawing.Point(10,290)

$form.Controls.AddRange(@(
    $labelUrls, $textUrls,
    $labelFormat, $comboFormat,
    $labelOutput, $btnDownload,
    $textLog
))

# Event: download click
$btnDownload.Add_Click({
    $urls = $textUrls.Text -split "`r?`n" | Where-Object { $_.Trim() -ne "" }
    if ($urls.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("❗ Kérlek adj meg legalább egy YouTube linket.")
        return
    }

    $args = switch ($comboFormat.SelectedIndex) {
        0 { "-x --audio-format mp3 --audio-quality 0" }
        1 { "-f bestvideo+bestaudio --merge-output-format mp4" }
        2 { "-f bestaudio" }
    }

    if (-not (Test-Path $outputPath)) {
        New-Item -ItemType Directory -Path $outputPath | Out-Null
    }

    foreach ($url in $urls) {
        $logLine = "⬇️ Letöltés indítása: $url"
        $textLog.AppendText("$logLine`r`n")

        $tmpOut = Join-Path $PSScriptRoot "yt-out.log"
        $tmpErr = Join-Path $PSScriptRoot "yt-err.log"

        $cmd = "`"$ytDlpPath`" $args -o `"$outputPath\%(title)s [%(uploader)s].%(ext)s`" `"$url`""
        cmd /c "$cmd > `"$tmpOut`" 2> `"$tmpErr`""

        if (Test-Path $tmpOut) { $textLog.AppendText((Get-Content $tmpOut -Raw) + "`r`n") }
        if (Test-Path $tmpErr) { $textLog.AppendText((Get-Content $tmpErr -Raw) + "`r`n") }

        Remove-Item $tmpOut, $tmpErr -ErrorAction SilentlyContinue
    }



    $textLog.AppendText("✅ Minden letöltés kész.`r`n")
})

$form.Topmost = $true
$form.ShowDialog()
