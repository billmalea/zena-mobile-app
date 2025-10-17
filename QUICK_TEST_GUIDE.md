# Quick Test Guide - After 405 Fix

## What Was Fixed

The mobile app was making requests to the wrong URL:
- **Before:** `https://www.zena.live/api/api/chat` ❌
- **After:** `https://www.zena.live/api/chat` ✅

## How to Test

### 1. Restart the App

```bash
# Stop the app
flutter run --release

# Or hot restart
# Press 'R' in the terminal
```

### 2. Send a Test Message

1. Open the chat screen
2. Type "hello"
3. Press send

### 3. Expected Results

#### ✅ Success Indicators

**In the logs, you should see:**
```
🚀 [ApiService] Starting stream request to: https://www.zena.live/api/chat
📡 [ApiService] Response status: 200
✅ [ApiService] Data line #1: ...
🎯 [ChatProvider] Received event: text
```

**In the UI:**
- Message sends successfully
- AI starts responding
- Text appears character by character (streaming)
- No error messages

#### ❌ If Still Failing

**Check these:**

1. **Network Connection**
   - Ensure device has internet
   - Try opening https://www.zena.live in browser

2. **Authentication**
   - Ensure you're logged in
   - Check if token is valid

3. **Backend Status**
   - Verify backend is running
   - Check backend logs for errors

4. **Logs**
   - Look for error messages in console
   - Note the status code (should be 200)

### 4. Test Different Messages

Try these to verify full functionality:

```
1. "hello" - Simple greeting
2. "search for properties in Nairobi" - Tool call
3. "what is 2+2?" - Simple question
4. "tell me a joke" - Creative response
```

### 5. Verify Features

- [ ] Text streaming works
- [ ] Tool calls work (if applicable)
- [ ] Error handling works
- [ ] Multiple messages work
- [ ] Conversation history works

## Troubleshooting

### Still Getting 405?

**Check the URL in logs:**
```
🚀 [ApiService] Starting stream request to: [URL HERE]
```

Should be: `https://www.zena.live/api/chat`

If it's still wrong, verify:
1. Hot restart was done (not just hot reload)
2. Code changes were saved
3. No build cache issues

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Getting 401 (Unauthorized)?

**Issue:** Authentication token missing or invalid

**Solution:**
1. Log out
2. Log back in
3. Try sending message again

### Getting 500 (Server Error)?

**Issue:** Backend error

**Check:**
1. Backend logs
2. Database connection
3. API configuration

### No Response?

**Issue:** Streaming not working

**Check:**
1. Network connection
2. Timeout settings
3. Backend streaming response

## Debug Mode

Enable detailed logging:

```dart
// In chat_service.dart
print('🔍 [DEBUG] Base URL: ${AppConfig.baseUrl}');
print('🔍 [DEBUG] API URL: ${AppConfig.apiUrl}');
print('🔍 [DEBUG] Full URL: ${AppConfig.baseUrl}/api/chat');
```

## Success Checklist

- [ ] App restarts without errors
- [ ] Can send "hello" message
- [ ] Receives AI response
- [ ] Response streams (not all at once)
- [ ] No 405 errors in logs
- [ ] Status code is 200
- [ ] Multiple messages work
- [ ] Tool calls work (if tested)

## Next Steps

Once basic chat works:

1. Test tool calls (property search, etc.)
2. Test file uploads
3. Test conversation history
4. Test error handling
5. Test on different devices
6. Test on different networks

## Performance Check

Monitor these metrics:

- **Response Time:** Should be < 2 seconds for first token
- **Memory Usage:** Should stay < 200 MB
- **Network Usage:** Should be minimal (streaming)
- **Battery Usage:** Should be normal

## Known Issues

None currently. If you encounter issues, document them here.

## Support

If issues persist:

1. Check logs for error messages
2. Verify backend is accessible
3. Test with Postman/curl
4. Check network connectivity
5. Review authentication flow

---

**Status:** Ready to test  
**Expected Result:** Chat works without 405 errors  
**Time to Test:** 2-3 minutes
