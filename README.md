# Hall Monitor - Network Intelligence System

A comprehensive Windows network monitoring tool with both GUI and command-line interfaces that displays real-time network statistics, connected devices, bandwidth usage, and traffic visualization.

## Features

- 🎨 **Hall Monitor GUI** - Easy-to-use graphical interface with styled buttons
- 📊 **Real-time Network Statistics** - View adapter info, IP config, DNS settings
- 🖥️ **Connected Devices** - Scan and identify all devices on your network
- 📈 **Bandwidth Monitoring** - Track upload/download speeds and per-process usage
- 📉 **Live Charts** - ASCII-based real-time network traffic visualization
- 💾 **Traffic History** - Persistent logging of network activity
- ⚙️ **Configuration** - Customizable settings and monitoring parameters
- 🔄 **Auto-refresh** - Continuous network monitoring capabilities

## System Requirements

- **OS:** Windows 7 or higher
- **Privileges:** Administrator rights required
- **PowerShell:** Version 3.0 or higher
- **.NET Framework:** 4.5 or higher

## Quick Start

### GUI Mode (Recommended)

```cmd
hall-monitor.bat
```

This launches the Hall Monitor GUI with easy-to-click buttons for all monitoring functions.

### CLI Mode

```cmd
network-monitor.bat
```

This opens the command-line menu for traditional interface navigation.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/DillionLarimore-USDA/network-monitor-cmd.git
   cd network-monitor-cmd
   ```

2. Right-click on `hall-monitor.bat` or `network-monitor.bat`

3. Select "Run as administrator"

## Project Structure

```
network-monitor-cmd/
├── hall-monitor.bat              # GUI Launcher (RECOMMENDED)
├── hall-monitor-gui.ps1          # Hall Monitor GUI Interface
├── network-monitor.bat           # CLI Launcher
├── scripts/
│   ├── get-network-info.ps1      # Network adapter statistics
│   ├── get-connected-devices.ps1 # Network device scanner
│   ├── get-bandwidth-usage.ps1   # Bandwidth analyzer
│   └── display-chart.ps1         # Real-time traffic charts
├── logs/
│   └── network-traffic.log       # Traffic history
└── config.ini                    # Configuration settings
```

## Hall Monitor GUI Features

The GUI provides quick access to all monitoring functions with colored buttons:

| Button | Function |
|--------|----------|
| 📊 Network Info | Display current network adapter information |
| 🖥️ Connected Devices | Scan network for active devices |
| 📈 Bandwidth Usage | Show current bandwidth consumption |
| 📉 Live Chart | Start real-time traffic monitoring |
| 📋 Traffic History | View logged network traffic |
| ⚙️ Configuration | Display current settings |
| 🔄 Refresh All | Refresh all monitoring data |
| ❌ Exit | Close the application |

## CLI Menu Options

When running `network-monitor.bat`:

- **1** - View Network Statistics
- **2** - View Connected Devices
- **3** - View Bandwidth Usage
- **4** - Start Continuous Monitoring
- **5** - View Traffic History
- **6** - Configure Settings
- **7** - Clear Logs
- **Q** - Quit

## Configuration

Edit `config.ini` to customize:

```ini
[Settings]
RefreshInterval=5          # Seconds between refreshes
LogTraffic=1              # Enable traffic logging
EnableCharts=1            # Enable chart visualization

[Thresholds]
HighBandwidthAlert=100    # Alert threshold in MB/s

[Logging]
LogDirectory=logs         # Log file directory
LogFile=network-traffic.log
LogRetention=30           # Days to retain logs

[Network]
NetworkInterface=         # Auto-detect if empty
ARPTimeout=5              # ARP scan timeout
EnableDNSResolution=1     # Resolve hostnames
```

## Usage Examples

### View Network Information
```powershell
.\scripts\get-network-info.ps1
```

### Scan for Connected Devices
```powershell
.\scripts\get-connected-devices.ps1
```

### Monitor Bandwidth Usage
```powershell
.\scripts\get-bandwidth-usage.ps1
```

### Start Real-time Monitoring (Press CTRL+C to stop)
```powershell
.\scripts\display-chart.ps1
```

## Screenshots / Output Examples

### Network Statistics
Shows active adapters, IP addresses, link speeds, and packet counts.

### Connected Devices
Displays table of connected devices with IP, MAC address, hostname, and status.

### Bandwidth Usage
Real-time Mbps upload/download speeds with process-level monitoring.

### Live Charts
ASCII-based bar charts showing network traffic trends over time.

## Troubleshooting

### "Access Denied" Error
- Ensure you're running as Administrator
- Right-click the batch file and select "Run as administrator"

### PowerShell Execution Policy Error
- The scripts handle execution policy, but if issues persist:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
```

### No Devices Found
- Ensure your network is active
- Check that ARP is enabled on your network adapter
- Try running from a network with multiple devices

### GUI Won't Display
- Ensure .NET Framework 4.5+ is installed
- Try running PowerShell as Administrator
- Check Windows Forms assembly: `[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")`

## Performance Notes

- Network scanning can take 1-2 minutes for large subnets
- Charts update every 2-5 seconds depending on configuration
- Bandwidth calculations use 2-second sampling intervals
- Process monitoring requires administrator privileges

## Contributing

Feel free to fork and submit pull requests for improvements!

### Suggested Enhancements
- Export to CSV/JSON
- Email alerts for bandwidth spikes
- Integration with SNMP
- Mobile app companion
- Network topology visualization

## License

MIT License - See LICENSE file for details

## Author

**Dillion Larimore**
- Organization: USDA
- GitHub: [@DillionLarimore-USDA](https://github.com/DillionLarimore-USDA)

## Support

For issues, questions, or suggestions:
1. Check the Troubleshooting section
2. Review configuration settings in `config.ini`
3. Open an issue on GitHub with detailed error messages
4. Provide system information and PowerShell version

## Changelog

### Version 1.0 (Current)
- ✨ Initial release
- 🎨 Hall Monitor GUI interface
- 📊 Network statistics monitoring
- 🖥️ Device detection and tracking
- 📈 Bandwidth usage analysis
- 📉 Real-time traffic charts
- 💾 Traffic history logging
- ⚙️ Configuration management

---

**Hall Monitor** - Your Network's Watchdog
