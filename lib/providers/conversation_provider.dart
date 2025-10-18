import 'package:flutter/foundation.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';

/// Conversation Provider for managing conversation list state
/// Handles conversation loading, switching, deletion, and search
class ConversationProvider with ChangeNotifier {
  final ChatService _chatService;

  List<Conversation> _conversations = [];
  String? _activeConversationId;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';

  ConversationProvider(this._chatService);

  // Getters
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  String? get activeConversationId => _activeConversationId;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  /// Load conversations with optional refresh
  /// If refresh is true, clears existing conversations and reloads from page 1
  Future<void> loadConversations({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _conversations = [];
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newConversations = await _chatService.getConversations();

      if (refresh) {
        _conversations = newConversations;
      } else {
        _conversations.addAll(newConversations);
      }

      // Assume pagination limit is 20 items per page
      _hasMore = newConversations.length >= 20;
      _currentPage++;
    } catch (e) {
      _error = 'Failed to load conversations: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more conversations (pagination)
  /// Only loads if there are more conversations and not currently loading
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await loadConversations();
  }

  /// Switch to a different conversation
  /// Updates the active conversation ID
  Future<void> switchConversation(String conversationId) async {
    _activeConversationId = conversationId;
    notifyListeners();
  }

  /// Delete a conversation
  /// Removes from local list and clears active conversation if deleted
  Future<void> deleteConversation(String conversationId) async {
    try {
      // TODO: Call API to delete when endpoint is available
      // await _chatService.deleteConversation(conversationId);

      // Remove from local list
      _conversations.removeWhere((c) => c.id == conversationId);

      // If deleted active conversation, clear it
      if (_activeConversationId == conversationId) {
        _activeConversationId = null;
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete conversation: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Search conversations by query
  /// Filters conversations based on message content
  Future<void> searchConversations(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      await loadConversations(refresh: true);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Filter locally for now
      // TODO: Implement server-side search if available
      final allConversations = await _chatService.getConversations();
      _conversations = allConversations.where((conv) {
        // Search in last message content
        final lastMessage = conv.messages.isNotEmpty
            ? conv.messages.last.content.toLowerCase()
            : '';
        return lastMessage.contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set active conversation
  /// Updates the active conversation ID without loading
  void setActiveConversation(String conversationId) {
    _activeConversationId = conversationId;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
