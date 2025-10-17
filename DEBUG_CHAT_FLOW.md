# Debug Chat Flow - Complete Logging Guide

## Overview

I've added comprehensive logging throughout the entire chat flow to help debug the issue. Now when you send a message, you'll see exactly what's happening at each step.

## Architecture Flow

```
User sends "hello"
    ↓
ChatProvider (UI layer)
    ↓
ChatService.sendMessage()
    ↓
ChatClient.sendMessage()
    ↓
AIStreamClient.streamChat()
    ↓
HTTP Request to backend
    ↓
Parse SSE stream
    ↓
Emit AIStreamEvent
    ↓
Convert to ChatResponse
    ↓
Convert to ChatEvent
    ↓
Update UI
```

## Expected Log Output

When you send "hello", you should see logs in this order:

### 1. ChatService Layer
```
🎬 [ChatService] sendMessage called
💬 [ChatService] Message: hello
🆔 [ChatService] Conversation ID: null
🔄 [ChatService] Calling ChatClient...
```

### 2. ChatClient Layer
```
🎯 [ChatClient] sendMessage called
💬 [ChatClient] Message: hello
🆔 [ChatClient] Conversation ID: null
📨 [ChatClient] UIMessage created: msg-1234567890
🔄 [ChatClient] Starting stream...
```

### 3. AIStreamClient Layer
```
🚀 [AIStreamClient] Starting request
📍 [AIStreamClient] Base URL: https://www.zena.live
📍 [AIStreamClient] Endpoint: /api/chat
📍 [AIStreamClient] Full URL: https://www.zena.live/api/chat
📤 [AIStreamClient] Request body: {"messages":[...]}
🔑 [AIStreamClient] Headers: [Content-Type, Accept, Authorization]
⏳ [AIStreamClient] Sending request...
```

### 4. HTTP Response
```
📡 [AIStreamClient] Response status: 200
📋 [AIStreamClient] Response headers: {content-type: text/event-stream, ...}
✅ [AIStreamClient] Request successful, starting to parse stream...
```

### 5. Stream Parsing
```
🎬 [AIStreamClient] Starting stream parsing...
📦 [AIStreamClient] Chunk #1 received (256 bytes)
📝 [AIStreamClient] Processing line: data: 0:"Hello"
🔢 [AIStreamClient] UIMessage format detected
✅ [AIStreamClient] Event #1: AIStreamEventType.textDelta
```

### 6. Event Processing
```
📥 [ChatClient] Received event: AIStreamEventType.textDelta
📥 [ChatService] Received response: text=5 chars, error=null
✅ [ChatService] Text response: Hello...
```

### 7. Completion
```
🎉 [AIStreamClient] Stream parsing complete. Total chunks: 10, Events: 15
🎉 [ChatService] Stream complete
```

## Troubleshooting by Log Output

### Scenario 1: No Logs at All

**Symptom:** No logs appear when sending message

**Possible Causes:**
1. ChatService not being called
2. UI not connected to ChatService
3. Hot reload didn't apply changes

**Solution:**
```bash
# Full restart
flutter clean
flutter pub get
flutter run
```

### Scenario 2: Logs Stop at ChatService

**Symptom:**
```
🎬 [ChatService] sendMessage called
💬 [ChatService] Message: hello
🔄 [ChatService] Calling ChatClient...
[NOTHING AFTER THIS]
```

**Possible Causes:**
1. ChatClient not initialized
2. Exception in ChatClient constructor
3. BaseUrl configuration issue

**Check:**
```dart
// In chat_service.dart constructor
print('🔧 [ChatService] Initializing ChatClient with baseUrl: ${AppConfig.baseUrl}');
```

### Scenario 3: Logs Stop at AIStreamClient Request

**Symptom:**
```
🚀 [AIStreamClient] Starting request
📍 [AIStreamClient] Full URL: https://www.zena.live/api/chat
⏳ [AIStreamClient] Sending request...
[NOTHING AFTER THIS]
```

**Possible Causes:**
1. Network timeout
2. No internet connection
3. Backend not responding
4. Firewall blocking request

