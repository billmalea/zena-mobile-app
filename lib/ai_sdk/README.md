# AI SDK Dart Client

A comprehensive Dart client for working with AI SDK streaming responses. This library provides a clean, type-safe interface for handling AI SDK's `toUIMessageStreamResponse` format.

## Features

- ✅ Full support for AI SDK UIMessage streaming format
- ✅ Support for DataStream format (JSON events)
- ✅ Text streaming with delta updates
- ✅ Tool calls and results handling
- ✅ Error handling
- ✅ Type-safe message construction
- ✅ Easy integration with existing Flutter apps
- ✅ **NEW:** Usage metadata (token counts)
- ✅ **NEW:** Annotations support
- ✅ **NEW:** Reasoning steps (for advanced models)
- ✅ **NEW:** Step events (for debugging)

## Architecture

```
ai_sdk/
├── ai_stream_client.dart   # Low-level streaming client
├── chat_client.dart         # High-level chat interface
└── README.md               # This file
```

## Quick Start

### 1. Basic Usage

```dart
import 'package:your_app/ai_sdk/chat_client.dart';

// Create client
final chatClient = ChatClient(
  baseUrl: 'https://your-api.com',
  authService: authService,
);

// Send message and stream response
await for (final response in chatClient.sendMessage(
  message: 'Hello, AI!',
  conversationId: 'conv-123',
)) {
  print('AI: ${response.text}');
  
  // Handle tool calls
  for (final toolCall in response.toolCalls) {
    print('Tool called: ${toolCall.name}');
  }
  
  // Handle tool results
  for (final toolResult in response.toolResults) {
    print('Tool result: ${toolResult.result}');
  }
  
  // Check for errors
  if (response.hasError) {
    print('Error: ${response.error}');
  }
}
```

### 2. Advanced Usage with Low-Level Client

```dart
import 'package:your_app/ai_sdk/ai_stream_client.dart';

// Create low-level client
final streamClient = AIStreamClient(
  baseUrl: 'https://your-api.com',
  getHeaders: () async {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  },
);

// Create messages
final messages = [
  UIMessage.text(text: 'What is the weather?', role: 'user'),
];

// Stream chat
await for (final event in streamClient.streamChat(
  endpoint: '/api/chat',
  messages: messages,
  conversationId: 'conv-123',
)) {
  switch (event.type) {
    case AIStreamEventType.textDelta:
      print('Text: ${event.text}');
      print('Delta: ${event.delta}');
      break;
    case AIStreamEventType.toolCall:
      print('Tool call: ${event.toolName}');
      break;
    case AIStreamEventType.toolResult:
      print('Tool result: ${event.toolResult}');
      break;
    case AIStreamEventType.error:
      print('Error: ${event.error}');
      break;
    case AIStreamEventType.done:
      print('Done: ${event.finishReason}');
      break;
  }
}
```

### 3. Using Optional Features

```dart
await for (final response in chatClient.sendMessage(
  message: 'Explain quantum computing',
)) {
  // Token usage
  if (response.hasUsage) {
    print('Tokens used: ${response.usage!.totalTokens}');
  }
  
  // Annotations
  if (response.hasAnnotations) {
    print('Metadata: ${response.annotations}');
  }
  
  // Reasoning steps (for models like o1)
  if (response.hasReasoning) {
    for (var step in response.reasoningSteps) {
      print('Reasoning: $step');
    }
  }
  
  print('Response: ${response.text}');
}
```

### 4. Building Complex Messages

```dart
// Text message
final textMessage = UIMessage.text(
  text: 'Hello!',
  role: 'user',
);

// Message with file attachment
final messageWithFile = UIMessage(
  id: 'msg-123',
  role: 'user',
  parts: [
    TextPart(text: 'Check this image'),
    FilePart(
      url: 'data:image/png;base64,...',
      mediaType: 'image/png',
    ),
  ],
);
```

## Stream Event Types

### UIMessage Format (Numbered Prefixes)

The AI SDK's `toUIMessageStreamResponse` uses numbered prefixes:

- `0:` - Text delta (incremental text updates)
- `2:` - Tool calls
- `8:` - Tool results
- `9:` - Finish reason
- `e:` - Error

