# Streaming Format Fix - AI SDK Compatibility

## Problem
The mobile app was not receiving responses from the chat API even though the server returned 200 OK. The issue was that the mobile app was trying to parse the stream as simple JSON, but the API uses the AI SDK's `toUIMessageStreamResponse` format.

## Root Cause
The Next.js API uses `toUIMessageStreamResponse()` from the AI SDK, which sends data in a specific format:
- `0:"text"` - Text deltas (incremental text updates)
- `2:[...]` - Tool calls
- `8:[...]` - Tool results
- `9:{...}` - Finish reason
- `e:{...}` - Errors

The mobile app was expecting simple JSON like:
```json
{"type": "text", "content": "hello"}
```

But was receiving:
```
data: 0:"hello"
data: 0:" world"
```

## Solution
Updated the mobile app's `chat_service.dart` to parse the AI SDK's streaming format correctly, matching how the web app's `useChat` hook handles it.

### Implementation

**Before** (Incorrect):
```dart
final json = jsonDecode(data) as Map<String, dynamic>;
final type = json['type'] as String?;

if (type == 'text') {
  yield ChatEvent(
    type: 'text',
    content: json['content'] as String?,
  );
}
```

**After** (Correct):
```dart
// AI SDK toUIMessageStreamResponse format
if (data.startsWith('0:')) {
  // Text delta - extract and accumulate
  final textContent = data.substring(2);
  final decodedText = jsonDecode(textContent) as String;
  textBuffer += decodedText;
  
  yield ChatEvent(
    type: 'text',
    content: textBuffer,
  );
} else if (data.startsWith('2:')) {
  // Tool call
  final toolCallsJson = data.substring(2);
  final toolCalls = jsonDecode(toolCallsJson) as List;
  // Process tool calls...
} else if (data.startsWith('8:')) {
  // Tool result
  final toolResultsJson = data.substring(2);
  final toolResults = jsonDecode(toolResultsJson) as List;
  // Process tool results...
}
```

## AI SDK Stream Format

The AI SDK uses a numbered prefix system:

| Prefix | Type | Description | Example |
|--------|------|-------------|---------|
| `0:` | Text Delta | Incremental text content | `0:"Hello"` |
| `2:` | Tool Calls | Array of tool invocations | `2:[{"toolName":"search",...}]` |
| `8:` | Tool Results | Array of tool outputs | `8:[{"result":{...}}]` |
| `9:` | Finish | Stream completion info | `9:{"finishReason":"stop"}` |
| `e:` | Error | Error information | `e:{"message":"Error"}` |

## Key Changes

### 1. Text Accumulation
Text is sent as deltas (incremental updates), so we accumulate them:
```dart
String textBuffer = '';

// Each delta adds to the buffer
textBuffer += decodedText;

// Yield the accumulated text
yield ChatEvent(type: 'text', content: textBuffer);
```

### 2. Tool Events
Separated tool calls and tool results:
```dart
// Tool call (when AI decides to use a tool)
yield ChatEvent(type: 'tool-call', toolResult: toolCall);

// Tool result (when tool execution completes)
yield ChatEvent(type: 'tool-result', toolResult: toolResult);
```

### 3. Error Handling
Parse errors from the `e:` prefix:
```dart
if (data.startsWith('e:')) {
  final errorJson = data.substring(2);
  final error = jsonDecode(errorJson);
  yield ChatEvent(type: 'error', content: error['message']);
}
```

## Benefits

✅ **Compatible with AI SDK** - Mobile app now parses the same format as web  
✅ **No API changes needed** - API continues using standard AI SDK format  
✅ **Streaming works** - Text appears incrementally as it's generated  
✅ **Tool support** - Can handle tool calls and results  
✅ **Error handling** - Properly displays errors from the stream  

## Testing

After this fix:
1. ✅ Mobile app receives text responses
2. ✅ Text streams incrementally (word by word)
3. ✅ Tool calls are detected
4. ✅ Tool results are displayed
5. ✅ Errors are shown properly

### Test Scenarios
- **Simple message**: "Hello" → Should see text streaming
- **Tool usage**: "Find properties in Nairobi" → Should see tool calls and results
- **Error case**: Invalid request → Should see error message

## Related Files

- `zena_mobile_app/lib/services/chat_service.dart` - Updated stream parsing
- `zena/app/api/chat/route.ts` - Uses `toUIMessageStreamResponse()`
- `zena/app/chat/page.tsx` - Web app uses `useChat` hook (handles format automatically)

## Technical Notes

### Why This Format?
The AI SDK uses this format because:
1. **Efficient** - Numbered prefixes are compact
2. **Typed** - Each prefix indicates the data type
3. **Streamable** - Can send different types of data in the same stream
4. **Standard** - Used by all AI SDK client libraries

### SSE (Server-Sent Events)
The stream uses SSE format:
```
data: 0:"Hello"
data: 0:" world"
data: 9:{"finishReason":"stop"}
```

The `api_service.dart` already handles SSE correctly by:
1. Looking for `data: ` prefix
2. Extracting the content after `data: `
3. Yielding each line to the chat service

### Buffer Management
Text buffer is reset when:
- Stream finishes (`9:` prefix)
- New message starts
- Error occurs

This ensures each message starts fresh.

## Future Improvements

Potential enhancements:
- [ ] Add typing indicators based on stream state
- [ ] Show tool execution progress
- [ ] Handle partial tool results
- [ ] Add retry logic for failed streams
- [ ] Cache responses for offline viewing

## References

- [AI SDK Documentation](https://sdk.vercel.ai/docs)
- [Server-Sent Events (SSE)](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events)
- [AI SDK React Hooks](https://sdk.vercel.ai/docs/ai-sdk-ui/overview)
