@echo off
setlocal
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"
set "TASK_NAME=KensaAnalysisServer"
set "TASK_CMD=%BASE_DIR%\start_server.bat"

echo [INFO] Registering startup task: %TASK_NAME%
schtasks /Create /TN "%TASK_NAME%" /SC ONSTART /RU SYSTEM /RL HIGHEST /TR "\"%TASK_CMD%\"" /F >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Failed to register startup task.
  echo [INFO] Run this file as Administrator.
  exit /b 1
)

echo [INFO] Startup task registered successfully.
echo [INFO] Reboot PC or run manually with: schtasks /Run /TN "%TASK_NAME%"
exit /b 0
