#!/bin/bash

# Generate Hive adapters for CI/CD environments

set -e

if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter not found in PATH"
    exit 1
fi

flutter packages get

# Generate Hive adapters and other code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Verify generated files exist
generated_files=$(find lib -name "*.g.dart" -type f | wc -l)
if [ "$generated_files" -eq 0 ]; then
    echo "ERROR: No generated files found"
    exit 1
fi
