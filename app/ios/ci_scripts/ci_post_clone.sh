#!/bin/sh -x 

set -e

cd "$CI_PRIMARY_REPOSITORY_PATH" || { echo "Failed to change directory"; exit 1; }
pwd

# Install Flutter 3.27.2 using git.
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.27.2 $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"
dart --version

# Pre-cache Flutter artifacts for iOS.
flutter precache --ios

cd ./app || { echo "Failed to change directory $(pwd)"; ls; exit 1; }
# Ensure we are in a Flutter project directory
if [ ! -f "pubspec.yaml" ]; then
  echo "Error: pubspec.yaml not found in $(pwd)"
  exit 1
fi

flutter pub get

# Run build_runner if needed.
if grep -q "build_runner" "pubspec.yaml"; then
  echo "Running build_runner..."
  flutter pub run build_runner build --delete-conflicting-outputs
fi

# Install CocoaPods
HOMEBREW_NO_AUTO_UPDATE=1
brew install cocoapods

# Ensure iOS directory exists
if [ ! -d "ios" ]; then
  echo "Error: ios directory not found"
  exit 1
fi

cd ios
pod install || { echo "Pod install failed"; exit 1; }
cd ..
mv lib/app_config_local.template lib/app_config_local.dart
mv lib/helpers/env_config_local.template lib/helpers/env_config.dart
exit 0
