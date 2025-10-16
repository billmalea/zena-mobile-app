# Your SHA-1 Fingerprint

## ✅ Your Debug SHA-1 Certificate

```
16:2E:C0:F5:7A:35:6C:52:15:87:A1:6F:AD:F4:DD:92:56:12:EC:4C
```

## 📋 What You Need to Do NOW

### Step 1: Go to Google Cloud Console

1. Open [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to **APIs & Services** → **Credentials**

### Step 2: Check If You Have an Android OAuth Client

Look at your list of OAuth 2.0 Client IDs. Do you see:

- ✅ A **Web application** client (you already have this)
- ❓ An **Android** client (do you have this?)

### Step 3A: If You DON'T Have an Android Client (Most Likely)

**Create it now:**

1. Click **"+ CREATE CREDENTIALS"** button at the top
2. Select **"OAuth client ID"**
3. For "Application type", select **"Android"**
4. Fill in the form:
   - **Name:** `Zena Mobile Android`
   - **Package name:** `com.zena.mobile`
   - **SHA-1 certificate fingerprint:** `16:2E:C0:F5:7A:35:6C:52:15:87:A1:6F:AD:F4:DD:92:56:12:EC:4C`
5. Click **"CREATE"**
6. Click **"OK"** on the confirmation dialog

**Then:**
- ⏰ Wait 10 minutes for Google to propagate the changes
- 🔄 Run: `flutter clean && flutter pub get && flutter run`
- 🧪 Try signing in again

### Step 3B: If You Already Have an Android Client

**Update it:**

1. Click on your Android OAuth client to open it
2. Check the **Package name** - it should be: `com.zena.mobile`
3. Check the **SHA-1 certificate fingerprints** section
4. If your SHA-1 is NOT there, click **"Add fingerprint"**
5. Paste: `16:2E:C0:F5:7A:35:6C:52:15:87:A1:6F:AD:F4:DD:92:56:12:EC:4C`
6. Click **"Save"**

**Then:**
- ⏰ Wait 10 minutes for Google to propagate the changes
- 🔄 Run: `flutter clean && flutter pub get && flutter run`
- 🧪 Try signing in again

## ⚠️ Important Notes

### Package Name MUST Be Exact

The package name in your Android OAuth client must be exactly:
```
com.zena.mobile
```

NOT:
- ❌ `com.zena.zena_mobile`
- ❌ `com.example.zena`
- ❌ Any other variation

### You Need TWO OAuth Clients

After creating the Android client, you should have **2 OAuth clients** in Google Cloud Console:

1. **Web application** - Used by Supabase (already in your `.env.local`)
2. **Android** - Used by Google Play Services (works automatically)

### Don't Copy the Android Client ID

The Android OAuth client generates a Client ID, but you **don't need to copy it anywhere**. It works automatically through Google Play Services using your package name and SHA-1.

## 🧪 After Creating/Updating

1. **Wait 10 minutes** - This is important! Google needs time to sync.
2. **Clean your project:**
   ```bash
   flutter clean
   flutter pub get
   ```
3. **Run the app:**
   ```bash
   flutter run
   ```
4. **Try signing in with Google**

## ✅ Success Indicators

When it works, you'll see these logs:

```
🔐 [AuthService] Initializing Google Sign-In...
👤 [AuthService] Launching Google Sign-In UI...
✅ [AuthService] Google user selected: your-email@gmail.com
🔑 [AuthService] Getting authentication tokens...
🎫 [AuthService] ID Token present: true
📤 [AuthService] Sending ID token to Supabase...
✅ [AuthService] Supabase sign-in response received
```

No more `ApiException: 10`! 🎉

## 📸 What It Should Look Like

### In Google Cloud Console - Credentials List:

```
OAuth 2.0 Client IDs
┌────────────────────────────────────────────────────┐
│ Name                  Type              Client ID  │
├────────────────────────────────────────────────────┤
│ Web client 1         Web application   xxxxx...   │
│ Zena Mobile Android  Android           xxxxx...   │ ← This one!
└────────────────────────────────────────────────────┘
```

### When You Click on "Zena Mobile Android":

```
Application type: Android

Name: Zena Mobile Android

Package name: com.zena.mobile

SHA-1 certificate fingerprints:
16:2E:C0:F5:7A:35:6C:52:15:87:A1:6F:AD:F4:DD:92:56:12:EC:4C

Client ID: xxxxx-xxxxx.apps.googleusercontent.com
(Auto-generated, don't need to copy this)
```

## 🆘 Still Not Working After 10 Minutes?

If you've done everything above and waited 10 minutes:

1. **Verify the package name** is exactly `com.zena.mobile`
2. **Verify the SHA-1** matches exactly (copy-paste to avoid typos)
3. **Try deleting and recreating** the Android OAuth client
4. **Wait another 10 minutes** (sometimes Google is slow)
5. **Check Supabase dashboard** - make sure Google auth is enabled and Web Client ID is added

## 📞 Need Help?

If it's still not working, share:
- Screenshot of your OAuth clients list in Google Cloud Console
- Screenshot of your Android client details
- The error logs from the app

Good luck! 🚀
