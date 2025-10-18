import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'message_persistence_service.dart';
import 'chat_service.dart';

/// Service for syncing messages between local storage and backend
/// Handles periodic background sync and conflict resolution using last-write-wins strategy
class MessageSyncService {
  final MessagePersistenceService _persistenceService;
  final ChatService _chatService;
  Timer? _syncTimer;
  bool _isSyncing = false;

  MessageSyncService(this._persistenceService, this._chatService);

  /// Start background sync with periodic interval (every 5 minutes)
  /// Automatically syncs all conversations in the background
  void startBackgroundSync() {
    if (_syncTimer != null) {
      debugPrint('[MessageSyncService] Background sync already running');
      return;
    }

    debugPrint('[MessageSyncService] Starting background sync (every 5 minutes)');
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncAllConversations();
    });
  }

  /// Stop background sync
  /// Cancels the periodic timer
  void stopBackgroundSync() {
    if (_syncTimer != null) {
      debugPrint('[MessageSyncService] Stopping background sync');
      _syncTimer?.cancel();
      _syncTimer = null;
    }
  }

  /// Sync messages for a specific conversation
  /// Loads messages from backend and merges with local storage using last-write-wins
  Future<void> syncMessages(String conversationId) async {
    if (_isSyncing) {
      debugPrint('[MessageSyncService] Sync already in progress, skipping');
      return;
    }

    try {
      _isSyncing = true;
      debugPrint('[MessageSyncService] Syncing messages for conversation: $conversationId');

      // Get messages from backend
      final Conversation conversation = await _chatService.getConversation(conversationId);
      final List<Message> backendMessages = conversation.messages;

      debugPrint('[MessageSyncService] Received ${backendMessages.length} messages from backend');

      // Get local messages
      final List<Message> localMessages = await _persistenceService.loadMessages(conversationId);
      debugPrint('[MessageSyncService] Found ${localMessages.length} local messages');

      // Create a map of local messages by ID for quick lookup
      final Map<String, Message> localMessageMap = {
        for (var msg in localMessages) msg.id: msg
      };

      // Merge messages using last-write-wins strategy
      for (final backendMessage in backendMessages) {
        final localMessage = localMessageMap[backendMessage.id];

        if (localMessage == null) {
          // New message from backend, save it
          debugPrint('[MessageSyncService] New message from backend: ${backendMessage.id}');
          final syncedMessage = backendMessage.copyWith(synced: true);
          await _persistenceService.saveMessage(syncedMessage, conversationId);
        } else {
          // Message exists locally, check which is newer
          final backendUpdatedAt = backendMessage.updatedAt ?? backendMessage.createdAt;
          final localUpdatedAt = localMessage.updatedAt ?? localMessage.createdAt;

          if (backendUpdatedAt.isAfter(localUpdatedAt)) {
            // Backend version is newer, update local
            debugPrint('[MessageSyncService] Backend version newer for: ${backendMessage.id}');
            final syncedMessage = backendMessage.copyWith(synced: true);
            await _persistenceService.saveMessage(syncedMessage, conversationId);
          } else if (localUpdatedAt.isAfter(backendUpdatedAt)) {
            // Local version is newer, keep local (backend should be updated separately)
            debugPrint('[MessageSyncService] Local version newer for: ${localMessage.id}');
            // Note: In a full implementation, we would push local changes to backend here
          } else {
            // Same timestamp, just mark as synced
            await _persistenceService.markAsSynced(backendMessage.id);
          }
        }
      }

      debugPrint('[MessageSyncService] Sync completed for conversation: $conversationId');
    } catch (e, stackTrace) {
      debugPrint('[MessageSyncService] Sync failed for conversation $conversationId: $e');
      debugPrint('[MessageSyncService] Stack trace: $stackTrace');
      // Don't rethrow - sync failures should not crash the app
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync all conversations
  /// Loads all conversations from backend and syncs their messages
  Future<void> syncAllConversations() async {
    if (_isSyncing) {
      debugPrint('[MessageSyncService] Sync already in progress, skipping');
      return;
    }

    try {
      _isSyncing = true;
      debugPrint('[MessageSyncService] Starting sync for all conversations');

      // Get all conversations from backend
      final List<Conversation> conversations = await _chatService.getConversations();
      debugPrint('[MessageSyncService] Found ${conversations.length} conversations to sync');

      // Sync each conversation
      for (final conversation in conversations) {
        try {
          // Reset syncing flag for individual conversation sync
          _isSyncing = false;
          await syncMessages(conversation.id);
          _isSyncing = true;
        } catch (e) {
          debugPrint('[MessageSyncService] Failed to sync conversation ${conversation.id}: $e');
          // Continue with next conversation
        }
      }

      debugPrint('[MessageSyncService] Completed sync for all conversations');
    } catch (e, stackTrace) {
      debugPrint('[MessageSyncService] Failed to sync all conversations: $e');
      debugPrint('[MessageSyncService] Stack trace: $stackTrace');
      // Don't rethrow - sync failures should not crash the app
    } finally {
      _isSyncing = false;
    }
  }

  /// Check if sync is currently in progress
  bool get isSyncing => _isSyncing;

  /// Dispose resources
  /// Stops background sync and cleans up
  void dispose() {
    stopBackgroundSync();
  }
}
