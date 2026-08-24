@echo off
REM ============================================================================
REM Hall Monitor GUI Launcher
REM ============================================================================
REM This script launches the Hall Monitor GUI interface

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

cls
echo.
echo ============================================================================
echo              HALL MONITOR - Network Intelligence System
echo ============================================================================
echo.
echo Launching Hall Monitor GUI...
echo.

REM Create logs directory if it doesn't exist
if not exist "%SCRIPT_DIR%logs" mkdir "%SCRIPT_DIR%logs"

REM Launch the GUI
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT_DIR%\hall-monitor-gui.ps1"

if %errorLevel% neq 0 (
    echo.
    echo ERROR: Failed to launch Hall Monitor GUI
    echo Please ensure PowerShell 3.0+ is installed
    echo.
    pause
    exit /b 1
)

exit /b 0
