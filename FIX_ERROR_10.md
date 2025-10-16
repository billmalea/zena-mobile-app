# Fix Google Sign-In Error 10 (Developer Error)

## The Problem

You're getting `ApiException: 10` which is a "Developer Error". This means Google Cloud Console doesn't recognize your app because the SHA-1 certificate fingerprint doesn't match.

## Your App Details

- **Package Name:** `com.zena.mobile`
- **Namespace:** `com.zena.zena_mobile`

## Solution: Add Your Debug SHA-1 Certificate

### Step 1: Get Your SHA-1 Fingerprint

Open a terminal in your project root and run:

**On Mac/Linux:**
```bash
cd android
./gradlew signingReport
```

**On Windows:**
```bash
cd android
gradlew.bat signingReport
```

Look for the **debug** variant output. You'll see something like:
```
Variant: debug
Config: debug
Store: C:\Users\bill\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:...
SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
SHA-256: ...
```

**Copy the SHA1 value** (the one with colons like `A1:B2:C3:...`)

### Step 2: Update Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to **APIs & Services** → **Credentials**
4. Find your **Android OAuth 2.0 Client ID** (you should have created this earlier)
5. Click on it to edit
6. Verify these settings:
   - **Application type:** Android
   - **Package name:** `com.zena.mobile` ⚠️ IMPORTANT: Must match exactly!
   - **SHA-1 certificate fingerprint:** Paste the SHA-1 from Step 1
7. Click **Save**

### Step 3: Wait a Few Minutes

Google Cloud Console changes can take 5-10 minutes to propagate. Grab a coffee! ☕

### Step 4: Clean and Rebuild

```bash
# Go back to project root
cd ..

# Clean everything
flutter clean

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Step 5: Test Again

1. Tap "Sign in with Google"
2. You should now see the Google account picker
3. Select your account
4. Sign in should complete successfully!

## Common Issues

### Issue: "I don't see an Android OAuth Client ID"

You need to create one:

1. In Google Cloud Console → **Credentials**
2. Click **Create Credentials** → **OAuth 2.0 Client ID**
3. Select **Android**
4. Enter:
   - **Name:** Zena Mobile Android
   - **Package name:** `com.zena.mobile`
   - **SHA-1:** Your SHA-1 from Step 1
5. Click **Create**

### Issue: "Package name doesn't match"

The package name in Google Cloud Console MUST be exactly: `com.zena.mobile`

If you used a different package name, you need to either:
- Update it in Google Cloud Console, OR
- Create a new Android OAuth Client ID with the correct package name

### Issue: "Still getting Error 10 after adding SHA-1"

Try these:

1. **Wait longer** - Changes can take up to 10 minutes
2. **Check you added SHA-1 to the Android client** (not the Web client)
3. **Verify package name is exactly** `com.zena.mobile`
4. **Run signing report again** to make sure you copied the right SHA-1
5. **Restart your app completely** (not just hot reload)

### Issue: "Multiple SHA-1 fingerprints"

You can add multiple SHA-1 certificates to the same Android OAuth Client ID:
- Debug certificate (for development)
- Release certificate (for production)
- Different developer machines

Just click "Add fingerprint" in Google Cloud Console.

## Quick Verification Checklist

Before testing again, verify:

- [ ] Ran `./gradlew signingReport` and copied SHA-1
- [ ] Added SHA-1 to **Android** OAuth Client ID (not Web)
- [ ] Package name is exactly `com.zena.mobile`
- [ ] Waited 5-10 minutes after saving changes
- [ ] Ran `flutter clean && flutter pub get`
- [ ] Completely restarted the app

## What the Logs Should Show After Fix

After fixing, you should see:

```
🔐 [AuthService] Initializing Google Sign-In...
📋 [AuthService] Server Client ID: your-web-client-id.apps.googleusercontent.com
👤 [AuthService] Launching Google Sign-In UI...
✅ [AuthService] Google user selected: your-email@gmail.com
🔑 [AuthService] Getting authentication tokens...
🎫 [AuthService] ID Token present: true
📤 [AuthService] Sending ID token to Supabase...
✅ [AuthService] Supabase sign-in response received
```

No more `ApiException: 10`! 🎉

## Need More Help?

If you're still getting Error 10 after following all steps:

1. Run `./gradlew signingReport` again and share the output
2. Share a screenshot of your Android OAuth Client ID settings in Google Cloud Console
3. Verify the web client ID is also added to Supabase dashboard
