@echo off
echo ========================================
echo NNG AGENT - REBUILD SCRIPT
echo ========================================
echo.
echo Membersihkan build cache...
call flutter clean
echo.
echo Mengambil dependencies...
call flutter pub get
echo.
echo Generating launcher icons baru dari NNG.png...
call dart run flutter_launcher_icons
echo.
echo ========================================
echo SELESAI! Siap di-run!
echo ========================================
echo.
echo Pilih platform:
echo 1. Web (Chrome)
echo 2. Android Emulator
echo 3. Exit
echo.
set /p choice="Pilih (1/2/3): "

if "%choice%"=="1" (
    echo.
    echo Starting di Chrome...
    echo Setelah terbuka, tekan Ctrl+Shift+R di browser!
    echo.
    call flutter run -d chrome
)

if "%choice%"=="2" (
    echo.
    echo Starting di Android Emulator...
    echo.
    call flutter run -d emulator-5554
)

if "%choice%"=="3" (
    echo.
    echo Manual run:
    echo   flutter run -d chrome
    echo   flutter run -d emulator-5554
    echo.
    pause
)