**Check:**
1. Device has internet
2. Can access https://www.zena.live in browser
3. Backend is running
4. No proxy/VPN issues

### Scenario 4: 405 Error

**Symptom:**
```
📡 [AIStreamClient] Response status: 405
❌ [AIStreamClient] Request failed with status: 405
```

**Cause:** Wrong URL (double /api)

**Check the Full URL log:**
- ❌ Wrong: `https://www.zena.live/api/api/chat`
- ✅ Correct: `https://www.zena.live/api/chat`

**Solution:** Already fixed - baseUrl should be `https://www.zena.live`

### Scenario 5: 401 Error

**Symptom:**
```
📡 [AIStreamClient] Response status: 401
```

**Cause:** Missing or invalid authentication token

**Check:**
```
🔑 [AIStreamClient] Headers: [Content-Type, Accept, Authorization]
```

Should include `Authorization` header.

**Solution:**
1. Log out and log back in
2. Check token is being retrieved
3. Verify token is valid

### Scenario 6: 500 Error

**Symptom:**
```
📡 [AIStreamClient] Response status: 500
```

**Cause:** Backend error

**Check:**
1. Backend logs
2. Database connection
3. API configuration

### Scenario 7: No Stream Data

**Symptom:**
```
✅ [AIStreamClient] Request successful, starting to parse stream...
🎬 [AIStreamClient] Starting stream parsing...
[NO CHUNKS RECEIVED]
```

**Possible Causes:**
1. Backend not streaming
2. Response not in SSE format
3. Connection closed prematurely

**Check:**
- Backend logs for streaming response
- Response headers should include `content-type: text/event-stream`

### Scenario 8: Stream Data But No Events

**Symptom:**
```
📦 [AIStreamClient] Chunk #1 received (256 bytes)
📝 [AIStreamClient] Processing line: ...
⚠️ [AIStreamClient] Failed to parse JSON: ...
```

**Possible Causes:**
1. Wrong stream format
2. Malformed JSON
3. Unexpected event type

**Check:**
- The actual line being processed
- Compare with expected format

### Scenario 9: Events But No UI Update

**Symptom:**
```
✅ [ChatService] Text response: Hello...
[UI NOT UPDATING]
```

**Possible Causes:**
1. ChatProvider not listening
2. UI not rebuilding
3. State not updating

**Check:**
- ChatProvider logs
- UI widget logs
- State management

## How to Use These Logs

### Step 1: Send "hello"

Send a simple "hello" message and watch the logs.

### Step 2: Identify Where It Stops

Find the last log message that appears. This tells you where the problem is.

### Step 3: Check the Scenario

Match your log output to one of the scenarios above.

### Step 4: Apply the Solution

Follow the solution for your scenario.

## Additional Debug Commands

### Check Configuration
```dart
print('🔧 Base URL: ${AppConfig.baseUrl}');
print('🔧 API URL: ${AppConfig.apiUrl}');
print('🔧 Chat Endpoint: ${AppConfig.chatEndpoint}');
```

### Check Authentication
```dart
final token = await AuthService().getAccessToken();
print('🔑 Token: ${token != null ? "Present (${token.length} chars)" : "Missing"}');
```

### Check Network
```dart
try {
  final response = await http.get(Uri.parse('https://www.zena.live'));
  print('🌐 Network test: ${response.statusCode}');
} catch (e) {
  print('🌐 Network test failed: $e');
}
```

## What to Report

If the issue persists, provide:

1. **Last log message** - Where did it stop?
2. **Full URL** - From the log
3. **Status code** - If request was made
4. **Error message** - If any
5. **Device info** - Android/iOS version
6. **Network** - WiFi/Mobile data

## Quick Test

Run this to verify logging is working:

```dart
// In chat_service.dart
print('🧪 [TEST] ChatService initialized');
print('🧪 [TEST] Base URL: ${AppConfig.baseUrl}');
```

You should see these logs when the app starts.

---

**Status:** Comprehensive logging added  
**Next Step:** Send "hello" and check logs  
**Expected:** See complete flow from start to finish
