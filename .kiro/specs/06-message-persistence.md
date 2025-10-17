---
title: Message Persistence Enhancement
priority: MEDIUM
estimated_effort: 2 days
status: pending
dependencies: []
---

# Message Persistence Enhancement

## Overview
Enhance message persistence to save all messages (user, assistant, tool results) after streaming completes. This is MEDIUM PRIORITY - improves reliability but not blocking.

## Current State
- ⚠️ Partial message persistence
- ❌ Messages not saved after streaming
- ❌ Tool results not persisted
- ❌ No offline message support

## Requirements

### 1. Message Persistence Service
Create `lib/services/message_persistence_service.dart`

**Features:**
- Save user messages immediately
- Save assistant messages after streaming completes
- Save tool results in message metadata
- Update messages during streaming (optional)
- Load message history
- Delete messages
- Clear conversation messages

**Methods:**
```dart
Future<void> saveMessage(Message message, String conversationId)
Future<void> updateMessage(String messageId, Message message)
Future<List<Message>> loadMessages(String conversationId)
Future<void> deleteMessage(String messageId)
Future<void> clearConversationMessages(String conversationId)
```

### 2. Local Database Setup
Use SQLite for local message storage

**Schema:**
```sql
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  conversation_id TEXT NOT NULL,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  tool_results TEXT, -- JSON
  metadata TEXT, -- JSON
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (conversation_id) REFERENCES conversations(id)
);

CREATE INDEX idx_messages_conversation 
  ON messages(conversation_id);
  
CREATE INDEX idx_messages_created 
  ON messages(created_at);
```

**Alternative:** Use `sqflite` package (already in dependencies)

### 3. Chat Provider Enhancement
Update `lib/providers/chat_provider.dart`

**Features:**
- Save user messages immediately after adding to list
- Save assistant messages after streaming completes
- Update messages with tool results
- Load messages from local storage on conversation load
- Sync with backend periodically

**Integration:**
```dart
final MessagePersistenceService _persistenceService = 
  MessagePersistenceService();

Future<void> sendMessage(String text, [List<File>? files]) async {
  // ... existing code ...
  
  // Save user message
  await _persistenceService.saveMessage(userMessage, _conversationId!);
  
  // ... streaming code ...
}

void _handleChatEvent(ChatEvent event, String assistantMessageId) {
  // ... existing code ...
  
  // Save assistant message after streaming completes
  if (event.isDone) {
    final message = _messages.firstWhere((m) => m.id == assistantMessageId);
    _persistenceService.saveMessage(message, _conversationId!);
  }
}

Future<void> loadConversation(String conversationId) async {
  // Load from local storage first
  final localMessages = await _persistenceService.loadMessages(conversationId);
  
  if (localMessages.isNotEmpty) {
    _messages = localMessages;
    notifyListeners();
  }
  
  // Then sync with backend
  // ... existing code ...
}
```

### 4. Offline Support

**Features:**
- Queue messages when offline
- Send queued messages when online
- Show offline indicator
- Sync messages on reconnect

**Implementation:**
```dart
class OfflineMessageQueue {
  final List<Message> _queue = [];
  
  void enqueue(Message message) {
    _queue.add(message);
    _saveQueue();
  }
  
  Future<void> processQueue() async {
    while (_queue.isNotEmpty) {
      final message = _queue.first;
      try {
        await _sendMessage(message);
        _queue.removeAt(0);
      } catch (e) {
        break; // Stop if still offline
      }
    }
    _saveQueue();
  }
}
```

### 5. Message Sync Service
Create `lib/services/message_sync_service.dart`

**Features:**
- Sync local messages with backend
- Detect conflicts (same message edited on different devices)
- Resolve conflicts (last write wins)
- Background sync (periodic)

**Methods:**
```dart
Future<void> syncMessages(String conversationId)
Future<void> syncAllConversations()
void startBackgroundSync()
void stopBackgroundSync()
```

### 6. Message Metadata Enhancement
Update `lib/models/message.dart`

**Features:**
- Add `synced` flag
- Add `localOnly` flag
- Add `updatedAt` timestamp
- Add `metadata` field for tool results

**Model Update:**
```dart
class Message {
  final String id;
  final String role;
  final String content;
  final List<ToolResult>? toolResults;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool synced;
  final bool localOnly;
  final Map<String, dynamic>? metadata;
  
  Message copyWith({
    String? content,
    List<ToolResult>? toolResults,
    DateTime? updatedAt,
    bool? synced,
    Map<String, dynamic>? metadata,
  });
}
```

## Implementation Tasks

### Phase 1: Persistence Service (Day 1)
- [ ] Create `message_persistence_service.dart`
- [ ] Set up SQLite database
- [ ] Implement CRUD operations
- [ ] Test persistence

### Phase 2: Chat Provider Integration (Day 1-2)
- [ ] Update ChatProvider with persistence
- [ ] Save user messages immediately
- [ ] Save assistant messages after streaming
- [ ] Load messages from local storage
- [ ] Test end-to-end persistence

### Phase 3: Offline Support (Day 2)
- [ ] Create offline message queue
- [ ] Implement message queuing
- [ ] Implement queue processing
- [ ] Add offline indicator
- [ ] Test offline mode

### Phase 4: Sync Service (Day 2)
- [ ] Create message sync service
- [ ] Implement sync logic
- [ ] Handle conflicts
- [ ] Add background sync
- [ ] Test sync

## Testing Checklist

### Unit Tests
- [ ] Message save
- [ ] Message load
- [ ] Message update
- [ ] Message delete
- [ ] Offline queue

### Integration Tests
- [ ] Messages persist after app restart
- [ ] Tool results persist
- [ ] Offline messages queue
- [ ] Queued messages send on reconnect
- [ ] Sync resolves conflicts

### Manual Tests
- [ ] Send message, restart app, verify message persists
- [ ] Complete workflow, restart app, verify state persists
- [ ] Go offline, send message, go online, verify message sends
- [ ] Edit message on two devices, verify conflict resolution

## Success Criteria
- ✅ All messages persist locally
- ✅ Tool results persist
- ✅ Messages survive app restart
- ✅ Offline messages queue and send on reconnect
- ✅ Sync keeps messages consistent across devices

## Dependencies
- SQLite database (`sqflite` package)
- Network connectivity detection
- Background task support (optional)

## Notes
- Use SQLite for local storage
- Consider using `sqflite` package
- Implement conflict resolution strategy
- Background sync improves UX
- Offline support is critical for mobile

## Reference Files
- Web implementation: `zena/app/api/chat/route.ts` (message persistence)
- Message model: `zena_mobile_app/lib/models/message.dart`
