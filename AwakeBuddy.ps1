Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Native Interop for Taskbar Icon
$code = @"
    using System;
    using System.Runtime.InteropServices;
    public class Win32 {
        [DllImport("shell32.dll", SetLastError=true)]
        public static extern void SetCurrentProcessExplicitAppUserModelID([MarshalAs(UnmanagedType.LPWStr)] string AppID);
    }
"@
Add-Type -TypeDefinition $code -Language CSharp
[Win32]::SetCurrentProcessExplicitAppUserModelID("Montesito.AwakeBuddy")

# Path Resolution
$rootPath = $PSScriptRoot
$assetsPath = Join-Path $rootPath "Assets"
$srcLogicPath = Join-Path $rootPath "Src\Logic"
$srcUIPath = Join-Path $rootPath "Src\UI"

$iconPath = Join-Path $assetsPath "app.ico"
$iconPngPath = Join-Path $assetsPath "app.png"
$jobScriptPath = Join-Path $srcLogicPath "JobScript.ps1"
$stylesPath = Join-Path $srcUIPath "Styles.xaml"
$mainWindowPath = Join-Path $srcUIPath "MainWindow.xaml"

# Dependency Validation
if (!(Test-Path $stylesPath) -or !(Test-Path $mainWindowPath) -or !(Test-Path $jobScriptPath)) {
    Write-Error "Critical files missing in Src/ directory."
    exit
}

# XAML Component Initialization
try {
    # Load style resources
    $stylesXml = [xml](Get-Content $stylesPath)
    $stylesReader = (New-Object System.Xml.XmlNodeReader $stylesXml)
    $stylesDic = [Windows.Markup.XamlReader]::Load($stylesReader)

    # Load main window markup
    $windowXml = [xml](Get-Content $mainWindowPath)
    $windowReader = (New-Object System.Xml.XmlNodeReader $windowXml)
    $window = [Windows.Markup.XamlReader]::Load($windowReader)

    # Merge styles
    $window.Resources.MergedDictionaries.Add($stylesDic)

    # Set window icon
    $iconToLoad = $null
    if (Test-Path $iconPngPath) { $iconToLoad = $iconPngPath }
    elseif (Test-Path $iconPath) { $iconToLoad = $iconPath }

    if ($iconToLoad) {
        try {
            $iconUri = New-Object Uri -ArgumentList $iconToLoad, "Absolute"
            $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
            $bitmap.BeginInit()
            $bitmap.UriSource = $iconUri
            $bitmap.EndInit()
            $window.Icon = $bitmap
        }
        catch {
            Write-Warning "Failed to set window icon: $_"
        }
    }

}
catch {
    Write-Host "Error loading XAML components: $_"
    exit
}

# UI Element Binding
$headerGrid = $window.FindName("HeaderGrid")
$closeBtn = $window.FindName("CloseBtn")
$toggleBtn = $window.FindName("ToggleBtn")
$statusText = $window.FindName("StatusText")
$consoleLog = $window.FindName("ConsoleLog")
$logScroller = $window.FindName("LogScroller")
# Asset Configuration


# Logging Utilities
function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $consoleLog.Text += "`n[$timestamp] $message"
    if ($logScroller) { $logScroller.ScrollToBottom() }
}

# Job State Management
$job = $null

# Cleanup Logic
function Stop-ActivityJob {
    if ($job) {
        try {
            Stop-Job $job -ErrorAction SilentlyContinue
            Remove-Job $job -ErrorAction SilentlyContinue
        }
        catch {}
        $Script:job = $null
    }
}

# Event Declarations

# Window drag support
$headerGrid.Add_MouseLeftButtonDown({
        $window.DragMove()
    })

# Application shutdown
$closeBtn.Add_Click({
        Stop-ActivityJob
        $window.Close()
    })

# Service toggle logic
$toggleBtn.Add_Click({
        if ($toggleBtn.Tag -eq "Off") {
            # Enable service
            $toggleBtn.Tag = "On"
            $statusText.Text = "Status: Active"
            $statusText.Foreground = [System.Windows.Media.Brushes]::Cyan
        
            Write-Log "Starting AwakeBuddy service..."
        
            # Initialize background job
            if ($job) { Remove-Job $job -Force -ErrorAction SilentlyContinue }
        
            # Execute logic script
            $job = Start-Job -FilePath $jobScriptPath -ArgumentList 60
            $Script:job = $job 
        
        }
        else {
            # Disable service
            $toggleBtn.Tag = "Off"
            $statusText.Text = "Status: Inactive"
            $statusText.Foreground = [System.Windows.Media.Brushes]::Gray
        
            Write-Log "Stopping service..."
        
            if ($job) { 
                Stop-Job $job
                Remove-Job $job
                $Script:job = $null
            }
        
            Write-Log "Service stopped."
        }
    })

# Runspace monitoring timer
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(1)
$timer.Add_Tick({
        if ($job -and $job.State -eq "Running") {
            $newLogs = Receive-Job -Job $job
            if ($newLogs) {
                foreach ($line in $newLogs) {
                    Write-Log $line
                }
            }
        }
    })
$timer.Start()

# Native Interop (Duplicate fix)
$code = @"
    using System;
    using System.Runtime.InteropServices;
    public class Win32 {
        [DllImport("shell32.dll", SetLastError=true)]
        public static extern void SetCurrentProcessExplicitAppUserModelID([MarshalAs(UnmanagedType.LPWStr)] string AppID);
    }
"@
Add-Type -TypeDefinition $code -Language CSharp
[Win32]::SetCurrentProcessExplicitAppUserModelID("Montesito.KeepAwake") # Unique ID forces taskbar to use the app icon

# Resource cleanup
$window.Add_Closed({
        $timer.Stop()
        Stop-ActivityJob
    })

# Application entry
$window.ShowDialog() | Out-Null
