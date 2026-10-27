@echo off
REM ============================================================
REM  Mass-production Transfer Committee Portal - server launcher
REM  Double-click to start. Close this window to stop the server.
REM  No pip install needed: uses Python standard library only.
REM ============================================================
chcp 65001 >nul
cd /d "%~dp0"
title Transfer Portal Server

set "PY="
python --version >nul 2>nul && set "PY=python"
if not defined PY ( py -3 --version >nul 2>nul && set "PY=py -3" )
if not defined PY (
  echo [ERROR] Python 3 is not installed or not in PATH.
  echo         Install Python 3.8+ and check "Add python.exe to PATH".
  pause
  exit /b 1
)

REM Port: change 8000 below if needed (80 = no port number in the address)
if not defined PORTAL_PORT set "PORTAL_PORT=8000"
net session >nul 2>nul
if not errorlevel 1 (
  echo [INFO] Running with administrator rights. Outlook mail will use a normal-rights helper automatically.
  echo.
)
echo [START] http://localhost:%PORTAL_PORT%
start "" /b cmd /c "timeout /t 3 >nul & start http://localhost:%PORTAL_PORT%"
%PY% app.py
echo.
echo [STOP] Server stopped.
pause
