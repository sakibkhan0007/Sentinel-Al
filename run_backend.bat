@echo off
setlocal
cd /d "%~dp0backend"
title SENTINEL AI - Backend Server (Port 8000)

echo ==============================================================================
echo [SENTINEL AI] Starting FastAPI Core Engine on http://127.0.0.1:8000
echo ==============================================================================

if exist "venv\Scripts\python.exe" (
    ".\venv\Scripts\python.exe" -m uvicorn main:app --host 127.0.0.1 --port 8000 --reload
) else (
    echo [ERROR] Virtual environment not found at backend\venv!
    pause
)
