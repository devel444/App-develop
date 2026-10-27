@echo off
REM ============================================================
REM  Mass-production Transfer Committee Portal - server launcher
REM  Double-click to start. Close this window to stop the server.
REM ============================================================
chcp 65001 >nul
cd /d "%~dp0"
title Transfer Portal Server (port 8000)

where python >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Python 3 is not installed or not in PATH.
  echo         Install Python 3.9+ and check "Add python.exe to PATH".
  pause
  exit /b 1
)

if not exist ".venv\Scripts\python.exe" (
  echo [SETUP] Creating virtual environment .venv ...
  python -m venv .venv
  if errorlevel 1 ( echo [ERROR] venv creation failed. & pause & exit /b 1 )
)

".venv\Scripts\python.exe" -c "import fastapi, uvicorn, multipart" >nul 2>nul
if errorlevel 1 (
  echo [SETUP] Installing packages ...
  if exist "wheels\" (
    echo         offline mode: installing from .\wheels
    ".venv\Scripts\python.exe" -m pip install --no-index --find-links wheels -r requirements.txt
  ) else (
    ".venv\Scripts\python.exe" -m pip install -r requirements.txt
  )
  if errorlevel 1 ( echo [ERROR] package install failed. See README.md offline install. & pause & exit /b 1 )
)

echo [START] http://localhost:8000
start "" /b cmd /c "timeout /t 3 >nul & start http://localhost:8000"
".venv\Scripts\python.exe" app.py
echo.
echo [STOP] Server stopped.
pause
