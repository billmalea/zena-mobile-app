import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// AI SDK Stream Client for Dart
/// Handles streaming responses from AI SDK's toUIMessageStreamResponse format
/// 
/// Supports:
/// - Text streaming (text-delta events)
/// - Tool calls and results
/// - Error handling
/// - Multiple stream formats (UIMessage and DataStream)
class AIStreamClient {
  final http.Client _client;
  final String baseUrl;
  final Future<Map<String, String>> Function()? getHeaders;

  AIStreamClient({
    required this.baseUrl,
    this.getHeaders,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Stream a chat completion
  /// 
  /// [endpoint] - API endpoint (e.g., '/api/chat')
  /// [messages] - Array of UIMessage objects
  /// [conversationId] - Optional conversation ID
  /// [additionalData] - Any additional data to send
  Stream<AIStreamEvent> streamChat({
    required String endpoint,
    required List<UIMessage> messages,
    String? conversationId,
    Map<String, dynamic>? additionalData,
  }) async* {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = getHeaders != null ? await getHeaders!() : <String, String>{};
      
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'text/event-stream';

      final body = {
        'messages': messages.map((m) => m.toJson()).toList(),
        if (conversationId != null) 'conversationId': conversationId,
        ...?additionalData,
      };

      // Debug logging
      print('🚀 [AIStreamClient] Starting request');
      print('📍 [AIStreamClient] Base URL: $baseUrl');
      print('📍 [AIStreamClient] Endpoint: $endpoint');
      print('📍 [AIStreamClient] Full URL: $url');
      print('📤 [AIStreamClient] Request body: ${jsonEncode(body)}');
      print('🔑 [AIStreamClient] Headers: ${headers.keys.toList()}');

      final request = http.Request('POST', url);
      request.headers.addAll(headers);
      request.body = jsonEncode(body);

      print('⏳ [AIStreamClient] Sending request...');
      final streamedResponse = await _client.send(request);

      print('📡 [AIStreamClient] Response status: ${streamedResponse.statusCode}');
      print('📋 [AIStreamClient] Response headers: ${streamedResponse.headers}');

      if (streamedResponse.statusCode != 200) {
        print('❌ [AIStreamClient] Request failed with status: ${streamedResponse.statusCode}');
        throw AIStreamException(
          'Request failed with status: ${streamedResponse.statusCode}',
          streamedResponse.statusCode,
        );
      }

      print('✅ [AIStreamClient] Request successful, starting to parse stream...');

      // Parse the stream
      await for (final event in _parseStream(streamedResponse.stream)) {
        yield event;
      }
    } catch (e) {
      if (e is AIStreamException) {
        rethrow;
      }
      throw AIStreamException('Stream error: ${e.toString()}');
    }
  }

  /// Parse the SSE stream and convert to AIStreamEvent objects
  Stream<AIStreamEvent> _parseStream(Stream<List<int>> byteStream) async* {
    String buffer = '';
    String textBuffer = '';
    int chunkCount = 0;
    int eventCount = 0;

    print('🎬 [AIStreamClient] Starting stream parsing...');

    await for (final chunk in byteStream.transform(utf8.decoder)) {
      chunkCount++;
      print('📦 [AIStreamClient] Chunk #$chunkCount received (${chunk.length} bytes)');
      buffer += chunk;
      
      // Process complete lines
      final lines = buffer.split('\n');
      buffer = lines.last;
      
      for (int i = 0; i < lines.length - 1; i++) {
        final line = lines[i];
        
        if (line.trim().isEmpty) continue;
        
        print('📝 [AIStreamClient] Processing line: ${line.length > 100 ? line.substring(0, 100) + "..." : line}');
        
        // Handle SSE format (data: prefix)
        if (line.startsWith('data: ')) {
          final data = line.substring(6).trim();
          
          if (data.isEmpty || data == '[DONE]') {
            print('🏁 [AIStreamClient] Stream done marker received');
            continue;
          }

          // Try to parse as JSON
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final type = json['type'] as String?;

            print('🔍 [AIStreamClient] Parsed JSON event, type: $type');

            // DataStream format (JSON objects with type field)
            if (type != null) {
              final event = _parseDataStreamEvent(json, textBuffer);
              if (event != null) {
                eventCount++;
                print('✅ [AIStreamClient] Event #$eventCount: ${event.type}');
                if (event.type == AIStreamEventType.textDelta) {
                  textBuffer = event.text ?? '';
                }
                yield event;
              }
            }
          } catch (e) {
            print('⚠️ [AIStreamClient] Failed to parse JSON: $e');
            continue;
          }
        }
        // Handle UIMessage format (numbered prefixes without data: prefix)
        else if (line.contains(':')) {
          print('🔢 [AIStreamClient] UIMessage format detected');
          final event = _parseUIMessageEvent(line, textBuffer);
          if (event != null) {
            eventCount++;
            print('✅ [AIStreamClient] Event #$eventCount: ${event.type}');
            if (event.type == AIStreamEventType.textDelta) {
              textBuffer = event.text ?? '';
            }
            yield event;
          }
        }
      }
    }

    print('🎉 [AIStreamClient] Stream parsing complete. Total chunks: $chunkCount, Events: $eventCount');

    // Process remaining buffer
    if (buffer.trim().isNotEmpty) {
      if (buffer.startsWith('data: ')) {
        final data = buffer.substring(6).trim();
        if (data.isNotEmpty && data != '[DONE]') {
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final event = _parseDataStreamEvent(json, textBuffer);
            if (event != null) {
              yield event;
            }
          } catch (_) {
            // Ignore parse errors
          }
        }
      } else if (buffer.contains(':')) {
        final event = _parseUIMessageEvent(buffer, textBuffer);
        if (event != null) {
          yield event;
        }
      }
    }
  }

  /// Parse DataStream format events (JSON objects with type field)
  AIStreamEvent? _parseDataStreamEvent(Map<String, dynamic> json, String currentTextBuffer) {
    final type = json['type'] as String?;

    // Handle tool-specific events
    if (type == 'tool-input-start' || type == 'tool-input-delta' || type == 'tool-input-available') {
      // Tool input events - treat as tool call
      final toolName = json['toolName'] as String?;
      final toolCallId = json['toolCallId'] as String?;
      
      if (type == 'tool-input-available') {
        print('🔧 [AIStreamClient] Tool call: $toolName');
        return AIStreamEvent(
          type: AIStreamEventType.toolCall,
          toolName: toolName,
          toolCallId: toolCallId,
          toolArgs: json['args'],
          annotations: json['annotations'] as Map<String, dynamic>?,
        );
      }
      return null; // Skip input-start and input-delta
    } else if (type == 'tool-output-available') {
      // Tool output event - treat as tool result
      final toolCallId = json['toolCallId'] as String?;
      final output = json['output'];
      
      print('📊 [AIStreamClient] Tool result received');
      return AIStreamEvent(
        type: AIStreamEventType.toolResult,
        toolCallId: toolCallId,
        toolResult: output,
        annotations: json['annotations'] as Map<String, dynamic>?,
      );
    } else if (type == 'start-step' || type == 'finish-step') {
      // Step events - can be ignored or used for debugging
      print('📍 [AIStreamClient] Step event: $type');
      return null;
    } else if (type == 'text-delta') {
      // Text delta event
      final delta = json['delta'] as String?;
      if (delta != null && delta.isNotEmpty) {
        final newBuffer = currentTextBuffer + delta;
        return AIStreamEvent(
          type: AIStreamEventType.textDelta,
          text: newBuffer,
          delta: delta,
          annotations: json['annotations'] as Map<String, dynamic>?,
        );
      }
    } else if (type == 'text') {
      // Full text event
      final text = json['text'] as String?;
      if (text != null && text.isNotEmpty) {
        return AIStreamEvent(
          type: AIStreamEventType.textDelta,
          text: text,
          annotations: json['annotations'] as Map<String, dynamic>?,
        );
      }
    } else if (type?.startsWith('tool-') == true) {
      // Tool event
      final toolName = type!.replaceFirst('tool-', '');
      final state = json['state'] as String?;
      final output = json['output'];
      final errorText = json['errorText'] as String?;

      if (state == 'output-available' && output != null) {
        return AIStreamEvent(
          type: AIStreamEventType.toolResult,
          toolName: toolName,
          toolResult: output,
          toolState: state,
          annotations: json['annotations'] as Map<String, dynamic>?,
        );
      } else if (state == 'output-error') {
        return AIStreamEvent(
          type: AIStreamEventType.error,
          error: 'Tool $toolName failed: ${errorText ?? "Unknown error"}',
        );
      } else if (state == 'input-streaming' || state == 'input-available') {
        return AIStreamEvent(
          type: AIStreamEventType.toolCall,
          toolName: toolName,
          toolState: state,
          annotations: json['annotations'] as Map<String, dynamic>?,
        );
      }
    } else if (type == 'tool-call') {
      // Tool call in DataStream format
      return AIStreamEvent(
        type: AIStreamEventType.toolCall,
        toolName: json['toolName'] as String?,
        toolArgs: json['args'],
        annotations: json['annotations'] as Map<String, dynamic>?,
      );
    } else if (type == 'tool-result') {
      // Tool result in DataStream format
      return AIStreamEvent(
        type: AIStreamEventType.toolResult,
        toolName: json['toolName'] as String?,
        toolResult: json['result'],
        annotations: json['annotations'] as Map<String, dynamic>?,
      );
    } else if (type == 'error') {
      return AIStreamEvent(
        type: AIStreamEventType.error,
        error: json['error'] as String? ?? 'An error occurred',
      );
    } else if (type == 'finish' || type == 'finish-step') {
      // Parse usage metadata if available
      UsageMetadata? usage;
      if (json['usage'] != null) {
        usage = UsageMetadata.fromJson(json['usage'] as Map<String, dynamic>);
      }
      
      return AIStreamEvent(
        type: AIStreamEventType.done,
        finishReason: json['finishReason'] as String?,
        usage: usage,
        annotations: json['annotations'] as Map<String, dynamic>?,
      );
    } else if (type == 'step-start') {
      // Step start event (for debugging)
      return AIStreamEvent(
        type: AIStreamEventType.stepStart,
        stepType: json['stepType'] as String?,
        annotations: json['annotations'] as Map<String, dynamic>?,
      );
    } else if (type == 'step-finish') {
      // Step finish event (for debugging)
      return AIStreamEvent(
        type: AIStreamEventType.stepFinish,
        stepType: json['stepType'] as String?,
        annotations: json['annotations'] as Map<String, dynamic>?,
      );
    } else if (type == 'annotation') {
      // Annotation event
      return AIStreamEvent(
        type: AIStreamEventType.annotation,
        annotations: json['data'] as Map<String, dynamic>?,
      );
    } else if (type == 'reasoning') {
      // Reasoning step (for advanced models like o1)
      return AIStreamEvent(
        type: AIStreamEventType.reasoning,
        reasoningContent: json['content'] as String?,
        annotations: json['annotations'] as Map<String, dynamic>?,
      );
    }

    return null;
  }

  /// Parse UIMessage format events (numbered prefixes)
  AIStreamEvent? _parseUIMessageEvent(String line, String currentTextBuffer) {
    if (!line.contains(':')) return null;

    final colonIndex = line.indexOf(':');
    final prefix = line.substring(0, colonIndex);
    final content = line.substring(colonIndex + 1);

    try {
      if (prefix == '0') {
        // Text delta
        final decodedText = jsonDecode(content) as String;
        final newBuffer = currentTextBuffer + decodedText;
        return AIStreamEvent(
          type: AIStreamEventType.textDelta,
          text: newBuffer,
          delta: decodedText,
        );
      } else if (prefix == '2') {
        // Tool calls
        final toolCalls = jsonDecode(content) as List;
        if (toolCalls.isNotEmpty) {
          final toolCall = toolCalls.first as Map<String, dynamic>;
          return AIStreamEvent(
            type: AIStreamEventType.toolCall,
            toolName: toolCall['toolName'] as String?,
            toolCallId: toolCall['toolCallId'] as String?,
            toolArgs: toolCall['args'],
            annotations: toolCall['annotations'] as Map<String, dynamic>?,
          );
        }
      } else if (prefix == '8') {
        // Tool results
        final toolResults = jsonDecode(content) as List;
        if (toolResults.isNotEmpty) {
          final toolResult = toolResults.first as Map<String, dynamic>;
          return AIStreamEvent(
            type: AIStreamEventType.toolResult,
            toolName: toolResult['toolName'] as String?,
            toolCallId: toolResult['toolCallId'] as String?,
            toolResult: toolResult['result'],
            annotations: toolResult['annotations'] as Map<String, dynamic>?,
          );
        }
      } else if (prefix == '9') {
        // Finish reason with usage metadata
        final finishData = jsonDecode(content) as Map<String, dynamic>;
        
        UsageMetadata? usage;
        if (finishData['usage'] != null) {
          usage = UsageMetadata.fromJson(finishData['usage'] as Map<String, dynamic>);
        }
        
        return AIStreamEvent(
          type: AIStreamEventType.done,
          finishReason: finishData['finishReason'] as String?,
          usage: usage,
          annotations: finishData['annotations'] as Map<String, dynamic>?,
        );
      } else if (prefix == 'e') {
        // Error
        final errorData = jsonDecode(content) as Map<String, dynamic>;
        return AIStreamEvent(
          type: AIStreamEventType.error,
          error: errorData['message'] as String? ?? 'An error occurred',
        );
      } else if (prefix == 'd') {
        // Data/annotation event (prefix 'd')
        final annotationData = jsonDecode(content) as Map<String, dynamic>;
        return AIStreamEvent(
          type: AIStreamEventType.annotation,
          annotations: annotationData,
        );
      } else if (prefix == 'r') {
        // Reasoning event (prefix 'r')
        final reasoningData = jsonDecode(content) as String;
        return AIStreamEvent(
          type: AIStreamEventType.reasoning,
          reasoningContent: reasoningData,
        );
      }
    } catch (_) {
      // Ignore parse errors
      return null;
    }

    return null;
  }

  void dispose() {
    _client.close();
  }
}

