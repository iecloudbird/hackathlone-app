#!/bin/bash

# Setup Firebase configuration for CI/CD builds
# This script creates the google-services.json file from environment variables

echo "🔥 Setting up Firebase configuration..."

# Check if environment variable exists
if [ -z "$GOOGLE_SERVICES_JSON" ]; then
    echo "❌ Error: GOOGLE_SERVICES_JSON environment variable is not set"
    echo "Please add the base64-encoded google-services.json content to your CI environment variables"
    exit 1
fi

# Create the android/app directory if it doesn't exist
mkdir -p android/app

# Method 1: Try base64 decode (preferred)
echo "📱 Attempting to decode base64 Firebase config..."
if echo "$GOOGLE_SERVICES_JSON" | base64 -d > android/app/google-services.json 2>/dev/null; then
    echo "✅ Successfully created google-services.json using base64 -d"
elif echo "$GOOGLE_SERVICES_JSON" | base64 --decode > android/app/google-services.json 2>/dev/null; then
    echo "✅ Successfully created google-services.json using base64 --decode"
elif python3 -c "import base64, sys; sys.stdout.buffer.write(base64.b64decode('$GOOGLE_SERVICES_JSON'))" > android/app/google-services.json 2>/dev/null; then
    echo "✅ Successfully created google-services.json using Python base64"
else
    echo "❌ All base64 decode methods failed"
    echo "Environment variable content length: ${#GOOGLE_SERVICES_JSON}"
    echo "First 50 characters: ${GOOGLE_SERVICES_JSON:0:50}..."
    
    # Check if it's already JSON (not base64 encoded)
    if [[ "$GOOGLE_SERVICES_JSON" == *"{"* ]]; then
        echo "🔄 Detected JSON format, using direct content..."
        echo "$GOOGLE_SERVICES_JSON" > android/app/google-services.json
        echo "✅ Created google-services.json from direct JSON content"
    else
        echo "❌ Unable to process environment variable content"
        exit 1
    fi
fi

# Verify the file was created and is valid JSON
if [ -f android/app/google-services.json ]; then
    echo "📋 File created successfully:"
    ls -la android/app/google-services.json
    
    # Validate JSON structure
    if command -v python3 >/dev/null 2>&1; then
        if python3 -m json.tool android/app/google-services.json >/dev/null 2>&1; then
            echo "✅ JSON structure is valid"
        else
            echo "❌ Invalid JSON structure in google-services.json"
            exit 1
        fi
    else
        echo "⚠️  Python3 not available, skipping JSON validation"
    fi
    
    # Show first few lines for verification (without sensitive data)
    echo "📄 First few lines of the file:"
    head -n 5 android/app/google-services.json
    
else
    echo "❌ google-services.json file was not created"
    exit 1
fi

echo "🎉 Firebase configuration setup completed successfully!"
