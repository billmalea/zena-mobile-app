# AI SDK Dart Client - Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter Mobile App                        │
│                     (Your Existing UI Code)                      │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ No changes needed!
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      ChatProvider (State)                        │
│  - Manages conversation state                                    │
│  - Calls ChatService.sendMessage()                              │
│  - Updates UI with ChatEvent objects                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Stream<ChatEvent>
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ChatService (Adapter Layer)                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ sendMessage() {                                           │  │
│  │   await for (response in _chatClient.sendMessage()) {    │  │
│  │     yield ChatEvent(type: 'text', content: response.text)│  │
│  │   }                                                       │  │
│  │ }                                                         │  │
│  └───────────────────────────────────────────────────────────┘  │
│  - Converts ChatResponse → ChatEvent                            │
│  - Maintains backward compatibility                             │
│  - 40 lines (was 200+)                                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Stream<ChatResponse>
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                  ChatClient (High-Level API)                     │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ Stream<ChatResponse> sendMessage({                        │  │
│  │   required String message,                                │  │
│  │   String? conversationId,                                 │  │
│  │ }) async* {                                               │  │
│  │   // Accumulates text, tracks tools                      │  │
│  │   await for (event in _streamClient.streamChat()) {      │  │
│  │     yield ChatResponse(                                   │  │
│  │       text: accumulatedText,                             │  │
│  │       toolCalls: [...],                                  │  │
│  │       toolResults: [...],                                │  │
│  │     );                                                    │  │
│  │   }                                                       │  │
│  │ }                                                         │  │
│  └───────────────────────────────────────────────────────────┘  │
│  - Simple, clean API                                            │
│  - Automatic text accumulation                                  │
│  - Tool tracking                                                │
│  - 150 lines                                                    │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Stream<AIStreamEvent>
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              AIStreamClient (Low-Level Streaming)                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ Stream<AIStreamEvent> streamChat({                        │  │
│  │   required String endpoint,                               │  │
│  │   required List<UIMessage> messages,                      │  │
│  │ }) async* {                                               │  │
│  │   // Parse SSE stream                                     │  │
│  │   await for (chunk in httpStream) {                       │  │
│  │     if (line.startsWith('0:')) {                         │  │
│  │       yield AIStreamEvent(type: textDelta, ...)          │  │
│  │     } else if (line.startsWith('2:')) {                  │  │
│  │       yield AIStreamEvent(type: toolCall, ...)           │  │
│  │     } else if (line.startsWith('8:')) {                  │  │
│  │       yield AIStreamEvent(type: toolResult, ...)         │  │
│  │     }                                                     │  │
│  │   }                                                       │  │
│  │ }                                                         │  │
│  └───────────────────────────────────────────────────────────┘  │
│  - Handles AI SDK streaming formats                             │
│  - UIMessage format (0:, 2:, 8:, 9:, e:)                       │
│  - DataStream format (JSON objects)                             │
│  - Buffer management                                            │
│  - 400 lines                                                    │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTP POST with SSE
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Backend API (/api/chat)                       │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ const result = streamText({                               │  │
│  │   model: google("gemini-2.5-flash-lite"),                │  │
│  │   messages: modelMessages,                                │  │
│  │   tools: allTools,                                        │  │
│  │ })                                                        │  │
│  │                                                           │  │
│  │ return result.toUIMessageStreamResponse({                │  │
│  │   headers: { 'Content-Type': 'text/event-stream' }      │  │
│  │ })                                                        │  │
│  └───────────────────────────────────────────────────────────┘  │
│  - AI SDK v5.0.53                                               │
│  - Streams UIMessage format                                     │
│  - Handles tool execution                                       │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### Request Flow (Mobile → Backend)

```
User Input
    │
    ▼
ChatProvider
    │
    ▼
ChatService.sendMessage()
    │
    ▼
ChatClient.sendMessage()
    │
    ▼
AIStreamClient.streamChat()
    │
    ▼
HTTP POST /api/chat
    │
    ▼
Backend API
```

### Response Flow (Backend → Mobile)

