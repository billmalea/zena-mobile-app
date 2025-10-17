# AI SDK UIMessage Format - Complete Implementation

## Overview
The Next.js API uses AI SDK's `toUIMessageStreamResponse()` which sends events in UIMessage format. The mobile app now correctly parses all event types.

## Event Types

### 1. Text Events
**Format**: `{"type":"text","text":"Hello! How can I help you?"}`

**Fields**:
- `type`: `"text"`
- `text`: The actual message content

**Mobile Handling**:
```dart
if (type == 'text') {
  final text = json['text'] as String?;
  yield ChatEvent(type: 'text', content: text);
}
```

**Example**:
```json
{"type":"text","text":"Hello! How can I help you today?"}
```

### 2. Tool Events
**Format**: `{"type":"tool-{toolName}","state":"...","output":{...}}`

**Fields**:
- `type`: `"tool-searchProperties"`, `"tool-submitProperty"`, etc.
- `state`: Tool execution state
  - `input-streaming`: Tool is being invoked
  - `input-available`: Tool input ready
  - `output-available`: Tool completed successfully
  - `output-error`: Tool failed
- `output`: Tool result (when state is `output-available`)
- `errorText`: Error message (when state is `output-error`)

**Mobile Handling**:
```dart
if (type?.startsWith('tool-') == true) {
  final toolName = type!.replaceFirst('tool-', '');
  final state = json['state'];
  final output = json['output'];
  
  if (state == 'output-available') {
    yield ChatEvent(
      type: 'tool-result',
      toolResult: {'toolName': toolName, 'result': output}
    );
  }
}
```

**Examples**:
```json
// Tool being invoked
{"type":"tool-searchProperties","state":"input-streaming"}

// Tool completed
{"type":"tool-searchProperties","state":"output-available","output":{"properties":[...]}}

// Tool failed
{"type":"tool-searchProperties","state":"output-error","errorText":"Failed to search"}
```

### 3. Step Events
**Format**: `{"type":"step-start"}`

**Purpose**: Metadata event indicating a new step in the AI's reasoning

**Mobile Handling**: Ignored (metadata only)

```dart
if (type == 'step-start') {
  // Ignore - just metadata
}
```

### 4. Finish Events
**Format**: `{"type":"finish"}` or `{"type":"finish-step"}`

**Purpose**: Indicates stream completion

**Mobile Handling**: Reset buffer for next message

```dart
if (type == 'finish' || type == 'finish-step') {
  textBuffer = ''; // Reset for next message
}
```

## Complete Event Flow

### Simple Text Response
```
1. {"type":"step-start"}
2. {"type":"text","text":"Hello! How can I help you today?"}
3. {"type":"finish"}
```

### Response with Tool
```
1. {"type":"step-start"}
2. {"type":"tool-searchProperties","state":"input-streaming"}
3. {"type":"tool-searchProperties","state":"output-available","output":{...}}
4. {"type":"text","text":"I found 5 properties for you."}
5. {"type":"finish"}
```

### Multiple Tools
```
1. {"type":"step-start"}
2. {"type":"tool-searchProperties","state":"output-available","output":{...}}
3. {"type":"step-start"}
4. {"type":"tool-getNeighborhoodInfo","state":"output-available","output":{...}}
5. {"type":"text","text":"Here's what I found..."}
6. {"type":"finish"}
```

## Mobile App Implementation

### ChatService
Parses SSE stream and yields `ChatEvent` objects:

```dart
Stream<ChatEvent> sendMessage({
  required String message,
  String? conversationId,
}) async* {
  // Parse each SSE event
  await for (final data in _apiService.streamPost(...)) {
    final json = jsonDecode(data);
    final type = json['type'];
    
    // Handle text
    if (type == 'text') {
      yield ChatEvent(type: 'text', content: json['text']);
    }
    
    // Handle tools
    if (type?.startsWith('tool-')) {
      final toolName = type.replaceFirst('tool-', '');
      if (json['state'] == 'output-available') {
        yield ChatEvent(
          type: 'tool-result',
          toolResult: {'toolName': toolName, 'result': json['output']}
        );
      }
    }
  }
}
```

### ChatProvider
Handles events and updates UI:

```dart
void _handleChatEvent(ChatEvent event, String messageId) {
  if (event.isText) {
    // Update message content
    _messages[index] = message.copyWith(content: event.content);
    notifyListeners();
  }
  
  if (event.isToolResult) {
    // Add tool result to message
    final toolResult = ToolResult(
      toolName: event.toolResult['toolName'],
      result: event.toolResult['result']
    );
    _messages[index] = message.copyWith(
      toolResults: [...message.toolResults, toolResult]
    );
    notifyListeners();
  }
}
```

## Testing Scenarios

### 1. Simple Greeting
**Input**: "hello"
**Expected Events**:
- `step-start`
- `text`: "Hello! How can I help you today?"
- `finish`

### 2. Property Search
**Input**: "find properties in Nairobi"
**Expected Events**:
- `step-start`
- `tool-searchProperties` (input-streaming)
- `tool-searchProperties` (output-available with results)
- `text`: "I found X properties..."
- `finish`

### 3. Property Submission
**Input**: "I want to list my property"
**Expected Events**:
- `step-start`
- `tool-submitProperty` (output-available)
- `text`: "Great! Please upload a video..."
- `finish`

### 4. Error Case
**Input**: Invalid request
**Expected Events**:
- `step-start`
- `tool-something` (output-error)
- `text`: "I encountered an error..."
- `finish`

## Debugging

### Enable Detailed Logs
The mobile app logs every event:
```
📋 [ChatService] JSON object detected
📝 [ChatService] Event type: text
✅ [ChatService] Text event #1: "Hello!"
🎯 [ChatProvider] Received event: text
💬 [ChatProvider] Updating text content: "Hello!"
```

### Check Event Counts
At stream end:
```
📊 [ChatService] Total events: 8
📊 [ChatService] Text events: 1
📊 [ChatService] Tool events: 2
```

### Server Logs
Check what the API sends:
```
🏁 Last message parts: 2
🏁 Part 0 type: step-start
🏁 Part 1 type: text
🏁 Part 1 text preview: Hello! How can I help you today?
```

## Key Differences from DataStream Format

| Feature | UIMessage Format | DataStream Format |
|---------|-----------------|-------------------|
| Text | `{"type":"text","text":"..."}` | `{"type":"text-delta","textDelta":"..."}` |
| Tools | `{"type":"tool-X","state":"..."}` | `{"type":"tool-call",...}` |
| Metadata | `{"type":"step-start"}` | None |
| Streaming | Full text in each event | Incremental deltas |

## Related Files

- `lib/services/chat_service.dart` - Parses UIMessage format
- `lib/services/api_service.dart` - Handles SSE streaming
- `lib/providers/chat_provider.dart` - Updates UI with events
- `app/api/chat/route.ts` - Sends UIMessage format
- `app/chat/page.tsx` - Web app (reference implementation)

## Summary

✅ **Text responses** - Fully supported  
✅ **Tool calls** - Fully supported  
✅ **Tool results** - Fully supported  
✅ **Error handling** - Fully supported  
✅ **Metadata events** - Handled (ignored)  
✅ **Stream completion** - Handled  

The mobile app now has complete parity with the web app in terms of handling AI SDK responses!
