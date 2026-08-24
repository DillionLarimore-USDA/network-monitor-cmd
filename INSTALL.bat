@echo off
REM ============================================================================
REM Hall Monitor Installation Script
REM ============================================================================
REM Run this script to set up Hall Monitor on your system

setlocal enabledelayedexpansion

cls
echo.
echo ============================================================================
echo              HALL MONITOR - Installation Script
echo ============================================================================
echo.

REM Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script requires Administrator privileges!
    echo Please run Command Prompt as Administrator.
    echo.
    pause
    exit /b 1
)

set "INSTALL_DIR=%~dp0"

echo Installation Directory: %INSTALL_DIR%
echo.
echo Creating necessary directories...

REM Create logs directory
if not exist "%INSTALL_DIR%logs" (
    mkdir "%INSTALL_DIR%logs"
    echo ✓ Created logs directory
)

REM Create scripts directory
if not exist "%INSTALL_DIR%scripts" (
    mkdir "%INSTALL_DIR%scripts"
    echo ✓ Created scripts directory
)

REM Verify all required files exist
echo.
echo Verifying installation files...

set "FILES_OK=1"

if not exist "%INSTALL_DIR%hall-monitor.bat" (
    echo ✗ Missing: hall-monitor.bat
    set "FILES_OK=0"
)

if not exist "%INSTALL_DIR%hall-monitor-gui.ps1" (
    echo ✗ Missing: hall-monitor-gui.ps1
    set "FILES_OK=0"
)

if not exist "%INSTALL_DIR%network-monitor.bat" (
    echo ✗ Missing: network-monitor.bat
    set "FILES_OK=0"
)

if not exist "%INSTALL_DIR%scripts\get-network-info.ps1" (
    echo ✗ Missing: scripts\get-network-info.ps1
    set "FILES_OK=0"
)

if not exist "%INSTALL_DIR%scripts\get-connected-devices.ps1" (
    echo ✗ Missing: scripts\get-connected-devices.ps1
    set "FILES_OK=0"
)

if not exist "%INSTALL_DIR%scripts\get-bandwidth-usage.ps1" (
    echo ✗ Missing: scripts\get-bandwidth-usage.ps1
    set "FILES_OK=0"
)

if not exist "%INSTALL_DIR%scripts\display-chart.ps1" (
    echo ✗ Missing: scripts\display-chart.ps1
    set "FILES_OK=0"
)

if not exist "%INSTALL_DIR%config.ini" (
    echo ✗ Missing: config.ini
    set "FILES_OK=0"
)

if not exist "%INSTALL_DIR%README.md" (
    echo ✗ Missing: README.md
    set "FILES_OK=0"
)

if %FILES_OK% equ 1 (
    echo ✓ All installation files verified
) else (
    echo.
    echo ERROR: Some files are missing from the installation package.
    echo Please ensure all files were extracted from the ZIP file.
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================================================
echo Installation Complete!
echo ============================================================================
echo.
echo Hall Monitor is ready to use!
echo.
echo Quick Start:
echo   1. Double-click: hall-monitor.bat
echo      OR
echo   2. Run Command Prompt as Administrator
echo      Type: hall-monitor.bat
echo.
echo For CLI version (alternative):
echo   Double-click: network-monitor.bat
echo.
echo Documentation:
echo   Open: README.md
echo.
echo ============================================================================
echo.
pause
