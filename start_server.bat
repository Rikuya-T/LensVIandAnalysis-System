@echo off
setlocal
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"
cd /d "%BASE_DIR%" || exit /b 1

set "LOG_DIR=%BASE_DIR%\logs"
set "LOG_FILE=%LOG_DIR%\start_server.log"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo [INFO] %DATE% %TIME% Starting app.py > "%LOG_FILE%"

if exist "%BASE_DIR%\.venv\Scripts\python.exe" (
  "%BASE_DIR%\.venv\Scripts\python.exe" "%BASE_DIR%\app.py" >> "%LOG_FILE%" 2>&1
  exit /b %ERRORLEVEL%
)

py -3 "%BASE_DIR%\app.py" >> "%LOG_FILE%" 2>&1
if %ERRORLEVEL% EQU 0 exit /b 0

python "%BASE_DIR%\app.py" >> "%LOG_FILE%" 2>&1
exit /b %ERRORLEVEL%
