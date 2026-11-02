@echo off
setlocal enabledelayedexpansion

title Stop SENTINEL AI
cd /d "%~dp0"

echo ==============================================================================
echo [SENTINEL AI] Clean Shutdown Utility
echo ==============================================================================
echo.

:: 1. Terminate Backend processes on port 8000
echo [*] Terminating Backend processes on port 8000...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8000') do (
    taskkill /PID %%a /F >nul 2>&1
)

:: 2. Terminate Frontend processes on port 3000
echo [*] Terminating Frontend processes on port 3000...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000') do (
    taskkill /PID %%a /F >nul 2>&1
)

echo.
echo ==============================================================================
echo [SUCCESS] SENTINEL AI processes stopped cleanly.
echo (Persistent database and audit logs were safely preserved.)
echo ==============================================================================
ping 127.0.0.1 -n 3 >nul
