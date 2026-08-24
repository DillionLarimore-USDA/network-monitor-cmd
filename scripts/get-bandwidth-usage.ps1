# Get Bandwidth Usage Script
# Monitors and displays bandwidth usage by device

param(
    [string]$ConfigFile = "$PSScriptRoot\..\config.ini",
    [int]$SampleInterval = 2
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

function Get-NetworkInterfaceStats {
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "Bandwidth Usage Monitoring" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Collecting baseline statistics..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        # Get all active network adapters
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
        
        if ($null -eq $adapters) {
            Write-Host "No active network adapters found." -ForegroundColor Yellow
            return
        }
        
        # Collect baseline stats
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
        Write-Host "Sampling for $SampleInterval seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds $SampleInterval
        
        # Collect new stats
        $bandwidthData = @()
        foreach ($adapter in $adapters) {
            $stats = Get-NetAdapterStatistics -InterfaceDescription $adapter.InterfaceDescription
            $baseline = $baselineStats[$adapter.Name]
            $elapsed = (Get-Date) - $baseline.Timestamp
            
            $bytesSentDiff = $stats.SentBytes - $baseline.BytesSent
            $bytesReceivedDiff = $stats.ReceivedBytes - $baseline.BytesReceived
            
            # Calculate bandwidth in Mbps
            $elapsedSeconds = $elapsed.TotalSeconds
            $uploadMbps = ($bytesSentDiff * 8) / ($elapsedSeconds * 1000000)
            $downloadMbps = ($bytesReceivedDiff * 8) / ($elapsedSeconds * 1000000)
            $totalMbps = $uploadMbps + $downloadMbps
            
            $data = [PSCustomObject]@{
                'Adapter' = $adapter.Name
                'Upload (Mbps)' = "{0:F2}" -f $uploadMbps
                'Download (Mbps)' = "{0:F2}" -f $downloadMbps
                'Total (Mbps)' = "{0:F2}" -f $totalMbps
                'Upload (MB)' = "{0:F2}" -f ($bytesSentDiff / 1024 / 1024)
                'Download (MB)' = "{0:F2}" -f ($bytesReceivedDiff / 1024 / 1024)
            }
            
            $bandwidthData += $data
        }
        
        # Display results
        $bandwidthData | Format-Table -AutoSize
        
        # Display summary
        Write-Host ""
        Write-Host "============================================================================" -ForegroundColor Cyan
        Write-Host "Bandwidth Summary" -ForegroundColor Cyan
        Write-Host "============================================================================" -ForegroundColor Cyan
        Write-Host ""
        
        foreach ($data in $bandwidthData) {
            $totalMbps = [double]$data.'Total (Mbps)'
            $status = if ($totalMbps -gt 50) { "High" } elseif ($totalMbps -gt 20) { "Medium" } else { "Low" }
            $statusColor = switch ($status) {
                "High" { "Red" }
                "Medium" { "Yellow" }
                "Low" { "Green" }
            }
            
            Write-Host "$($data.Adapter): $($data.'Total (Mbps)') Mbps [$status Usage]" -ForegroundColor $statusColor
        }
    }
    catch {
        Write-Host "Error retrieving bandwidth statistics: $_" -ForegroundColor Red
    }
}

function Get-ProcessNetworkStats {
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "Top Network Processes (by bandwidth)" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Scanning active network connections..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        $connections = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue
        $udpConnections = Get-NetUDPEndpoint -ErrorAction SilentlyContinue
        
        $processData = @()
        
        # Aggregate by process
        $allConnections = @($connections) + @($udpConnections)
        $groupedByProcess = $allConnections | Group-Object -Property OwningProcess
        
        foreach ($group in $groupedByProcess) {
            $processId = $group.Name
            if ([int]::TryParse($processId, [ref]$null)) {
                try {
                    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
                    if ($null -ne $process) {
                        $connCount = $group.Count
                        $data = [PSCustomObject]@{
                            'Process Name' = $process.Name
                            'Process ID' = $processId
                            'Connections' = $connCount
                            'Memory (MB)' = "{0:F2}" -f ($process.WorkingSet / 1024 / 1024)
                        }
                        $processData += $data
                    }
                }
                catch { }
            }
        }
        
        # Sort by connection count and display top 10
        $topProcesses = $processData | Sort-Object -Property 'Connections' -Descending | Select-Object -First 10
        
        if ($topProcesses.Count -gt 0) {
            $topProcesses | Format-Table -AutoSize
        } else {
            Write-Host "No active network processes found." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error retrieving process network statistics: $_" -ForegroundColor Yellow
    }
}

function Get-NetworkConnections {
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "Active Network Connections" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        $connections = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | Select-Object -First 20
        
        if ($null -eq $connections -or $connections.Count -eq 0) {
            Write-Host "No established connections found." -ForegroundColor Yellow
            return
        }
        
        $connectionData = @()
        foreach ($conn in $connections) {
            $process = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            $procName = if ($null -ne $process) { $process.Name } else { "Unknown" }
            
            $data = [PSCustomObject]@{
                'Local Address' = $conn.LocalAddress
                'Local Port' = $conn.LocalPort
                'Remote Address' = $conn.RemoteAddress
                'Remote Port' = $conn.RemotePort
                'Process' = $procName
                'State' = $conn.State
            }
            
            $connectionData += $data
        }
        
        $connectionData | Format-Table -AutoSize
        Write-Host ""
        Write-Host "Showing top 20 connections. Total connections: $($(Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue).Count)" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Error retrieving network connections: $_" -ForegroundColor Yellow
    }
}

# Main execution
Write-Host ""
Get-NetworkInterfaceStats
Get-ProcessNetworkStats
Get-NetworkConnections

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Bandwidth Analysis Completed at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
