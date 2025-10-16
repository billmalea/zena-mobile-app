# Debug Guide - Google Sign-In Errors

## How to View Logs

The app now has comprehensive logging throughout the authentication flow. Here's how to view them:

### Android
```bash
# View all logs
flutter run

# Or filter for our specific logs
adb logcat | grep -E "AuthService|AuthProvider|WelcomeScreen"
```

### iOS
```bash
# View all logs
flutter run

# Logs will appear in the Xcode console or terminal
```

### VS Code / Android Studio
- Logs will appear in the Debug Console automatically when running the app

## Log Symbols

The logs use emojis to make them easy to scan:

- 🔐 = Authentication process starting
- ✅ = Success
- ❌ = Error
- ⚠️ = Warning
- 👤 = User information
- 🔑 = Token/credential operations
- 🎫 = Token presence check
- 📤 = Sending data
- 📥 = Receiving data
- 🔗 = URL/connection info
- 🔄 = State change
- 📧 = Email information
- 🎟️ = Session information
- 📅 = Event information
- 📋 = Configuration
- 🧹 = Cleanup operation
- 📍 = Stack trace/location
- 🚀 = Initialization

## Authentication Flow Logs

When you tap "Sign in with Google", you should see logs in this order:

```
🔐 [WelcomeScreen] Starting Google Sign-In...
🔐 [AuthProvider] Starting sign-in process...
📞 [AuthProvider] Calling AuthService.signInWithGoogle()...
🔐 [AuthService] Initializing Google Sign-In...
📋 [AuthService] Server Client ID: your-client-id.apps.googleusercontent.com
👤 [AuthService] Launching Google Sign-In UI...
✅ [AuthService] Google user selected: user@gmail.com
🔑 [AuthService] Getting authentication tokens...
🎫 [AuthService] ID Token present: true
🎫 [AuthService] Access Token present: true
📤 [AuthService] Sending ID token to Supabase...
🔗 [AuthService] Supabase URL: https://your-project.supabase.co
✅ [AuthService] Supabase sign-in response received
👤 [AuthService] User ID: uuid-here
📧 [AuthService] User Email: user@gmail.com
🎟️ [AuthService] Session present: true
✅ [AuthProvider] AuthService.signInWithGoogle() completed
🔄 [AuthProvider] Auth state changed
📧 [AuthProvider] User: user@gmail.com
🎟️ [AuthProvider] Session: true
📅 [AuthProvider] Event: SIGNED_IN
✅ [WelcomeScreen] Google Sign-In completed successfully
```

## Common Error Patterns

### Error: "Failed to get ID token from Google"

**Logs will show:**
```
❌ [AuthService] ID token is null!
```

**Cause:** Google Sign-In didn't return an ID token

**Solutions:**
1. Check that `GOOGLE_WEB_CLIENT_ID` is set in `.env.local`
2. Verify the web client ID is correct
3. Ensure you created all 3 client IDs (Web, Android, iOS)

### Error: "Google sign-in was cancelled"

**Logs will show:**
```
⚠️ [AuthService] User cancelled Google Sign-In
```

**Cause:** User closed the Google Sign-In dialog

**Solution:** This is normal user behavior, no action needed

### Error: "Developer Error" or "Error 10"

**Logs will show:**
```
❌ [AuthService] Error during sign-in: PlatformException(sign_in_failed, ...)
```

**Cause:** Android configuration issue

**Solutions:**
1. Check SHA-1 certificate fingerprint in Google Cloud Console
2. Verify package name matches
3. Run: `flutter clean && flutter pub get`

### Error: Supabase authentication fails

**Logs will show:**
```
✅ [AuthService] Google user selected: user@gmail.com
🎫 [AuthService] ID Token present: true
📤 [AuthService] Sending ID token to Supabase...
❌ [AuthService] Error during sign-in: AuthException(...)
```

**Cause:** Supabase rejected the ID token

**Solutions:**
1. Verify web client ID is added to Supabase dashboard
2. Check "Skip nonce checks" is enabled in Supabase
3. Ensure Google auth is enabled in Supabase

## How to Share Logs

When reporting an issue:

1. Run the app: `flutter run`
2. Tap "Sign in with Google"
3. Copy ALL the logs from the console
4. Share the complete log output

The logs will show exactly where the authentication flow is failing!

## Testing Checklist

Before reporting an issue, verify:

- [ ] `.env.local` has `GOOGLE_WEB_CLIENT_ID` set
- [ ] Web client ID is added to Supabase dashboard
- [ ] "Skip nonce checks" is enabled in Supabase
- [ ] Google auth is enabled in Supabase
- [ ] Android SHA-1 is correct (for Android)
- [ ] iOS reversed client ID is in Info.plist (for iOS)
- [ ] Ran `flutter clean && flutter pub get`
- [ ] Checked the logs for specific error messages
