@echo off
REM ==========================================
REM FINAL SOLUTION - INCOGNITO + FRESH INSTALL
REM ==========================================
cls
title FINAL SOLUTION
color 0C
echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║         FINAL SOLUTION - INCOGNITO + FRESH           ║
echo ║    Browser tanpa cache + Android fresh install       ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
echo ACTION 1: Buka Chrome INCOGNITO (no cache)
echo.
echo Tekan ENTER untuk lanjut...
pause

REM Kill Chrome
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 1 >nul

REM Open Chrome in Incognito mode
echo.
echo Membuka Chrome Incognito Mode...
start chrome.exe --incognito http://localhost:55207
echo ✓ Chrome Incognito dibuka!
echo.
echo ========================================================
echo IMPORTANT: Di browser Incognito, Anda akan melihat:
echo   ✓ Browser tab: NNG AGENT by nayrbryanGaming
echo   ✓ Logo: NNG.png
echo   ✓ Title: NNG AGENT / by nayrbryanGaming
echo   ✓ NO "LoopCaster" anymore!
echo ========================================================
echo.
pause

REM ACTION 2: Android Fresh Install
echo.
echo ACTION 2: Android Fresh Install
echo.
echo Uninstalling old app...
adb uninstall com.example.nng_tiktok_live_agent

echo.
echo Restarting ADB...
adb kill-server
timeout /t 2 >nul
adb start-server
timeout /t 2 >nul

echo.
echo Fresh build and install...
cd /d "E:\0flutter androidstudio\nng_tiktok_live_agent"
call flutter clean
call flutter pub get
call flutter run -d 2405CPCFBG --no-fast-start

echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║           FINAL SOLUTION COMPLETE!                  ║
echo ║                                                       ║
echo ║  ✓ Browser Incognito: NO CACHE                      ║
echo ║  ✓ Android: Fresh install                           ║
echo ║  ✓ Branding: NNG AGENT by nayrbryanGaming          ║
echo ║  ✓ Logo: NNG.png everywhere                         ║
echo ║                                                       ║
echo ║  Check both browser dan device sekarang!            ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
pause

