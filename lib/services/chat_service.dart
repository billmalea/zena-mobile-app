import '../config/app_config.dart';
import '../models/conversation.dart';
import '../ai_sdk/chat_client.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Chat Service for handling chat operations
/// Manages conversations and message streaming
class ChatService {
  final _apiService = ApiService();
  final _authService = AuthService();
  late final ChatClient _chatClient;

  ChatService() {
    _chatClient = ChatClient(
      baseUrl: AppConfig.baseUrl, // Use baseUrl, not apiUrl (client adds /api/chat)
      authService: _authService,
    );
  }

  /// Get current user ID
  String? getUserId() {
    return _authService.currentUser?.id;
  }

  /// Send a message and stream the response using AI SDK client
  /// Message text may contain embedded file URLs
  Stream<ChatEvent> sendMessage({
    required String message,
    String? conversationId,
  }) async* {
    print('🎬 [ChatService] sendMessage called');
    print('💬 [ChatService] Message: $message');
    print('🆔 [ChatService] Conversation ID: $conversationId');
    
    try {
      print('🔄 [ChatService] Calling ChatClient...');
      await for (final response in _chatClient.sendMessage(
        message: message,
        conversationId: conversationId,
      )) {
        print('📥 [ChatService] Received response: text=${response.text.length} chars, error=${response.error}');
        // Convert ChatResponse to ChatEvent
        if (response.hasError) {
          print('❌ [ChatService] Error response: ${response.error}');
          yield ChatEvent(
            type: 'error',
            content: response.error,
          );
        } else if (response.text.isNotEmpty) {
          print('✅ [ChatService] Text response: ${response.text.substring(0, response.text.length > 50 ? 50 : response.text.length)}...');
          yield ChatEvent(
            type: 'text',
            content: response.text,
          );
        }

        // Yield tool calls
        for (final toolCall in response.toolCalls) {
          yield ChatEvent(
            type: 'tool-call',
            toolResult: {
              'toolName': toolCall.name,
              'toolCallId': toolCall.id,
              'args': toolCall.args,
              'state': toolCall.state,
            },
          );
        }

        // Yield tool results
        for (final toolResult in response.toolResults) {
          yield ChatEvent(
            type: 'tool-result',
            toolResult: {
              'toolName': toolResult.name,
              'toolCallId': toolResult.id,
              'result': toolResult.result,
              'state': toolResult.state,
            },
          );
        }
      }
      print('🎉 [ChatService] Stream complete');
    } catch (e) {
      print('❌ [ChatService] Error: $e');
      print('❌ [ChatService] Stack trace: ${StackTrace.current}');
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
