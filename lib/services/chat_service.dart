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
      baseUrl:
          AppConfig.baseUrl, // Use baseUrl, not apiUrl (client adds /api/chat)
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

    // Track which tool results we've already yielded to avoid duplicates
    final yieldedToolResultIds = <String>{};
    final yieldedActiveToolCallIds = <String>{};
    bool conversationIdYielded = false;

    try {
      print('🔄 [ChatService] Calling ChatClient...');
      await for (final response in _chatClient.sendMessage(
        message: message,
        conversationId: conversationId,
      )) {
        print(
            '📥 [ChatService] Received response: text=${response.text.length} chars, error=${response.error}');
        
        // Extract and yield conversation ID from annotations (only once)
        if (!conversationIdYielded && response.annotations != null) {
          final responseConversationId = response.annotations!['conversationId'] as String?;
          if (responseConversationId != null) {
            print('🆔 [ChatService] Extracted conversation ID from annotations: $responseConversationId');
            conversationIdYielded = true;
            yield ChatEvent(
              type: 'conversation-id',
              content: responseConversationId,
            );
          }
        }
        
        // Convert ChatResponse to ChatEvent
        if (response.hasError) {
          print('❌ [ChatService] Error response: ${response.error}');
          yield ChatEvent(
            type: 'error',
            content: response.error,
          );
        } else if (response.text.isNotEmpty) {
          print(
              '✅ [ChatService] Text response: ${response.text.substring(0, response.text.length > 50 ? 50 : response.text.length)}...');
          yield ChatEvent(
            type: 'text',
            content: response.text,
          );
        }

        // Yield only NEW active tool calls (for loading indicators)
        for (final toolCall in response.activeToolCalls) {
          if (!yieldedActiveToolCallIds.contains(toolCall.id)) {
            yieldedActiveToolCallIds.add(toolCall.id);
            yield ChatEvent(
              type: 'tool-call-active',
              toolResult: {
                'toolName': toolCall.name,
                'toolCallId': toolCall.id,
                'state': toolCall.state,
              },
            );
          }
        }

        // Yield only NEW tool results (avoid duplicates across messages)
        for (final toolResult in response.toolResults) {
          final resultId = toolResult.id ?? toolResult.name;
          if (!yieldedToolResultIds.contains(resultId)) {
            yieldedToolResultIds.add(resultId);
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
          ? '${AppConfig.conversationEndpoint}?conversationId=$conversationId' // Fixed: was ?id=
          : AppConfig.conversationEndpoint;

      print('🔍 [ChatService.getConversation] Fetching conversation');
      print('📍 [ChatService.getConversation] Endpoint: $endpoint');
      print(
          '🆔 [ChatService.getConversation] Conversation ID: $conversationId');

      final response = await _apiService.get(endpoint);

      print('📥 [ChatService.getConversation] Response received');
      print(
          '📦 [ChatService.getConversation] Response type: ${response.runtimeType}');
      print('📄 [ChatService.getConversation] Response data: $response');

      if (response == null) {
        print('❌ [ChatService.getConversation] Response is null');
        throw ApiException('No conversation data received', null);
      }

      final responseMap = response as Map<String, dynamic>;

      // Check if response has nested conversation structure
      Map<String, dynamic> conversationData;
      if (responseMap.containsKey('conversation')) {
        conversationData = responseMap['conversation'] as Map<String, dynamic>;
        final messages = responseMap['messages'] as List? ?? [];
        conversationData['messages'] = messages;
      } else {
        // Response is already in the correct format
        conversationData = responseMap;
      }

      print(
          '🔄 [ChatService.getConversation] Parsing conversation data: $conversationData');

      final conversation = Conversation.fromJson(conversationData);
      print('✅ [ChatService.getConversation] Conversation parsed successfully');
      print(
          '🆔 [ChatService.getConversation] Conversation ID: ${conversation.id}');
      print(
          '💬 [ChatService.getConversation] Message count: ${conversation.messages.length}');

      return conversation;
    } catch (e, stackTrace) {
      print('❌ [ChatService.getConversation] Error: $e');
      print('📚 [ChatService.getConversation] Stack trace: $stackTrace');
      throw ApiException('Failed to load conversation: ${e.toString()}', null);
    }
  }

  /// Get all conversations for the current user
  Future<List<Conversation>> getConversations() async {
    try {
      print('🔍 [ChatService.getConversations] Fetching conversations list');
      print(
          '📍 [ChatService.getConversations] Endpoint: ${AppConfig.conversationsEndpoint}');

      final response = await _apiService.get(AppConfig.conversationsEndpoint);

      print('📥 [ChatService.getConversations] Response received');
      print(
          '📦 [ChatService.getConversations] Response type: ${response.runtimeType}');
      print('📄 [ChatService.getConversations] Response data: $response');

      if (response == null) {
        print(
            '⚠️ [ChatService.getConversations] Response is null, returning empty list');
        return [];
      }

      final responseMap = response as Map<String, dynamic>;
      final conversationsList = responseMap['conversations'] as List;
      print(
          '📊 [ChatService.getConversations] Conversations count: ${conversationsList.length}');

      final conversations = conversationsList.map((json) {
        print('🔄 [ChatService.getConversations] Parsing conversation: $json');
        final conversationMap = json as Map<String, dynamic>;
        
        // Transform API response to match Conversation model
        // API returns: {id, title, lastMessage, lastMessageTime, messageCount, createdAt, updatedAt}
        // Pass all fields including optional ones for list display
        return Conversation.fromJson({
          'id': conversationMap['id'],
          'userId': '', // Not provided in list response
          'messages': [], // Messages not included in list response
          'createdAt': conversationMap['createdAt'],
          'updatedAt': conversationMap['updatedAt'],
          'title': conversationMap['title'],
          'lastMessage': conversationMap['lastMessage'],
          'lastMessageTime': conversationMap['lastMessageTime'],
          'messageCount': conversationMap['messageCount'],
        });
      }).toList();

      print(
          '✅ [ChatService.getConversations] Successfully parsed ${conversations.length} conversations');
      return conversations;
    } catch (e, stackTrace) {
      print('❌ [ChatService.getConversations] Error: $e');
      print('📚 [ChatService.getConversations] Stack trace: $stackTrace');
      throw ApiException('Failed to load conversations: ${e.toString()}', null);
    }
  }

  /// Create a new conversation
  Future<Conversation> createConversation() async {
    try {
      print('🔍 [ChatService.createConversation] Creating new conversation');
      print(
          '📍 [ChatService.createConversation] Endpoint: ${AppConfig.conversationEndpoint}');
      print('📦 [ChatService.createConversation] Request body: {}');

      final response = await _apiService.post(
        AppConfig.conversationEndpoint,
        {},
      );

      print('📥 [ChatService.createConversation] Response received');
      print(
          '📦 [ChatService.createConversation] Response type: ${response.runtimeType}');
      print('📄 [ChatService.createConversation] Response data: $response');

      if (response == null) {
        print('❌ [ChatService.createConversation] Response is null');
        throw ApiException('No conversation data received', null);
      }

      final responseMap = response as Map<String, dynamic>;

      // Extract conversation data from nested structure
      final conversationData =
          responseMap['conversation'] as Map<String, dynamic>;
      final messages = responseMap['messages'] as List? ?? [];

      // Add messages to conversation data
      conversationData['messages'] = messages;

      print(
          '🔄 [ChatService.createConversation] Parsing conversation data: $conversationData');

      final conversation = Conversation.fromJson(conversationData);
      print(
          '✅ [ChatService.createConversation] Conversation created successfully');
      print(
          '🆔 [ChatService.createConversation] Conversation ID: ${conversation.id}');

      return conversation;
    } catch (e, stackTrace) {
      print('❌ [ChatService.createConversation] Error: $e');
      print('📚 [ChatService.createConversation] Stack trace: $stackTrace');
      throw ApiException(
          'Failed to create conversation: ${e.toString()}', null);
    }
  }
}

/// Chat event for streaming responses
class ChatEvent {
  final String type; // 'text', 'tool-call', 'tool-result', 'error', 'conversation-id'
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
  bool get isConversationId => type == 'conversation-id';
}