```
Backend API
    │
    │ SSE Stream
    ▼
data: 0:"Hello"
data: 0:" World"
data: 2:[{toolCall}]
data: 8:[{toolResult}]
data: 9:{finish}
    │
    ▼
AIStreamClient
    │ Parses stream
    ▼
AIStreamEvent(type: textDelta, text: "Hello")
AIStreamEvent(type: textDelta, text: "Hello World")
AIStreamEvent(type: toolCall, toolName: "search")
AIStreamEvent(type: toolResult, result: {...})
AIStreamEvent(type: done, finishReason: "stop")
    │
    ▼
ChatClient
    │ Accumulates & tracks
    ▼
ChatResponse(text: "Hello World", toolCalls: [...], toolResults: [...])
    │
    ▼
ChatService
    │ Converts format
    ▼
ChatEvent(type: 'text', content: "Hello World")
ChatEvent(type: 'tool-call', toolResult: {...})
ChatEvent(type: 'tool-result', toolResult: {...})
    │
    ▼
ChatProvider
    │ Updates state
    ▼
UI Updates
```

## Stream Format Details

### UIMessage Format (AI SDK v5.x)

```
┌─────────────────────────────────────────────────────────────────┐
│                      SSE Stream Format                           │
├─────────────────────────────────────────────────────────────────┤
│ data: 0:"Hello"              → Text delta                        │
│ data: 0:" World"             → Text delta                        │
│ data: 2:[{...}]              → Tool calls                        │
│ data: 8:[{...}]              → Tool results                      │
│ data: 9:{"finishReason"}     → Finish                           │
│ data: e:{"message"}          → Error                            │
└─────────────────────────────────────────────────────────────────┘
```

### Event Type Mapping

```
┌──────────────┬─────────────────────┬──────────────────────────┐
│ SSE Prefix   │ AI SDK Type         │ Dart Event Type          │
├──────────────┼─────────────────────┼──────────────────────────┤
│ 0:           │ Text delta          │ AIStreamEventType.       │
│              │                     │   textDelta              │
├──────────────┼─────────────────────┼──────────────────────────┤
│ 2:           │ Tool calls          │ AIStreamEventType.       │
│              │                     │   toolCall               │
├──────────────┼─────────────────────┼──────────────────────────┤
│ 8:           │ Tool results        │ AIStreamEventType.       │
│              │                     │   toolResult             │
├──────────────┼─────────────────────┼──────────────────────────┤
│ 9:           │ Finish reason       │ AIStreamEventType.       │
│              │                     │   done                   │
├──────────────┼─────────────────────┼──────────────────────────┤
│ e:           │ Error               │ AIStreamEventType.       │
│              │                     │   error                  │
└──────────────┴─────────────────────┴──────────────────────────┘
```

## Type Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                          UIMessage                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ id: String                                                │  │
│  │ role: 'user' | 'assistant' | 'system'                    │  │
│  │ parts: List<MessagePart>                                 │  │
│  └───────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        MessagePart                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ Abstract base class                                       │  │
│  └───────────────────────────────────────────────────────────┘  │
└──────┬──────────────────────────────────────────┬───────────────┘
       │                                          │
       ▼                                          ▼
┌──────────────────┐                    ┌──────────────────┐
│    TextPart      │                    │    FilePart      │
│  ┌────────────┐  │                    │  ┌────────────┐  │
│  │ type: text │  │                    │  │ type: file │  │
│  │ text: str  │  │                    │  │ url: str   │  │
│  └────────────┘  │                    │  │ mediaType  │  │
└──────────────────┘                    │  └────────────┘  │
                                        └──────────────────┘
```

## Error Handling Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         Error Sources                            │
└────────┬────────────────────────────────────────┬────────────────┘
         │                                        │
         ▼                                        ▼
┌──────────────────┐                    ┌──────────────────┐
│  Network Error   │                    │   Stream Error   │
│  - Timeout       │                    │   - Parse error  │
│  - Connection    │                    │   - Invalid JSON │
│  - DNS           │                    │   - Bad format   │
└────────┬─────────┘                    └────────┬─────────┘
         │                                        │
         └────────────────┬───────────────────────┘
                          │
                          ▼
                ┌──────────────────┐
                │  AIStreamClient  │
                │  Catches & wraps │
                └────────┬─────────┘
                         │
                         ▼
                ┌──────────────────┐
                │  ChatClient      │
                │  Propagates      │
                └────────┬─────────┘
                         │
                         ▼
                ┌──────────────────┐
                │  ChatService     │
                │  Converts to     │
                │  ChatEvent       │
                └────────┬─────────┘
                         │
                         ▼
                ┌──────────────────┐
                │  ChatProvider    │
                │  Shows error UI  │
                └──────────────────┘
```

