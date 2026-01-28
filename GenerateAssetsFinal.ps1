Add-Type -AssemblyName System.Drawing

$size = 64
$bmp = New-Object System.Drawing.Bitmap $size, $size
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::Transparent)

# Color definitions
$cyan = [System.Drawing.ColorTranslator]::FromHtml("#00FFFF")
$blue = [System.Drawing.ColorTranslator]::FromHtml("#0077BE")
$brush1 = New-Object System.Drawing.Pen $cyan, 4
$brush2 = New-Object System.Drawing.SolidBrush $blue

# Draw geometry
# Outer shape
$g.DrawPolygon($brush1, @(
        New-Object System.Drawing.Point 32, 4
        New-Object System.Drawing.Point 60, 32
        New-Object System.Drawing.Point 32, 60
        New-Object System.Drawing.Point 4, 32
    ))

# Inner shape
$g.DrawPolygon($brush1, @(
        New-Object System.Drawing.Point 16, 32
        New-Object System.Drawing.Point 24, 24
        New-Object System.Drawing.Point 32, 32
        New-Object System.Drawing.Point 24, 40
    ))

$g.FillPolygon($brush2, @(
        New-Object System.Drawing.Point 40, 32
        New-Object System.Drawing.Point 48, 24
        New-Object System.Drawing.Point 56, 32
        New-Object System.Drawing.Point 48, 40
    ))

# Save PNG asset
$pngPath = "$PSScriptRoot\Assets\app.png"
if (Test-Path $pngPath) { Remove-Item $pngPath -Force }
$bmp.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "PNG Generated: $pngPath"

# Save ICO asset
$ms = New-Object System.IO.MemoryStream
$bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
$pngBytes = $ms.ToArray()
$icoHeader = [byte[]]@(0, 0, 1, 0, 1, 0)
$sizeBytes = $pngBytes.Length
$offset = 22
$entry = [byte[]]@(64, 64, 0, 0, 1, 0, 32, 0, ($sizeBytes -band 0xFF), ($sizeBytes -shr 8 -band 0xFF), ($sizeBytes -shr 16 -band 0xFF), ($sizeBytes -shr 24 -band 0xFF), ($offset -band 0xFF), ($offset -shr 8 -band 0xFF), ($offset -shr 16 -band 0xFF), ($offset -shr 24 -band 0xFF))

$icoPath = "$PSScriptRoot\Assets\app.ico"
[System.IO.File]::WriteAllBytes($icoPath, ($icoHeader + $entry + $pngBytes))
Write-Host "ICO Generated: $icoPath"

$g.Dispose()
$bmp.Dispose()
