import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';

/// Conversation Provider for managing conversation list state
/// Handles conversation loading, switching, deletion, and search with local persistence
class ConversationProvider with ChangeNotifier {
  final ChatService _chatService;
  static const String _cacheKey = 'cached_conversations';
  static const String _cacheTimestampKey = 'conversations_cache_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 24);

  List<Conversation> _conversations = [];
  String? _activeConversationId;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';
  bool _isInitialized = false;

  ConversationProvider(this._chatService) {
    _initializeFromCache();
  }

  /// Initialize provider by loading conversations from cache
  Future<void> _initializeFromCache() async {
    if (_isInitialized) return;
    
    try {
      await _loadFromCache();
      _isInitialized = true;
      
      // Sync with backend in the background
      _syncWithBackend();
    } catch (e) {
      debugPrint('Failed to initialize from cache: $e');
    }
  }

  // Getters
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  String? get activeConversationId => _activeConversationId;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get isInitialized => _isInitialized;

  /// Load conversations from local cache
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final cacheTimestamp = prefs.getInt(_cacheTimestampKey);

      if (cachedData != null) {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        _conversations = jsonList
            .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
            .toList();
        
        debugPrint('Loaded ${_conversations.length} conversations from cache');
        notifyListeners();

        // Check if cache is expired
        if (cacheTimestamp != null) {
          final cacheTime = DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);
          final now = DateTime.now();
          if (now.difference(cacheTime) > _cacheExpiry) {
            debugPrint('Cache expired, will sync with backend');
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load from cache: $e');
      // Don't set error state, just continue without cache
    }
  }

  /// Save conversations to local cache
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _conversations.map((c) => c.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      
      debugPrint('Saved ${_conversations.length} conversations to cache');
    } catch (e) {
      debugPrint('Failed to save to cache: $e');
      // Don't throw error, caching is optional
    }
  }

  /// Clear local cache
  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
      debugPrint('Cache cleared');
    } catch (e) {
      debugPrint('Failed to clear cache: $e');
    }
  }

  /// Sync conversations with backend
  Future<void> _syncWithBackend() async {
    try {
      final newConversations = await _chatService.getConversations();
      _conversations = newConversations;
      _hasMore = newConversations.length >= 20;
      
      // Save to cache after successful sync
      await _saveToCache();
      
      notifyListeners();
      debugPrint('Synced ${_conversations.length} conversations with backend');
    } catch (e) {
      debugPrint('Failed to sync with backend: $e');
      // Don't set error state if we have cached data
      if (_conversations.isEmpty) {
        _error = 'Failed to load conversations. Please check your connection.';
        notifyListeners();
      }
    }
  }

  /// Load conversations with optional refresh
  /// If refresh is true, clears existing conversations and reloads from page 1
  /// Automatically saves to cache after successful load
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
      
      // Save to cache after successful load
      await _saveToCache();
    } catch (e) {
      _error = 'Failed to load conversations: ${e.toString()}';
      // If we have cached data, keep showing it
      if (_conversations.isEmpty) {
        debugPrint('No cached data available, showing error');
      } else {
        debugPrint('Using cached data while offline');
        _error = 'Showing cached conversations. Unable to sync with server.';
      }
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
  /// Removes from local list and cache, clears active conversation if deleted
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

      // Update cache after deletion
      await _saveToCache();
      
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
