@echo off
REM ==========================================
REM NNG AGENT - COMPLETE REBUILD & INSTALL
REM ==========================================
echo.
echo LANGKAH 1: Uninstall app lama...
adb uninstall com.example.nng_tiktok_live_agent
echo.

echo LANGKAH 2: Hapus semua cache...
cd /d "E:\0flutter androidstudio\nng_tiktok_live_agent"
call flutter clean
if exist build rmdir /s /q build
if exist .dart_tool rmdir /s /q .dart_tool
echo.

echo LANGKAH 3: Get dependencies fresh...
call flutter pub get
echo.

echo LANGKAH 4: Build & install ke device...
echo Tunggu... ini mungkin 5-10 menit...
call flutter run -d 22120RN86G --no-fast-start
echo.

echo ==========================================
echo SELESAI! App sudah install dengan branding baru!
echo ==========================================
pause

