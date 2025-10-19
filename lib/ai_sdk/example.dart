// ignore_for_file: unused_local_variable, avoid_print

import 'ai_stream_client.dart';
import 'chat_client.dart';

/// Example usage of AI SDK Dart Client
void main() async {
  // Example 1: High-level ChatClient usage
  await example1HighLevelClient();

  // Example 2: Low-level AIStreamClient usage
  await example2LowLevelClient();

  // Example 3: Building complex messages
  await example3ComplexMessages();

  // Example 4: Error handling
  await example4ErrorHandling();

  // Example 5: Tool handling
  await example5ToolHandling();

  // Example 6: Optional features (annotations, usage, reasoning)
  await example6OptionalFeatures();

  // Example 7: Low-level optional features
  await example7LowLevelOptionalFeatures();
}

/// Example 1: High-level ChatClient usage
Future<void> example1HighLevelClient() async {
  print('\n=== Example 1: High-level ChatClient ===\n');

  final chatClient = ChatClient(
    baseUrl: 'https://api.example.com',
  );

  try {
    await for (final response in chatClient.sendMessage(
      message: 'What is the weather in Nairobi?',
      conversationId: 'conv-123',
    )) {
      // Print accumulated text
      print('AI: ${response.text}');

      // Handle active tool calls (loading state)
      if (response.hasActiveToolCalls) {
        for (final toolCall in response.activeToolCalls) {
          print('🔧 Tool running: ${toolCall.name}');
          print('   State: ${toolCall.state}');
        }
      }

      // Handle tool results
      if (response.hasToolResults) {
        for (final toolResult in response.toolResults) {
          print('📊 Tool result: ${toolResult.name}');
          print('   Result: ${toolResult.result}');
        }
      }

      // Check if complete
      if (response.isComplete) {
        print('✅ Response complete');
        if (response.finishReason != null) {
          print('   Finish reason: ${response.finishReason}');
        }
      }
    }
  } finally {
    chatClient.dispose();
  }
}

/// Example 2: Low-level AIStreamClient usage
Future<void> example2LowLevelClient() async {
  print('\n=== Example 2: Low-level AIStreamClient ===\n');

  final streamClient = AIStreamClient(
    baseUrl: 'https://api.example.com',
    getHeaders: () async => {
      'Authorization': 'Bearer your-token',
      'Content-Type': 'application/json',
    },
  );

  final messages = [
    UIMessage.text(
      text: 'Tell me a joke',
      role: 'user',
    ),
  ];

  try {
    String accumulatedText = '';

    await for (final event in streamClient.streamChat(
      endpoint: '/api/chat',
      messages: messages,
    )) {
      switch (event.type) {
        case AIStreamEventType.textDelta:
          accumulatedText = event.text ?? '';
          print('📝 Text: $accumulatedText');
          if (event.delta != null) {
            print('   Delta: "${event.delta}"');
          }
          break;

        case AIStreamEventType.toolCallStreaming:
          print('🔧 Tool call streaming: ${event.toolName}');
          print('   ID: ${event.toolCallId}');
          break;

        case AIStreamEventType.toolCallAvailable:
          print('🔧 Tool call available: ${event.toolName}');
          print('   ID: ${event.toolCallId}');
          print('   Args: ${event.toolArgs}');
          break;

        case AIStreamEventType.toolResult:
          print('📊 Tool result: ${event.toolName}');
          print('   ID: ${event.toolCallId}');
          print('   Result: ${event.toolResult}');
          break;

        case AIStreamEventType.error:
          print('❌ Error: ${event.error}');
          break;

        case AIStreamEventType.done:
          print('✅ Done: ${event.finishReason}');
          break;

        case AIStreamEventType.toolError:
          print('❌ Tool error: ${event.toolName}');
          print('   Error: ${event.error}');
          break;

        case AIStreamEventType.stepStart:
        case AIStreamEventType.stepFinish:
        case AIStreamEventType.annotation:
        case AIStreamEventType.reasoning:
          // Optional features - see example 7
          break;
      }
    }
  } finally {
    streamClient.dispose();
  }
}

/// Example 3: Building complex messages
Future<void> example3ComplexMessages() async {
  print('\n=== Example 3: Complex Messages ===\n');

  // Simple text message
  final textMessage = UIMessage.text(
    text: 'Hello, AI!',
    role: 'user',
  );
  print('Text message: ${textMessage.text}');

  // Message with file attachment
  final messageWithFile = UIMessage(
    id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
    role: 'user',
    parts: [
      TextPart(text: 'What do you see in this image?'),
      FilePart(
        url:
            'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
        mediaType: 'image/png',
      ),
    ],
  );
  print('Message with file: ${messageWithFile.parts.length} parts');

  // Message with multiple parts
  final multiPartMessage = UIMessage(
    id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
    role: 'user',
    parts: [
      TextPart(text: 'Compare these two images:'),
      FilePart(
        url: 'data:image/png;base64,...',
        mediaType: 'image/png',
      ),
      FilePart(
        url: 'data:image/jpeg;base64,...',
        mediaType: 'image/jpeg',
      ),
    ],
  );
  print('Multi-part message: ${multiPartMessage.parts.length} parts');

  // Convert to JSON
  final json = textMessage.toJson();
  print('JSON: $json');

  // Parse from JSON
  final parsedMessage = UIMessage.fromJson(json);
  print('Parsed: ${parsedMessage.text}');
}

