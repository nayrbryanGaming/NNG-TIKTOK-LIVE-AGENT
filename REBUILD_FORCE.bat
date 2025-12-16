@echo off
echo.
echo =========================================
echo    AUTO-FIX - LOGO & SHUFFLE REBUILD
echo =========================================
echo.
echo [0] Deleting old main_new.dart...
if exist lib\main_new.dart del lib\main_new.dart
echo Deleted.

echo.
echo [1] Cleaning build cache...
call flutter clean
if errorlevel 1 goto flutter_error

echo.
echo [2] Getting dependencies...
call flutter pub get
if errorlevel 1 goto flutter_error

echo.
echo [3] Building and installing...
echo    (This will take 2-3 minutes)
echo.
call flutter run

echo.
echo =========================================
echo    BUILD COMPLETE!
echo    Logo NNG & Tombol Shuffle now visible!
echo =========================================
echo.
pause
exit /b 0

:flutter_error
echo.
echo ERROR: Flutter command failed!
echo Make sure Flutter is installed and in PATH
echo.
pause
exit /b 1

