@echo off
REM ==========================================
REM AUTO-START APP - NO USER INTERACTION NEEDED
REM ==========================================
cls
title NNG AGENT - AUTO-START BUILD
color 0B
echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║     NNG AGENT - AUTO-START BUILD                    ║
echo ║  App akan jalan OTOMATIS tanpa klik tombol apapun   ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
echo FITUR:
echo  ✓ Auto-launch saat device distart
echo  ✓ Tanpa perlu klik tombol launcher
echo  ✓ Auto-start service
echo.
pause

REM Kill processes
echo [1/6] Stopping all processes...
taskkill /F /IM dart.exe >nul 2>&1
taskkill /F /IM java.exe >nul 2>&1
timeout /t 1 >nul

REM Reset ADB
echo [2/6] Resetting ADB...
adb kill-server
timeout /t 2 >nul
adb start-server
timeout /t 2 >nul

REM Check device
echo [3/6] Checking device...
adb devices
echo.
echo Pastikan device terdeteksi sebagai "device"
echo Jika offline, unplug dan restart device
pause

REM Uninstall old
echo [4/6] Uninstalling old app...
adb uninstall com.example.nng_tiktok_live_agent >nul 2>&1
timeout /t 1 >nul

REM Go to project
echo [5/6] Building with auto-start support...
cd /d "E:\0flutter androidstudio\nng_tiktok_live_agent"
call flutter clean >nul 2>&1
call flutter pub get >nul 2>&1

REM Build and install
echo [6/6] Installing auto-start app...
call flutter run -d 2405CPCFBG --no-fast-start

echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║          AUTO-START APP INSTALLED!                  ║
echo ║                                                       ║
echo ║  ✓ App auto-launch saat device start                ║
echo ║  ✓ Nama: NNG AGENT by nayrbryanGaming             ║
echo ║  ✓ Logo: NNG.png                                   ║
echo ║  ✓ Tanpa perlu klik tombol!                        ║
echo ║                                                       ║
echo ║  TEST: Restart device (power off/on)               ║
echo ║  App akan otomatis launch! ✓                       ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
pause

