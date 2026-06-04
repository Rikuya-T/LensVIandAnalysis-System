@echo off
setlocal
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"
cd /d "%BASE_DIR%" || exit /b 1

echo [INFO] GitHub Repository Initialization Guide
echo.
echo 1. Create repository at https://github.com/new
echo 2. Copy the repository URL (https://github.com/YOUR_USERNAME/REPO_NAME.git)
echo.
set /p "REPO_URL=Enter repository URL: "

if "%REPO_URL%"=="" (
  echo [ERROR] Repository URL cannot be empty.
  exit /b 1
)

echo [INFO] Initializing local git repository...
git init
git add .
git commit -m "Initial commit"
git branch -M main

echo [INFO] Adding remote origin...
git remote add origin %REPO_URL%

echo [INFO] Pushing to GitHub...
git push -u origin main

if %errorlevel% EQU 0 (
  echo [INFO] Repository setup complete.
  echo [INFO] Repository: %REPO_URL%
  echo [INFO] Next: Deploy on Streamlit Cloud at https://streamlit.io/cloud
  exit /b 0
) else (
  echo [ERROR] Push failed. Check your repository URL and GitHub credentials.
  exit /b 1
)
