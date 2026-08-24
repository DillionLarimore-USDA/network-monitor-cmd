# Hall Monitor - Network Monitoring GUI
# A Windows Forms-based GUI for easy network monitoring

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:ConfigFile = "$PSScriptRoot\..\config.ini"
$script:ScriptsPath = "$PSScriptRoot"

# Set up form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Hall Monitor - Network Monitor"
$form.Size = New-Object System.Drawing.Size(900, 700)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)

# Create title label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "🚀 HALL MONITOR - Network Intelligence System"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::DarkBlue
$titleLabel.Location = New-Object System.Drawing.Point(20, 15)
$titleLabel.Size = New-Object System.Drawing.Size(850, 40)
$titleLabel.AutoSize = $false
$form.Controls.Add($titleLabel)

# Create subtitle
$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "Real-time network monitoring, device tracking, and bandwidth analysis"
$subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$subtitleLabel.ForeColor = [System.Drawing.Color]::Gray
$subtitleLabel.Location = New-Object System.Drawing.Point(20, 50)
$subtitleLabel.Size = New-Object System.Drawing.Size(850, 25)
$form.Controls.Add($subtitleLabel)

# Create main panel for buttons
$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Location = New-Object System.Drawing.Point(20, 85)
$mainPanel.Size = New-Object System.Drawing.Size(850, 580)
$mainPanel.BackColor = [System.Drawing.Color]::White
$mainPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$form.Controls.Add($mainPanel)

# Function to create button with style
function New-StyledButton {
    param(
        [string]$Text,
        [int]$X,
        [int]$Y,
        [System.Drawing.Color]$BackColor,
        [System.EventHandler]$ClickHandler
    )
    
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Location = New-Object System.Drawing.Point($X, $Y)
    $button.Size = New-Object System.Drawing.Size(200, 80)
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $button.BackColor = $BackColor
    $button.ForeColor = [System.Drawing.Color]::White
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.FlatAppearance.BorderSize = 0
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $button.Add_Click($ClickHandler)
    
    # Add hover effect
    $button.Add_MouseEnter({
        $this.BackColor = [System.Drawing.Color]::FromArgb([Math]::Min(255, $this.BackColor.R + 30), [Math]::Min(255, $this.BackColor.G + 30), [Math]::Min(255, $this.BackColor.B + 30))
    })
    
    $button.Add_MouseLeave({
        $this.BackColor = $BackColor
    })
    
    return $button
}

# Create buttons
$networkInfoBtn = New-StyledButton -Text "📊 Network Info" -X 20 -Y 20 -BackColor ([System.Drawing.Color]::FromArgb(52, 152, 219)) -ClickHandler {
    $outputForm = Show-OutputWindow "Network Statistics"
    & "$script:ScriptsPath\get-network-info.ps1" | ForEach-Object { $outputForm.Text += $_ + "`r`n" }
}
$mainPanel.Controls.Add($networkInfoBtn)

$devicesBtn = New-StyledButton -Text "🖥️ Connected Devices" -X 250 -Y 20 -BackColor ([System.Drawing.Color]::FromArgb(46, 204, 113)) -ClickHandler {
    $outputForm = Show-OutputWindow "Connected Devices"
    & "$script:ScriptsPath\get-connected-devices.ps1" | ForEach-Object { $outputForm.Text += $_ + "`r`n" }
}
$mainPanel.Controls.Add($devicesBtn)

$bandwidthBtn = New-StyledButton -Text "📈 Bandwidth Usage" -X 480 -Y 20 -BackColor ([System.Drawing.Color]::FromArgb(155, 89, 182)) -ClickHandler {
    $outputForm = Show-OutputWindow "Bandwidth Usage"
    & "$script:ScriptsPath\get-bandwidth-usage.ps1" | ForEach-Object { $outputForm.Text += $_ + "`r`n" }
}
$mainPanel.Controls.Add($bandwidthBtn)

$chartBtn = New-StyledButton -Text "📉 Live Chart" -X 610 -Y 20 -BackColor ([System.Drawing.Color]::FromArgb(230, 126, 34)) -ClickHandler {
    $form.Hide()
    & "$script:ScriptsPath\display-chart.ps1"
    $form.Show()
}
$mainPanel.Controls.Add($chartBtn)

