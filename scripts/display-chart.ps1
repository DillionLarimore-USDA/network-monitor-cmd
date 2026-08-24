# Display Real-time Chart Script
# Shows continuous network traffic monitoring with ASCII charts

param(
    [string]$ConfigFile = "$PSScriptRoot\..\config.ini",
    [int]$RefreshInterval = 2,
    [int]$DataPoints = 30
)

function Get-ConfigValue {
    param(
        [string]$Key,
        [string]$Section = "Settings"
    )
    
    if (-not (Test-Path $ConfigFile)) {
        return $null
    }
    
    $content = Get-Content $ConfigFile
    foreach ($line in $content) {
        if ($line -match "^\[$Section\]") {
            $inSection = $true
            continue
        }
        if ($line -match "^\[" -and $inSection) {
            break
        }
        if ($inSection -and $line -match "^$Key\s*=\s*(.+)") {
            return $matches[1].Trim()
        }
    }
    return $null
}

function Get-ASCIIChart {
    param(
        [array]$Data,
        [string]$Title,
        [int]$Height = 10,
        [int]$Width = 60
    )
    
    if ($null -eq $Data -or $Data.Count -eq 0) {
        return ""
    }
    
    $maxValue = ($Data | Measure-Object -Maximum).Maximum
    if ($maxValue -le 0) { $maxValue = 1 }
    
    $chart = ""
    $chart += "`n$Title`n"
    $chart += "=" * $Width + "`n"
    
    # Create chart rows
    for ($y = $Height; $y -gt 0; $y--) {
        $threshold = ($maxValue / $Height) * $y
        $row = "$([string]::Format('{0:F1}', $threshold))..|"
        
        for ($x = 0; $x -lt [Math]::Min($Data.Count, $Width); $x++) {
            $value = $Data[$x]
            if ($value -ge $threshold) {
                $row += "█"
            } else {
                $row += " "
            }
        }
        
        $chart += $row + "`n"
    }
    
    $chart += "0.0..|" + ("-" * [Math]::Min($Data.Count, $Width)) + "`n"
    
    return $chart
}

function Start-ContinuousMonitoring {
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "Real-time Network Monitoring - Press CTRL+C to stop" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $uploadHistory = @()
    $downloadHistory = @()
    $maxDataPoints = $DataPoints
    
    try {
        while ($true) {
            # Get baseline stats
            $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
            $baselineStats = @{}
            
            foreach ($adapter in $adapters) {
                $stats = Get-NetAdapterStatistics -InterfaceDescription $adapter.InterfaceDescription
                $baselineStats[$adapter.Name] = @{
                    BytesSent = $stats.SentBytes
                    BytesReceived = $stats.ReceivedBytes
                    Timestamp = Get-Date
                }
            }
            
            # Wait for sample interval
            Start-Sleep -Seconds $RefreshInterval
            
            # Get new stats
            $totalUpload = 0
            $totalDownload = 0
            
            foreach ($adapter in $adapters) {
                $stats = Get-NetAdapterStatistics -InterfaceDescription $adapter.InterfaceDescription
                $baseline = $baselineStats[$adapter.Name]
                $elapsed = (Get-Date) - $baseline.Timestamp
                
                $bytesSentDiff = $stats.SentBytes - $baseline.BytesSent
                $bytesReceivedDiff = $stats.ReceivedBytes - $baseline.BytesReceived
                
                $elapsedSeconds = $elapsed.TotalSeconds
                $uploadMbps = ($bytesSentDiff * 8) / ($elapsedSeconds * 1000000)
                $downloadMbps = ($bytesReceivedDiff * 8) / ($elapsedSeconds * 1000000)
                
                $totalUpload += $uploadMbps
                $totalDownload += $downloadMbps
            }
            
            # Add to history
            $uploadHistory += $totalUpload
            $downloadHistory += $totalDownload
            
            # Keep only last N data points
            if ($uploadHistory.Count -gt $maxDataPoints) {
                $uploadHistory = $uploadHistory[-$maxDataPoints..-1]
                $downloadHistory = $downloadHistory[-$maxDataPoints..-1]
            }
            
            # Clear screen and display
            Clear-Host
            Write-Host ""
            Write-Host "============================================================================" -ForegroundColor Cyan
            Write-Host "Real-time Network Monitoring ($(Get-Date -Format 'HH:mm:ss'))" -ForegroundColor Cyan
            Write-Host "============================================================================" -ForegroundColor Cyan
            Write-Host ""
            
            # Display current stats
            Write-Host "Current Upload:   $([string]::Format('{0:F2}', $totalUpload)) Mbps" -ForegroundColor Green
            Write-Host "Current Download: $([string]::Format('{0:F2}', $totalDownload)) Mbps" -ForegroundColor Blue
            Write-Host "Total Bandwidth:  $([string]::Format('{0:F2}', $totalUpload + $totalDownload)) Mbps" -ForegroundColor Cyan
            
            # Display charts
            Write-Host (Get-ASCIIChart -Data $downloadHistory -Title "Download Bandwidth (Mbps)" -Height 8 -Width 50) -ForegroundColor Blue
            Write-Host (Get-ASCIIChart -Data $uploadHistory -Title "Upload Bandwidth (Mbps)" -Height 8 -Width 50) -ForegroundColor Green
            
            # Display additional info
            Write-Host ""
            Write-Host "Connected Devices:" -ForegroundColor Cyan
            $devices = Get-NetNeighbor -AddressFamily IPv4 -State Reachable -ErrorAction SilentlyContinue
            Write-Host "Active: $($devices.Count) devices" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Last updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
            Write-Host "Press CTRL+C to stop monitoring" -ForegroundColor Yellow
        }
    }
    catch {
        if ($_ -notmatch "PipelineStoppedException") {
            Write-Host "Error during monitoring: $_" -ForegroundColor Red
        }
    }
}

# Main execution
Start-ContinuousMonitoring
