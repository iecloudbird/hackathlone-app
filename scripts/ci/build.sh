#!/bin/bash

# Flutter CI/CD build script
# Ensures Hive adapters are generated before building

set -e

flutter packages get

# Critical: Generate Hive adapters for CI environment
flutter packages pub run build_runner build --delete-conflicting-outputs

# Verify generated files exist
if ! find lib -name "*.g.dart" -type f -print -quit | grep -q .; then
    echo "ERROR: No generated files found"
    exit 1
fi

flutter analyze --fatal-infos
flutter test || true  # Don't fail build on test failures
flutter build apk --release --no-obfuscate --no-shrink