/// Example 4: Error handling
Future<void> example4ErrorHandling() async {
  print('\n=== Example 4: Error Handling ===\n');

  final chatClient = ChatClient(
    baseUrl: 'https://api.example.com',
  );

  try {
    await for (final response in chatClient.sendMessage(
      message: 'Hello',
    )) {
      if (response.hasError) {
        print('❌ Error in response: ${response.error}');
        // Handle error gracefully
        break;
      } else {
        print('✅ Text: ${response.text}');
      }
    }
  } on AIStreamException catch (e) {
    print('❌ Stream exception: ${e.message}');
    if (e.statusCode != null) {
      print('   Status code: ${e.statusCode}');
    }
  } catch (e) {
    print('❌ Unexpected error: $e');
  } finally {
    chatClient.dispose();
  }
}

/// Example 5: Tool handling
Future<void> example5ToolHandling() async {
  print('\n=== Example 5: Tool Handling ===\n');

  final chatClient = ChatClient(
    baseUrl: 'https://api.example.com',
  );

  try {
    final toolCallsReceived = <String>[];
    final toolResultsReceived = <String>[];

    await for (final response in chatClient.sendMessage(
      message: 'Search for properties in Nairobi',
    )) {
      // Track active tool calls (loading state)
      for (final toolCall in response.activeToolCalls) {
        if (!toolCallsReceived.contains(toolCall.name)) {
          toolCallsReceived.add(toolCall.name);
          print('🔧 Tool running: ${toolCall.name}');
          print('   State: ${toolCall.state}');
        }
      }

      // Track tool results
      for (final toolResult in response.toolResults) {
        if (!toolResultsReceived.contains(toolResult.name)) {
          toolResultsReceived.add(toolResult.name);
          print('📊 Tool result: ${toolResult.name}');
          print('   State: ${toolResult.state}');
          print('   Result: ${toolResult.result}');
        }
      }

      // Print final text
      if (response.isComplete && response.text.isNotEmpty) {
        print('\n💬 Final response: ${response.text}');
      }
    }

    print('\n📈 Summary:');
    print('   Tools called: ${toolCallsReceived.length}');
    print('   Tools completed: ${toolResultsReceived.length}');
  } finally {
    chatClient.dispose();
  }
}

/// Example 6: Optional features (annotations, usage, reasoning)
Future<void> example6OptionalFeatures() async {
  print('\n=== Example 6: Optional Features ===\n');

  final chatClient = ChatClient(
    baseUrl: 'https://api.example.com',
  );

  try {
    await for (final response in chatClient.sendMessage(
      message: 'Explain quantum computing',
    )) {
      // Usage metadata (token counts)
      if (response.hasUsage) {
        print('📊 Token Usage:');
        print('   Prompt tokens: ${response.usage!.promptTokens}');
        print('   Completion tokens: ${response.usage!.completionTokens}');
        print('   Total tokens: ${response.usage!.totalTokens}');
      }

      // Annotations (custom metadata)
      if (response.hasAnnotations) {
        print('🏷️ Annotations:');
        response.annotations!.forEach((key, value) {
          print('   $key: $value');
        });
      }

      // Reasoning steps (for advanced models like o1)
      if (response.hasReasoning) {
        print('🧠 Reasoning Steps:');
        for (var i = 0; i < response.reasoningSteps.length; i++) {
          print('   Step ${i + 1}: ${response.reasoningSteps[i]}');
        }
      }

      // Final response
      if (response.isComplete && response.text.isNotEmpty) {
        print('\n💬 Final response: ${response.text}');
      }
    }
  } finally {
    chatClient.dispose();
  }
}

/// Example 7: Low-level event handling with optional features
Future<void> example7LowLevelOptionalFeatures() async {
  print('\n=== Example 7: Low-level Optional Features ===\n');

  final streamClient = AIStreamClient(
    baseUrl: 'https://api.example.com',
    getHeaders: () async => {
      'Authorization': 'Bearer your-token',
    },
  );

  final messages = [
    UIMessage.text(text: 'Complex reasoning task', role: 'user'),
  ];

  try {
    await for (final event in streamClient.streamChat(
      endpoint: '/api/chat',
      messages: messages,
    )) {
      switch (event.type) {
        case AIStreamEventType.textDelta:
          print('📝 Text: ${event.text}');
          break;

        case AIStreamEventType.reasoning:
          print('🧠 Reasoning: ${event.reasoningContent}');
          break;

        case AIStreamEventType.annotation:
          print('🏷️ Annotation: ${event.annotations}');
          break;

        case AIStreamEventType.stepStart:
          print('▶️ Step started: ${event.stepType}');
          break;

        case AIStreamEventType.stepFinish:
          print('⏹️ Step finished: ${event.stepType}');
          break;

        case AIStreamEventType.done:
          if (event.usage != null) {
            print('📊 Usage: ${event.usage}');
          }
          print('✅ Done: ${event.finishReason}');
          break;

        default:
          break;
      }
    }
  } finally {
    streamClient.dispose();
  }
}
