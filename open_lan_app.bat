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

echo [INFO] Checking LAN server status...
netstat -ano | findstr ":8501" | findstr "LISTENING" >nul
if %errorlevel%==0 (
  echo [INFO] Server is already running.
  goto open_browser
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
start "" "%URL%"

echo [INFO] Access from another account/PC with:
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /R /C:"IPv4 Address" /C:"IPv4.*"') do (
  set "IP=%%A"
  call :print_ip
)
exit /b 0

:print_ip
set "IP=%IP: =%"
if not "%IP%"=="" echo        http://%IP%:8501
exit /b 0

:timeout
echo [WARN] Startup confirmation timed out.
echo [INFO] Try browser manually: %URL%
echo [INFO] Check log: %BASE_DIR%\logs\start_server.log
start "" "%URL%"
exit /b 0
