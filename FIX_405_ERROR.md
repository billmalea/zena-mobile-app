# Fix: 405 Method Not Allowed Error

## Problem

When sending a message from the mobile app, you received a **405 Method Not Allowed** error.

## Root Cause

The `ChatClient` was being initialized with the wrong base URL:

```dart
// WRONG ❌
_chatClient = ChatClient(
  baseUrl: AppConfig.apiUrl,  // This is "https://www.zena.live/api"
  authService: _authService,
);
```

This caused the client to make requests to:
```
https://www.zena.live/api/api/chat  ❌ (double /api)
```

Instead of:
```
https://www.zena.live/api/chat  ✅ (correct)
```

## Solution

Changed the base URL to use `AppConfig.baseUrl` instead of `AppConfig.apiUrl`:

```dart
// CORRECT ✅
_chatClient = ChatClient(
  baseUrl: AppConfig.baseUrl,  // This is "https://www.zena.live"
  authService: _authService,
);
```

Now the client correctly makes requests to:
```
https://www.zena.live/api/chat  ✅
```

## File Changed

**`lib/services/chat_service.dart`**
- Line 14: Changed `AppConfig.apiUrl` to `AppConfig.baseUrl`

## How It Works

The `ChatClient` internally appends `/api/chat` to the base URL:

```dart
// Inside ChatClient
await for (final event in _streamClient.streamChat(
  endpoint: '/api/chat',  // This gets appended to baseUrl
  messages: [uiMessage],
  conversationId: conversationId,
)) {
  // ...
}
```

So:
- `baseUrl` = `https://www.zena.live`
- `endpoint` = `/api/chat`
- **Final URL** = `https://www.zena.live/api/chat` ✅

## Testing

After this fix, try sending "hello" again from the mobile app. It should now work correctly!

## Expected Behavior

1. Message sends successfully
2. AI responds with streaming text
3. No 405 errors

## Additional Notes

### URL Configuration

```dart
// app_config.dart
static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://zena.live';
static String get apiUrl => '$baseUrl/api';  // Used for other API calls
```

- `baseUrl`: Base domain (for AI SDK client)
- `apiUrl`: Base domain + /api (for other API calls like conversations)

### Other API Calls

Other API calls (like `getConversations()`) still use `AppConfig.apiUrl` correctly:

```dart
// This is correct ✅
final response = await _apiService.get(AppConfig.conversationsEndpoint);
// Makes request to: https://www.zena.live/api/chat/conversations
```

## Verification

To verify the fix is working, check the logs:

```
🚀 [ApiService] Starting stream request to: https://www.zena.live/api/chat
📡 [ApiService] Response status: 200
✅ [ApiService] Data line #1: ...
```

If you see status 200 instead of 405, the fix is working!

---

**Status:** ✅ FIXED  
**Impact:** Critical - Enables chat functionality  
**Testing:** Ready to test
