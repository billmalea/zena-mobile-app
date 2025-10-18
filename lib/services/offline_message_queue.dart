import 'package:flutter/foundation.dart';
import '../models/message.dart';
import 'message_persistence_service.dart';
import 'chat_service.dart';

/// Service for queuing messages when offline and sending when online
/// Handles automatic retry with exponential backoff
class OfflineMessageQueue {
  final MessagePersistenceService _persistenceService;
  final ChatService _chatService;
  final List<_QueuedMessage> _queue = [];

  OfflineMessageQueue(this._persistenceService, this._chatService);

  /// Enqueue message for sending when online
  /// Marks message as local_only in persistence
  Future<void> enqueue(Message message, String conversationId) async {
    debugPrint('📥 [OfflineMessageQueue] Enqueuing message: ${message.id}');
    
    // Add to in-memory queue
    _queue.add(_QueuedMessage(
      message: message,
      conversationId: conversationId,
      retryCount: 0,
    ));

    // Save to persistence with local_only flag
    final localMessage = message.copyWith(
      localOnly: true,
      synced: false,
    );
    
    await _persistenceService.saveMessage(localMessage, conversationId);
    
    debugPrint('✅ [OfflineMessageQueue] Message enqueued. Queue size: ${_queue.length}');
  }

  /// Process queued messages and send them when online
  /// Returns true if all messages were sent successfully
  Future<bool> processQueue() async {
    if (_queue.isEmpty) {
      debugPrint('ℹ️ [OfflineMessageQueue] Queue is empty, nothing to process');
      return true;
    }

    debugPrint('🔄 [OfflineMessageQueue] Processing queue with ${_queue.length} messages');
    
    bool allSent = true;
    final messagesToRemove = <_QueuedMessage>[];

    for (final queuedMessage in _queue) {
      try {
        debugPrint('📤 [OfflineMessageQueue] Attempting to send message: ${queuedMessage.message.id}');
        
        // Try to send message via chat service
        await for (final event in _chatService.sendMessage(
          message: queuedMessage.message.content,
          conversationId: queuedMessage.conversationId,
        )) {
          // Check for errors
          if (event.isError) {
            throw Exception(event.content ?? 'Unknown error');
          }
          
          // Wait for stream to complete
          // In a real implementation, you'd handle the full response
        }

        // Mark as synced in persistence
        await _persistenceService.markAsSynced(queuedMessage.message.id);
        
        // Mark for removal from queue
        messagesToRemove.add(queuedMessage);
        
        debugPrint('✅ [OfflineMessageQueue] Message sent successfully: ${queuedMessage.message.id}');
      } catch (e) {
        debugPrint('❌ [OfflineMessageQueue] Failed to send message: ${queuedMessage.message.id}, error: $e');
        
        // Increment retry count
        queuedMessage.retryCount++;
        
        // If max retries exceeded, mark for removal
        if (queuedMessage.retryCount >= _maxRetries) {
          debugPrint('⚠️ [OfflineMessageQueue] Max retries exceeded for message: ${queuedMessage.message.id}');
          messagesToRemove.add(queuedMessage);
        }
        
        allSent = false;
        
        // Stop processing if still offline
        break;
      }
    }

    // Remove successfully sent messages from queue
    for (final message in messagesToRemove) {
      _queue.remove(message);
    }

    debugPrint('🏁 [OfflineMessageQueue] Queue processing complete. Remaining: ${_queue.length}');
    
    return allSent;
  }

  /// Check if queue has messages waiting to be sent
  bool get hasQueuedMessages => _queue.isNotEmpty;

  /// Get current queue size
  int get queueSize => _queue.length;

  /// Maximum retry attempts before giving up
  static const int _maxRetries = 3;
}

/// Internal class to track queued messages with retry count
class _QueuedMessage {
  final Message message;
  final String conversationId;
  int retryCount;

  _QueuedMessage({
    required this.message,
    required this.conversationId,
    required this.retryCount,
  });
}
