import 'dart:convert';
import '../config/app_config.dart';
import '../models/conversation.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Chat Service for handling chat operations
/// Manages conversations and message streaming
class ChatService {
  final _apiService = ApiService();
  final _authService = AuthService();

  /// Get current user ID
  String? getUserId() {
    return _authService.currentUser?.id;
  }

  /// Send a message and stream the response
  /// Message text may contain embedded file URLs
  Stream<ChatEvent> sendMessage({
    required String message,
    String? conversationId,
  }) async* {
    try {
      // Build message parts (AI SDK format)
      final messageParts = <Map<String, dynamic>>[
        {'type': 'text', 'text': message},
      ];

      // Build messages array (AI SDK format)
      final messages = [
        {
          'id': 'msg-${DateTime.now().millisecondsSinceEpoch}',
          'role': 'user',
          'parts': messageParts,
        }
      ];

      final body = {
        'messages': messages,
        if (conversationId != null) 'conversationId': conversationId,
      };

      // Buffer to accumulate text content
      String textBuffer = '';
      int eventCount = 0;
      int textEventCount = 0;
      int toolEventCount = 0;

      print('🎬 [ChatService] Starting to process stream events');

      await for (final data in _apiService.streamPost(
        AppConfig.chatEndpoint,
        body,
      )) {
        eventCount++;
        print('🔄 [ChatService] Event #$eventCount: $data');

        try {
          // Check if data is JSON object
          if (data.startsWith('{')) {
            print('📋 [ChatService] JSON object detected');
            final json = jsonDecode(data) as Map<String, dynamic>;
            final type = json['type'] as String?;

            print('📝 [ChatService] Event type: $type');
            print('🔍 [ChatService] Full JSON keys: ${json.keys.toList()}');

            // Handle different event types from AI SDK UIMessage format
            if (type == 'text') {
              // Text part - contains the actual message text
              final text = json['text'] as String?;
              if (text != null && text.isNotEmpty) {
                textBuffer = text; // Replace buffer with full text
                textEventCount++;
                print('✅ [ChatService] Text event #$textEventCount: "$text"');

                yield ChatEvent(
                  type: 'text',
                  content: textBuffer,
                );
              }
            } else if (type?.startsWith('tool-') == true) {
              // Tool part - format: tool-{toolName}
              final toolName = type!.replaceFirst('tool-', '');
              final state = json['state'] as String?;
              final output = json['output'];
              final errorText = json['errorText'] as String?;

              toolEventCount++;
              print(
                  '🔧 [ChatService] Tool event #$toolEventCount: $toolName (state: $state)');

              if (state == 'output-available' && output != null) {
                // Tool execution completed with result
                print('📊 [ChatService] Tool output available for: $toolName');
                yield ChatEvent(
                  type: 'tool-result',
                  toolResult: {
                    'toolName': toolName,
                    'result': output,
                    'state': state,
                  },
                );
              } else if (state == 'output-error') {
                // Tool execution failed
                print('❌ [ChatService] Tool error for $toolName: $errorText');
                yield ChatEvent(
                  type: 'error',
                  content:
                      'Tool $toolName failed: ${errorText ?? "Unknown error"}',
                );
              } else if (state == 'input-streaming' ||
                  state == 'input-available') {
                // Tool is being invoked (can show loading state)
                print('⏳ [ChatService] Tool $toolName is executing...');
                yield ChatEvent(
                  type: 'tool-call',
                  toolResult: {
                    'toolName': toolName,
                    'state': state,
                  },
                );
              }
            } else if (type == 'step-start') {
              // Metadata event - can be ignored
              print('📍 [ChatService] Step start (metadata)');
            } else if (type == 'text-delta') {
              // Text delta
              final textDelta = json['textDelta'] as String?;
              print('📄 [ChatService] textDelta field value: "$textDelta"');

              if (textDelta != null && textDelta.isNotEmpty) {
                textBuffer += textDelta;
                textEventCount++;
                print(
                    '✅ [ChatService] Text delta #$textEventCount: "$textDelta"');
                print('📚 [ChatService] Buffer now: "$textBuffer"');

                yield ChatEvent(
                  type: 'text',
                  content: textBuffer,
                );
              } else {
                print('⚠️ [ChatService] textDelta is null or empty');
              }
            } else if (type == 'tool-call') {
              // Tool call
              toolEventCount++;
              print(
                  '🔧 [ChatService] Tool call #$toolEventCount in DataStream format');
              yield ChatEvent(
                type: 'tool-call',
                toolResult: json,
              );
            } else if (type == 'tool-result') {
              // Tool result
              toolEventCount++;
              print(
                  '📊 [ChatService] Tool result #$toolEventCount in DataStream format');
              yield ChatEvent(
                type: 'tool-result',
                toolResult: json,
              );
            } else if (type == 'finish' || type == 'finish-step') {
              // Stream finished
              print('🏁 [ChatService] Stream finish detected: $type');
              textBuffer = ''; // Reset buffer
            } else if (type == 'error') {
              // Error
              print('❌ [ChatService] Error in DataStream format');
              yield ChatEvent(
                type: 'error',
                content: json['error'] as String? ?? 'An error occurred',
              );
            } else {
              print('⚠️ [ChatService] Unknown DataStream type: $type');
              print('📦 [ChatService] Full JSON: $json');
            }
            continue;
          }

          // AI SDK toUIMessageStreamResponse format (numbered prefixes):
          // 0:"text content" - text delta
          // 2:[...] - tool calls
          // 8:[...] - tool results
          // 9:{...} - finish reason
          // e:{...} - error

          if (data.startsWith('0:')) {
            print('📝 [ChatService] Text delta detected (UIMessage format)');
            // Text delta - extract the JSON string
            final textContent = data.substring(2);
            print('📄 [ChatService] Text content: $textContent');

            try {
              final decodedText = jsonDecode(textContent) as String;
              textBuffer += decodedText;
              print('✅ [ChatService] Decoded text: "$decodedText"');
              print('📚 [ChatService] Buffer now: "$textBuffer"');

              // Yield text event with accumulated content
              yield ChatEvent(
                type: 'text',
                content: textBuffer,
              );
            } catch (e) {
              print(
                  '⚠️ [ChatService] JSON decode failed, treating as plain text: $e');
              // If JSON decode fails, treat as plain text
              textBuffer += textContent;
              yield ChatEvent(
                type: 'text',
                content: textBuffer,
              );
            }
          } else if (data.startsWith('2:')) {
            print('🔧 [ChatService] Tool call detected');
            // Tool call - extract the JSON array
            final toolCallsJson = data.substring(2);
            print('🔧 [ChatService] Tool calls JSON: $toolCallsJson');

            try {
              final toolCalls = jsonDecode(toolCallsJson) as List;
              print('✅ [ChatService] Parsed ${toolCalls.length} tool calls');

              for (final toolCall in toolCalls) {
                print('🛠️ [ChatService] Tool call: ${toolCall['toolName']}');
                yield ChatEvent(
                  type: 'tool-call',
                  toolResult: toolCall as Map<String, dynamic>,
                );
              }
            } catch (e) {
              print('❌ [ChatService] Failed to parse tool calls: $e');
              // Skip malformed tool calls
              continue;
            }
          } else if (data.startsWith('8:')) {
            print('📊 [ChatService] Tool result detected');
            // Tool result - extract the JSON array
            final toolResultsJson = data.substring(2);
            print('📊 [ChatService] Tool results JSON: $toolResultsJson');

            try {
              final toolResults = jsonDecode(toolResultsJson) as List;
              print(
                  '✅ [ChatService] Parsed ${toolResults.length} tool results');

              for (final toolResult in toolResults) {
                print(
                    '📦 [ChatService] Tool result: ${toolResult['toolName']}');
                yield ChatEvent(
                  type: 'tool-result',
                  toolResult: toolResult as Map<String, dynamic>,
                );
              }
            } catch (e) {
              print('❌ [ChatService] Failed to parse tool results: $e');
              // Skip malformed tool results
              continue;
            }
          } else if (data.startsWith('9:')) {
            print('🏁 [ChatService] Finish reason detected');
            // Finish reason - stream is complete
            textBuffer = ''; // Reset buffer for next message
          } else if (data.startsWith('e:')) {
            print('❌ [ChatService] Error detected');
            // Error
            final errorJson = data.substring(2);
            print('❌ [ChatService] Error JSON: $errorJson');

            try {
              final error = jsonDecode(errorJson) as Map<String, dynamic>;
              print('⚠️ [ChatService] Error message: ${error['message']}');
              yield ChatEvent(
                type: 'error',
                content: error['message'] as String? ?? 'An error occurred',
              );
            } catch (e) {
              print('❌ [ChatService] Failed to parse error: $e');
              yield ChatEvent(
                type: 'error',
                content: 'An error occurred',
              );
            }
          } else {
            print(
                '⚠️ [ChatService] Unknown event type: ${data.substring(0, data.length > 50 ? 50 : data.length)}');
          }
        } catch (e) {
          print('❌ [ChatService] Error processing event: $e');
          // Skip malformed chunks
          continue;
        }
      }

      print('🎬 [ChatService] Stream processing complete');
      print('📊 [ChatService] Total events: $eventCount');
      print('📊 [ChatService] Text events: $textEventCount');
      print('📊 [ChatService] Tool events: $toolEventCount');
      print('📊 [ChatService] Final text buffer: "$textBuffer"');
      print('📊 [ChatService] Buffer length: ${textBuffer.length} characters');
    } catch (e) {
      print('❌ [ChatService] Stream error: $e');
      yield ChatEvent(
        type: 'error',
        content: 'Failed to send message: ${e.toString()}',
      );
    }
  }

