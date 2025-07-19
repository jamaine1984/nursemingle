$source = "build/app/outputs/flutter-apk/app-prod-release.apk"
$destination = "$env:USERPROFILE\Downloads\app-release.apk"

if (Test-Path $source) {
    Move-Item -Force -Path $source -Destination $destination
    Write-Host "APK moved to $destination"
} else {
    Write-Host "APK not found at $source"
} 