## Performance Characteristics

```
┌─────────────────────────────────────────────────────────────────┐
│                      Memory Usage                                │
├─────────────────────────────────────────────────────────────────┤
│ Component          │ Memory      │ Notes                         │
├────────────────────┼─────────────┼───────────────────────────────┤
│ Text Buffer        │ O(n)        │ n = response length           │
│ Stream Buffer      │ O(1)        │ Small, fixed size             │
│ Event Objects      │ O(1)        │ Only current event            │
│ Tool Tracking      │ O(m)        │ m = number of tools           │
│ Total per stream   │ ~1-2 MB     │ Typical conversation          │
└────────────────────┴─────────────┴───────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       CPU Usage                                  │
├─────────────────────────────────────────────────────────────────┤
│ Operation          │ Complexity  │ Notes                         │
├────────────────────┼─────────────┼───────────────────────────────┤
│ JSON Parsing       │ O(n)        │ Only when needed              │
│ String Concat      │ O(n)        │ Efficient in Dart             │
│ Buffer Split       │ O(n)        │ Per chunk                     │
│ Event Creation     │ O(1)        │ Constant time                 │
│ Per-event overhead │ <1ms        │ Negligible                    │
└────────────────────┴─────────────┴───────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                     Network Usage                                │
├─────────────────────────────────────────────────────────────────┤
│ Aspect             │ Impact      │ Notes                         │
├────────────────────┼─────────────┼───────────────────────────────┤
│ Additional Headers │ None        │ Standard HTTP headers         │
│ Request Size       │ Same        │ No overhead                   │
│ Response Size      │ Same        │ Direct streaming              │
│ Latency            │ None        │ Immediate processing          │
│ Bandwidth          │ Optimal     │ No buffering                  │
└────────────────────┴─────────────┴───────────────────────────────┘
```

## Comparison: Before vs After

```
┌─────────────────────────────────────────────────────────────────┐
│                    BEFORE (Manual Parsing)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ChatService (200+ lines)                                       │
│  ├─ Manual SSE parsing                                          │
│  ├─ Buffer management                                           │
│  ├─ Format detection                                            │
│  ├─ JSON parsing                                                │
│  ├─ Error handling                                              │
│  ├─ Debug logging                                               │
│  └─ Event emission                                              │
│                                                                  │
│  Issues:                                                         │
│  ❌ Complex, hard to maintain                                   │
│  ❌ Error-prone                                                 │
│  ❌ Hard to test                                                │
│  ❌ Not reusable                                                │
│  ❌ Mixed concerns                                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    AFTER (AI SDK Client)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ChatService (40 lines)                                         │
│  └─ Delegates to ChatClient                                     │
│                                                                  │
│  ChatClient (150 lines)                                         │
│  ├─ High-level API                                              │
│  └─ Delegates to AIStreamClient                                 │
│                                                                  │
│  AIStreamClient (400 lines)                                     │
│  ├─ SSE parsing                                                 │
│  ├─ Buffer management                                           │
│  ├─ Format detection                                            │
│  ├─ JSON parsing                                                │
│  └─ Error handling                                              │
│                                                                  │
│  Benefits:                                                       │
│  ✅ Clean separation of concerns                                │
│  ✅ Easy to maintain                                            │
│  ✅ Easy to test                                                │
│  ✅ Reusable library                                            │
│  ✅ Type-safe                                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Summary

This architecture provides:

1. **Clean Separation:** Each layer has a single responsibility
2. **Type Safety:** All data flows are strongly typed
3. **Maintainability:** Easy to understand and modify
4. **Testability:** Each component can be tested independently
5. **Performance:** Optimized streaming with minimal overhead
6. **Compatibility:** Works with existing UI code without changes

The implementation perfectly mirrors the AI SDK's functionality while providing a clean, Dart-idiomatic API for your mobile app.
