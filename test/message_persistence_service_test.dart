import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/services/message_persistence_service.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('MessagePersistenceService CRUD Operations', () {
    late MessagePersistenceService service;
    late Database db;
    const testConversationId = 'test-conversation-123';

    setUp(() async {
      // Use in-memory database for testing
      db = await openDatabase(
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
      service = MessagePersistenceService.createWithDatabase(db);
    });

    tearDown(() async {
      await service.close();
    });

    test('should save and load a message', () async {
      // Arrange
      final message = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Hello, world!',
        createdAt: DateTime.now(),
      );

      // Act
      await service.saveMessage(message, testConversationId);
      final loadedMessages = await service.loadMessages(testConversationId);

      // Assert
      expect(loadedMessages.length, 1);
      expect(loadedMessages.first.id, message.id);
      expect(loadedMessages.first.role, message.role);
      expect(loadedMessages.first.content, message.content);
    });

    test('should save message with tool results', () async {
      // Arrange
      final toolResult = ToolResult(
        toolName: 'search_properties',
        result: {'count': 5, 'properties': []},
      );
      final message = Message(
        id: 'msg-2',
        role: 'assistant',
        content: 'Found 5 properties',
        toolResults: [toolResult],
        createdAt: DateTime.now(),
      );

      // Act
      await service.saveMessage(message, testConversationId);
      final loadedMessages = await service.loadMessages(testConversationId);

      // Assert
      expect(loadedMessages.length, 1);
      expect(loadedMessages.first.toolResults, isNotNull);
      expect(loadedMessages.first.toolResults!.length, 1);
      expect(loadedMessages.first.toolResults!.first.toolName, 'search_properties');
    });

    test('should save message with metadata', () async {
      // Arrange
      final message = Message(
        id: 'msg-3',
        role: 'user',
        content: 'Submit property',
        metadata: {'submissionId': 'sub-123', 'workflowStage': 'contact_info'},
        createdAt: DateTime.now(),
      );

      // Act
      await service.saveMessage(message, testConversationId);
      final loadedMessages = await service.loadMessages(testConversationId);

      // Assert
      expect(loadedMessages.length, 1);
      expect(loadedMessages.first.metadata, isNotNull);
      expect(loadedMessages.first.metadata!['submissionId'], 'sub-123');
      expect(loadedMessages.first.metadata!['workflowStage'], 'contact_info');
    });

    test('should update existing message', () async {
      // Arrange
      final message = Message(
        id: 'msg-4',
        role: 'assistant',
        content: 'Initial content',
        createdAt: DateTime.now(),
      );
      await service.saveMessage(message, testConversationId);

      // Act
      final updatedMessage = message.copyWith(content: 'Updated content');
      await service.updateMessage(message.id, updatedMessage);
      final loadedMessages = await service.loadMessages(testConversationId);

      // Assert
      expect(loadedMessages.length, 1);
      expect(loadedMessages.first.content, 'Updated content');
    });

    test('should delete a message', () async {
      // Arrange
      final message = Message(
        id: 'msg-5',
        role: 'user',
        content: 'To be deleted',
        createdAt: DateTime.now(),
      );
      await service.saveMessage(message, testConversationId);

      // Act
      await service.deleteMessage(message.id);
      final loadedMessages = await service.loadMessages(testConversationId);

      // Assert
      expect(loadedMessages.length, 0);
    });

    test('should clear all conversation messages', () async {
      // Arrange
      final message1 = Message(
        id: 'msg-6',
        role: 'user',
        content: 'Message 1',
        createdAt: DateTime.now(),
      );
      final message2 = Message(
        id: 'msg-7',
        role: 'assistant',
        content: 'Message 2',
        createdAt: DateTime.now(),
      );
      await service.saveMessage(message1, testConversationId);
      await service.saveMessage(message2, testConversationId);

      // Act
      await service.clearConversationMessages(testConversationId);
      final loadedMessages = await service.loadMessages(testConversationId);

      // Assert
      expect(loadedMessages.length, 0);
    });

    test('should mark message as synced', () async {
      // Arrange
      final message = Message(
        id: 'msg-8',
        role: 'user',
        content: 'Unsynced message',
        createdAt: DateTime.now(),
      );
      await service.saveMessage(message, testConversationId);

      // Act
      final unsyncedBefore = await service.getUnsyncedMessages();
      await service.markAsSynced(message.id);
      final unsyncedAfter = await service.getUnsyncedMessages();

      // Assert
      expect(unsyncedBefore.length, 1);
      expect(unsyncedAfter.length, 0);
    });

    test('should get unsynced messages', () async {
      // Arrange
      final message1 = Message(
        id: 'msg-9',
        role: 'user',
        content: 'Unsynced 1',
        createdAt: DateTime.now(),
      );
      final message2 = Message(
        id: 'msg-10',
        role: 'user',
        content: 'Unsynced 2',
        createdAt: DateTime.now(),
      );
      await service.saveMessage(message1, testConversationId);
      await service.saveMessage(message2, testConversationId);
      await service.markAsSynced(message1.id);

      // Act
      final unsyncedMessages = await service.getUnsyncedMessages();

      // Assert
      expect(unsyncedMessages.length, 1);
      expect(unsyncedMessages.first.id, message2.id);
    });

    test('should load messages in chronological order', () async {
      // Arrange
      final now = DateTime.now();
      final message1 = Message(
        id: 'msg-11',
        role: 'user',
        content: 'First',
        createdAt: now.subtract(Duration(minutes: 2)),
      );
      final message2 = Message(
        id: 'msg-12',
        role: 'assistant',
        content: 'Second',
        createdAt: now.subtract(Duration(minutes: 1)),
      );
      final message3 = Message(
        id: 'msg-13',
        role: 'user',
        content: 'Third',
        createdAt: now,
      );

      // Act - Save in random order
      await service.saveMessage(message2, testConversationId);
      await service.saveMessage(message1, testConversationId);
      await service.saveMessage(message3, testConversationId);

      final loadedMessages = await service.loadMessages(testConversationId);

      // Assert
      expect(loadedMessages.length, 3);
      expect(loadedMessages[0].content, 'First');
      expect(loadedMessages[1].content, 'Second');
      expect(loadedMessages[2].content, 'Third');
    });

    test('should handle multiple conversations separately', () async {
      // Arrange
      const conversation1 = 'conv-1';
      const conversation2 = 'conv-2';
      final message1 = Message(
        id: 'msg-14',
        role: 'user',
        content: 'Conv 1 message',
        createdAt: DateTime.now(),
      );
      final message2 = Message(
        id: 'msg-15',
        role: 'user',
        content: 'Conv 2 message',
        createdAt: DateTime.now(),
      );

      // Act
      await service.saveMessage(message1, conversation1);
      await service.saveMessage(message2, conversation2);

      final conv1Messages = await service.loadMessages(conversation1);
      final conv2Messages = await service.loadMessages(conversation2);

      // Assert
      expect(conv1Messages.length, 1);
      expect(conv2Messages.length, 1);
      expect(conv1Messages.first.content, 'Conv 1 message');
      expect(conv2Messages.first.content, 'Conv 2 message');
    });

    test('should replace message on duplicate save', () async {
      // Arrange
      final message = Message(
        id: 'msg-16',
        role: 'user',
        content: 'Original',
        createdAt: DateTime.now(),
      );
      await service.saveMessage(message, testConversationId);

      // Act - Save again with same ID but different content
      final updatedMessage = message.copyWith(content: 'Replaced');
      await service.saveMessage(updatedMessage, testConversationId);

      final loadedMessages = await service.loadMessages(testConversationId);

      // Assert
      expect(loadedMessages.length, 1);
      expect(loadedMessages.first.content, 'Replaced');
    });
  });
}
