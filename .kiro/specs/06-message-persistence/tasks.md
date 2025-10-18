# Implementation Plan

- [x] 1. Create Message Persistence Service





  - Create `lib/services/message_persistence_service.dart`
  - Implement static create() method to initialize database
  - Implement _initDatabase() to create SQLite database with messages table
  - Create messages table with fields (id, conversation_id, role, content, tool_results, metadata, synced, local_only, created_at, updated_at)
  - Create indexes on conversation_id and created_at for performance
  - Implement saveMessage() method to insert/replace message
  - Implement updateMessage() method to update existing message
  - Implement loadMessages() method to retrieve messages for conversation
  - Implement deleteMessage() method to remove message
  - Implement clearConversationMessages() method to remove all messages for conversation
  - Implement markAsSynced() method to update synced flag
  - Implement getUnsyncedMessages() method to retrieve unsynced messages
  - Implement _messageFromMap() helper to convert database row to Message object
  - Test all CRUD operations
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 2. Update Message Model with Persistence Fields





  - Update `lib/models/message.dart` to add synced, localOnly, and updatedAt fields
  - Update Message constructor to include new fields with defaults
  - Update toJson() and fromJson() to handle new fields
  - Update copyWith() method to include new fields
  - Test serialization with new fields
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_



- [x] 3. Integrate Message Persistence into Chat Provider



  - Update `lib/providers/chat_provider.dart` to integrate MessagePersistenceService
  - Initialize MessagePersistenceService in ChatProvider constructor
  - Update sendMessage() to save user message immediately after adding to list
  - Update _handleChatEvent() to save assistant message after streaming completes
  - Update loadConversation() to load messages from local storage first, then sync with backend
  - Save backend messages to local storage after loading
  - Test message persistence during send/receive
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 4. Create Offline Message Queue Service






  - Create `lib/services/offline_message_queue.dart`
  - Add _queue list to store offline messages
  - Implement enqueue() method to add message to queue and mark as local_only
  - Implement processQueue() method to send queued messages when online
  - Implement hasQueuedMessages getter
  - Implement queueSize getter
  - Test queue operations
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 5. Create Message Sync Service







  - Create `lib/services/message_sync_service.dart`
  - Implement syncMessages() method to sync conversation messages with backend
  - Implement syncAllConversations() method to sync all conversations
  - Implement startBackgroundSync() method to start periodic sync (every 5 minutes)
  - Implement stopBackgroundSync() method to stop periodic sync
  - Handle merge conflicts using last-write-wins strategy
  - Mark synced messages with synced flag
  - Test sync operations
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 6. Integrate Offline Queue into Chat Provider






  - Update ChatProvider to integrate OfflineMessageQueue
  - Detect offline state when sending message
  - Enqueue message when offline
  - Process queue when connection is restored
  - Show "pending" indicator for queued messages
  - Test offline message queuing
  - Test automatic sending when online
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 7. Integrate Sync Service into Chat Provider

  - Update ChatProvider to integrate MessageSyncService
  - Start background sync when app starts
  - Stop background sync when app closes
  - Sync messages periodically
  - Handle sync errors gracefully
  - Test background sync
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 8. Implement Data Cleanup
  - Add method to archive old messages (threshold: 1000 per conversation)
  - Implement conversation deletion to remove all associated messages
  - Add option to clear message history in settings
  - Add option to export conversation history
  - Implement storage low notification and cleanup offer
  - Test cleanup operations
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 9. Test Message Persistence After App Restart
  - Send messages in conversation
  - Close and restart app
  - Verify messages are loaded from local storage
  - Verify tool results persist
  - Verify message metadata persists
  - Test with multiple conversations
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 10. Test Offline Scenarios
  - Disable network connection
  - Send message (should queue)
  - Verify message shows "pending" indicator
  - Enable network connection
  - Verify queued message sends automatically
  - Verify message marked as synced
  - Test with multiple queued messages
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 11. Test Sync Functionality
  - Create messages on device A
  - Sync with backend
  - Load conversation on device B
  - Verify messages appear on device B
  - Test conflict resolution (edit same message on both devices)
  - Verify last-write-wins strategy
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 12. End-to-End Integration Testing
  - Test complete message lifecycle (send → persist → restart → load)
  - Test offline message queuing and sending
  - Test background sync
  - Test data cleanup
  - Test with large message history (1000+ messages)
  - Test performance with multiple conversations
  - Verify no data loss scenarios
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5, 6.1, 6.2, 6.3, 6.4, 6.5_