/// AI Stream Event Types
enum AIStreamEventType {
  textDelta,
  toolCall,
  toolResult,
  error,
  done,
  stepStart,
  stepFinish,
  annotation,
  reasoning,
}

/// AI Stream Event
class AIStreamEvent {
  final AIStreamEventType type;
  final String? text;
  final String? delta;
  final String? toolName;
  final String? toolCallId;
  final dynamic toolArgs;
  final dynamic toolResult;
  final String? toolState;
  final String? error;
  final String? finishReason;
  
  // Optional features
  final Map<String, dynamic>? annotations;
  final UsageMetadata? usage;
  final String? stepType;
  final String? reasoningContent;

  AIStreamEvent({
    required this.type,
    this.text,
    this.delta,
    this.toolName,
    this.toolCallId,
    this.toolArgs,
    this.toolResult,
    this.toolState,
    this.error,
    this.finishReason,
    this.annotations,
    this.usage,
    this.stepType,
    this.reasoningContent,
  });

  bool get isText => type == AIStreamEventType.textDelta;
  bool get isToolCall => type == AIStreamEventType.toolCall;
  bool get isToolResult => type == AIStreamEventType.toolResult;
  bool get isError => type == AIStreamEventType.error;
  bool get isDone => type == AIStreamEventType.done;
  bool get isStepStart => type == AIStreamEventType.stepStart;
  bool get isStepFinish => type == AIStreamEventType.stepFinish;
  bool get isAnnotation => type == AIStreamEventType.annotation;
  bool get isReasoning => type == AIStreamEventType.reasoning;

