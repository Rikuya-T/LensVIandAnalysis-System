@echo off
setlocal
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"
cd /d "%BASE_DIR%" || exit /b 1

echo [INFO] Git Configuration Guide
echo.
echo This will configure git with your name and email.
echo.
set /p "GIT_USER=Enter your full name: "
set /p "GIT_EMAIL=Enter your email address: "

git config --global user.name "%GIT_USER%"
git config --global user.email "%GIT_EMAIL%"

if %errorlevel% EQU 0 (
  echo [INFO] Git configured successfully.
  echo [INFO] Name: %GIT_USER%
  echo [INFO] Email: %GIT_EMAIL%
  exit /b 0
) else (
  echo [ERROR] Git configuration failed.
  exit /b 1
)
