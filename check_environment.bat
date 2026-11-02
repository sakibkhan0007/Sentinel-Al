@echo off
setlocal enabledelayedexpansion

echo ==============================================================================
echo [SENTINEL AI] Environment Diagnostics ^& Health Checker
echo ==============================================================================
echo.

:: 1. Check Python
echo [1/5] Checking Python installation...
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [ERROR] Python is not installed or not in PATH!
    echo   Please install Python 3.11+ from https://python.org and add to PATH.
) else (
    for /f "tokens=*" %%i in ('python --version') do echo   [OK] Detected: %%i
)

:: 2. Check Node.js
echo.
echo [2/5] Checking Node.js runtime...
node -v >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [ERROR] Node.js is not installed or not in PATH!
    echo   Please install Node.js 18+ from https://nodejs.org.
) else (
    for /f "tokens=*" %%i in ('node -v') do echo   [OK] Detected Node.js: %%i
)

:: 3. Check npm
echo.
echo [3/5] Checking npm package manager...
call npm.cmd -v >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [WARNING] npm.cmd check failed. Will test npm via cmd.
) else (
    for /f "tokens=*" %%i in ('call npm.cmd -v') do echo   [OK] Detected npm: %%i
)

:: 4. Check Ports 8000 and 3000
echo.
echo [4/5] Checking local port availability...
netstat -ano | findstr :8000 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   [NOTICE] Port 8000 is currently occupied (Backend or existing service).
) else (
    echo   [OK] Port 8000 is available for FastAPI Backend.
)

netstat -ano | findstr :3000 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   [NOTICE] Port 3000 is currently occupied (Frontend or existing service).
) else (
    echo   [OK] Port 3000 is available for Next.js Dashboard.
)

:: 5. Check Docker
echo.
echo [5/5] Checking Docker Compose...
docker --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [INFO] Docker is not installed or not in PATH.
    echo   SENTINEL AI will use built-in Zero-Friction SQLite ^& In-Memory Coordinator mode.
) else (
    for /f "tokens=*" %%i in ('docker --version') do echo   [OK] Detected: %%i
)

echo.
echo ==============================================================================
echo Environment verification completed.
echo ==============================================================================
pause
