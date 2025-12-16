@echo off
REM ==========================================
REM NUCLEAR OPTION - COMPLETE SYSTEM RESET
REM ==========================================
cls
title NNG AGENT - NUCLEAR RESET
color 0A
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║         🔥 NNG AGENT - NUCLEAR RESET 🔥                 ║
echo ║  Ini akan COMPLETE membersihkan semua cache dan rebuild!  ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
pause

REM Kill everything
echo [1/10] Killing all processes...
taskkill /F /IM chrome.exe >nul 2>&1
taskkill /F /IM chromium.exe >nul 2>&1
taskkill /F /IM dart.exe >nul 2>&1
taskkill /F /IM java.exe >nul 2>&1
taskkill /F /IM flutter.bat >nul 2>&1
timeout /t 2 >nul

REM Nuclear Chrome cache delete
echo [2/10] Nuking Chrome cache completely...
set CHROME=%LOCALAPPDATA%\Google\Chrome
rmdir /s /q "%CHROME%\User Data\Default\Cache" >nul 2>&1
rmdir /s /q "%CHROME%\User Data\Default\Code Cache" >nul 2>&1
rmdir /s /q "%CHROME%\User Data\Default\Service Worker\Database" >nul 2>&1
rmdir /s /q "%CHROME%\User Data\Default\Local Storage" >nul 2>&1
del /f /q "%CHROME%\User Data\Default\Cookies" >nul 2>&1
del /f /q "%CHROME%\User Data\Default\Cookies-journal" >nul 2>&1
echo ✓ Chrome nuclear cleaned!

REM Reset ADB
echo [3/10] Resetting ADB...
adb kill-server
timeout /t 2 >nul
adb start-server
timeout /t 2 >nul

REM Uninstall app
echo [4/10] Uninstalling old app...
adb uninstall com.example.nng_tiktok_live_agent >nul 2>&1
timeout /t 1 >nul

REM Go to project
echo [5/10] Going to project directory...
cd /d "E:\0flutter androidstudio\nng_tiktok_live_agent"

REM Nuclear Flutter clean
echo [6/10] Nuclear Flutter clean...
call flutter clean >nul 2>&1
if exist build rmdir /s /q build >nul 2>&1
if exist .dart_tool rmdir /s /q .dart_tool >nul 2>&1
if exist windows\flutter\ephemeral rmdir /s /q windows\flutter\ephemeral >nul 2>&1
if exist ios\Flutter\Flutter.framework rmdir /s /q ios\Flutter\Flutter.framework >nul 2>&1
echo ✓ Flutter nuclear cleaned!

REM Fresh pub get
echo [7/10] Fresh pub get...
call flutter pub get

REM List devices
echo [8/10] Checking devices...
adb devices
echo.

REM Final build and run
echo [9/10] Building fresh APK...
call flutter build apk --debug --no-fast-start

echo [10/10] Installing to device...
call flutter run -d 2405CPCFBG --no-fast-start

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║             ✓ NUCLEAR RESET COMPLETE!                    ║
echo ║                                                            ║
echo ║  ✓ Chrome: COMPLETELY NUKED                             ║
echo ║  ✓ Flutter: COMPLETELY REBUILT                          ║
echo ║  ✓ Device: FRESH APP INSTALLED                          ║
echo ║                                                            ║
echo ║  Check device for:                                        ║
echo ║  - NNG AGENT branding                                    ║
echo ║  - NNG.png logo                                          ║
echo ║  - NO "LoopCaster"                                       ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
pause

