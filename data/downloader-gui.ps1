Add-Type -AssemblyName PresentationFramework

# Create the GUI
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="yt-dlp GUI" Height="300" Width="500" ResizeMode="CanResizeWithGrip">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>

        <Button Name="DownloadButton" Content="Download Video" Width="150" Height="40" HorizontalAlignment="Left" Margin="0,0,0,10"/>
        <TextBox Name="LogBox" Grid.Row="1" Margin="0,10,0,0" AcceptsReturn="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$DownloadButton = $window.FindName("DownloadButton")
$LogBox         = $window.FindName("LogBox")

# Logging helper
function Log($text) {
    $LogBox.AppendText("[$(Get-Date -Format HH:mm:ss)] $text`n")
    $LogBox.ScrollToEnd()
}

# Download video
$DownloadButton.Add_Click({
    $videoUrl = "https://www.youtube.com/watch?v=6-tQqhBS4I4"  # Example video
    $ytDlpPath = Join-Path -Path $PSScriptRoot -ChildPath "yt-dlp.exe"

    if (-not (Test-Path $ytDlpPath)) {
        Log "yt-dlp.exe not found."
        return
    }

    Log "Starting download..."
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $ytDlpPath
    $psi.Arguments = $videoUrl
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    $process.Start() | Out-Null

    while (-not $process.HasExited) {
        $output = $process.StandardOutput.ReadLine()
        if ($output) { Log $output }
    }

    # Also show error output (if any)
    while (-not $process.StandardError.EndOfStream) {
        $error = $process.StandardError.ReadLine()
        if ($error) { Log "ERROR: $error" }
    }

    Log "Download complete (exit code $($process.ExitCode))."
})

# Show the window
$window.ShowDialog() | Out-Null
