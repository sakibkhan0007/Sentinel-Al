@echo off
setlocal
cd /d "%~dp0frontend"
title SENTINEL AI - Frontend Dashboard (Port 3000)

echo ==============================================================================
echo [SENTINEL AI] Starting Next.js Command Center on http://localhost:3000
echo ==============================================================================

call npm.cmd run dev
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to start frontend dev server.
    pause
)
