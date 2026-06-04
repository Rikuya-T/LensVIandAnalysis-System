@echo off
setlocal
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"

set "TARGET=%BASE_DIR%\open_lan_app.bat"
set "SHORTCUT_NAME=KensaAnalysis-LAN.lnk"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$desktop=[Environment]::GetFolderPath('Desktop');" ^
  "$linkPath=Join-Path $desktop '%SHORTCUT_NAME%';" ^
  "$w=New-Object -ComObject WScript.Shell;" ^
  "$s=$w.CreateShortcut($linkPath);" ^
  "$s.TargetPath='%TARGET%';" ^
  "$s.WorkingDirectory='%BASE_DIR%';" ^
  "$s.IconLocation='%SystemRoot%\System32\SHELL32.dll,220';" ^
  "$s.Description='Launch Kensa Analysis LAN';" ^
  "$s.Save();"

if errorlevel 1 (
  echo [ERROR] Failed to create desktop shortcut.
  exit /b 1
)

echo [INFO] Desktop shortcut created: %SHORTCUT_NAME%
exit /b 0
