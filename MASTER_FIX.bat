@echo off
REM ==========================================
REM MASTER FIX SCRIPT - FINAL SOLUTION
REM ==========================================
cls
echo.
echo ╔════════════════════════════════════════╗
echo ║  NNG AGENT - MASTER FIX SCRIPT        ║
echo ║  Fixing Cache + Device Issues         ║
echo ╚════════════════════════════════════════╝
echo.

REM STEP 1: Kill Chrome completely
echo STEP 1: Closing Chrome completely...
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 1 >nul

REM STEP 2: Clear Chrome cache from command line
echo STEP 2: Clearing Chrome user data...
set CHROME_DATA=%LOCALAPPDATA%\Google\Chrome\User Data
rmdir /s /q "%CHROME_DATA%\Default\Cache" >nul 2>&1
rmdir /s /q "%CHROME_DATA%\Default\Code Cache" >nul 2>&1
echo ✓ Chrome cache cleared!
echo.

REM STEP 3: Kill Flutter and ADB
echo STEP 3: Stopping Flutter and ADB...
taskkill /F /IM dart.exe >nul 2>&1
taskkill /F /IM java.exe >nul 2>&1
timeout /t 1 >nul
echo ✓ Flutter stopped!
echo.

REM STEP 4: Reset ADB connection
echo STEP 4: Resetting ADB connection...
adb kill-server
timeout /t 2 >nul
adb start-server
timeout /t 2 >nul
adb devices
echo ✓ ADB restarted!
echo.

REM STEP 5: Clean Flutter project
echo STEP 5: Cleaning Flutter project...
cd /d "E:\0flutter androidstudio\nng_tiktok_live_agent"
call flutter clean >nul 2>&1
if exist build rmdir /s /q build >nul 2>&1
if exist .dart_tool rmdir /s /q .dart_tool >nul 2>&1
echo ✓ Flutter cleaned!
echo.

REM STEP 6: Get fresh dependencies
echo STEP 6: Getting fresh dependencies...
call flutter pub get
echo ✓ Dependencies updated!
echo.

REM STEP 7: Uninstall old app
echo STEP 7: Uninstalling old app from device...
adb uninstall com.example.nng_tiktok_live_agent >nul 2>&1
timeout /t 1 >nul
echo ✓ Old app uninstalled!
echo.

REM STEP 8: Build and install new app
echo STEP 8: Building and installing new app...
echo This may take 10-15 minutes...
echo.
call flutter run -d 2405CPCFBG --no-fast-start

echo.
echo ╔════════════════════════════════════════╗
echo ║  ✓ MASTER FIX COMPLETE!               ║
echo ║                                        ║
echo ║  ✓ Chrome cache cleared               ║
echo ║  ✓ Android app reinstalled            ║
echo ║  ✓ Branding: NNG AGENT               ║
echo ║  ✓ Logo: NNG.png                     ║
echo ║                                        ║
echo ║  Check your device now!              ║
echo ╚════════════════════════════════════════╝
echo.
pause

