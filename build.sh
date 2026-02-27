#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Automatic Versioning V2 ---
# This script implements a versioning strategy where the user-visible version name
# directly reflects the build number, which is based on the total git commit count.

# 1. Define the major.minor version prefix. 
#    e.g., Extracts "1.0" from a full version string like "1.0.2+12"
VERSION_PREFIX=$(grep 'version:' pubspec.yaml | cut -d ' ' -f 2 | cut -d '.' -f 1,2)

# 2. Use the total number of commits as the patch number AND the internal build number.
COMMIT_COUNT=$(git rev-list --count HEAD)

# 3. Construct the new, user-visible version name (e.g., "1.0.12").
NEW_VERSION_NAME="${VERSION_PREFIX}.${COMMIT_COUNT}"
#    The internal build number is also the commit count.
NEW_BUILD_NUMBER=${COMMIT_COUNT}


echo "-------------------------------------"
echo "Building Version Name (visible to user): ${NEW_VERSION_NAME}"
echo "Building Version Code (internal for Android): ${NEW_BUILD_NUMBER}"
echo "-------------------------------------"

# 4. Update pubspec.yaml to reflect the new version for project consistency.
#    The format in pubspec will be x.y.z+z, for example: 1.0.12+12
echo "Updating pubspec.yaml to version ${NEW_VERSION_NAME}+${NEW_BUILD_NUMBER}"
sed -i "s/^version: .*/version: ${NEW_VERSION_NAME}+${NEW_BUILD_NUMBER}/" pubspec.yaml

# --- Build Process ---

echo "Starting Flutter build..."
# 5. Run the flutter build command, injecting the new version name and build number.
flutter build apk --build-name=${NEW_VERSION_NAME} --build-number=${NEW_BUILD_NUMBER}


echo "-------------------------------------"
echo "Build successful!"
echo "APK located at: build/app/outputs/flutter-apk/app-release.apk"
echo "Final User-Visible Version: ${NEW_VERSION_NAME}"
echo "-------------------------------------"
