@echo off
echo ========================================
echo    EMERGENCY FIX - APP STUCK 5 JAM
echo ========================================
echo.
echo [1] Stop app yang running...
echo.

taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM dart.exe 2>nul
timeout /t 2 >nul

echo [2] Cleaning build cache...
echo.

cd /d "E:\0flutter androidstudio\nng_tiktok_live_agent"
call flutter clean

echo.
echo [3] Getting dependencies...
echo.

call flutter pub get

echo.
echo [4] Launching app with FIX...
echo.
echo ========================================
echo   TUNGGU 10 DETIK SETELAH LOADING
echo   TOMBOL "Skip & Continue" AKAN MUNCUL
echo   KLIK TOMBOL ITU!
echo ========================================
echo.

call flutter run

pause

