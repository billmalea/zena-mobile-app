import 'dart:convert';
import '../config/app_config.dart';
import '../models/conversation.dart';
import 'api_service.dart';

/// Chat Service for handling chat operations
/// Manages conversations and message streaming
class ChatService {
  final _apiService = ApiService();

  /// Send a message and stream the response
  Stream<ChatEvent> sendMessage({
    required String message,
    String? conversationId,
    List<String>? fileUrls,
  }) async* {
    try {
      final body = {
        'message': message,
        if (conversationId != null) 'conversationId': conversationId,
        if (fileUrls != null && fileUrls.isNotEmpty) 'fileUrls': fileUrls,
      };

      await for (final data in _apiService.streamPost(
        AppConfig.chatEndpoint,
        body,
      )) {
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final type = json['type'] as String?;

          if (type == 'text') {
            yield ChatEvent(
              type: 'text',
              content: json['content'] as String?,
            );
          } else if (type == 'tool') {
            yield ChatEvent(
              type: 'tool',
              toolResult: json['result'] as Map<String, dynamic>?,
            );
          } else if (type == 'error') {
            yield ChatEvent(
              type: 'error',
              content: json['message'] as String? ?? 'An error occurred',
            );
          }
        } catch (e) {
          // Skip malformed JSON chunks
          continue;
        }
      }
    } catch (e) {
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
  final String type; // 'text', 'tool', 'error'
  final String? content;
  final Map<String, dynamic>? toolResult;

  ChatEvent({
    required this.type,
    this.content,
    this.toolResult,
  });

  bool get isText => type == 'text';
  bool get isTool => type == 'tool';
  bool get isError => type == 'error';
}
