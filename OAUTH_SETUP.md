# Google OAuth Setup for Mobile (CORRECT IMPLEMENTATION)

## Overview

The app uses **native Google Sign-In** with Supabase's `signInWithIdToken()` method. This provides a seamless in-app authentication experience without redirecting to a browser.

## How It Works

1. User taps "Sign in with Google"
2. Native Google Sign-In SDK opens (stays within the app)
3. User authenticates with Google using native UI
4. App receives an ID token from Google
5. App sends the ID token to Supabase using `signInWithIdToken()`
6. Supabase verifies the token and creates a session
7. User is automatically logged in and navigated to the chat screen

## Required Setup

### 1. Google Cloud Console Setup

You need to create OAuth 2.0 client IDs for each platform:

#### A. Web Client ID (Required for Supabase)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project or create a new one
3. Navigate to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth 2.0 Client ID**
5. Select **Web application**
6. Add authorized redirect URIs (not needed for this flow, but required by Google)
7. **Copy the Client ID** - this is your `GOOGLE_WEB_CLIENT_ID`

#### B. Android Client ID
1. In Google Cloud Console → **Credentials**
2. Click **Create Credentials** → **OAuth 2.0 Client ID**
3. Select **Android**
4. Enter your package name: `com.zena.mobile` (or your actual package name)
5. Get your SHA-1 certificate fingerprint:
   ```bash
   # For debug builds
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # For release builds
   keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias
   ```
6. Enter the SHA-1 fingerprint
7. Create the client ID

#### C. iOS Client ID
1. In Google Cloud Console → **Credentials**
2. Click **Create Credentials** → **OAuth 2.0 Client ID**
3. Select **iOS**
4. Enter your iOS bundle ID (found in `ios/Runner.xcodeproj/project.pbxproj`)
5. Create the client ID
6. **Copy the iOS Client ID** - you'll need the reversed version

### 2. Configure Supabase Dashboard

1. Go to your [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Navigate to **Authentication** → **Providers** → **Google**
4. Toggle **Enable Sign in with Google** to ON
5. In **Authorized Client IDs**, paste your **Web Client ID** from step 1A
6. Toggle **Skip nonce checks** to ON (required for iOS compatibility)
7. Click **Save**

### 3. Configure Environment Variables

Update your `.env.local` file:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Google OAuth Configuration
# This is the WEB client ID from Google Cloud Console
GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com

# Base API URL
BASE_URL=https://zena.live
```

### 4. Configure iOS (Info.plist)

The `ios/Runner/Info.plist` is already configured with the deep link scheme `io.supabase.zena`. 

**Important**: You also need to add the reversed iOS client ID:

1. Open `ios/Runner/Info.plist`
2. Find the `CFBundleURLSchemes` array
3. Add your reversed iOS client ID:

```xml
<key>CFBundleURLTypes</key>
<array>
    <!-- Existing Supabase deep link -->
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>io.supabase.zena</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.supabase.zena</string>
        </array>
    </dict>
    
    <!-- Add Google Sign-In reversed client ID -->
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.googleusercontent.apps</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with YOUR reversed iOS client ID -->
            <string>com.googleusercontent.apps.YOUR-IOS-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

To get the reversed client ID:
- If your iOS client ID is: `123456789-abc123.apps.googleusercontent.com`
- The reversed version is: `com.googleusercontent.apps.123456789-abc123`

### 5. Android Configuration

The Android manifest is already configured. No additional changes needed for Android!

## Testing

### Android
1. Run: `flutter run`
2. Tap "Sign in with Google"
3. Native Google Sign-In bottom sheet appears
4. Select your Google account
5. App returns and you're logged in

### iOS
1. Run: `flutter run`
2. Tap "Sign in with Google"
3. Native Google Sign-In screen appears
4. Select your Google account
5. App returns and you're logged in

## Troubleshooting

### Issue: "Error 10" or "Developer Error" on Android (MOST COMMON!)
**This is the error you're currently experiencing!**

**Solution**: 
1. Get your SHA-1 fingerprint: `cd android && ./gradlew signingReport`
2. Add it to your Android OAuth Client ID in Google Cloud Console
3. Verify package name is exactly: `com.zena.mobile`
4. Wait 5-10 minutes for changes to propagate
5. Run: `flutter clean && flutter pub get && flutter run`

**See FIX_ERROR_10.md for detailed step-by-step instructions!**

### Issue: "Sign in failed" on iOS
**Solution**:
- Verify the reversed client ID is correctly added to Info.plist
- Check that the iOS client ID is created in Google Cloud Console
- Ensure your bundle ID matches

### Issue: "Missing required environment variable: GOOGLE_WEB_CLIENT_ID"
**Solution**:
- Add the web client ID to your `.env.local` file
- Run `flutter clean && flutter pub get`
- Do a full restart (not hot reload)

### Issue: "Failed to get ID token from Google"
**Solution**:
- Verify all three client IDs are created (Web, Android, iOS)
- Check that the web client ID is added to Supabase dashboard
- Ensure "Skip nonce checks" is enabled in Supabase

### Issue: User signs in but Supabase session not created
**Solution**:
- Verify the web client ID in `.env.local` matches the one in Supabase dashboard
- Check Supabase logs for authentication errors
- Ensure your Supabase project has Google auth enabled

## Why This Approach?

This implementation uses the `google_sign_in` package with Supabase's `signInWithIdToken()` method because:

- ✅ **Native UX**: Uses platform-native Google Sign-In UI (no browser redirect)
- ✅ **Better Performance**: Faster authentication flow
- ✅ **Secure**: ID token is verified by Supabase
- ✅ **User Data**: Supabase automatically populates user metadata from the ID token
- ✅ **Cross-Platform**: Works consistently on Android, iOS, and Web

## Key Differences from Web OAuth

| Feature | Native Google Sign-In (Current) | Web OAuth (Previous) |
|---------|--------------------------------|----------------------|
| User Experience | Native in-app UI | Browser redirect |
| Speed | Fast | Slower (browser launch) |
| Method | `signInWithIdToken()` | `signInWithOAuth()` |
| Deep Linking | Not required | Required |
| Setup Complexity | Medium (3 client IDs) | Low (1 redirect URL) |
| Mobile UX | Excellent | Poor |

## Reference

This implementation follows the official Supabase Flutter authentication guide:
https://supabase.com/blog/flutter-authentication
