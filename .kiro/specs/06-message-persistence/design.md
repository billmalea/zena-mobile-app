# Design Document

## Overview

The Message Persistence Enhancement ensures all messages (user, assistant, tool results) are saved locally after streaming completes. This provides offline access, prevents data loss, and enables offline message queuing. The system uses SQLite for local storage and implements sync mechanisms for consistency.

**Current State:** No message persistence exists. Messages are lost on app restart.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Chat Provider                        │
│                         │                               │
│         ┌───────────────┼───────────────┐              │
│         ▼               ▼               ▼              │
│   Send Message   Stream Response   Load Messages       │
│         │               │               │              │
│         ▼               ▼               ▼              │
│  Message Persistence Service                           │
│         │               │               │              │
│         ▼               ▼               ▼              │
│   Save User Msg   Save AI Msg    Load from DB         │
│         │               │               │              │
│         └───────────────┼───────────────┘              │
│                         ▼                               │
│                  SQLite Database                        │
│                  (messages table)                       │
└─────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. Message Persistence Service

**Location:** `lib/services/message_persistence_service.dart`

**Purpose:** Handle all message persistence operations

**Interface:**
```dart
class MessagePersistenceService {
  final Database _db;
  
  MessagePersistenceService(this._db);
  
  /// Initialize database
  static Future<MessagePersistenceService> create() async {
    final db = await _initDatabase();
    return MessagePersistenceService(db);
  }
  
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'zena_messages.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            conversation_id TEXT NOT NULL,
            role TEXT NOT NULL,
            content TEXT NOT NULL,
            tool_results TEXT,
            metadata TEXT,
            synced INTEGER DEFAULT 0,
            local_only INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (conversation_id) REFERENCES conversations(id)
          )
        ''');
        
        await db.execute('''
          CREATE INDEX idx_messages_conversation 
          ON messages(conversation_id)
        ''');
        
        await db.execute('''
          CREATE INDEX idx_messages_created 
          ON messages(created_at)
        ''');
      },
    );
  }
  
  /// Save message
  Future<void> saveMessage(Message message, String conversationId) async {
    await _db.insert(
      'messages',
      {
        'id': message.id,
        'conversation_id': conversationId,
        'role': message.role,
        'content': message.content,
        'tool_results': message.toolResults != null 
          ? jsonEncode(message.toolResults!.map((tr) => tr.toJson()).toList())
          : null,
        'metadata': message.metadata != null 
          ? jsonEncode(message.metadata)
          : null,
        'synced': 0,
        'local_only': 0,
        'created_at': message.createdAt.millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Update message
  Future<void> updateMessage(String messageId, Message message) async {
    await _db.update(
      'messages',
      {
        'content': message.content,
        'tool_results': message.toolResults != null 
          ? jsonEncode(message.toolResults!.map((tr) => tr.toJson()).toList())
          : null,
        'metadata': message.metadata != null 
          ? jsonEncode(message.metadata)
          : null,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }
  
  /// Load messages for conversation
  Future<List<Message>> loadMessages(String conversationId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
    );
    
    return maps.map((map) => _messageFromMap(map)).toList();
  }
  
  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    await _db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }
  
  /// Clear conversation messages
  Future<void> clearConversationMessages(String conversationId) async {
    await _db.delete(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
  }
  
  /// Mark message as synced
  Future<void> markAsSynced(String messageId) async {
    await _db.update(
      'messages',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }
  
  /// Get unsynced messages
  Future<List<Message>> getUnsyncedMessages() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'messages',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
    
    return maps.map((map) => _messageFromMap(map)).toList();
  }
  
  /// Convert map to Message
  Message _messageFromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      role: map['role'],
      content: map['content'],
      toolResults: map['tool_results'] != null
        ? (jsonDecode(map['tool_results']) as List)
            .map((tr) => ToolResult.fromJson(tr))
            .toList()
        : null,
      metadata: map['metadata'] != null
        ? jsonDecode(map['metadata'])
        : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}
```

### 2. Offline Message Queue

**Location:** `lib/services/offline_message_queue.dart`

**Purpose:** Queue messages when offline and send when online

**Interface:**
```dart
class OfflineMessageQueue {
  final MessagePersistenceService _persistenceService;
  final ChatService _chatService;
  final List<Message> _queue = [];
  
  OfflineMessageQueue(this._persistenceService, this._chatService);
  
  /// Enqueue message
  Future<void> enqueue(Message message, String conversationId) async {
    _queue.add(message);
    
    // Mark as local only
    await _persistenceService.saveMessage(message, conversationId);
  }
  
  /// Process queue
  Future<void> processQueue() async {
    while (_queue.isNotEmpty) {
      final message = _queue.first;
      
      try {
        // Try to send message
        // await _chatService.sendMessage(...);
        
        // Mark as synced
        await _persistenceService.markAsSynced(message.id);
        
        // Remove from queue
        _queue.removeAt(0);
      } catch (e) {
        // Still offline, stop processing
        break;
      }
    }
  }
  
  /// Check if queue has messages
  bool get hasQueuedMessages => _queue.isNotEmpty;
  
  /// Get queue size
  int get queueSize => _queue.length;
}
```

