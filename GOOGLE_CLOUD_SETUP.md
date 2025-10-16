# Google Cloud Console Setup - Step by Step

## Overview

You need **3 different OAuth Client IDs** in Google Cloud Console:
1. ✅ **Web Client ID** - You already have this (it's in your `.env.local`)
2. ❌ **Android Client ID** - You need to CREATE this (this is what's missing!)
3. ⚠️ **iOS Client ID** - You'll need this for iOS (create later)

## Step 1: Get Your SHA-1 Fingerprint First

Before creating the Android client, get your SHA-1:

```bash
cd android
./gradlew signingReport
```

**Windows:**
```bash
cd android
gradlew.bat signingReport
```

Look for output like this:
```
Variant: debug
Config: debug
Store: C:\Users\bill\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
```

**Copy the SHA1 value** - you'll need it in the next step!

## Step 2: Create Android OAuth Client ID

### 2.1 Go to Google Cloud Console

1. Open [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (the same one where you created the Web client)
3. Click on the hamburger menu (☰) → **APIs & Services** → **Credentials**

### 2.2 Create New Credentials

1. Click the **"+ CREATE CREDENTIALS"** button at the top
2. Select **"OAuth client ID"** from the dropdown

### 2.3 Configure OAuth Client

You'll see a form. Fill it out:

**Application type:**
- Select **"Android"** from the dropdown

**Name:**
- Enter: `Zena Mobile Android` (or any name you like)

**Package name:**
- Enter exactly: `com.zena.mobile`
- ⚠️ This MUST match your app's package name exactly!

**SHA-1 certificate fingerprint:**
- Paste the SHA-1 you copied from Step 1
- It should look like: `A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0`

### 2.4 Create the Client

1. Click **"CREATE"** button
2. You'll see a dialog saying "OAuth client created"
3. Click **"OK"**

**Important:** You don't need to copy any client ID from this Android client. The Android client ID is only used internally by Google Play Services.

## Step 3: Verify Your Setup

After creating, you should see **3 OAuth 2.0 Client IDs** in your credentials list:

1. **Web client** (Type: Web application)
   - This is the one you're using in `.env.local`
   - Shows the client ID like: `xxxxx.apps.googleusercontent.com`

2. **Android client** (Type: Android) ← **You just created this!**
   - Shows package name: `com.zena.mobile`
   - Shows SHA-1 fingerprint

3. **iOS client** (Type: iOS) ← **Create this later for iOS**
   - You'll create this when testing on iOS

## Step 4: Wait and Test

1. **Wait 5-10 minutes** for Google to propagate the changes
2. Go back to your project root:
   ```bash
   cd ..
   ```
3. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
4. Try signing in with Google again!

## Visual Guide - What You Should See

### In Google Cloud Console Credentials Page:

```
OAuth 2.0 Client IDs
┌─────────────────────────────────────────────────────────┐
│ Name                    Type              Client ID      │
├─────────────────────────────────────────────────────────┤
│ Web client 1           Web application   xxxxx.apps...  │ ← Already exists
│ Zena Mobile Android    Android           (auto-generated)│ ← Create this!
└─────────────────────────────────────────────────────────┘
```

### When You Click on "Zena Mobile Android":

```
Edit OAuth client ID
┌─────────────────────────────────────────────────────────┐
│ Application type: Android                                │
│                                                          │
│ Name: Zena Mobile Android                               │
│                                                          │
│ Package name: com.zena.mobile                           │
│                                                          │
│ SHA-1 certificate fingerprints:                         │
│ A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8  │
│                                                          │
│ [Add fingerprint]                                        │
│                                                          │
│ Client ID: xxxxx-xxxxx.apps.googleusercontent.com       │
│ (This is auto-generated, you don't need to copy it)     │
└─────────────────────────────────────────────────────────┘
```

## Common Questions

### Q: Do I need to add the Android Client ID to `.env.local`?
**A:** No! Only the **Web Client ID** goes in `.env.local`. The Android client is used automatically by Google Play Services.

### Q: Do I need to add the Android Client ID to Supabase?
**A:** No! Only the **Web Client ID** goes in Supabase dashboard under "Authorized Client IDs".

### Q: Can I have multiple SHA-1 fingerprints?
**A:** Yes! You can add multiple SHA-1 fingerprints to the same Android client:
- Debug certificate (for development)
- Release certificate (for production)
- Different developer machines

Just click "Add fingerprint" to add more.

### Q: What if I already created an Android client but forgot to add SHA-1?
**A:** No problem! Just:
1. Click on your existing Android client in the credentials list
2. Click "Add fingerprint"
3. Paste your SHA-1
4. Click "Save"

### Q: I don't see the "Android" option when creating OAuth client
**A:** You might need to configure the OAuth consent screen first:
1. Go to **OAuth consent screen** in the left menu
2. Fill out the required fields
3. Save
4. Then try creating the Android client again

## Summary - What You Need

| Client Type | Where It's Used | Do You Have It? |
|-------------|-----------------|-----------------|
| **Web Client ID** | `.env.local` + Supabase Dashboard | ✅ Yes (already in .env.local) |
| **Android Client** | Google Play Services (automatic) | ❌ Need to create |
| **iOS Client** | iOS app (for later) | ⚠️ Create when testing iOS |

## Next Steps

1. ✅ Get SHA-1 fingerprint: `cd android && ./gradlew signingReport`
2. ✅ Create Android OAuth Client ID in Google Cloud Console
3. ✅ Add package name: `com.zena.mobile`
4. ✅ Add SHA-1 fingerprint
5. ⏰ Wait 5-10 minutes
6. 🧪 Test: `flutter clean && flutter pub get && flutter run`

That's it! The Android client ID doesn't need to be copied anywhere - Google Play Services finds it automatically using your package name and SHA-1.
