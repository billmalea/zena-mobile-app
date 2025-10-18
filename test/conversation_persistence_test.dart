import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zena_mobile/models/conversation.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/providers/conversation_provider.dart';
import 'package:zena_mobile/services/chat_service.dart';

// Mock ChatService
class MockChatService extends ChatService {
  List<Conversation> mockConversations = [];
  bool shouldThrowError = false;

  MockChatService();

  @override
  Future<List<Conversation>> getConversations() async {
    if (shouldThrowError) {
      throw Exception('Network error');
    }
    return mockConversations;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Load environment variables before all tests
    await dotenv.load(fileName: '.env.local');
  });

  group('ConversationProvider Persistence Tests', () {
    late MockChatService mockChatService;
    late ConversationProvider provider;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      mockChatService = MockChatService();
    });

    tearDown(() async {
      // Clean up after each test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('should load conversations from cache on initialization', () async {
      // Arrange: Set up cached data and backend data
      final cachedConversations = [
        Conversation(
          id: 'conv1',
          userId: 'user1',
          messages: [
            Message(
              id: 'msg1',
              role: 'user',
              content: 'Hello from cache',
              createdAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          updatedAt: DateTime.now().subtract(Duration(hours: 1)),
        ),
      ];

      final prefs = await SharedPreferences.getInstance();
      final jsonList = cachedConversations.map((c) => c.toJson()).toList();
      // Properly encode as JSON string
      final jsonString = '[${jsonList.map((j) => '{"id":"${j['id']}","userId":"${j['userId']}","messages":[{"id":"msg1","role":"user","content":"Hello from cache","createdAt":"${DateTime.now().toIso8601String()}"}],"createdAt":"${j['createdAt']}","updatedAt":"${j['updatedAt']}"}').join(',')}]';
      await prefs.setString('cached_conversations', jsonString);

      // Set backend to return same data so it doesn't get cleared
      mockChatService.mockConversations = cachedConversations;

      // Act: Create provider (should load from cache)
      provider = ConversationProvider(mockChatService);
      
      // Wait for initialization (cache loads immediately)
      await Future.delayed(Duration(milliseconds: 50));

      // Assert: Should have loaded from cache
      expect(provider.conversations.length, greaterThan(0));
      expect(provider.conversations.first.id, equals('conv1'));
    });

    test('should save conversations to cache after loading', () async {
      // Arrange
      final testConversations = [
        Conversation(
          id: 'conv1',
          userId: 'user1',
          messages: [
            Message(
              id: 'msg1',
              role: 'user',
              content: 'Test message',
              createdAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      mockChatService.mockConversations = testConversations;
      provider = ConversationProvider(mockChatService);

      // Act: Load conversations
      await provider.loadConversations(refresh: true);

      // Assert: Check cache was updated
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_conversations');
      expect(cachedData, isNotNull);
      expect(cachedData, contains('conv1'));
      expect(cachedData, contains('Test message'));
    });

    test('should sync with backend after loading from cache', () async {
      // Arrange: Set up cached data
      final cachedConversations = [
        Conversation(
          id: 'conv1',
          userId: 'user1',
          messages: [],
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(Duration(hours: 2)),
        ),
      ];

      final prefs = await SharedPreferences.getInstance();
      final jsonList = cachedConversations.map((c) => c.toJson()).toList();
      await prefs.setString('cached_conversations',
          '[${jsonList.map((j) => '{"id":"${j['id']}","userId":"${j['userId']}","messages":[],"createdAt":"${j['createdAt']}","updatedAt":"${j['updatedAt']}"}').join(',')}]');

      // Set up backend data (different from cache)
      final backendConversations = [
        Conversation(
          id: 'conv2',
          userId: 'user1',
          messages: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      mockChatService.mockConversations = backendConversations;

      // Act: Create provider
      provider = ConversationProvider(mockChatService);

      // Wait for background sync
      await Future.delayed(Duration(milliseconds: 200));

      // Assert: Should have synced with backend
      expect(provider.conversations.any((c) => c.id == 'conv2'), isTrue);
    });

    test('should display cached conversations when offline', () async {
      // Arrange: Set up cached data
      final cachedConversations = [
        Conversation(
          id: 'conv1',
          userId: 'user1',
          messages: [
            Message(
              id: 'msg1',
              role: 'user',
              content: 'Cached message',
              createdAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final prefs = await SharedPreferences.getInstance();
      final jsonList = cachedConversations.map((c) => c.toJson()).toList();
      await prefs.setString('cached_conversations',
          '[${jsonList.map((j) => '{"id":"${j['id']}","userId":"${j['userId']}","messages":[{"id":"msg1","role":"user","content":"Cached message","createdAt":"${DateTime.now().toIso8601String()}"}],"createdAt":"${j['createdAt']}","updatedAt":"${j['updatedAt']}"}').join(',')}]');

      // Simulate offline (network error)
      mockChatService.shouldThrowError = true;
      provider = ConversationProvider(mockChatService);

      // Wait for initialization to load from cache
      await Future.delayed(Duration(milliseconds: 200));

      // Assert: Should have loaded cached conversations even though backend sync failed
      expect(provider.conversations.length, greaterThan(0));
      expect(provider.conversations.first.id, equals('conv1'));
    });

    test('should update cache when conversation is deleted', () async {
      // Arrange
      final testConversations = [
        Conversation(
          id: 'conv1',
          userId: 'user1',
          messages: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Conversation(
          id: 'conv2',
          userId: 'user1',
          messages: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      mockChatService.mockConversations = testConversations;
      provider = ConversationProvider(mockChatService);
      await provider.loadConversations(refresh: true);

      // Act: Delete a conversation
      await provider.deleteConversation('conv1');

      // Assert: Cache should be updated
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_conversations');
      expect(cachedData, isNotNull);
      expect(cachedData, isNot(contains('conv1')));
      expect(cachedData, contains('conv2'));
    });

    test('should persist cache across app restarts', () async {
      // Arrange: First session - load and cache conversations
      final testConversations = [
        Conversation(
          id: 'conv1',
          userId: 'user1',
          messages: [
            Message(
              id: 'msg1',
              role: 'user',
              content: 'Persistent message',
              createdAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      mockChatService.mockConversations = testConversations;
      provider = ConversationProvider(mockChatService);
      await provider.loadConversations(refresh: true);

      // Simulate app restart by creating new provider instance
      final newMockService = MockChatService();
      newMockService.shouldThrowError = true; // Simulate offline
      final newProvider = ConversationProvider(newMockService);

      // Wait for initialization from cache
      await Future.delayed(Duration(milliseconds: 100));

      // Assert: Should have loaded from cache
      expect(newProvider.conversations.length, greaterThan(0));
      expect(newProvider.conversations.first.id, equals('conv1'));
    });

    test('should handle cache expiry correctly', () async {
      // Arrange: Set up expired cache
      final cachedConversations = [
        Conversation(
          id: 'conv1',
          userId: 'user1',
          messages: [],
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          updatedAt: DateTime.now().subtract(Duration(days: 2)),
        ),
      ];

      final prefs = await SharedPreferences.getInstance();
      final jsonList = cachedConversations.map((c) => c.toJson()).toList();
      await prefs.setString('cached_conversations',
          '[${jsonList.map((j) => '{"id":"${j['id']}","userId":"${j['userId']}","messages":[],"createdAt":"${j['createdAt']}","updatedAt":"${j['updatedAt']}"}').join(',')}]');
      
      // Set cache timestamp to 25 hours ago (expired)
      final expiredTimestamp = DateTime.now()
          .subtract(Duration(hours: 25))
          .millisecondsSinceEpoch;
      await prefs.setInt('conversations_cache_timestamp', expiredTimestamp);

      // Set up fresh backend data
      final backendConversations = [
        Conversation(
          id: 'conv2',
          userId: 'user1',
          messages: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      mockChatService.mockConversations = backendConversations;

      // Act: Create provider
      provider = ConversationProvider(mockChatService);

      // Wait for sync
      await Future.delayed(Duration(milliseconds: 200));

      // Assert: Should have synced with backend due to expired cache
      expect(provider.conversations.any((c) => c.id == 'conv2'), isTrue);
    });

    test('should handle empty cache gracefully', () async {
      // Arrange: No cached data
      mockChatService.mockConversations = [];
      
      // Act: Create provider
      provider = ConversationProvider(mockChatService);
      
      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 100));

      // Assert: Should handle empty cache without errors
      expect(provider.conversations, isEmpty);
      expect(provider.error, isNull);
    });

    test('should handle corrupted cache data gracefully', () async {
      // Arrange: Set corrupted cache data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_conversations', 'invalid json data');

      mockChatService.mockConversations = [];

      // Act: Create provider
      provider = ConversationProvider(mockChatService);

      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 100));

      // Assert: Should handle corrupted cache without crashing
      expect(provider.conversations, isEmpty);
      // Should not throw error, just continue without cache
    });
  });
}