### 3. Message Sync Service

**Location:** `lib/services/message_sync_service.dart`

**Purpose:** Sync messages with backend

**Interface:**
```dart
class MessageSyncService {
  final MessagePersistenceService _persistenceService;
  final ChatService _chatService;
  Timer? _syncTimer;
  
  MessageSyncService(this._persistenceService, this._chatService);
  
  /// Start background sync
  void startBackgroundSync() {
    _syncTimer = Timer.periodic(Duration(minutes: 5), (_) {
      syncAllConversations();
    });
  }
  
  /// Stop background sync
  void stopBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
  
  /// Sync messages for conversation
  Future<void> syncMessages(String conversationId) async {
    try {
      // Get messages from backend
      final conversation = await _chatService.getConversation(conversationId);
      
      // Get local messages
      final localMessages = await _persistenceService.loadMessages(conversationId);
      
      // Merge messages (simple last-write-wins)
      for (final backendMessage in conversation.messages) {
        final localMessage = localMessages.firstWhere(
          (m) => m.id == backendMessage.id,
          orElse: () => backendMessage,
        );
        
        // Save/update local message
        await _persistenceService.saveMessage(backendMessage, conversationId);
        await _persistenceService.markAsSynced(backendMessage.id);
      }
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }
  
  /// Sync all conversations
  Future<void> syncAllConversations() async {
    // Implementation depends on available API
  }
}
```

### 4. Chat Provider Integration

**Location:** `lib/providers/chat_provider.dart` (update)

**Updates Required:**
- Integrate MessagePersistenceService
- Save messages after sending/receiving
- Load messages from local storage first
- Handle offline scenarios

**Updated Methods:**
```dart
class ChatProvider with ChangeNotifier {
  final MessagePersistenceService _persistenceService;
  final OfflineMessageQueue _offlineQueue;
  
  // ... existing code ...
  
  /// Load conversation with local persistence
  Future<void> loadConversation(String conversationId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Load from local storage first
      final localMessages = await _persistenceService.loadMessages(conversationId);
      
      if (localMessages.isNotEmpty) {
        _messages = localMessages;
        _conversationId = conversationId;
        notifyListeners();
      }
      
      // Then sync with backend
      final conversation = await _chatService.getConversation(conversationId);
      _conversationId = conversation.id;
      _messages = List.from(conversation.messages);
      
      // Save to local storage
      for (final message in _messages) {
        await _persistenceService.saveMessage(message, conversationId);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // If offline, use local messages
      _error = 'Failed to sync: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Send message with persistence
  Future<void> sendMessage(String text, [List<File>? files]) async {
    // ... existing code ...
    
    // Save user message immediately
    await _persistenceService.saveMessage(userMessage, _conversationId!);
    
    // ... streaming code ...
  }
  
  /// Handle chat event with persistence
  void _handleChatEvent(ChatEvent event, String assistantMessageId) {
    // ... existing code ...
    
    // Save assistant message after streaming completes
    if (event.isDone) {
      final message = _messages.firstWhere((m) => m.id == assistantMessageId);
      _persistenceService.saveMessage(message, _conversationId!);
    }
  }
}
```

## Data Models

### Message Model Enhancement

**Location:** `lib/models/message.dart` (update)

**Add fields:**
```dart
class Message {
  // ... existing fields ...
  final bool synced;
  final bool localOnly;
  final DateTime? updatedAt;
  
  Message({
    // ... existing parameters ...
    this.synced = false,
    this.localOnly = false,
    this.updatedAt,
  });
}
```

## Testing Strategy

### Unit Tests
- Test message save/load
- Test message update
- Test message delete
- Test offline queue
- Test sync service

### Integration Tests
- Test message persistence after app restart
- Test offline message queuing
- Test message sync
- Test conflict resolution

### Manual Tests
- Send message, restart app, verify message persists
- Go offline, send message, go online, verify message sends
- Test with multiple conversations

## Implementation Notes

### Phase 1: Persistence Service (Day 1)
- Create MessagePersistenceService
- Set up SQLite database
- Test CRUD operations

### Phase 2: Provider Integration (Day 1-2)
- Update ChatProvider
- Add persistence calls
- Test end-to-end

### Phase 3: Offline Support (Day 2)
- Create OfflineMessageQueue
- Create MessageSyncService
- Test offline scenarios

## Dependencies

```yaml
dependencies:
  sqflite: ^2.3.0  # SQLite database
  path: ^1.8.0  # Path operations
```
