@echo off
setlocal
set "TASK_NAME=KensaAnalysisServer"

echo [INFO] Removing startup task: %TASK_NAME%
schtasks /Delete /TN "%TASK_NAME%" /F >nul 2>&1
if errorlevel 1 (
  echo [WARN] Task not found or no permission.
  exit /b 1
)

echo [INFO] Startup task removed.
exit /b 0
