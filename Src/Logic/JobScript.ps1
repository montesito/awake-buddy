<#
.SYNOPSIS
    Background Activity Simulator
.DESCRIPTION
    Runs in a separate thread/job to simulate user input, preventing system sleep.
#>
param($interval)
Add-Type -AssemblyName System.Windows.Forms

while ($true) {
    if ($host.UI.RawUI.KeyAvailable) { break }
    
    # Simulate user input
    [System.Windows.Forms.SendKeys]::SendWait("{SCROLLLOCK}")
    Start-Sleep -Milliseconds 100
    [System.Windows.Forms.SendKeys]::SendWait("{SCROLLLOCK}")
    
    # Logging suppressed for performance
    Start-Sleep -Seconds $interval
}
