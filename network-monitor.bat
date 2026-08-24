@echo off
REM ============================================================================
REM Network Monitor CMD - Main Entry Point
REM ============================================================================
REM This script launches the network monitoring application
REM Requires: Administrator privileges, PowerShell 3.0+

setlocal enabledelayedexpansion

REM Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ERROR: This script requires Administrator privileges!
    echo Please run Command Prompt as Administrator.
    echo.
    pause
    exit /b 1
)

REM Set script directory
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Color codes
set "RESET=[0m"
set "BRIGHT_CYAN=[96m"
set "BRIGHT_GREEN=[92m"
set "BRIGHT_YELLOW=[93m"
set "BRIGHT_RED=[91m"

cls
echo.
echo ============================================================================
echo           NETWORK MONITOR - Real-time Network Statistics
echo ============================================================================
echo.
echo Loading system information...
echo.

REM Create logs directory if it doesn't exist
if not exist "%SCRIPT_DIR%logs" mkdir "%SCRIPT_DIR%logs"

REM Create config file if it doesn't exist
if not exist "%SCRIPT_DIR%config.ini" (
    call :create_default_config
)

:menu
cls
echo.
echo ============================================================================
echo           NETWORK MONITOR - Main Menu
echo ============================================================================
echo.
echo 1 - View Network Statistics
echo 2 - View Connected Devices
echo 3 - View Bandwidth Usage
echo 4 - Start Continuous Monitoring (Real-time Chart)
echo 5 - View Traffic History
echo 6 - Configure Settings
echo 7 - Clear Logs
echo Q - Quit
echo.
echo ============================================================================
echo.

set /p choice="Select an option (1-7, Q): "

if /i "%choice%"=="1" goto view_network_stats
if /i "%choice%"=="2" goto view_devices
if /i "%choice%"=="3" goto view_bandwidth
if /i "%choice%"=="4" goto continuous_monitor
if /i "%choice%"=="5" goto view_history
if /i "%choice%"=="6" goto configure
if /i "%choice%"=="7" goto clear_logs
if /i "%choice%"=="Q" goto exit_program

echo Invalid choice. Please try again.
timeout /t 2 /nobreak
goto menu

:view_network_stats
cls
echo.
echo Gathering network statistics...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT_DIR%\scripts\get-network-info.ps1"
echo.
pause
goto menu

:view_devices
cls
echo.
echo Scanning for connected devices on your network...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT_DIR%\scripts\get-connected-devices.ps1"
echo.
pause
goto menu

:view_bandwidth
cls
echo.
echo Calculating bandwidth usage by device...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT_DIR%\scripts\get-bandwidth-usage.ps1"
echo.
pause
goto menu

:continuous_monitor
cls
echo.
echo Starting continuous network monitoring...
echo Press CTRL+C to stop monitoring
echo.
timeout /t 2 /nobreak
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT_DIR%\scripts\display-chart.ps1"
goto menu

:view_history
cls
echo.
echo Traffic History Log
echo ============================================================================
echo.
if exist "%SCRIPT_DIR%logs\network-traffic.log" (
    type "%SCRIPT_DIR%logs\network-traffic.log"
) else (
    echo No traffic history available yet. Start monitoring to generate logs.
)
echo.
pause
goto menu

:configure
cls
echo.
echo Configuration Settings
echo ============================================================================
echo.
if exist "%SCRIPT_DIR%config.ini" (
    type "%SCRIPT_DIR%config.ini"
) else (
    echo No configuration file found.
)
echo.
echo To modify settings, edit config.ini in the project root directory.
echo.
pause
goto menu

:clear_logs
cls
echo.
echo Clear Logs Confirmation
echo ============================================================================
echo.
echo This will delete all traffic history logs.
echo.
set /p confirm="Are you sure? (Y/N): "
if /i "%confirm%"=="Y" (
    if exist "%SCRIPT_DIR%logs\network-traffic.log" (
        del "%SCRIPT_DIR%logs\network-traffic.log"
        echo Logs cleared successfully.
    ) else (
        echo No logs to clear.
    )
) else (
    echo Operation cancelled.
)
echo.
timeout /t 2 /nobreak
goto menu

:create_default_config
echo Creating default configuration file...
(
    echo [Network Monitor Configuration]
    echo.
    echo [Settings]
    echo RefreshInterval=5
    echo LogTraffic=1
    echo EnableCharts=1
    echo.
    echo [Thresholds]
    echo HighBandwidthAlert=100
    echo.
    echo [Logging]
    echo LogDirectory=logs
    echo LogFile=network-traffic.log
) > "%SCRIPT_DIR%config.ini"
goto :eof

:exit_program
cls
echo.
echo ============================================================================
echo Thank you for using Network Monitor!
echo ============================================================================
echo.
pause
exit /b 0
