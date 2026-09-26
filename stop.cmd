@echo off
rem Stops the Dynamic Island (and its native bridge helper).
setlocal
echo Stopping Dynamic Island...
taskkill /f /im electron.exe >nul 2>&1
taskkill /f /im IslandBridge.exe >nul 2>&1
echo Done.
timeout /t 2 >nul
exit /b 0
