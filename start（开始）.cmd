@echo off
rem ============================================================
rem  Dynamic Island for Windows  -  launcher
rem  Just double-click this file.
rem ============================================================
setlocal enabledelayedexpansion
cd /d "%~dp0"

rem %~dp0 ends with a backslash; strip it so Electron gets a clean path.
set "APPDIR=%~dp0"
if "%APPDIR:~-1%"=="\" set "APPDIR=%APPDIR:~0,-1%"

set "ELECTRON=%APPDIR%\node_modules\electron\dist\electron.exe"

if not exist "%ELECTRON%" (
  echo [!] Electron is not installed yet. Running "npm install"...
  call npm install || goto :fail
)

if not exist "%APPDIR%\resources\bridge\IslandBridge.exe" (
  echo [*] Building the native system bridge ^(needs the .NET 10 SDK^)...
  call npm run native:build || goto :fail
)

if not exist "%APPDIR%\out\main\index.js" (
  echo [*] Building the app...
  call npm run build || goto :fail
)

rem The app is single-instance: launching twice just exits the second copy.
tasklist /fi "imagename eq electron.exe" 2>nul | find /i "electron.exe" >nul
if not errorlevel 1 (
  echo [i] Dynamic Island is already running - look at the top centre of your screen.
  timeout /t 2 >nul
  exit /b 0
)

echo [*] Starting Dynamic Island...
start "" "%ELECTRON%" "%APPDIR%"
exit /b 0

:fail
echo.
echo [X] Something went wrong. Run these by hand to see the error:
echo       npm install
echo       npm run app
echo.
pause
exit /b 1
