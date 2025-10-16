#!/bin/bash

echo "🔍 Verifying Google Sign-In Setup..."
echo ""

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Run this script from the project root directory"
    exit 1
fi

echo "1️⃣ Checking package name..."
PACKAGE_NAME=$(grep "applicationId" android/app/build.gradle | sed 's/.*"\(.*\)".*/\1/')
echo "   Package Name: $PACKAGE_NAME"
if [ "$PACKAGE_NAME" = "com.zena.mobile" ]; then
    echo "   ✅ Package name is correct"
else
    echo "   ❌ Package name should be: com.zena.mobile"
fi
echo ""

echo "2️⃣ Getting SHA-1 fingerprint..."
cd android
if [ -f "gradlew" ]; then
    ./gradlew signingReport 2>/dev/null | grep "SHA1:" | head -1
    echo "   ⚠️ Copy this SHA-1 and add it to Google Cloud Console"
else
    echo "   ❌ gradlew not found"
fi
cd ..
echo ""

echo "3️⃣ Checking .env.local..."
if [ -f ".env.local" ]; then
    if grep -q "GOOGLE_WEB_CLIENT_ID" .env.local; then
        WEB_CLIENT=$(grep "GOOGLE_WEB_CLIENT_ID" .env.local | cut -d'=' -f2)
        if [ "$WEB_CLIENT" = "your_google_web_client_id_here" ]; then
            echo "   ❌ GOOGLE_WEB_CLIENT_ID not set in .env.local"
        else
            echo "   ✅ GOOGLE_WEB_CLIENT_ID is set"
            echo "   Web Client ID: $WEB_CLIENT"
        fi
    else
        echo "   ❌ GOOGLE_WEB_CLIENT_ID not found in .env.local"
    fi
else
    echo "   ❌ .env.local file not found"
fi
echo ""

echo "4️⃣ Checking google_sign_in package..."
if grep -q "google_sign_in:" pubspec.yaml; then
    echo "   ✅ google_sign_in package is in pubspec.yaml"
else
    echo "   ❌ google_sign_in package not found in pubspec.yaml"
fi
echo ""

echo "📋 Setup Checklist:"
echo ""
echo "In Google Cloud Console, you should have:"
echo "  [ ] Web OAuth Client ID (for Supabase)"
echo "  [ ] Android OAuth Client ID with:"
echo "      - Package name: com.zena.mobile"
echo "      - SHA-1 fingerprint (from step 2 above)"
echo ""
echo "In Supabase Dashboard:"
echo "  [ ] Google auth enabled"
echo "  [ ] Web Client ID added to 'Authorized Client IDs'"
echo "  [ ] 'Skip nonce checks' enabled"
echo ""
echo "In your .env.local:"
echo "  [ ] GOOGLE_WEB_CLIENT_ID set to your Web Client ID"
echo ""
echo "⏰ After creating Android client, wait 5-10 minutes!"
echo ""
