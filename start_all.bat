@echo off
setlocal enabledelayedexpansion

title SENTINEL AI Launcher
cd /d "%~dp0"

echo ==============================================================================
echo       SENTINEL AI — Autonomous Cyber Defense ^& Threat Intelligence
echo ==============================================================================
echo.

:: 1. Verify Prerequisites
echo [*] Step 1/5: Checking system prerequisites...
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Python is not installed or not in your Windows PATH!
    echo Please install Python 3.11+ from https://python.org and check "Add Python to PATH".
    pause
    exit /b 1
)

where npm.cmd >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js / npm is not installed or not in your Windows PATH!
    echo Please install Node.js 18+ from https://nodejs.org.
    pause
    exit /b 1
)
echo   [OK] Python and Node.js detected successfully.

:: 2. Ensure Environment Configuration (.env)
echo.
echo [*] Step 2/5: Verifying configuration (.env)...
if not exist ".env" (
    echo   [*] Generating root .env from template...
    copy /y ".env.example" ".env" >nul
)
if not exist "backend\.env" (
    copy /y ".env.example" "backend\.env" >nul
)
echo   [OK] Environment configuration verified.

:: 3. Ensure Backend Virtual Environment
echo.
echo [*] Step 3/5: Checking Python virtual environment...
if not exist "backend\venv\Scripts\python.exe" (
    echo   [*] Creating virtual environment at backend\venv...
    python -m venv "backend\venv"
    call "backend\venv\Scripts\python.exe" -m pip install -r "backend\requirements.txt"
    call "backend\venv\Scripts\python.exe" -m pip install greenlet
    powershell -Command "Get-ChildItem -Path .\backend\venv\Lib\site-packages\sqlalchemy -Filter '*.pyd' -Recurse -ErrorAction SilentlyContinue | Rename-Item -NewName { $_.Name + '.disabled' } -ErrorAction SilentlyContinue" >nul 2>&1
)
echo   [OK] Python virtual environment ready.

:: 4. Ensure Database Initialized
echo.
echo [*] Step 4/5: Initializing Sentinel database and security rules...
call "backend\venv\Scripts\python.exe" "backend\init_db_standalone.py"
echo   [OK] Database ready.

:: 5. Launch Backend & Frontend Services
echo.
echo [*] Step 5/5: Starting SENTINEL AI services...

:: Check if port 8000 is already active
netstat -ano | findstr :8000 | findstr LISTENING >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   [INFO] Backend is already running on port 8000.
) else (
    echo   [*] Launching Backend on http://127.0.0.1:8000...
    start "SENTINEL AI - Backend Engine" cmd /c "call "%~dp0run_backend.bat""
)

:: Check if port 3000 is already active
netstat -ano | findstr :3000 | findstr LISTENING >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   [INFO] Frontend is already running on port 3000.
) else (
    echo   [*] Launching Frontend on http://localhost:3000...
    start "SENTINEL AI - Command Center UI" cmd /c "call "%~dp0run_frontend.bat""
)

:: Wait for Backend Health Check
echo.
echo [*] Waiting for Backend to be operational...
set BACKEND_READY=0
for /l %%i in (1, 1, 30) do (
    curl -s http://127.0.0.1:8000/health >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        set BACKEND_READY=1
        goto :backend_ready_ok
    )
    ping 127.0.0.1 -n 2 >nul
)

:backend_ready_ok
if %BACKEND_READY% EQU 1 (
    echo   [OK] Backend is healthy and listening on http://127.0.0.1:8000
) else (
    echo   [WARNING] Backend took longer to start. Check the Backend console window.
)

:: Wait for Frontend Dev Server
echo [*] Waiting for Next.js Dashboard to be operational...
set FRONTEND_READY=0
for /l %%i in (1, 1, 35) do (
    curl -s http://localhost:3000 >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        set FRONTEND_READY=1
        goto :frontend_ready_ok
    )
    ping 127.0.0.1 -n 2 >nul
)

:frontend_ready_ok
if %FRONTEND_READY% EQU 1 (
    echo   [OK] Frontend is ready on http://localhost:3000
) else (
    echo   [WARNING] Frontend is still compiling pages. It will open shortly.
)

:: Open Browser
echo.
echo [*] Launching Command Center in browser...
start http://localhost:3000

echo.
echo ==============================================================================
echo [SUCCESS] SENTINEL AI is now running!
echo.
echo  - Command Center UI:  http://localhost:3000
echo  - Backend API:        http://127.0.0.1:8000
echo  - Swagger API Docs:   http://127.0.0.1:8000/docs
echo  - Default Login:      admin@sentinel.local / SentinelAdmin@2026!
echo.
echo Dono windows (Backend aur Frontend) ko background me khula rehne dein.
echo Band karne ke liye "stop_all.bat" chalayein.
echo ==============================================================================
pause
