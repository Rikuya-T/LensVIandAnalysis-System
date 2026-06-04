@echo off
setlocal
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"
cd /d "%BASE_DIR%" || exit /b 1

set /p "COMMIT_MSG=Commit message (default='Update'): "
if "%COMMIT_MSG%"=="" set "COMMIT_MSG=Update"

echo [INFO] Checking Git status...
git status >nul 2>&1
if %errorlevel% NEQ 0 (
  echo [ERROR] Not a git repository.
  echo [INFO] Run 'git init' first.
  exit /b 1
)

echo [INFO] Staging changes...
git add .

echo [INFO] Committing: %COMMIT_MSG%
git commit -m "%COMMIT_MSG%"
if %errorlevel% NEQ 0 (
  echo [WARN] Nothing to commit or commit failed.
  exit /b 1
)

echo [INFO] Pushing to GitHub...
git push origin main
if %errorlevel% EQU 0 (
  echo [INFO] Push successful. Streamlit Cloud will auto-redeploy.
  exit /b 0
) else (
  echo [ERROR] Push failed. Check your GitHub credentials.
  exit /b 1
)
