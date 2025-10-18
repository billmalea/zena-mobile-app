import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zena_mobile/models/conversation.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/providers/conversation_provider.dart';
import 'package:zena_mobile/services/chat_service.dart';

/// Mock ChatService for testing
class MockChatService implements ChatService {
  List<Conversation> mockConversations = [];
  bool shouldThrowError = false;
  String? deletedConversationId;

  @override
  Future<List<Conversation>> getConversations() async {
    if (shouldThrowError) {
      throw Exception('Failed to fetch conversations');
    }
    return mockConversations;
  }

  @override
  String? getUserId() => 'test-user-id';

  @override
  Future<Conversation> getConversation(String? conversationId) async {
    throw UnimplementedError();
  }

  @override
  Future<Conversation> createConversation() async {
    throw UnimplementedError();
  }

  @override
  Stream<ChatEvent> sendMessage({
    required String message,
    String? conversationId,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  // Load environment variables before running tests
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env.local');
  });

  group('ConversationProvider', () {
    late MockChatService mockChatService;
    late ConversationProvider provider;

    setUp(() {
      mockChatService = MockChatService();
      provider = ConversationProvider(mockChatService);
    });

    test('initial state is correct', () {
      expect(provider.conversations, isEmpty);
      expect(provider.activeConversationId, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.hasMore, isTrue);
      expect(provider.error, isNull);
      expect(provider.searchQuery, isEmpty);
    });

    group('loadConversations', () {
      test('loads conversations successfully', () async {
        // Arrange
        final mockConvs = [
          Conversation(
            id: '1',
            userId: 'user1',
            messages: [
              Message(
                id: 'm1',
                role: 'user',
                content: 'Hello',
                createdAt: DateTime.now(),
              ),
            ],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Conversation(
            id: '2',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        mockChatService.mockConversations = mockConvs;

        // Act
        await provider.loadConversations();

        // Assert
        expect(provider.conversations.length, 2);
        expect(provider.conversations[0].id, '1');
        expect(provider.conversations[1].id, '2');
        expect(provider.isLoading, isFalse);
        expect(provider.error, isNull);
      });

      test('sets loading state during load', () async {
        // Arrange
        mockChatService.mockConversations = [];
        bool wasLoading = false;

        provider.addListener(() {
          if (provider.isLoading) {
            wasLoading = true;
          }
        });

        // Act
        await provider.loadConversations();

        // Assert
        expect(wasLoading, isTrue);
        expect(provider.isLoading, isFalse);
      });

      test('handles error during load', () async {
        // Arrange
        mockChatService.shouldThrowError = true;

        // Act
        await provider.loadConversations();

        // Assert
        expect(provider.error, isNotNull);
        expect(provider.error, contains('Failed to load conversations'));
        expect(provider.isLoading, isFalse);
      });

      test('refresh clears existing conversations', () async {
        // Arrange
        mockChatService.mockConversations = [
          Conversation(
            id: '1',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        await provider.loadConversations();

        mockChatService.mockConversations = [
          Conversation(
            id: '2',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        await provider.loadConversations(refresh: true);

        // Assert
        expect(provider.conversations.length, 1);
        expect(provider.conversations[0].id, '2');
      });

      test('sets hasMore to false when less than 20 conversations', () async {
        // Arrange
        mockChatService.mockConversations = List.generate(
          10,
          (i) => Conversation(
            id: '$i',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Act
        await provider.loadConversations();

        // Assert
        expect(provider.hasMore, isFalse);
      });

      test('sets hasMore to true when 20 or more conversations', () async {
        // Arrange
        mockChatService.mockConversations = List.generate(
          20,
          (i) => Conversation(
            id: '$i',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Act
        await provider.loadConversations();

        // Assert
        expect(provider.hasMore, isTrue);
      });
    });

    group('loadMore', () {
      test('does not load when hasMore is false', () async {
        // Arrange
        mockChatService.mockConversations = [];
        await provider.loadConversations();
        expect(provider.hasMore, isFalse);

        int listenerCallCount = 0;
        provider.addListener(() {
          listenerCallCount++;
        });

        // Act
        await provider.loadMore();

        // Assert
        expect(listenerCallCount, 0);
      });

      test('does not load when already loading', () async {
        // Arrange
        mockChatService.mockConversations = List.generate(
          20,
          (i) => Conversation(
            id: '$i',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Act - start loading but don't await
        final future1 = provider.loadConversations();
        final future2 = provider.loadMore();

        await future1;
        await future2;

        // Assert - should only have loaded once
        expect(provider.conversations.length, 20);
      });

      test('loads more conversations when hasMore is true', () async {
        // Arrange
        mockChatService.mockConversations = List.generate(
          20,
          (i) => Conversation(
            id: '$i',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        await provider.loadConversations();

        mockChatService.mockConversations = List.generate(
          10,
          (i) => Conversation(
            id: '${i + 20}',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Act
        await provider.loadMore();

        // Assert
        expect(provider.conversations.length, 30);
      });
    });

    group('switchConversation', () {
      test('updates active conversation ID', () async {
        // Act
        await provider.switchConversation('conv123');

        // Assert
        expect(provider.activeConversationId, 'conv123');
      });

      test('notifies listeners', () async {
        // Arrange
        int listenerCallCount = 0;
        provider.addListener(() {
          listenerCallCount++;
        });

        // Act
        await provider.switchConversation('conv123');

        // Assert
        expect(listenerCallCount, 1);
      });
    });

    group('deleteConversation', () {
      test('removes conversation from list', () async {
        // Arrange
        mockChatService.mockConversations = [
          Conversation(
            id: '1',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Conversation(
            id: '2',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        await provider.loadConversations();

        // Act
        await provider.deleteConversation('1');

        // Assert
        expect(provider.conversations.length, 1);
        expect(provider.conversations[0].id, '2');
      });

      test('clears active conversation if deleted', () async {
        // Arrange
        mockChatService.mockConversations = [
          Conversation(
            id: '1',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        await provider.loadConversations();
        await provider.switchConversation('1');

        // Act
        await provider.deleteConversation('1');

        // Assert
        expect(provider.activeConversationId, isNull);
      });

      test('does not clear active conversation if different one deleted', () async {
        // Arrange
        mockChatService.mockConversations = [
          Conversation(
            id: '1',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Conversation(
            id: '2',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        await provider.loadConversations();
        await provider.switchConversation('1');

        // Act
        await provider.deleteConversation('2');

        // Assert
        expect(provider.activeConversationId, '1');
      });
    });

    group('searchConversations', () {
      test('filters conversations by message content', () async {
        // Arrange
        mockChatService.mockConversations = [
          Conversation(
            id: '1',
            userId: 'user1',
            messages: [
              Message(
                id: 'm1',
                role: 'user',
                content: 'Looking for property in downtown',
                createdAt: DateTime.now(),
              ),
            ],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Conversation(
            id: '2',
            userId: 'user1',
            messages: [
              Message(
                id: 'm2',
                role: 'user',
                content: 'Need help with submission',
                createdAt: DateTime.now(),
              ),
            ],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        await provider.searchConversations('property');

        // Assert
        expect(provider.conversations.length, 1);
        expect(provider.conversations[0].id, '1');
        expect(provider.searchQuery, 'property');
      });

      test('search is case insensitive', () async {
        // Arrange
        mockChatService.mockConversations = [
          Conversation(
            id: '1',
            userId: 'user1',
            messages: [
              Message(
                id: 'm1',
                role: 'user',
                content: 'PROPERTY search',
                createdAt: DateTime.now(),
              ),
            ],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        await provider.searchConversations('property');

        // Assert
        expect(provider.conversations.length, 1);
      });

      test('empty query restores full list', () async {
        // Arrange
        mockChatService.mockConversations = [
          Conversation(
            id: '1',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Conversation(
            id: '2',
            userId: 'user1',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        await provider.searchConversations('test');
        expect(provider.conversations.length, 0);

        // Act
        await provider.searchConversations('');

        // Assert
        expect(provider.conversations.length, 2);
        expect(provider.searchQuery, isEmpty);
      });

      test('handles error during search', () async {
        // Arrange
        mockChatService.shouldThrowError = true;

        // Act
        await provider.searchConversations('test');

        // Assert
        expect(provider.error, isNotNull);
        expect(provider.error, contains('Search failed'));
      });
    });

    group('setActiveConversation', () {
      test('sets active conversation without loading', () {
        // Act
        provider.setActiveConversation('conv456');

        // Assert
        expect(provider.activeConversationId, 'conv456');
      });

      test('notifies listeners', () {
        // Arrange
        int listenerCallCount = 0;
        provider.addListener(() {
          listenerCallCount++;
        });

        // Act
        provider.setActiveConversation('conv456');

        // Assert
        expect(listenerCallCount, 1);
      });
    });

    group('clearError', () {
      test('clears error message', () async {
        // Arrange
        mockChatService.shouldThrowError = true;
        await provider.loadConversations();
        expect(provider.error, isNotNull);

        // Act
        provider.clearError();

        // Assert
        expect(provider.error, isNull);
      });

      test('notifies listeners', () async {
        // Arrange
        mockChatService.shouldThrowError = true;
        await provider.loadConversations();

        int listenerCallCount = 0;
        provider.addListener(() {
          listenerCallCount++;
        });

        // Act
        provider.clearError();

        // Assert
        expect(listenerCallCount, 1);
      });
    });
  });
}