  /// Get a specific conversation by ID
  Future<Conversation> getConversation(String? conversationId) async {
    try {
      final endpoint = conversationId != null
          ? '${AppConfig.conversationEndpoint}?id=$conversationId'
          : AppConfig.conversationEndpoint;

      final response = await _apiService.get(endpoint);

      if (response == null) {
        throw ApiException('No conversation data received', null);
      }

      return Conversation.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to load conversation: ${e.toString()}', null);
    }
  }

  /// Get all conversations for the current user
  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _apiService.get(AppConfig.conversationsEndpoint);

      if (response == null) {
        return [];
      }

      final conversationsList = response as List;
      return conversationsList
          .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiException('Failed to load conversations: ${e.toString()}', null);
    }
  }

  /// Create a new conversation
  Future<Conversation> createConversation() async {
    try {
      final response = await _apiService.post(
        AppConfig.conversationEndpoint,
        {},
      );

      if (response == null) {
        throw ApiException('No conversation data received', null);
      }

      return Conversation.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ApiException(
          'Failed to create conversation: ${e.toString()}', null);
    }
  }
}

/// Chat event for streaming responses
class ChatEvent {
  final String type; // 'text', 'tool-call', 'tool-result', 'error'
  final String? content;
  final Map<String, dynamic>? toolResult;

  ChatEvent({
    required this.type,
    this.content,
    this.toolResult,
  });

  bool get isText => type == 'text';
  bool get isToolCall => type == 'tool-call';
  bool get isToolResult => type == 'tool-result';
  bool get isError => type == 'error';
}
