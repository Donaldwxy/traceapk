#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Automatic Versioning ---

# Use the total number of commits as the build number. 
# This is a common practice for CI/CD to ensure the build number is always incremental.
BUILD_NUMBER=$(git rev-list --count HEAD)

# Get the build name (e.g., 1.0.2) from pubspec.yaml
BUILD_NAME=$(grep 'version:' pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)


echo "-------------------------------------"
echo "Building version: ${BUILD_NAME}+${BUILD_NUMBER}"
echo "-------------------------------------"

# Update pubspec.yaml to reflect the new build number for consistency
echo "Updating pubspec.yaml to version ${BUILD_NAME}+${BUILD_NUMBER}"
sed -i "s/version: .*/version: ${BUILD_NAME}+${BUILD_NUMBER}/" pubspec.yaml

# --- Build Process ---

# Run the flutter build command, injecting the determined build number.
flutter build apk --build-name=${BUILD_NAME} --build-number=${BUILD_NUMBER}


echo "-------------------------------------"
echo "Build successful!"
echo "APK located at: build/app/outputs/flutter-apk/app-release.apk"
echo "Version: ${BUILD_NAME}+${BUILD_NUMBER}"
echo "-------------------------------------"

