@echo off
setlocal
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"
cd /d "%BASE_DIR%" || (
  echo [ERROR] Cannot change directory: %BASE_DIR%
  exit /b 1
)

set "APP_PATH=%BASE_DIR%\app.py"
set "STREAMLIT_ARGS=run \"%APP_PATH%\" --server.headless true --server.address 0.0.0.0 --server.port 8501"
set "LOG_DIR=%BASE_DIR%\logs"
set "LOG_FILE=%LOG_DIR%\run_local.log"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo [INFO] Starting app: http://localhost:8501 > "%LOG_FILE%"
echo [INFO] %DATE% %TIME% >> "%LOG_FILE%"

if exist "%BASE_DIR%\.venv\Scripts\python.exe" (
  echo [INFO] Try .venv Python... >> "%LOG_FILE%"
  "%BASE_DIR%\.venv\Scripts\python.exe" -m streamlit %STREAMLIT_ARGS% >> "%LOG_FILE%" 2>&1
  if %ERRORLEVEL% EQU 0 exit /b 0
)

echo [INFO] Try py launcher... >> "%LOG_FILE%"
py -3 -m streamlit %STREAMLIT_ARGS% >> "%LOG_FILE%" 2>&1
if %ERRORLEVEL% EQU 0 exit /b 0

echo [INFO] Try python command... >> "%LOG_FILE%"
python -m streamlit %STREAMLIT_ARGS% >> "%LOG_FILE%" 2>&1
if %ERRORLEVEL% EQU 0 exit /b 0

echo [ERROR] Failed to start Streamlit. >> "%LOG_FILE%"
echo [ERROR] Please install dependencies with: pip install -r requirements.txt >> "%LOG_FILE%"
exit /b 1

endlocal
