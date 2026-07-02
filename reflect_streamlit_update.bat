@echo off
setlocal
cd /d %~dp0

set /p COMMIT_MSG=コミットメッセージを入力してください: 
if "%COMMIT_MSG%"=="" set "COMMIT_MSG=Streamlit app update"

git add app.py README.md .gitignore requirements.txt
if exist logs\start_server.log git reset logs\start_server.log >nul 2>&1

git commit -m "%COMMIT_MSG%"
if errorlevel 1 (
  echo [INFO] コミット対象がないか、コミットに失敗しました。
  exit /b 1
)

git pull --rebase origin main
if errorlevel 1 (
  echo [ERROR] リモート取り込みに失敗しました。競合を確認してください。
  exit /b 1
)

git push origin main
if errorlevel 1 (
  echo [ERROR] Pushに失敗しました。
  exit /b 1
)

echo [INFO] 更新をGitHubへ反映しました。
echo [INFO] Streamlit Cloud 側は通常1〜2分で自動反映されます。
exit /b 0
