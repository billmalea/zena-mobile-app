# Quick Setup Checklist

## Current Status

Based on your error, here's what you have and what you need:

### ✅ What You Already Have

- [x] Flutter project set up
- [x] Supabase project created
- [x] Web Client ID (in your `.env.local`)
- [x] Web Client ID added to Supabase dashboard
- [x] `google_sign_in` package installed

### ❌ What's Missing (Causing Error 10)

- [ ] **Android OAuth Client ID in Google Cloud Console**
- [ ] **SHA-1 fingerprint added to Android client**

## Fix in 5 Minutes

### Step 1: Get SHA-1 (1 minute)
```bash
cd android
./gradlew signingReport
```
Copy the SHA1 line (looks like `A1:B2:C3:...`)

### Step 2: Create Android Client (2 minutes)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. **APIs & Services** → **Credentials**
3. Click **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
4. Select **"Android"**
5. Fill in:
   - Name: `Zena Mobile Android`
   - Package: `com.zena.mobile`
   - SHA-1: (paste from Step 1)
6. Click **"CREATE"**

### Step 3: Wait (5-10 minutes)
☕ Grab a coffee while Google propagates the changes

### Step 4: Test (1 minute)
```bash
cd ..
flutter clean
flutter pub get
flutter run
```

## Verification

After Step 2, you should see **2 OAuth clients** in Google Cloud Console:

```
1. Web client 1          [Web application]    ← Already exists
2. Zena Mobile Android   [Android]            ← You just created
```

## Important Notes

- ⚠️ **DO NOT** copy the Android Client ID anywhere
- ⚠️ **DO NOT** add Android Client ID to `.env.local`
- ⚠️ **DO NOT** add Android Client ID to Supabase
- ✅ **ONLY** the Web Client ID goes in `.env.local` and Supabase

The Android client works automatically through Google Play Services!

## Still Stuck?

See detailed guides:
- **GOOGLE_CLOUD_SETUP.md** - Step-by-step with explanations
- **FIX_ERROR_10.md** - Troubleshooting Error 10
- **OAUTH_SETUP.md** - Complete OAuth setup guide
