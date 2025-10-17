import 'dart:async';
import 'ai_stream_client.dart';
import '../services/auth_service.dart';

/// High-level Chat Client using AI SDK Stream Client
/// Provides a simple interface for chat operations
class ChatClient {
  final AIStreamClient _streamClient;
  final AuthService _authService;

  ChatClient({
    required String baseUrl,
    AuthService? authService,
  })  : _authService = authService ?? AuthService(),
        _streamClient = AIStreamClient(
          baseUrl: baseUrl,
          getHeaders: () async {
            final headers = <String, String>{};
            final token = await (authService ?? AuthService()).getAccessToken();
            if (token != null) {
              headers['Authorization'] = 'Bearer $token';
            }
            return headers;
          },
        );

  /// Send a message and stream the response
  /// 
  /// Returns a stream of [ChatResponse] objects containing:
  /// - Accumulated text
  /// - Tool calls and results
  /// - Errors
  Stream<ChatResponse> sendMessage({
    required String message,
    String? conversationId,
    List<MessagePart>? additionalParts,
  }) async* {
    print('🎯 [ChatClient] sendMessage called');
    print('💬 [ChatClient] Message: $message');
    print('🆔 [ChatClient] Conversation ID: $conversationId');

    // Build message
    final parts = <MessagePart>[
      TextPart(text: message),
      ...?additionalParts,
    ];

    final uiMessage = UIMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      parts: parts,
    );

    print('📨 [ChatClient] UIMessage created: ${uiMessage.id}');

    // Track state
    String accumulatedText = '';
    final toolCalls = <ToolCall>[];
    final toolResults = <ToolResult>[];
    final reasoningSteps = <String>[];
    Map<String, dynamic>? latestAnnotations;
    UsageMetadata? latestUsage;

    try {
      print('🔄 [ChatClient] Starting stream...');
      await for (final event in _streamClient.streamChat(
        endpoint: '/api/chat',
        messages: [uiMessage],
        conversationId: conversationId,
      )) {
        print('📥 [ChatClient] Received event: ${event.type}');
        // Update annotations if present
        if (event.annotations != null) {
          latestAnnotations = event.annotations;
        }
        
        // Update usage if present
        if (event.usage != null) {
          latestUsage = event.usage;
        }
        
        if (event.isText) {
          // Update accumulated text
          accumulatedText = event.text ?? '';
          yield ChatResponse(
            text: accumulatedText,
            delta: event.delta,
            toolCalls: List.from(toolCalls),
            toolResults: List.from(toolResults),
            reasoningSteps: List.from(reasoningSteps),
            annotations: latestAnnotations,
            usage: latestUsage,
            isComplete: false,
          );
        } else if (event.isToolCall) {
          // Add tool call
          final toolCall = ToolCall(
            name: event.toolName ?? 'unknown',
            id: event.toolCallId,
            args: event.toolArgs,
            state: event.toolState,
          );
          toolCalls.add(toolCall);
          
          yield ChatResponse(
            text: accumulatedText,
            toolCalls: List.from(toolCalls),
            toolResults: List.from(toolResults),
            reasoningSteps: List.from(reasoningSteps),
            annotations: latestAnnotations,
            usage: latestUsage,
            isComplete: false,
          );
        } else if (event.isToolResult) {
          // Add tool result
          final toolResult = ToolResult(
            name: event.toolName ?? 'unknown',
            id: event.toolCallId,
            result: event.toolResult,
            state: event.toolState,
          );
          toolResults.add(toolResult);
          
          yield ChatResponse(
            text: accumulatedText,
            toolCalls: List.from(toolCalls),
            toolResults: List.from(toolResults),
            reasoningSteps: List.from(reasoningSteps),
            annotations: latestAnnotations,
            usage: latestUsage,
            isComplete: false,
          );
        } else if (event.isReasoning) {
          // Add reasoning step
          if (event.reasoningContent != null) {
            reasoningSteps.add(event.reasoningContent!);
            yield ChatResponse(
              text: accumulatedText,
              toolCalls: List.from(toolCalls),
              toolResults: List.from(toolResults),
              reasoningSteps: List.from(reasoningSteps),
              annotations: latestAnnotations,
              usage: latestUsage,
              isComplete: false,
            );
          }
        } else if (event.isAnnotation) {
          // Annotation event - just update state, don't yield
          // Will be included in next event
        } else if (event.isStepStart || event.isStepFinish) {
          // Step events - can be used for debugging
          // Don't yield, just track internally
        } else if (event.isError) {
          yield ChatResponse(
            text: accumulatedText,
            toolCalls: List.from(toolCalls),
            toolResults: List.from(toolResults),
            reasoningSteps: List.from(reasoningSteps),
            annotations: latestAnnotations,
            usage: latestUsage,
            error: event.error,
            isComplete: true,
          );
        } else if (event.isDone) {
          yield ChatResponse(
            text: accumulatedText,
            toolCalls: List.from(toolCalls),
            toolResults: List.from(toolResults),
            reasoningSteps: List.from(reasoningSteps),
            annotations: latestAnnotations,
            usage: latestUsage,
            finishReason: event.finishReason,
            isComplete: true,
          );
        }
      }
    } catch (e) {
      yield ChatResponse(
        text: accumulatedText,
        toolCalls: List.from(toolCalls),
        toolResults: List.from(toolResults),
        reasoningSteps: List.from(reasoningSteps),
        annotations: latestAnnotations,
        usage: latestUsage,
        error: e.toString(),
        isComplete: true,
      );
    }
  }

  void dispose() {
    _streamClient.dispose();
  }
}

/// Chat Response
class ChatResponse {
  final String text;
  final String? delta;
  final List<ToolCall> toolCalls;
  final List<ToolResult> toolResults;
  final String? error;
  final String? finishReason;
  final bool isComplete;
  
  // Optional features
  final Map<String, dynamic>? annotations;
  final UsageMetadata? usage;
  final List<String> reasoningSteps;

  ChatResponse({
    required this.text,
    this.delta,
    required this.toolCalls,
    required this.toolResults,
    this.error,
    this.finishReason,
    required this.isComplete,
    this.annotations,
    this.usage,
    this.reasoningSteps = const [],
  });

  bool get hasError => error != null;
  bool get hasToolCalls => toolCalls.isNotEmpty;
  bool get hasToolResults => toolResults.isNotEmpty;
  bool get hasAnnotations => annotations != null && annotations!.isNotEmpty;
  bool get hasUsage => usage != null;
  bool get hasReasoning => reasoningSteps.isNotEmpty;

  @override
  String toString() {
    return 'ChatResponse(text: ${text.length} chars, toolCalls: ${toolCalls.length}, toolResults: ${toolResults.length}, error: $error, complete: $isComplete, usage: $usage)';
  }
}

/// Tool Call
class ToolCall {
  final String name;
  final String? id;
  final dynamic args;
  final String? state;

  ToolCall({
    required this.name,
    this.id,
    this.args,
    this.state,
  });

  @override
  String toString() => 'ToolCall(name: $name, id: $id, state: $state)';
}

/// Tool Result
class ToolResult {
  final String name;
  final String? id;
  final dynamic result;
  final String? state;

  ToolResult({
    required this.name,
    this.id,
    this.result,
    this.state,
  });

  @override
  String toString() => 'ToolResult(name: $name, id: $id, state: $state)';
}