  @override
  String toString() {
    return 'AIStreamEvent(type: $type, text: $text, toolName: $toolName, error: $error, usage: $usage)';
  }
}

/// Usage Metadata for token tracking
class UsageMetadata {
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;

  UsageMetadata({
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
  });

  factory UsageMetadata.fromJson(Map<String, dynamic> json) {
    return UsageMetadata(
      promptTokens: json['promptTokens'] as int?,
      completionTokens: json['completionTokens'] as int?,
      totalTokens: json['totalTokens'] as int?,
    );
  }

  @override
  String toString() {
    return 'UsageMetadata(prompt: $promptTokens, completion: $completionTokens, total: $totalTokens)';
  }
}

/// UIMessage - AI SDK message format
class UIMessage {
  final String id;
  final String role;
  final List<MessagePart> parts;

  UIMessage({
    required this.id,
    required this.role,
    required this.parts,
  });

  factory UIMessage.text({
    required String text,
    String role = 'user',
  }) {
    return UIMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      role: role,
      parts: [TextPart(text: text)],
    );
  }

  factory UIMessage.fromJson(Map<String, dynamic> json) {
    final parts = (json['parts'] as List?)
        ?.map((p) => MessagePart.fromJson(p as Map<String, dynamic>))
        .toList() ?? [];

    return UIMessage(
      id: json['id'] as String,
      role: json['role'] as String,
      parts: parts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'parts': parts.map((p) => p.toJson()).toList(),
    };
  }

  String get text {
    final textPart = parts.whereType<TextPart>().firstOrNull;
    return textPart?.text ?? '';
  }
}

/// Message Part base class
abstract class MessagePart {
  final String type;

  MessagePart(this.type);

  factory MessagePart.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    
    switch (type) {
      case 'text':
        return TextPart(text: json['text'] as String);
      case 'file':
        return FilePart(
          url: json['url'] as String,
          mediaType: json['mediaType'] as String?,
        );
      default:
        return TextPart(text: '');
    }
  }

  Map<String, dynamic> toJson();
}

/// Text Part
class TextPart extends MessagePart {
  final String text;

  TextPart({required this.text}) : super('text');

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
    };
  }
}

/// File Part
class FilePart extends MessagePart {
  final String url;
  final String? mediaType;

  FilePart({
    required this.url,
    this.mediaType,
  }) : super('file');

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
      if (mediaType != null) 'mediaType': mediaType,
    };
  }
}

/// AI Stream Exception
class AIStreamException implements Exception {
  final String message;
  final int? statusCode;

  AIStreamException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Extension for firstOrNull
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
