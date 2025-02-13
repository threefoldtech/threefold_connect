#!/bin/sh

set -e

cd $CI_PRIMARY_REPOSITORY_PATH

# Install Flutter using git.
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Pre-cache Flutter artifacts for iOS.
flutter precache --ios

# Install dependencies.
flutter pub get

# Run build_runner if needed.
if grep -q "build_runner" "pubspec.yaml"; then
  echo "Running build_runner..."
  flutter pub run build_runner build --delete-conflicting-outputs
fi

# Install CocoaPods
HOMEBREW_NO_AUTO_UPDATE=1
brew install cocoapods

# Install CocoaPods dependencies
cd ios && pod install

exit 0
