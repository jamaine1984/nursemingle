# === Nurse Mingle Automated Build Script ===
$PROJECT_DIR = "C:\Users\mattr\Downloads\nursemingle"
$ZIP_OUTPUT = "C:\APK-Files\nursemingle.zip"
$DEST_ZIP_FOLDER = "C:\APK-Files"

# Ensure destination folder exists
New-Item -ItemType Directory -Force -Path $DEST_ZIP_FOLDER

# Change to project directory
cd $PROJECT_DIR

# Run Flutter commands
echo "Running flutter pub get..."
flutter pub get

echo "Running flutter clean..."
flutter clean

echo "Building APK..."
flutter build apk

# Zip the project
Compress-Archive -Path "$PROJECT_DIR\*" -DestinationPath $ZIP_OUTPUT -Force

echo "✅ DONE! APK located at: $PROJECT_DIR\build\app\outputs\flutter-apk\app-release.apk"
echo "✅ Project zipped at: $ZIP_OUTPUT" 