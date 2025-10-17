# Testing Mobile Chat - Quick Guide

## Prerequisites
✅ BASE_URL updated to `https://www.zena.live`  
✅ API routes support Bearer token authentication  
✅ Flutter app configured correctly  

## Test Steps

### 1. Restart Flutter App
**Important**: Full restart required (not hot reload) because .env changes need to be reloaded.

```bash
# Stop the app completely
# Then rebuild and run
flutter run
```

### 2. Sign In
- Open the app
- Tap "Sign in with Google"
- Complete Google sign-in flow
- Verify you're signed in (should see chat screen)

### 3. Send Test Message
- Type a simple message: "hello"
- Tap send
- **Expected**: Message sends successfully, AI responds

### 4. Verify Success
✅ No 307 error  
✅ No 401 error  
✅ Message appears in chat  
✅ AI responds with a message  

## Troubleshooting

### Still Getting 307?
- Check `.env.local` has `BASE_URL=https://www.zena.live` (with www)
- Restart the app completely (not hot reload)
- Clear app data and reinstall if needed

### Still Getting 401?
- Verify you're signed in (check auth state)
- Check Flutter console for auth token logs
- Verify Supabase credentials in `.env.local` are correct
- Check that `auth_service.dart` is getting the access token

### Check Auth Token
Add this to your Flutter app to debug:

```dart
// In your chat screen or API service
final token = await AuthService().getAccessToken();
print('🔑 Access Token: ${token?.substring(0, 20)}...');
```

### Check API Request
Look for these logs in your Next.js console:

```
Authentication successful
userId: <user-id>
email: <user-email>
authMethod: Bearer token (mobile)
```

## Manual API Test

You can test the API directly with curl (replace TOKEN with your actual token):

```bash
curl -X POST https://www.zena.live/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"messages":[{"id":"test","role":"user","parts":[{"type":"text","text":"hello"}]}]}'
```

**Expected**: Stream of SSE events with AI response (not 401 error)

## Success Indicators

When everything works correctly, you should see:

### In Flutter Console:
```
✅ [AuthService] Authentication successful
✅ [ApiService] POST /chat - Status: 200
✅ [ChatService] Streaming response received
```

### In Next.js Console:
```
✅ Authentication successful
✅ userId: <uuid>
✅ authMethod: Bearer token (mobile)
✅ AI stream finished
```

### In the App:
- Your message appears immediately
- AI response streams in word by word
- No error messages

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| 307 Redirect | Using `zena.live` instead of `www.zena.live` | Update BASE_URL in .env.local |
| 401 Unauthorized | Token not sent or invalid | Check auth service, verify sign-in |
| Connection timeout | Wrong URL or network issue | Check BASE_URL, test network |
| Empty response | API error | Check Next.js logs for errors |

## Need Help?

If chat still doesn't work after following these steps:

1. Check all three documentation files:
   - `CHAT_307_ERROR_FIX.md`
   - `AUTHENTICATION_FIX.md`
   - `MOBILE_CHAT_FIX_SUMMARY.md`

2. Verify all files were updated:
   - `.env.local` (BASE_URL)
   - `auth-helper.ts` (created)
   - `chat/route.ts` (updated)
   - `conversation/route.ts` (updated)

3. Check logs in both Flutter console and Next.js console for specific errors
