@echo off
REM ============================================================
REM  Mass-production Transfer Committee Portal - server launcher
REM  Double-click to start. Close this window to stop the server.
REM  No pip install needed: uses Python standard library only.
REM ============================================================
chcp 65001 >nul
cd /d "%~dp0"
title Transfer Portal Server (port 8000)

set "PY="
python --version >nul 2>nul && set "PY=python"
if not defined PY ( py -3 --version >nul 2>nul && set "PY=py -3" )
if not defined PY (
  echo [ERROR] Python 3 is not installed or not in PATH.
  echo         Install Python 3.8+ and check "Add python.exe to PATH".
  pause
  exit /b 1
)

echo [START] http://localhost:8000
start "" /b cmd /c "timeout /t 3 >nul & start http://localhost:8000"
%PY% app.py
echo.
echo [STOP] Server stopped.
pause
