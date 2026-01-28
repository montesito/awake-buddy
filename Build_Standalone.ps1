# Build_Standalone.ps1
# Generates a single-file executable for AwakeBuddy
# Usage: Run this script to create Bin/AwakeBuddy_Standalone.exe

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# --- Configuration ---
$ProjectRoot = $ScriptDir
$BinDir = Join-Path $ProjectRoot "Bin"
$OutputExe = Join-Path $BinDir "AwakeBuddy.exe"
$IconPath = Join-Path $ProjectRoot "Assets\app.ico"
$WrapperSource = Join-Path $BinDir "Wrapper.cs"

# Ensure Bin directory exists
if (!(Test-Path $BinDir)) { New-Item -ItemType Directory -Path $BinDir | Out-Null }

Write-Host "--- AwakeBuddy Standalone Builder ---" -ForegroundColor Cyan

# --- 1. Locate C# Compiler (csc.exe) ---
$cscPath = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (!(Test-Path $cscPath)) {
    $cscPath = "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\csc.exe" # Fallback to 32-bit
}

if (!(Test-Path $cscPath)) {
    Write-Error "C# Compiler (csc.exe) not found. Ensure .NET Framework is installed."
    exit
}
Write-Host "Using Compiler: $cscPath" -ForegroundColor Gray

# --- 2. Identify Resources to Embed ---
$script:embedArgs = @()

# Helper to add resource
function Add-Resource {
    param($FilePath, $RelativePath)
    $resName = $RelativePath -replace "\\", "." # Valid C# resource name
    # Quote only if path has spaces (safest for array passing)
    # But /resource:path,name syntax is one argument.
    $script:embedArgs += "/resource:$FilePath,$resName"
    Write-Host "Embedding: $RelativePath -> $resName" -ForegroundColor DarkGray
    return $resName
}

# Add AwakeBuddy.ps1
$resources += Add-Resource -FilePath (Join-Path $ProjectRoot "AwakeBuddy.ps1") -RelativePath "AwakeBuddy.ps1"

# Add Assets/*
Get-ChildItem -Path (Join-Path $ProjectRoot "Assets") -File | ForEach-Object {
    $relPath = "Assets\$($_.Name)"
    $resources += Add-Resource -FilePath $_.FullName -RelativePath $relPath
}

# Add Src/**/*
Get-ChildItem -Path (Join-Path $ProjectRoot "Src") -Recurse -File | ForEach-Object {
    $relPath = ($_.FullName).Substring($ProjectRoot.Length + 1)
    $resources += Add-Resource -FilePath $_.FullName -RelativePath $relPath
}

# --- 3. Generate C# Wrapper Source ---
$csharpCode = @"
using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;

namespace AwakeBuddyStandalone
{
    class Program
    {
        [STAThread]
        static void Main()
        {
            try
            {
                // 1. Create unique temp directory
                string tempPath = Path.Combine(Path.GetTempPath(), "AwakeBuddy_" + Guid.NewGuid().ToString().Substring(0, 8));
                Directory.CreateDirectory(tempPath);

                // 2. Extract Resources
                Assembly assembly = Assembly.GetExecutingAssembly();
                foreach (string resourceName in assembly.GetManifestResourceNames())
                {
                    // Convert resource name back to file path (e.g., Src.UI.Styles.xaml -> Src\UI\Styles.xaml)
                    // NOTE: This assumes simple mapping. We need to be careful with dots in filenames vs dir separators.
                    // Since our project structure is simple, we map specifically known folders.
                    
                    string fileName = resourceName.Replace("AwakeBuddyStandalone.", ""); // remove namespace prefix if added by default
                    
                    // Manual mapping for reliability based on known structure
                    string relativePath = "";
                    
                    if (resourceName.EndsWith(".ps1")) relativePath = resourceName; 
                    else if (resourceName.Contains(".Assets.")) relativePath = resourceName.Replace(".", "\\");
                    else if (resourceName.Contains(".Src.")) relativePath = resourceName.Replace(".", "\\");

                    // Heuristic fallback: Reconstruct path (Assumes files don't have extra dots in name except extension)
                    // We embedded with logic names like 'Assets.app.png'.
                    
                    // Better approach: We used 'Assets.app.png' as resource name.
                    // So we replace the first occurrence of known folders to fix path.
                    
                    string[] parts = resourceName.Split('.');
                    string extension = "." + parts[parts.Length - 1];
                    string name = parts[parts.Length - 2];
                    
                    // Simple reconstruction isn't robust. Let's rely on the exact names we passed.
                    // We passed 'Assets.app.png'.
                    
                    string outPath = Path.Combine(tempPath, resourceName.Replace(".", "\\"));
                    
                    // Fix the extension (Windows expects last dot to be extension)
                    // The replace above turned 'Assets.app.png' into 'Assets\app\png'.
                    // We need to restore the last backslash to a dot.
                    int lastSlash = outPath.LastIndexOf('\\');
                    if (lastSlash > 0)
                    {
                        char[] outPathChars = outPath.ToCharArray();
                        outPathChars[lastSlash] = '.'; // Restore extension dot
                        outPath = new String(outPathChars);
                    }
                    
                    // Ensure directory exists
                    string dir = Path.GetDirectoryName(outPath);
                    if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

                    using (Stream stream = assembly.GetManifestResourceStream(resourceName))
                    using (FileStream fileStream = new FileStream(outPath, FileMode.Create))
                    {
                        stream.CopyTo(fileStream);
                    }
                }

                // 3. Launch PowerShell Script
                string scriptPath = Path.Combine(tempPath, "AwakeBuddy.ps1");
                
                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = "powershell.exe";
                psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"" + scriptPath + "\"";
                psi.WindowStyle = ProcessWindowStyle.Hidden;
                psi.CreateNoWindow = true;
                psi.UseShellExecute = false;

                Process p = Process.Start(psi);
                
                // Optional: Wait for exit implies we stay in memory. 
                // AwakeBuddy runs indefinitely, so we can exit the wrapper and leave PS running.
                // Or we can wait. If we exit, we can't delete temp files easily.
                // For a lightweight launcher, we exit and leave temp cleanup for OS or next run.
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error launching AwakeBuddy:\n" + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}
"@

[System.IO.File]::WriteAllText($WrapperSource, $csharpCode)

# --- 4. Compile ---
Write-Host "Compiling executable..." -ForegroundColor Yellow

$compileArgs = @(
    "/target:winexe",
    "/out:$OutputExe",
    "/win32icon:$IconPath"
)
$compileArgs += $script:embedArgs
$compileArgs += "$WrapperSource"

Write-Host "Arguments: $($compileArgs -join ' ')" -ForegroundColor DarkGray

# Run csc.exe using Call Operator (&)
& $cscPath $compileArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! Executable created at:" -ForegroundColor Green
    Write-Host $OutputExe -ForegroundColor White
    
    # Check size
    $size = (Get-Item $OutputExe).Length
    Write-Host "Size: $size bytes" -ForegroundColor Gray
    if ($size -lt 20000) {
        Write-Warning "File size ($size) seems too small. Embedding might have failed."
    }

    # Cleanup wrapper source
    Remove-Item $WrapperSource -Force
}
else {
    Write-Error "Compilation Failed. Exit Code: $LASTEXITCODE"
}
