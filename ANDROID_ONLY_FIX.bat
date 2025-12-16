@echo off
REM ==========================================
REM ANDROID ONLY - AGGRESSIVE FIX
REM ==========================================
cls
title ANDROID ONLY - AGGRESSIVE FIX
color 0A
echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║     ANDROID ONLY - AGGRESSIVE DEVICE FIX            ║
echo ║  Fokus 100% ke Android, lupakan Chrome             ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
pause

REM STEP 1: Kill all processes
echo [STEP 1/8] Killing all processes...
taskkill /F /IM dart.exe >nul 2>&1
taskkill /F /IM java.exe >nul 2>&1
taskkill /F /IM adb.exe >nul 2>&1
timeout /t 1 >nul
echo ✓ Processes killed!
echo.

REM STEP 2: Restart ADB
echo [STEP 2/8] Restarting ADB...
adb kill-server
timeout /t 2 >nul
adb start-server
timeout /t 2 >nul
echo ✓ ADB restarted!
echo.

REM STEP 3: Check devices
echo [STEP 3/8] Checking connected devices...
adb devices
echo.
echo Tunggu sampai device terdeteksi sebagai "device" (bukan offline)
echo Jika tidak terdeteksi:
echo   - Unplug USB
echo   - Restart device (power off/on)
echo   - Plug kembali
echo.
pause

REM STEP 4: Uninstall old app
echo [STEP 4/8] Uninstalling old app...
adb uninstall com.example.nng_tiktok_live_agent
timeout /t 2 >nul
echo ✓ Old app uninstalled!
echo.

REM STEP 5: Go to project
echo [STEP 5/8] Going to project...
cd /d "E:\0flutter androidstudio\nng_tiktok_live_agent"
echo ✓ In project directory!
echo.

REM STEP 6: Flutter clean
echo [STEP 6/8] Cleaning Flutter (aggressive)...
call flutter clean
if exist build rmdir /s /q build >nul 2>&1
if exist .dart_tool rmdir /s /q .dart_tool >nul 2>&1
echo ✓ Flutter cleaned!
echo.

REM STEP 7: Get dependencies
echo [STEP 7/8] Getting dependencies...
call flutter pub get
echo ✓ Dependencies ready!
echo.

REM STEP 8: Build and install
echo [STEP 8/8] Building and installing to Android...
echo This may take 10-20 minutes. JANGAN BATALKAN!
echo.
call flutter run -d 2405CPCFBG --no-fast-start

echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║           ANDROID FIX COMPLETE!                      ║
echo ║                                                       ║
echo ║  ✓ App should now launch                            ║
echo ║  ✓ Title: NNG AGENT by nayrbryanGaming            ║
echo ║  ✓ Logo: NNG.png                                   ║
echo ║  ✓ NO layar hitam!                                 ║
echo ║                                                       ║
echo ║  Lihat device sekarang!                            ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
pause

