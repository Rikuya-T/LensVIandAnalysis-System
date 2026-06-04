@echo off
setlocal
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"
cd /d "%BASE_DIR%" || (
  echo [ERROR] Cannot change directory: %BASE_DIR%
  exit /b 1
)

set "VENV_PY=%BASE_DIR%\.venv\Scripts\python.exe"

if not exist ".venv" (
  echo [INFO] Creating virtual environment (.venv)...
  py -3.10 -m venv .venv 2>nul || python -m venv .venv
)

if not exist "%VENV_PY%" (
  echo [ERROR] Python in venv not found: %VENV_PY%
  exit /b 1
)

"%VENV_PY%" -m pip install --upgrade pip
"%VENV_PY%" -m pip install -r "%BASE_DIR%\requirements.txt"

echo [INFO] Starting LAN mode.
echo [INFO] Access from another PC: http://THIS_PC_IP:8501
"%VENV_PY%" -m streamlit run "%BASE_DIR%\app.py" --server.address 0.0.0.0 --server.port 8501 --server.headless true

endlocal
