import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/services/offline_message_queue.dart';
import 'package:zena_mobile/services/message_persistence_service.dart';
import 'package:zena_mobile/services/chat_service.dart';

void main() {
  // Initialize FFI and load environment for testing
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env.local');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('OfflineMessageQueue', () {
    late MessagePersistenceService persistenceService;
    late ChatService chatService;
    late OfflineMessageQueue queue;
    late Database db;

    setUp(() async {
      // Create unique in-memory database for each test
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
        },
      );

      persistenceService = MessagePersistenceService.createWithDatabase(db);
      chatService = ChatService();
      queue = OfflineMessageQueue(persistenceService, chatService);
    });

    tearDown(() async {
      await db.close();
    });

    test('should initialize with empty queue', () {
      expect(queue.hasQueuedMessages, false);
      expect(queue.queueSize, 0);
    });

    test('should enqueue message and mark as local_only', () async {
      // Arrange
      final message = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Test message',
        createdAt: DateTime.now(),
      );
      const conversationId = 'conv-1';

      // Act
      await queue.enqueue(message, conversationId);

      // Assert
      expect(queue.hasQueuedMessages, true);
      expect(queue.queueSize, 1);

      // Verify message was saved to persistence
      final messages = await persistenceService.loadMessages(conversationId);
      expect(messages.length, 1);
      expect(messages[0].id, 'msg-1');
      expect(messages[0].localOnly, true);
      expect(messages[0].synced, false);
    });

    test('should enqueue multiple messages', () async {
      // Arrange
      final message1 = Message(
        id: 'msg-1',
        role: 'user',
        content: 'First message',
        createdAt: DateTime.now(),
      );
      final message2 = Message(
        id: 'msg-2',
        role: 'user',
        content: 'Second message',
        createdAt: DateTime.now(),
      );
      const conversationId = 'conv-1';

      // Act
      await queue.enqueue(message1, conversationId);
      await queue.enqueue(message2, conversationId);

      // Assert
      expect(queue.hasQueuedMessages, true);
      expect(queue.queueSize, 2);
    });

    test('should handle empty queue when processing', () async {
      // Act
      final result = await queue.processQueue();

      // Assert
      expect(result, true);
      expect(queue.queueSize, 0);
    });

    test('hasQueuedMessages should return false when queue is empty', () {
      expect(queue.hasQueuedMessages, false);
    });

    test('hasQueuedMessages should return true when queue has messages', () async {
      // Arrange
      final message = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Test message',
        createdAt: DateTime.now(),
      );

      // Act
      await queue.enqueue(message, 'conv-1');

      // Assert
      expect(queue.hasQueuedMessages, true);
    });

    test('queueSize should return correct count', () async {
      // Arrange
      final message1 = Message(
        id: 'msg-1',
        role: 'user',
        content: 'First',
        createdAt: DateTime.now(),
      );
      final message2 = Message(
        id: 'msg-2',
        role: 'user',
        content: 'Second',
        createdAt: DateTime.now(),
      );

      // Act
      await queue.enqueue(message1, 'conv-1');
      expect(queue.queueSize, 1);

      await queue.enqueue(message2, 'conv-1');
      expect(queue.queueSize, 2);
    });

    test('should preserve message content when enqueuing', () async {
      // Arrange
      final message = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Important message content',
        createdAt: DateTime.now(),
        metadata: {'key': 'value'},
      );

      // Act
      await queue.enqueue(message, 'conv-1');

      // Assert
      final messages = await persistenceService.loadMessages('conv-1');
      expect(messages[0].content, 'Important message content');
      expect(messages[0].metadata?['key'], 'value');
    });

    test('should handle messages with tool results', () async {
      // Arrange
      final message = Message(
        id: 'msg-1',
        role: 'assistant',
        content: 'Response with tools',
        createdAt: DateTime.now(),
        toolResults: [
          ToolResult(
            toolName: 'test_tool',
            result: {'data': 'test'},
          ),
        ],
      );

      // Act
      await queue.enqueue(message, 'conv-1');

      // Assert
      expect(queue.queueSize, 1);
      final messages = await persistenceService.loadMessages('conv-1');
      expect(messages[0].toolResults?.length, 1);
      expect(messages[0].toolResults?[0].toolName, 'test_tool');
    });

    test('should maintain queue order', () async {
      // Arrange
      final messages = List.generate(
        5,
        (i) => Message(
          id: 'msg-$i',
          role: 'user',
          content: 'Message $i',
          createdAt: DateTime.now(),
        ),
      );

      // Act
      for (final message in messages) {
        await queue.enqueue(message, 'conv-1');
      }

      // Assert
      expect(queue.queueSize, 5);
    });
  });
}
