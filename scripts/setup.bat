@echo off
setlocal

if "%~1"=="" goto usage
set "PROFILE=%~2"
if "%PROFILE%"=="" set "PROFILE=balanced"

if /I "%~3"=="--profile-only" (
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" -TargetRepository "%~1" -Profile "%PROFILE%" -ProfileOnly
) else (
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" -TargetRepository "%~1" -Profile "%PROFILE%"
)
exit /b %ERRORLEVEL%

:usage
echo Usage: setup.bat ^<target-repository^> [balanced^|quality^|economy] [--profile-only]
exit /b 2
