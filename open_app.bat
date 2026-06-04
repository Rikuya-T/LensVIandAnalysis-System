@echo off
setlocal
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"
cd /d "%BASE_DIR%" || (
  echo [ERROR] Cannot change directory: %BASE_DIR%
  exit /b 1
)

set "URL=http://localhost:8501"
set "WAIT_SECONDS=240"
set /a MAX_TRIES=%WAIT_SECONDS%/2

echo [INFO] Checking server status...
netstat -ano | findstr ":8501" | findstr "LISTENING" >nul
if %errorlevel%==0 (
  echo [INFO] Server is already running. Opening browser...
  start "" "%URL%"
  exit /b 0
)

echo [INFO] Server is not running. Starting in background...
start "" /min "%BASE_DIR%\start_server.bat"

echo [INFO] Waiting for server startup (max %WAIT_SECONDS% sec)...
set /a COUNT=0
:wait_loop
netstat -ano | findstr ":8501" | findstr "LISTENING" >nul
if %errorlevel%==0 goto open_browser
set /a COUNT+=1
if %COUNT% GEQ %MAX_TRIES% goto timeout

timeout /t 2 /nobreak >nul
goto wait_loop

:open_browser
echo [INFO] Opening browser: %URL%
start "" "%URL%" || powershell -NoProfile -Command "Start-Process '%URL%'"
exit /b 0

:timeout
echo [WARN] Startup confirmation timed out.
echo [INFO] Opening browser anyway: %URL%
start "" "%URL%"
echo [WARN] If page does not load, keep waiting or run start_server.bat directly.
echo [INFO] Check log: %BASE_DIR%\logs\start_server.log
exit /b 0
