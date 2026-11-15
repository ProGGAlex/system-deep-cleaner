@echo off
chcp 65001 > nul

net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo =======================================================
echo         System Temp Files ^& Deep Cleaner
echo =======================================================
echo.
echo Press ANY key to start cleaning...
echo =======================================================
pause > nul

cls
echo =======================================================
echo             Cleaning started, please wait...
echo =======================================================
echo.

for /f "usebackq" %%i in (`powershell -NoProfile -Command "(Get-ChildItem '%TEMP%', 'C:\Windows\Temp', 'C:\Windows\Prefetch', 'C:\$Recycle.Bin', '$LOCALAPPDATA\D3DSCache', 'C:\Windows\SoftwareDistribution\Download' -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum"`) do set "sizeBefore=%%i"

echo [1/7] Cleaning User TEMP folder...
del /q /f /s "%TEMP%\*" 2>nul
for /d %%i in ("%TEMP%\*") do rmdir /q /s "%%i" 2>nul

echo [2/7] Cleaning System Temp folder...
del /q /f /s "C:\Windows\Temp\*" 2>nul
for /d %%i in ("C:\Windows\Temp\*") do rmdir /q /s "%%i" 2>nul

echo [3/7] Cleaning Windows Prefetch...
del /q /f /s "C:\Windows\Prefetch\*" 2>nul
for /d %%i in ("C:\Windows\Prefetch\*") do rmdir /q /s "%%i" 2>nul

echo [4/7] Cleaning DirectX Shader Cache...
del /q /f /s "%LOCALAPPDATA%\D3DSCache\*" 2>nul
for /d %%i in ("%LOCALAPPDATA%\D3DSCache\*") do rmdir /q /s "%%i" 2>nul

echo [5/7] Cleaning Windows Update Downloads...
net stop wuauserv >nul 2>&1
del /q /f /s "C:\Windows\SoftwareDistribution\Download\*" 2>nul
for /d %%i in ("C:\Windows\SoftwareDistribution\Download\*") do rmdir /q /s "%%i" 2>nul
net start wuauserv >nul 2>&1

echo [6/7] Running Windows Cleanmgr...
cleanmgr /sagerun:1 >nul 2>&1

echo [7/7] Emptying Recycle Bin...
powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" 2>nul

for /f "usebackq" %%i in (`powershell -NoProfile -Command "(Get-ChildItem '%TEMP%', 'C:\Windows\Temp', 'C:\Windows\Prefetch', 'C:\$Recycle.Bin', '$LOCALAPPDATA\D3DSCache', 'C:\Windows\SoftwareDistribution\Download' -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum"`) do set "sizeAfter=%%i"

if "%sizeBefore%"=="" set sizeBefore=0
if "%sizeAfter%"=="" set sizeAfter=0

cls
powershell -NoProfile -Command "$b = [int64]%sizeBefore%; $a = [int64]%sizeAfter%; $diff = [Math]::Max(0, $b - $a); $mb = [Math]::Round($diff / 1MB, 2); Write-Host '======================================================='; Write-Host ('Successfully freed up: ' + $mb + ' MB of total junk!'); Write-Host '======================================================= '"

echo.
echo Cleaning complete. Press any key to exit...
pause > nul