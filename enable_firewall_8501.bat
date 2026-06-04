@echo off
setlocal

echo [INFO] Creating Windows Firewall rule for TCP 8501...
netsh advfirewall firewall add rule name="KensaAnalysis8501" dir=in action=allow protocol=TCP localport=8501 >nul 2>&1
if errorlevel 1 (
  echo [WARN] Could not add firewall rule. Run this file as Administrator.
  exit /b 1
)

echo [INFO] Firewall rule created: KensaAnalysis8501
exit /b 0
