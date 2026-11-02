@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

echo ==============================================================================
echo [SENTINEL AI] Platform Setup ^& Dependency Installer
echo ==============================================================================
echo.

:: 1. Copy .env if missing
if not exist ".env" (
    echo [*] Creating .env from .env.example...
    copy ".env.example" ".env" >nul
)
if not exist "backend\.env" (
    copy ".env.example" "backend\.env" >nul
)

:: 2. Setup Backend Python Virtual Environment
echo [*] Checking Backend virtual environment...
if not exist "backend\venv\Scripts\python.exe" (
    echo [*] Creating virtual environment at backend\venv...
    python -m venv "backend\venv"
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Failed to create Python virtual environment.
        pause
        exit /b 1
    )
)

echo [*] Installing Backend dependencies...
"backend\venv\Scripts\python.exe" -m pip install -r "backend\requirements.txt"
"backend\venv\Scripts\python.exe" -m pip install greenlet

:: Disable compiled .pyd DLLs in sqlalchemy if blocked by Windows Defender Application Control
powershell -Command "Get-ChildItem -Path .\backend\venv\Lib\site-packages\sqlalchemy -Filter '*.pyd' -Recurse -ErrorAction SilentlyContinue | Rename-Item -NewName { $_.Name + '.disabled' } -ErrorAction SilentlyContinue" >nul 2>&1

:: 3. Setup Frontend Dependencies
echo.
echo [*] Installing Frontend NPM dependencies...
cd frontend
call npm.cmd install --no-audit
cd ..

:: 4. Initialize Database
echo.
echo [*] Initializing database and security rules...
call "backend\venv\Scripts\python.exe" "backend\init_db_standalone.py"

echo.
echo ==============================================================================
echo [SUCCESS] SENTINEL AI Setup Completed!
echo You can now run "start_all.bat" to launch the platform.
echo ==============================================================================
pause