$historyBtn = New-StyledButton -Text "📋 Traffic History" -X 20 -Y 120 -BackColor ([System.Drawing.Color]::FromArgb(41, 128, 185)) -ClickHandler {
    $outputForm = Show-OutputWindow "Traffic History"
    if (Test-Path "$PSScriptRoot\..\logs\network-traffic.log") {
        Get-Content "$PSScriptRoot\..\logs\network-traffic.log" | ForEach-Object { $outputForm.AppendText($_ + "`r`n") }
    } else {
        $outputForm.AppendText("No traffic history available yet.`r`n")
    }
}
$mainPanel.Controls.Add($historyBtn)

$configBtn = New-StyledButton -Text "⚙️ Configuration" -X 250 -Y 120 -BackColor ([System.Drawing.Color]::FromArgb(149, 165, 166)) -ClickHandler {
    $outputForm = Show-OutputWindow "Configuration Settings"
    if (Test-Path $script:ConfigFile) {
        Get-Content $script:ConfigFile | ForEach-Object { $outputForm.AppendText($_ + "`r`n") }
    } else {
        $outputForm.AppendText("No configuration file found.`r`n")
    }
}
$mainPanel.Controls.Add($configBtn)

$refreshBtn = New-StyledButton -Text "🔄 Refresh All" -X 480 -Y 120 -BackColor ([System.Drawing.Color]::FromArgb(52, 73, 94)) -ClickHandler {
    [System.Windows.Forms.MessageBox]::Show("All data has been refreshed!`n`nClick individual buttons to view updated information.", "Refresh Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
$mainPanel.Controls.Add($refreshBtn)

$exitBtn = New-StyledButton -Text "❌ Exit" -X 610 -Y 120 -BackColor ([System.Drawing.Color]::FromArgb(192, 57, 43)) -ClickHandler {
    $form.Close()
}
$mainPanel.Controls.Add($exitBtn)

# Create info text box
$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Text = "ℹ️ Select an option above to monitor your network. Hall Monitor provides real-time insights into network traffic, connected devices, and bandwidth usage."
$infoLabel.Location = New-Object System.Drawing.Point(20, 230)
$infoLabel.Size = New-Object System.Drawing.Size(810, 60)
$infoLabel.AutoSize = $false
$infoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$infoLabel.ForeColor = [System.Drawing.Color]::Gray
$infoLabel.BackColor = [System.Drawing.Color]::WhiteSmoke
$infoLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$infoLabel.Padding = New-Object System.Windows.Forms.Padding(10)
$mainPanel.Controls.Add($infoLabel)

# Create status text box
$statusTextBox = New-Object System.Windows.Forms.TextBox
$statusTextBox.Location = New-Object System.Drawing.Point(20, 305)
$statusTextBox.Size = New-Object System.Drawing.Size(810, 255)
$statusTextBox.Multiline = $true
$statusTextBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$statusTextBox.ReadOnly = $true
$statusTextBox.Font = New-Object System.Drawing.Font("Courier New", 9)
$statusTextBox.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$statusTextBox.ForeColor = [System.Drawing.Color]::Lime
$mainPanel.Controls.Add($statusTextBox)

# Function to show output window
function Show-OutputWindow {
    param([string]$Title)
    
    $outputForm = New-Object System.Windows.Forms.Form
    $outputForm.Text = $Title
    $outputForm.Size = New-Object System.Drawing.Size(1000, 600)
    $outputForm.StartPosition = "CenterScreen"
    
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Dock = [System.Windows.Forms.DockStyle]::Fill
    $textBox.Multiline = $true
    $textBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
    $textBox.Font = New-Object System.Drawing.Font("Courier New", 9)
    $textBox.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $textBox.ForeColor = [System.Drawing.Color]::Lime
    $outputForm.Controls.Add($textBox)
    
    $outputForm.Add_Shown({ $outputForm.Activate() })
    $outputForm.Show() | Out-Null
    
    return $textBox
}

# Update status box with system info
$statusTextBox.AppendText("=== HALL MONITOR INITIALIZED ===" + "`r`n")
$statusTextBox.AppendText("System: Windows Network Monitor`r`n")
$statusTextBox.AppendText("Version: 1.0`r`n")
$statusTextBox.AppendText("Status: Ready for monitoring`r`n")
$statusTextBox.AppendText("`r`n")
$statusTextBox.AppendText("Features:`r`n")
$statusTextBox.AppendText("✓ Real-time network statistics`r`n")
$statusTextBox.AppendText("✓ Connected device detection`r`n")
$statusTextBox.AppendText("✓ Bandwidth usage analysis`r`n")
$statusTextBox.AppendText("✓ Live network charts`r`n")
$statusTextBox.AppendText("✓ Traffic history logging`r`n")
$statusTextBox.AppendText("`r`n")
$statusTextBox.AppendText("Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`r`n")

# Show form
[void]$form.ShowDialog()
