@echo off
setlocal EnableDelayedExpansion
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"
cd /d "%BASE_DIR%" || (
  echo [ERROR] Cannot change directory: %BASE_DIR%
  exit /b 1
)

set "LOG_DIR=%BASE_DIR%\logs"
set "CF_LOG=%LOG_DIR%\cloudflared.log"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
if exist "%CF_LOG%" del /q "%CF_LOG%" >nul 2>&1

echo [INFO] Checking app server status on port 8501...
netstat -ano | findstr ":8501" | findstr "LISTENING" >nul
if %errorlevel% NEQ 0 (
  echo [INFO] App server is not running. Starting in background...
  start "" /min "%BASE_DIR%\start_server.bat"
)

echo [INFO] Checking cloudflared command...
where cloudflared >nul 2>&1
if %errorlevel% NEQ 0 (
  echo [INFO] cloudflared not found. Trying to install with winget...
  winget install --id Cloudflare.cloudflared -e --accept-package-agreements --accept-source-agreements
  where cloudflared >nul 2>&1
  if %errorlevel% NEQ 0 (
    echo [ERROR] cloudflared install failed.
    echo [INFO] Install manually from:
    echo        https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/
    exit /b 1
  )
)

echo [INFO] Starting public tunnel...
start "" /min cmd /c "cloudflared tunnel --url http://localhost:8501 --no-autoupdate --logfile \"%CF_LOG%\""

echo [INFO] Waiting for public URL (max 120 sec)...
set "PUBLIC_URL="
for /L %%i in (1,1,60) do (
  for /f "usebackq delims=" %%u in (`powershell -NoProfile -Command "$p='%CF_LOG%'; if(Test-Path $p){$m=Select-String -Path $p -Pattern 'https://[-a-z0-9]+\.trycloudflare\.com' | Select-Object -Last 1; if($m){$m.Matches[0].Value}}"`) do (
    set "PUBLIC_URL=%%u"
  )
  if defined PUBLIC_URL goto :found
  timeout /t 2 /nobreak >nul
)

echo [WARN] Could not detect public URL yet.
echo [INFO] Check log file: %CF_LOG%
echo [INFO] Tunnel may still be starting.
exit /b 1

:found
echo [INFO] Public URL is ready:
echo        !PUBLIC_URL!
echo [INFO] Anyone with this URL can access the app while this PC is running.
start "" "!PUBLIC_URL!"
exit /b 0
