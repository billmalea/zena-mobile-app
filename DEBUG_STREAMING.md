# Debug Streaming - Logging Guide

## Added Comprehensive Logging

To help diagnose streaming issues, I've added detailed logging throughout the streaming pipeline.

## Log Levels

### 🚀 ApiService - Request Level
```
🚀 [ApiService] Starting stream request to: https://www.zena.live/api/chat
📤 [ApiService] Request body: {"messages":[...]}
📡 [ApiService] Response status: 200
📋 [ApiService] Response headers: {...}
```

### 📦 ApiService - Chunk Level
```
📦 [ApiService] Chunk #1 received (245 bytes)
📝 [ApiService] Raw chunk: data: 0:"Hello"\ndata: 0:" world"...
📄 [ApiService] Split into 3 lines
✅ [ApiService] Data line #1: 0:"Hello"
✅ [ApiService] Data line #2: 0:" world"
🏁 [ApiService] Stream completed with [DONE] marker
🎉 [ApiService] Stream finished. Total chunks: 5, Data lines: 12
```

### 🔄 ChatService - Event Level
```
🎬 [ChatService] Starting to process stream events
🔄 [ChatService] Event #1: 0:"Hello"
📝 [ChatService] Text delta detected
📄 [ChatService] Text content: "Hello"
✅ [ChatService] Decoded text: "Hello"
📚 [ChatService] Buffer now: "Hello"
```

### 🔧 ChatService - Tool Events
```
🔧 [ChatService] Tool call detected
🔧 [ChatService] Tool calls JSON: [{"toolName":"searchProperties",...}]
✅ [ChatService] Parsed 1 tool calls
🛠️ [ChatService] Tool call: searchProperties

📊 [ChatService] Tool result detected
📊 [ChatService] Tool results JSON: [{"result":{...}}]
✅ [ChatService] Parsed 1 tool results
📦 [ChatService] Tool result: searchProperties
```

### 🏁 ChatService - Completion
```
🏁 [ChatService] Finish reason detected
🎬 [ChatService] Stream processing complete. Total events: 15
```

### ❌ Error Logging
```
❌ [ApiService] Stream error: TimeoutException
❌ [ChatService] Failed to parse tool calls: FormatException
⚠️ [ChatService] JSON decode failed, treating as plain text
⚠️ [ChatService] Unknown event type: 3:"something"
```

## How to Use

### 1. Run the Mobile App in Debug Mode
```bash
flutter run
```

### 2. Send a Test Message
In the app, send: "hello"

### 3. Check the Console Output
Look for the log sequence:
1. Request initiated (🚀)
2. Response received (📡)
3. Chunks arriving (📦)
4. Events being processed (🔄)
5. Text being decoded (📝)
6. Stream completing (🏁)

## Expected Log Flow

### Simple Text Message
```
🚀 [ApiService] Starting stream request...
📡 [ApiService] Response status: 200
📦 [ApiService] Chunk #1 received
✅ [ApiService] Data line #1: 0:"Hello"
🔄 [ChatService] Event #1: 0:"Hello"
📝 [ChatService] Text delta detected
✅ [ChatService] Decoded text: "Hello"
📦 [ApiService] Chunk #2 received
✅ [ApiService] Data line #2: 0:" there"
🔄 [ChatService] Event #2: 0:" there"
✅ [ChatService] Decoded text: " there"
📚 [ChatService] Buffer now: "Hello there"
🏁 [ChatService] Finish reason detected
🎬 [ChatService] Stream processing complete
```

### Message with Tool Call
```
🚀 [ApiService] Starting stream request...
📡 [ApiService] Response status: 200
📦 [ApiService] Chunk #1 received
✅ [ApiService] Data line #1: 2:[{"toolName":"searchProperties",...}]
🔄 [ChatService] Event #1: 2:[...]
🔧 [ChatService] Tool call detected
✅ [ChatService] Parsed 1 tool calls
🛠️ [ChatService] Tool call: searchProperties
📦 [ApiService] Chunk #2 received
✅ [ApiService] Data line #2: 8:[{"result":{...}}]
🔄 [ChatService] Event #2: 8:[...]
📊 [ChatService] Tool result detected
✅ [ChatService] Parsed 1 tool results
📦 [ChatService] Tool result: searchProperties
```

## Common Issues to Look For

### Issue 1: No Data Lines
```
📦 [ApiService] Chunk #1 received (100 bytes)
📝 [ApiService] Raw chunk: some text without data: prefix
📄 [ApiService] Split into 1 lines
⚠️ [ApiService] Non-data line: some text
```
**Problem**: Response is not in SSE format
**Solution**: Check API is using `toUIMessageStreamResponse()`

### Issue 2: Malformed JSON
```
🔄 [ChatService] Event #1: 0:Hello (missing quotes)
📝 [ChatService] Text delta detected
⚠️ [ChatService] JSON decode failed, treating as plain text
```
**Problem**: AI SDK sending invalid JSON
**Solution**: Check AI SDK version compatibility

### Issue 3: Unknown Event Type
```
🔄 [ChatService] Event #1: 3:"something"
⚠️ [ChatService] Unknown event type: 3:"something"
```
**Problem**: Receiving event type we don't handle
**Solution**: Update chat_service.dart to handle new event types

### Issue 4: Empty Stream
```
🚀 [ApiService] Starting stream request...
📡 [ApiService] Response status: 200
🎉 [ApiService] Stream finished. Total chunks: 0, Data lines: 0
```
**Problem**: No data received from server
**Solution**: Check server logs, verify authentication

## Debugging Steps

### Step 1: Verify Request
Look for:
- ✅ Correct URL (https://www.zena.live/api/chat)
- ✅ Status 200
- ✅ Authorization header present

### Step 2: Verify Chunks
Look for:
- ✅ Chunks being received
- ✅ Data lines being extracted
- ✅ Proper SSE format (`data: ` prefix)

### Step 3: Verify Parsing
Look for:
- ✅ Events being processed
- ✅ Text being decoded
- ✅ Buffer accumulating

### Step 4: Verify Completion
Look for:
- ✅ Finish reason received
- ✅ Stream processing complete
- ✅ No errors

## Removing Logs

Once debugging is complete, you can remove the print statements or wrap them in a debug flag:

```dart
// Add to app_config.dart
static const bool enableDebugLogs = false;

// In services
if (AppConfig.enableDebugLogs) {
  print('🚀 [ApiService] ...');
}
```

## Related Files

- `lib/services/api_service.dart` - HTTP streaming and SSE parsing
- `lib/services/chat_service.dart` - AI SDK format parsing
- `lib/providers/chat_provider.dart` - State management

## Next Steps

1. Run the app and send "hello"
2. Copy the console output
3. Share the logs to diagnose any issues
4. Look for the specific error patterns above
