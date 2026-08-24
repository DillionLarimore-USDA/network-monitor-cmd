# Get Network Information Script
# Displays current network adapter statistics

param(
    [string]$ConfigFile = "$PSScriptRoot\..\config.ini"
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

function Get-NetworkAdapterStats {
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "Network Adapter Information" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
        
        if ($null -eq $adapters) {
            Write-Host "No active network adapters found." -ForegroundColor Yellow
            return
        }
        
        foreach ($adapter in $adapters) {
            Write-Host "Adapter Name: $($adapter.Name)" -ForegroundColor Green
            Write-Host "  Status: $($adapter.Status)" -ForegroundColor Gray
            Write-Host "  Link Speed: $($adapter.LinkSpeed)" -ForegroundColor Gray
            
            # Get IP Configuration
            $ipConfig = Get-NetIPConfiguration -InterfaceIndex $adapter.InterfaceIndex -ErrorAction SilentlyContinue
            if ($null -ne $ipConfig) {
                $ipv4 = $ipConfig.IPv4Address | Select-Object -First 1
                if ($null -ne $ipv4) {
                    Write-Host "  IPv4 Address: $($ipv4.IPAddress)" -ForegroundColor Gray
                }
                $gateway = $ipConfig.IPv4DefaultGateway | Select-Object -First 1
                if ($null -ne $gateway) {
                    Write-Host "  Default Gateway: $($gateway.NextHop)" -ForegroundColor Gray
                }
            }
            
            # Get Network Statistics
            $stats = Get-NetAdapterStatistics -InterfaceDescription $adapter.InterfaceDescription -ErrorAction SilentlyContinue
            if ($null -ne $stats) {
                Write-Host "  Bytes Received: $(Format-Bytes -Bytes $stats.ReceivedBytes)" -ForegroundColor Gray
                Write-Host "  Bytes Sent: $(Format-Bytes -Bytes $stats.SentBytes)" -ForegroundColor Gray
                Write-Host "  Packets Received: $($stats.ReceivedPackets)" -ForegroundColor Gray
                Write-Host "  Packets Sent: $($stats.SentPackets)" -ForegroundColor Gray
            }
            Write-Host ""
        }
    }
    catch {
        Write-Host "Error retrieving network adapter information: $_" -ForegroundColor Red
    }
}

function Get-DNSInfo {
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "DNS Configuration" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        $dnsServers = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses.Count -gt 0 }
        
        foreach ($dns in $dnsServers) {
            Write-Host "Interface: $($dns.InterfaceAlias)" -ForegroundColor Green
            Write-Host "  DNS Servers: $($dns.ServerAddresses -join ', ')" -ForegroundColor Gray
            Write-Host ""
        }
    }
    catch {
        Write-Host "Error retrieving DNS information: $_" -ForegroundColor Yellow
    }
}

function Format-Bytes {
    param([int64]$Bytes)
    
    if ($Bytes -lt 1024) { return "$Bytes B" }
    elseif ($Bytes -lt 1024 * 1024) { return "{0:F2} KB" -f ($Bytes / 1024) }
    elseif ($Bytes -lt 1024 * 1024 * 1024) { return "{0:F2} MB" -f ($Bytes / 1024 / 1024) }
    else { return "{0:F2} GB" -f ($Bytes / 1024 / 1024 / 1024) }
}

# Main execution
Write-Host ""
Get-NetworkAdapterStats
Get-DNSInfo

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Network Statistics Retrieved at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