### DataStream Format (JSON Objects)

Alternative format using JSON objects with `type` field:

- `text-delta` - Incremental text updates
- `text` - Full text content
- `tool-{name}` - Tool events (with state: input-streaming, output-available, output-error)
- `tool-call` - Tool invocation
- `tool-result` - Tool execution result
- `error` - Error event
- `finish` / `finish-step` - Stream completion

## API Reference

### AIStreamClient

Low-level client for streaming AI responses.

```dart
AIStreamClient({
  required String baseUrl,
  Map<String, String> Function()? getHeaders,
  http.Client? client,
})
```

**Methods:**
- `streamChat()` - Stream a chat completion
- `dispose()` - Clean up resources

### ChatClient

High-level client with simplified interface.

```dart
ChatClient({
  required String baseUrl,
  AuthService? authService,
})
```

**Methods:**
- `sendMessage()` - Send message and stream response
- `dispose()` - Clean up resources

### UIMessage

AI SDK message format.

```dart
UIMessage({
  required String id,
  required String role,
  required List<MessagePart> parts,
})

// Factory constructors
UIMessage.text({required String text, String role = 'user'})
UIMessage.fromJson(Map<String, dynamic> json)
```

### MessagePart

Base class for message parts.

**Subclasses:**
- `TextPart` - Text content
- `FilePart` - File attachment (images, videos, etc.)

### AIStreamEvent

Low-level stream event.

```dart
AIStreamEvent({
  required AIStreamEventType type,
  String? text,
  String? delta,
  String? toolName,
  String? toolCallId,
  dynamic toolArgs,
  dynamic toolResult,
  String? toolState,
  String? error,
  String? finishReason,
})
```

**Properties:**
- `isText` - Check if text event
- `isToolCall` - Check if tool call
- `isToolResult` - Check if tool result
- `isError` - Check if error
- `isDone` - Check if done

### ChatResponse

High-level chat response.

```dart
ChatResponse({
  required String text,
  String? delta,
  required List<ToolCall> toolCalls,
  required List<ToolResult> toolResults,
  String? error,
  String? finishReason,
  required bool isComplete,
})
```

**Properties:**
- `hasError` - Check if has error
- `hasToolCalls` - Check if has tool calls
- `hasToolResults` - Check if has tool results

## Integration with Existing Code

### Replacing Old Chat Service

```dart
// Old approach (manual parsing)
Stream<ChatEvent> sendMessage({
  required String message,
  String? conversationId,
}) async* {
  // Complex manual parsing of SSE stream...
}

// New approach (using AI SDK client)
Stream<ChatEvent> sendMessage({
  required String message,
  String? conversationId,
}) async* {
  await for (final response in _chatClient.sendMessage(
    message: message,
    conversationId: conversationId,
  )) {
    yield ChatEvent(
      type: 'text',
      content: response.text,
    );
    // Handle tool calls, results, errors...
  }
}
```

## Error Handling

```dart
try {
  await for (final response in chatClient.sendMessage(
    message: 'Hello',
  )) {
    if (response.hasError) {
      // Handle error
      print('Error: ${response.error}');
    } else {
      // Process response
      print('Text: ${response.text}');
    }
  }
} on AIStreamException catch (e) {
  print('Stream error: ${e.message}');
  print('Status code: ${e.statusCode}');
} catch (e) {
  print('Unexpected error: $e');
}
```

## Testing

```dart
// Mock the client for testing
class MockChatClient extends ChatClient {
  @override
  Stream<ChatResponse> sendMessage({
    required String message,
    String? conversationId,
  }) async* {
    yield ChatResponse(
      text: 'Mock response',
      toolCalls: [],
      toolResults: [],
      isComplete: true,
    );
  }
}
```

## Performance Considerations

- The client uses streaming to minimize memory usage
- Text deltas are accumulated efficiently
- Tool calls and results are tracked separately
- Automatic cleanup with `dispose()`

## Compatibility

- ✅ AI SDK v4.x (toUIMessageStreamResponse)
- ✅ AI SDK v3.x (DataStream format)
- ✅ Flutter 3.0+
- ✅ Dart 3.0+

## License

MIT
