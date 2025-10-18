import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zena_mobile/services/message_persistence_service.dart';
import 'package:zena_mobile/models/message.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Message Persistence Integration with ChatProvider', () {
    late MessagePersistenceService persistenceService;

    setUp(() async {
      // Create persistence service
      persistenceService = await MessagePersistenceService.create();
    });

    tearDown(() async {
      await persistenceService.close();
    });

    test('should save and load messages for a conversation', () async {
      const conversationId = 'test-conversation-1';
      
      // Create test messages
      final userMessage = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Hello, I want to submit a property',
        createdAt: DateTime.now(),
      );
      
      final assistantMessage = Message(
        id: 'msg-2',
        role: 'assistant',
        content: 'I can help you with that!',
        createdAt: DateTime.now(),
        toolResults: [
          ToolResult(
            toolName: 'submitProperty',
            result: {'stage': 'start', 'submissionId': 'sub-123'},
          ),
        ],
      );
      
      // Save messages
      await persistenceService.saveMessage(userMessage, conversationId);
      await persistenceService.saveMessage(assistantMessage, conversationId);
      
      // Load messages
      final loadedMessages = await persistenceService.loadMessages(conversationId);
      
      // Verify
      expect(loadedMessages.length, 2);
      expect(loadedMessages[0].id, 'msg-1');
      expect(loadedMessages[0].role, 'user');
      expect(loadedMessages[0].content, 'Hello, I want to submit a property');
      expect(loadedMessages[1].id, 'msg-2');
      expect(loadedMessages[1].role, 'assistant');
      expect(loadedMessages[1].toolResults?.length, 1);
      expect(loadedMessages[1].toolResults?[0].toolName, 'submitProperty');
    });

    test('should update message content after streaming', () async {
      const conversationId = 'test-conversation-2';
      
      // Create initial message with empty content
      final message = Message(
        id: 'msg-1',
        role: 'assistant',
        content: '',
        createdAt: DateTime.now(),
      );
      
      await persistenceService.saveMessage(message, conversationId);
      
      // Update message with streamed content
      final updatedMessage = message.copyWith(
        content: 'This is the complete streamed response',
      );
      
      await persistenceService.updateMessage(message.id, updatedMessage);
      
      // Load and verify
      final loadedMessages = await persistenceService.loadMessages(conversationId);
      expect(loadedMessages.length, 1);
      expect(loadedMessages[0].content, 'This is the complete streamed response');
    });

    test('should persist messages across service restarts', () async {
      const conversationId = 'test-conversation-3';
      
      // Save message
      final message = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Test persistence',
        createdAt: DateTime.now(),
      );
      
      await persistenceService.saveMessage(message, conversationId);
      await persistenceService.close();
      
      // Create new service instance (simulating app restart)
      final newService = await MessagePersistenceService.create();
      
      // Load messages
      final loadedMessages = await newService.loadMessages(conversationId);
      
      // Verify
      expect(loadedMessages.length, 1);
      expect(loadedMessages[0].id, 'msg-1');
      expect(loadedMessages[0].content, 'Test persistence');
      
      await newService.close();
    });

    test('should handle messages with metadata', () async {
      const conversationId = 'test-conversation-4';
      
      // Create message with metadata
      final message = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Message with metadata',
        createdAt: DateTime.now(),
        metadata: {
          'submissionId': 'sub-123',
          'workflowStage': 'start',
        },
      );
      
      await persistenceService.saveMessage(message, conversationId);
      
      // Load and verify
      final loadedMessages = await persistenceService.loadMessages(conversationId);
      expect(loadedMessages.length, 1);
      expect(loadedMessages[0].metadata?['submissionId'], 'sub-123');
      expect(loadedMessages[0].metadata?['workflowStage'], 'start');
    });

    test('should clear conversation messages', () async {
      const conversationId = 'test-conversation-5';
      
      // Save multiple messages
      for (int i = 0; i < 3; i++) {
        final message = Message(
          id: 'msg-$i',
          role: 'user',
          content: 'Message $i',
          createdAt: DateTime.now(),
        );
        await persistenceService.saveMessage(message, conversationId);
      }
      
      // Verify messages exist
      var loadedMessages = await persistenceService.loadMessages(conversationId);
      expect(loadedMessages.length, 3);
      
      // Clear messages
      await persistenceService.clearConversationMessages(conversationId);
      
      // Verify messages are cleared
      loadedMessages = await persistenceService.loadMessages(conversationId);
      expect(loadedMessages.length, 0);
    });
  });
}
