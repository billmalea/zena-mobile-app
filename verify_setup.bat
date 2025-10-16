@echo off
echo 🔍 Verifying Google Sign-In Setup...
echo.

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo ❌ Error: Run this script from the project root directory
    exit /b 1
)

echo 1️⃣ Checking package name...
findstr "applicationId" android\app\build.gradle
echo    ⚠️ Should be: com.zena.mobile
echo.

echo 2️⃣ Getting SHA-1 fingerprint...
cd android
if exist "gradlew.bat" (
    call gradlew.bat signingReport 2>nul | findstr "SHA1:"
    echo    ⚠️ Copy this SHA-1 and add it to Google Cloud Console
) else (
    echo    ❌ gradlew.bat not found
)
cd ..
echo.

echo 3️⃣ Checking .env.local...
if exist ".env.local" (
    findstr "GOOGLE_WEB_CLIENT_ID" .env.local
    if errorlevel 1 (
        echo    ❌ GOOGLE_WEB_CLIENT_ID not found in .env.local
    ) else (
        echo    ✅ GOOGLE_WEB_CLIENT_ID is set
    )
) else (
    echo    ❌ .env.local file not found
)
echo.

echo 4️⃣ Checking google_sign_in package...
findstr "google_sign_in:" pubspec.yaml >nul
if errorlevel 1 (
    echo    ❌ google_sign_in package not found in pubspec.yaml
) else (
    echo    ✅ google_sign_in package is in pubspec.yaml
)
echo.

echo 📋 Setup Checklist:
echo.
echo In Google Cloud Console, you should have:
echo   [ ] Web OAuth Client ID (for Supabase)
echo   [ ] Android OAuth Client ID with:
echo       - Package name: com.zena.mobile
echo       - SHA-1 fingerprint (from step 2 above)
echo.
echo In Supabase Dashboard:
echo   [ ] Google auth enabled
echo   [ ] Web Client ID added to 'Authorized Client IDs'
echo   [ ] 'Skip nonce checks' enabled
echo.
echo In your .env.local:
echo   [ ] GOOGLE_WEB_CLIENT_ID set to your Web Client ID
echo.
echo ⏰ After creating Android client, wait 5-10 minutes!
echo.
pause
