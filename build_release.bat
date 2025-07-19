@echo off
title Nurse Mingle APK Builder
color 0A

echo ========================================
echo    NURSE MINGLE APK BUILDER
echo ========================================
echo.

echo [1/6] Cleaning project...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b 1
)

echo [2/6] Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Pub get failed!
    pause
    exit /b 1
)

echo [3/6] Cleaning Android...
cd android
call gradlew clean
cd ..
if %errorlevel% neq 0 (
    echo ERROR: Gradle clean failed!
    pause
    exit /b 1
)

echo [4/6] Building APK (this may take a while)...
flutter build apk --release --no-shrink
if %errorlevel% neq 0 (
    echo ERROR: APK build failed!
    echo.
    echo Common fixes:
    echo - Check if you have enough disk space
    echo - Try: flutter doctor
    echo - Check Android SDK is properly installed
    pause
    exit /b 1
)

echo [5/6] Moving APK to Downloads...
if not exist "%USERPROFILE%\Downloads" (
    echo ERROR: Downloads folder not found!
    pause
    exit /b 1
)

copy "build\app\outputs\flutter-apk\app-release.apk" "%USERPROFILE%\Downloads\nurse-mingle-v%date:~-4,4%%date:~-10,2%%date:~-7,2%.apk"
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy APK!
    pause
    exit /b 1
)

echo [6/6] Installing APK...
adb install -r "%USERPROFILE%\Downloads\nurse-mingle-v%date:~-4,4%%date:~-10,2%%date:~-7,2%.apk"

echo.
echo ========================================
echo     BUILD SUCCESSFUL!
echo ========================================
echo APK Location: %USERPROFILE%\Downloads\
echo File: nurse-mingle-v%date:~-4,4%%date:~-10,2%%date:~-7,2%.apk
echo ========================================
pause 