# Still Getting Error 10? Here's Why

## You're Still Getting This Error

```
ApiException: 10
```

This means Google Cloud Console doesn't recognize your app. Here are the most common reasons:

## Reason 1: You Haven't Created the Android Client Yet (Most Likely!)

**Check:** Go to [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials

**Do you see TWO OAuth clients?**
- ✅ Web client (Type: Web application)
- ❌ Android client (Type: Android) ← **This is probably missing!**

**If you only see the Web client**, you need to create the Android client:

1. Click **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
2. Select **"Android"** (NOT Web!)
3. Fill in:
   - Package name: `com.zena.mobile`
   - SHA-1: Run `cd android && ./gradlew signingReport` to get it
4. Click **"CREATE"**

## Reason 2: You Just Created It (Need to Wait!)

**If you just created the Android client:**
- ⏰ Wait **10-15 minutes** for Google to propagate changes
- ☕ Seriously, go get coffee. Google's servers need time to sync.
- 🔄 After waiting, run: `flutter clean && flutter pub get && flutter run`

## Reason 3: Wrong Package Name

**Check your Android client in Google Cloud Console:**

The package name MUST be exactly: `com.zena.mobile`

**Common mistakes:**
- ❌ `com.zena.zena_mobile` (wrong!)
- ❌ `com.example.zena` (wrong!)
- ✅ `com.zena.mobile` (correct!)

**To fix:**
1. Click on your Android OAuth client
2. Check the package name
3. If wrong, delete it and create a new one with the correct package name

## Reason 4: Wrong or Missing SHA-1

**Check your Android client in Google Cloud Console:**

1. Click on your Android OAuth client
2. Look at "SHA-1 certificate fingerprints"
3. Is there a SHA-1 listed?

**If no SHA-1:**
1. Get your SHA-1: `cd android && ./gradlew signingReport`
2. Copy the SHA1 line (looks like `A1:B2:C3:...`)
3. Click "Add fingerprint" in Google Cloud Console
4. Paste it and save

**If SHA-1 is there but still not working:**
- Make sure you copied the **debug** SHA-1 (not release)
- Run `./gradlew signingReport` again to verify you copied the right one
- Delete the old SHA-1 and add the correct one

## Reason 5: You're Testing Too Soon

**Did you just make changes in Google Cloud Console?**

Changes take time to propagate:
- Minimum: 5 minutes
- Average: 10 minutes
- Sometimes: 15-20 minutes

**What to do:**
1. Close your app completely
2. Wait 10 minutes
3. Run: `flutter clean && flutter pub get`
4. Run: `flutter run`
5. Try signing in again

## Reason 6: Wrong Client ID in .env.local

**Check your `.env.local` file:**

```env
GOOGLE_WEB_CLIENT_ID=xxxxx.apps.googleusercontent.com
```

This should be your **Web Client ID**, NOT the Android Client ID!

**To verify:**
1. Go to Google Cloud Console → Credentials
2. Click on your **Web client** (not Android)
3. Copy the Client ID
4. Make sure it matches what's in `.env.local`

## Diagnostic Script

Run this to check your setup:

**Windows:**
```bash
verify_setup.bat
```

**Mac/Linux:**
```bash
chmod +x verify_setup.sh
./verify_setup.sh
```

This will show you:
- Your package name
- Your SHA-1 fingerprint
- Your .env.local configuration
- What's missing

## Step-by-Step Verification

Let's verify everything is correct:

### ✅ Step 1: Verify Package Name

Run:
```bash
grep "applicationId" android/app/build.gradle
```

Should show: `applicationId = "com.zena.mobile"`

### ✅ Step 2: Get SHA-1

Run:
```bash
cd android
./gradlew signingReport
```

Look for the **debug** variant SHA1. Copy it.

### ✅ Step 3: Check Google Cloud Console

Go to [Google Cloud Console](https://console.cloud.google.com/) → Credentials

You should see:
```
OAuth 2.0 Client IDs
┌──────────────────────────────────────────────┐
│ Name                Type          Client ID  │
├──────────────────────────────────────────────┤
│ Web client 1       Web app       xxxxx...   │
│ Zena Mobile        Android       xxxxx...   │ ← Must exist!
└──────────────────────────────────────────────┘
```

### ✅ Step 4: Click on "Zena Mobile" (Android client)

Verify:
- Package name: `com.zena.mobile` ✅
- SHA-1 fingerprint: (matches what you got in Step 2) ✅

### ✅ Step 5: Check .env.local

Open `.env.local` and verify:
```env
GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

This should be the **Web Client ID** (from the Web client, not Android).

### ✅ Step 6: Check Supabase Dashboard

1. Go to Supabase Dashboard → Authentication → Providers → Google
2. Verify:
   - "Enable Sign in with Google" is ON ✅
   - "Authorized Client IDs" has your Web Client ID ✅
   - "Skip nonce checks" is ON ✅

### ✅ Step 7: Wait and Test

If you just made changes:
1. Wait 10 minutes ⏰
2. Run:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
3. Try signing in

## Still Not Working?

If you've verified ALL of the above and it's still not working:

1. **Delete the Android OAuth client** in Google Cloud Console
2. **Create it again** with the correct package name and SHA-1
3. **Wait 15 minutes**
4. **Test again**

Sometimes Google's cache gets stuck, and recreating the client fixes it.

## Need More Help?

Share these details:

1. Screenshot of your OAuth clients list in Google Cloud Console
2. Screenshot of your Android client details (package name + SHA-1)
3. Output of: `grep "applicationId" android/app/build.gradle`
4. Output of: `cd android && ./gradlew signingReport | grep "SHA1:"`
5. Contents of your `.env.local` (hide the actual keys, just show the format)

This will help identify exactly what's wrong!
