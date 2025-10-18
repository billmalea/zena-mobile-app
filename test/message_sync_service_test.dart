import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zena_mobile/models/conversation.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/services/message_persistence_service.dart';
import 'package:zena_mobile/services/message_sync_service.dart';
import 'package:zena_mobile/services/chat_service.dart';

/// Mock ChatService for testing
class MockChatService extends ChatService {
  List<Conversation> mockConversations = [];
  Map<String, Conversation> mockConversationMap = {};

  @override
  Future<List<Conversation>> getConversations() async {
    return mockConversations;
  }

  @override
  Future<Conversation> getConversation(String? conversationId) async {
    if (conversationId == null || !mockConversationMap.containsKey(conversationId)) {
      throw Exception('Conversation not found');
    }
    return mockConversationMap[conversationId]!;
  }
}

void main() {
  late Database database;
  late MessagePersistenceService persistenceService;
  late MockChatService chatService;
  late MessageSyncService syncService;

  setUpAll(() async {
    // Initialize FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    // Load environment variables for testing
    await dotenv.load(fileName: '.env.local');
  });

  setUp(() async {
    // Create in-memory database for testing
    database = await openDatabase(
      inMemoryDatabasePath,
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
            updated_at INTEGER NOT NULL
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

    persistenceService = MessagePersistenceService.createWithDatabase(database);
    chatService = MockChatService();
    syncService = MessageSyncService(persistenceService, chatService);
  });

  tearDown(() async {
    syncService.dispose();
    await database.close();
  });

  group('MessageSyncService', () {
    test('syncMessages should sync new messages from backend', () async {
      // Arrange
      final conversationId = 'conv-1';
      final backendMessage = Message(
        id: 'msg-1',
        role: 'assistant',
        content: 'Hello from backend',
        createdAt: DateTime.now(),
      );

      chatService.mockConversationMap[conversationId] = Conversation(
        id: conversationId,
        userId: 'user-1',
        messages: [backendMessage],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await syncService.syncMessages(conversationId);

      // Assert
      final localMessages = await persistenceService.loadMessages(conversationId);
      expect(localMessages.length, 1);
      expect(localMessages[0].id, 'msg-1');
      expect(localMessages[0].content, 'Hello from backend');
      expect(localMessages[0].synced, true);
    });

    test('syncMessages should use last-write-wins for conflicts', () async {
      // Arrange
      final conversationId = 'conv-1';
      final now = DateTime.now();
      final oldTime = now.subtract(const Duration(hours: 1));

      // Save older local message
      final localMessage = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Old local content',
        createdAt: oldTime,
        updatedAt: oldTime,
      );
      await persistenceService.saveMessage(localMessage, conversationId);

      // Backend has newer version
      final backendMessage = Message(
        id: 'msg-1',
        role: 'user',
        content: 'New backend content',
        createdAt: oldTime,
        updatedAt: now,
      );

      chatService.mockConversationMap[conversationId] = Conversation(
        id: conversationId,
        userId: 'user-1',
        messages: [backendMessage],
        createdAt: oldTime,
        updatedAt: now,
      );

      // Act
      await syncService.syncMessages(conversationId);

      // Assert
      final localMessages = await persistenceService.loadMessages(conversationId);
      expect(localMessages.length, 1);
      expect(localMessages[0].content, 'New backend content');
      expect(localMessages[0].synced, true);
    });

    test('syncMessages should keep local version if newer', () async {
      // Arrange
      final conversationId = 'conv-1';
      final now = DateTime.now();
      final oldTime = now.subtract(const Duration(hours: 1));

      // Save newer local message
      final localMessage = Message(
        id: 'msg-1',
        role: 'user',
        content: 'New local content',
        createdAt: oldTime,
        updatedAt: now,
      );
      await persistenceService.saveMessage(localMessage, conversationId);

      // Backend has older version
      final backendMessage = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Old backend content',
        createdAt: oldTime,
        updatedAt: oldTime,
      );

      chatService.mockConversationMap[conversationId] = Conversation(
        id: conversationId,
        userId: 'user-1',
        messages: [backendMessage],
        createdAt: oldTime,
        updatedAt: oldTime,
      );

      // Act
      await syncService.syncMessages(conversationId);

      // Assert
      final localMessages = await persistenceService.loadMessages(conversationId);
      expect(localMessages.length, 1);
      expect(localMessages[0].content, 'New local content');
    });

    test('syncAllConversations should sync multiple conversations', () async {
      // Arrange
      final conv1 = Conversation(
        id: 'conv-1',
        userId: 'user-1',
        messages: [
          Message(
            id: 'msg-1',
            role: 'user',
            content: 'Message in conv 1',
            createdAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final conv2 = Conversation(
        id: 'conv-2',
        userId: 'user-1',
        messages: [
          Message(
            id: 'msg-2',
            role: 'user',
            content: 'Message in conv 2',
            createdAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      chatService.mockConversations = [conv1, conv2];
      chatService.mockConversationMap['conv-1'] = conv1;
      chatService.mockConversationMap['conv-2'] = conv2;

      // Act
      await syncService.syncAllConversations();

      // Assert
      final conv1Messages = await persistenceService.loadMessages('conv-1');
      final conv2Messages = await persistenceService.loadMessages('conv-2');

      expect(conv1Messages.length, 1);
      expect(conv1Messages[0].content, 'Message in conv 1');
      expect(conv2Messages.length, 1);
      expect(conv2Messages[0].content, 'Message in conv 2');
    });

    test('startBackgroundSync should start periodic sync', () async {
      // Act
      syncService.startBackgroundSync();

      // Assert
      expect(syncService.isSyncing, false);

      // Cleanup
      syncService.stopBackgroundSync();
    });

    test('stopBackgroundSync should stop periodic sync', () async {
      // Arrange
      syncService.startBackgroundSync();

      // Act
      syncService.stopBackgroundSync();

      // Assert - no exception should be thrown
      expect(syncService.isSyncing, false);
    });

    test('syncMessages should handle errors gracefully', () async {
      // Arrange
      final conversationId = 'non-existent';

      // Act & Assert - should not throw
      await syncService.syncMessages(conversationId);

      // Verify no messages were saved
      final messages = await persistenceService.loadMessages(conversationId);
      expect(messages.length, 0);
    });

    test('syncMessages should mark messages as synced', () async {
      // Arrange
      final conversationId = 'conv-1';
      final backendMessage = Message(
        id: 'msg-1',
        role: 'assistant',
        content: 'Test message',
        createdAt: DateTime.now(),
      );

      chatService.mockConversationMap[conversationId] = Conversation(
        id: conversationId,
        userId: 'user-1',
        messages: [backendMessage],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await syncService.syncMessages(conversationId);

      // Assert
      final localMessages = await persistenceService.loadMessages(conversationId);
      expect(localMessages[0].synced, true);
    });

    test('isSyncing should return sync status', () async {
      // Initially not syncing
      expect(syncService.isSyncing, false);

      // Note: Testing actual syncing state would require async coordination
      // which is complex in unit tests. The property is tested indirectly
      // through other tests.
    });
  });
}
