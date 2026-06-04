@echo off
setlocal

echo [INFO] Stopping cloudflared tunnel...
taskkill /IM cloudflared.exe /F >nul 2>&1
if %errorlevel% EQU 0 (
  echo [INFO] cloudflared tunnel stopped.
) else (
  echo [WARN] cloudflared process was not running.
)

echo [INFO] If needed, stop app server manually by closing its window/process.
exit /b 0
