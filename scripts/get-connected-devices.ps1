# Get Connected Devices Script
# Scans the network for active devices using ARP and ping

param(
    [string]$ConfigFile = "$PSScriptRoot\..\config.ini",
    [int]$Timeout = 5000
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

function Get-SubnetFromAdapter {
    try {
        $adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
        if ($null -eq $adapter) {
            return $null
        }
        
        $ipConfig = Get-NetIPConfiguration -InterfaceIndex $adapter.InterfaceIndex
        $ipAddress = $ipConfig.IPv4Address.IPAddress | Select-Object -First 1
        
        if ($null -eq $ipAddress) {
            return $null
        }
        
        $parts = $ipAddress -split '\.'
        return "$($parts[0]).$($parts[1]).$($parts[2]).0/24"
    }
    catch {
        return $null
    }
}

function Get-ARPTable {
    Write-Host "Scanning ARP table for connected devices..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "Connected Devices (from ARP Cache)" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        $arpTable = Get-NetNeighbor -AddressFamily IPv4 -State Reachable -ErrorAction SilentlyContinue
        
        if ($null -eq $arpTable -or $arpTable.Count -eq 0) {
            Write-Host "No devices found in ARP table." -ForegroundColor Yellow
            return
        }
        
        $deviceList = @()
        $counter = 1
        
        foreach ($entry in $arpTable) {
            $ipAddr = $entry.IPAddress
            $macAddr = $entry.LinkLayerAddress
            $ifaceAlias = $entry.InterfaceAlias
            
            # Try to resolve hostname
            $hostname = "Unknown"
            try {
                $hostname = [System.Net.Dns]::GetHostEntry($ipAddr).HostName
            }
            catch {
                $hostname = "N/A"
            }
            
            $device = [PSCustomObject]@{
                'Number' = $counter
                'IP Address' = $ipAddr
                'MAC Address' = $macAddr
                'Hostname' = $hostname
                'Interface' = $ifaceAlias
                'Status' = "Active"
            }
            
            $deviceList += $device
            $counter++
        }
        
        # Display formatted table
        $deviceList | Format-Table -Property Number, 'IP Address', 'MAC Address', Hostname, Interface, Status -AutoSize
        
        Write-Host ""
        Write-Host "Total Devices Found: $($deviceList.Count)" -ForegroundColor Green
    }
    catch {
        Write-Host "Error scanning ARP table: $_" -ForegroundColor Red
    }
}

function Get-ActivePingDevices {
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "Scanning Network by Ping (This may take a minute)..." -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        $subnet = Get-SubnetFromAdapter
        if ($null -eq $subnet) {
            Write-Host "Could not determine subnet. Please check your network configuration." -ForegroundColor Red
            return
        }
        
        Write-Host "Scanning subnet: $subnet" -ForegroundColor Cyan
        Write-Host ""
        
        # Parse subnet
        $subnetParts = $subnet -split '\.'
        $baseIP = "$($subnetParts[0]).$($subnetParts[1]).$($subnetParts[2])"
        
        $activeDevices = @()
        
        for ($i = 1; $i -lt 255; $i++) {
            $testIP = "$baseIP.$i"
            $pingJob = Start-Job -ScriptBlock {
                param($ip, $to)
                try {
                    $ping = New-Object System.Net.NetworkInformation.Ping
                    $result = $ping.Send($ip, $to)
                    if ($result.Status -eq "Success") {
                        return $ip
                    }
                }
                catch { }
                return $null
            } -ArgumentList $testIP, $Timeout
            
            # Show progress
            if ($i % 10 -eq 0) {
                Write-Host "." -NoNewline -ForegroundColor Yellow
            }
        }
        
        Write-Host ""
        Write-Host "Ping scan completed." -ForegroundColor Green
    }
    catch {
        Write-Host "Error during ping scan: $_" -ForegroundColor Red
    }
}

function Get-LocalNetworkInfo {
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "Local Network Configuration" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        $adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
        if ($null -ne $adapter) {
            $ipConfig = Get-NetIPConfiguration -InterfaceIndex $adapter.InterfaceIndex
            $ipv4 = $ipConfig.IPv4Address | Select-Object -First 1
            $gateway = $ipConfig.IPv4DefaultGateway | Select-Object -First 1
            
            Write-Host "Adapter: $($adapter.Name)" -ForegroundColor Green
            Write-Host "  MAC Address: $($adapter.MacAddress)" -ForegroundColor Gray
            Write-Host "  Local IP: $($ipv4.IPAddress)" -ForegroundColor Gray
            Write-Host "  Subnet Mask: $($ipv4.PrefixLength)" -ForegroundColor Gray
            Write-Host "  Gateway: $($gateway.NextHop)" -ForegroundColor Gray
            Write-Host ""
        }
    }
    catch {
        Write-Host "Error retrieving local network info: $_" -ForegroundColor Yellow
    }
}

# Main execution
Write-Host ""
Get-LocalNetworkInfo
Get-ARPTable
Get-ActivePingDevices

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Device Scan Completed at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
