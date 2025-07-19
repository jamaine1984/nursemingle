@echo off
echo Building release APK...
flutter clean
flutter pub get
flutter build apk --release

if %errorlevel% equ 0 (
    echo Build successful! Moving APK to Downloads...
    copy "build\app\outputs\flutter-apk\app-release.apk" "%USERPROFILE%\Downloads\nurse-mingle-release.apk"
    if %errorlevel% equ 0 (
        echo APK moved to Downloads folder successfully!
        echo Installing APK...
        adb install -r "%USERPROFILE%\Downloads\nurse-mingle-release.apk"
    ) else (
        echo Failed to move APK
    )
) else (
    echo Build failed!
)
pause 