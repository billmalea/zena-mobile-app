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
    List<UIMessage>? conversationHistory,  // ← Add conversation history parameter
  }) async* {
    print('🎯 [ChatClient] sendMessage called');
    print('💬 [ChatClient] Message: $message');
    print('🆔 [ChatClient] Conversation ID: $conversationId');

    // Build current message
    final parts = <MessagePart>[
      TextPart(text: message),
      ...?additionalParts,
    ];

    final currentMessage = UIMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      parts: parts,
    );

    print('📨 [ChatClient] UIMessage created: ${currentMessage.id}');

    // Combine conversation history with current message (like useChat does)
    final allMessages = [
      ...?conversationHistory,  // Previous messages with tool results
      currentMessage,           // Current user message
    ];
    
    print('📊 [ChatClient] Sending ${allMessages.length} messages (${conversationHistory?.length ?? 0} history + 1 current)');

    // Track state
    String accumulatedText = '';
    final activeToolCalls = <ActiveToolCall>{}; // Track active tool calls by ID
    final toolResults = <ToolResult>[];
    final reasoningSteps = <String>[];
    Map<String, dynamic>? latestAnnotations;
    UsageMetadata? latestUsage;

    try {
      print('🔄 [ChatClient] Starting stream...');
      await for (final event in _streamClient.streamChat(
        endpoint: '/api/chat',
        messages: allMessages,  // ← Send all messages (like useChat)
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
            activeToolCalls: List.from(activeToolCalls),
            toolResults: List.from(toolResults),
            reasoningSteps: List.from(reasoningSteps),
            annotations: latestAnnotations,
            usage: latestUsage,
            isComplete: false,
          );
        } else if (event.isToolCallStreaming) {
          // Tool call started - add to active calls
          if (event.toolCallId != null) {
            activeToolCalls.add(ActiveToolCall(
              name: event.toolName ?? 'unknown',
              id: event.toolCallId!,
              state: 'input-streaming',
            ));

            yield ChatResponse(
              text: accumulatedText,
              activeToolCalls: List.from(activeToolCalls),
              toolResults: List.from(toolResults),
              reasoningSteps: List.from(reasoningSteps),
              annotations: latestAnnotations,
              usage: latestUsage,
              isComplete: false,
            );
          }
        } else if (event.isToolCallAvailable) {
          // Tool call processing - update state
          if (event.toolCallId != null) {
            activeToolCalls.removeWhere((tc) => tc.id == event.toolCallId);
            activeToolCalls.add(ActiveToolCall(
              name: event.toolName ?? 'unknown',
              id: event.toolCallId!,
              state: 'input-available',
            ));

            yield ChatResponse(
              text: accumulatedText,
              activeToolCalls: List.from(activeToolCalls),
              toolResults: List.from(toolResults),
              reasoningSteps: List.from(reasoningSteps),
              annotations: latestAnnotations,
              usage: latestUsage,
              isComplete: false,
            );
          }
        } else if (event.isToolResult) {
          // Tool completed - remove from active calls and add result
          if (event.toolCallId != null) {
            activeToolCalls.removeWhere((tc) => tc.id == event.toolCallId);
          }

          final toolResult = ToolResult(
            name: event.toolName ?? 'unknown',
            id: event.toolCallId,
            result: event.toolResult,
            state: 'success',
          );
          toolResults.add(toolResult);

          yield ChatResponse(
            text: accumulatedText,
            activeToolCalls: List.from(activeToolCalls),
            toolResults: List.from(toolResults),
            reasoningSteps: List.from(reasoningSteps),
            annotations: latestAnnotations,
            usage: latestUsage,
            isComplete: false,
          );
        } else if (event.isToolError) {
          // Tool failed - remove from active calls and add error result
          if (event.toolCallId != null) {
            activeToolCalls.removeWhere((tc) => tc.id == event.toolCallId);
          }

          final toolResult = ToolResult(
            name: event.toolName ?? 'unknown',
            id: event.toolCallId,
            result: {'error': event.error ?? 'Unknown error'},
            state: 'error',
          );
          toolResults.add(toolResult);

          yield ChatResponse(
            text: accumulatedText,
            activeToolCalls: List.from(activeToolCalls),
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
              activeToolCalls: List.from(activeToolCalls),
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
            activeToolCalls: List.from(activeToolCalls),
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
            activeToolCalls: List.from(activeToolCalls),
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
        activeToolCalls: List.from(activeToolCalls),
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
  final List<ActiveToolCall> activeToolCalls; // Currently running tools
  final List<ToolResult> toolResults; // Completed tools
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
    this.activeToolCalls = const [],
    required this.toolResults,
    this.error,
    this.finishReason,
    required this.isComplete,
    this.annotations,
    this.usage,
    this.reasoningSteps = const [],
  });

  bool get hasError => error != null;
  bool get hasActiveToolCalls => activeToolCalls.isNotEmpty;
  bool get hasToolResults => toolResults.isNotEmpty;
  bool get hasAnnotations => annotations != null && annotations!.isNotEmpty;
  bool get hasUsage => usage != null;
  bool get hasReasoning => reasoningSteps.isNotEmpty;

  @override
  String toString() {
    return 'ChatResponse(text: ${text.length} chars, activeToolCalls: ${activeToolCalls.length}, toolResults: ${toolResults.length}, error: $error, complete: $isComplete, usage: $usage)';
  }
}

/// Active Tool Call (currently running)
class ActiveToolCall {
  final String name;
  final String id;
  final String state; // 'input-streaming' | 'input-available'

  ActiveToolCall({
    required this.name,
    required this.id,
    required this.state,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveToolCall &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ActiveToolCall(name: $name, id: $id, state: $state)';
}

/// Tool Result (completed tool execution)
class ToolResult {
  final String name;
  final String? id;
  final dynamic result;
  final String state; // 'success' | 'error'

  ToolResult({
    required this.name,
    this.id,
    required this.result,
    required this.state,
  });

  bool get isError => state == 'error';
  bool get isSuccess => state == 'success';

  @override
  String toString() => 'ToolResult(name: $name, id: $id, state: $state)';
}
