import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zena_mobile/models/conversation.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/providers/conversation_provider.dart';
import 'package:zena_mobile/services/chat_service.dart';
import 'package:zena_mobile/widgets/conversation/conversation_drawer.dart';

// Mock ChatService that doesn't require DotEnv initialization
class MockChatService implements ChatService {
  List<Conversation> mockConversations = [];
  bool shouldThrowError = false;
  int getConversationsCallCount = 0;

  @override
  Future<List<Conversation>> getConversations() async {
    getConversationsCallCount++;
    if (shouldThrowError) {
      throw Exception('Network error');
    }
    return mockConversations;
  }

  @override
  String? getUserId() => 'test-user-id';

  @override
  Stream<ChatEvent> sendMessage({
    required String message,
    String? conversationId,
  }) async* {
    yield ChatEvent(type: 'text', content: 'Mock response');
  }

  @override
  Future<Conversation> getConversation(String? conversationId) async {
    return mockConversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => throw Exception('Conversation not found'),
    );
  }

  @override
  Future<Conversation> createConversation() async {
    final newConv = Conversation(
      id: 'new-conv-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'test-user-id',
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    mockConversations.add(newConv);
    return newConv;
  }

  void reset() {
    getConversationsCallCount = 0;
    shouldThrowError = false;
  }
}

void main() {
  late MockChatService mockChatService;
  late ConversationProvider conversationProvider;

  setUp(() async {
    // Initialize SharedPreferences with mock values
    SharedPreferences.setMockInitialValues({});
    
    mockChatService = MockChatService();
    conversationProvider = ConversationProvider(mockChatService);
    
    // Wait for initialization to complete
    await Future.delayed(const Duration(milliseconds: 100));
  });

  Widget createTestWidget({
    String? activeConversationId,
    Function(String)? onConversationSelected,
    VoidCallback? onNewConversation,
  }) {
    return MaterialApp(
      home: ChangeNotifierProvider<ConversationProvider>.value(
        value: conversationProvider,
        child: Scaffold(
          drawer: ConversationDrawer(
            activeConversationId: activeConversationId,
            onConversationSelected: onConversationSelected ?? (_) {},
            onNewConversation: onNewConversation ?? () {},
          ),
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Text('Open Drawer'),
            ),
          ),
        ),
      ),
    );
  }

  List<Conversation> createMockConversations() {
    return [
      Conversation(
        id: '1',
        userId: 'user1',
        messages: [
          Message(
            id: 'msg1',
            role: 'user',
            content: 'Hello',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Conversation(
        id: '2',
        userId: 'user1',
        messages: [
          Message(
            id: 'msg2',
            role: 'user',
            content: 'Test message',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  group('ConversationDrawer Pull-to-Refresh Tests', () {
    testWidgets('RefreshIndicator is present in conversation list',
        (WidgetTester tester) async {
      // Arrange
      final mockConversations = createMockConversations();
      mockChatService.mockConversations = mockConversations;

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Load conversations
      await conversationProvider.loadConversations(refresh: true);
      await tester.pumpAndSettle();

      // Assert - RefreshIndicator should be present
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('Pull-to-refresh reloads conversations',
        (WidgetTester tester) async {
      // Arrange
      final mockConversations = createMockConversations();
      mockChatService.mockConversations = mockConversations;

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Load initial conversations
      await conversationProvider.loadConversations(refresh: true);
      await tester.pumpAndSettle();

      final initialCallCount = mockChatService.getConversationsCallCount;

      // Act - Perform pull-to-refresh gesture
      await tester.drag(
        find.byType(ListView),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      // Assert - getConversations should be called again
      expect(mockChatService.getConversationsCallCount, greaterThan(initialCallCount));
    });

    testWidgets('Pull-to-refresh shows loading indicator',
        (WidgetTester tester) async {
      // Arrange
      final mockConversations = createMockConversations();
      mockChatService.mockConversations = mockConversations;

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Load initial conversations
      await conversationProvider.loadConversations(refresh: true);
      await tester.pumpAndSettle();

      // Act - Start pull-to-refresh gesture
      await tester.drag(
        find.byType(ListView),
        const Offset(0, 300),
      );
      await tester.pump(); // Don't settle yet to see loading state

      // Assert - RefreshProgressIndicator should be visible during refresh
      expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    });

    testWidgets('Pull-to-refresh works on empty state',
        (WidgetTester tester) async {
      // Arrange
      mockChatService.mockConversations = [];

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Load conversations (empty)
      await conversationProvider.loadConversations(refresh: true);
      await tester.pumpAndSettle();

      // Assert - Empty state should be shown
      expect(find.text('No conversations yet'), findsOneWidget);

      final initialCallCount = mockChatService.getConversationsCallCount;

      // Act - Perform pull-to-refresh on empty state
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      // Assert - getConversations should be called again
      expect(mockChatService.getConversationsCallCount, greaterThan(initialCallCount));
    });

    testWidgets('Pull-to-refresh works on error state',
        (WidgetTester tester) async {
      // Arrange
      mockChatService.shouldThrowError = true;

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Load conversations (will fail)
      await conversationProvider.loadConversations(refresh: true);
      await tester.pumpAndSettle();

      // Assert - Error state should be shown
      expect(find.text('Failed to load conversations: Exception: Network error'),
          findsOneWidget);

      final initialCallCount = mockChatService.getConversationsCallCount;

      // Act - Perform pull-to-refresh on error state
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      // Assert - getConversations should be called again
      expect(mockChatService.getConversationsCallCount, greaterThan(initialCallCount));
    });

    testWidgets('Pull-to-refresh updates conversation list with new data',
        (WidgetTester tester) async {
      // Arrange
      final initialConversations = createMockConversations();
      mockChatService.mockConversations = initialConversations;

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Load initial conversations
      await conversationProvider.loadConversations(refresh: true);
      await tester.pumpAndSettle();

      // Assert - Initial count
      expect(conversationProvider.conversations.length, 2);

      // Update mock to return new data
      final updatedConversations = [
        ...initialConversations,
        Conversation(
          id: '3',
          userId: 'user1',
          messages: [
            Message(
              id: 'msg3',
              role: 'user',
              content: 'New conversation',
              createdAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      mockChatService.mockConversations = updatedConversations;

      // Act - Perform pull-to-refresh
      await tester.drag(
        find.byType(ListView),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      // Assert - Updated count
      expect(conversationProvider.conversations.length, 3);
      expect(find.text('New conversation'), findsWidgets);
    });

    testWidgets('Pull-to-refresh clears previous errors',
        (WidgetTester tester) async {
      // Arrange
      mockChatService.shouldThrowError = true;

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Load conversations (will fail)
      await conversationProvider.loadConversations(refresh: true);
      await tester.pumpAndSettle();

      // Assert - Error should be present
      expect(conversationProvider.error, isNotNull);

      // Update mock to succeed
      final mockConversations = createMockConversations();
      mockChatService.shouldThrowError = false;
      mockChatService.mockConversations = mockConversations;

      // Act - Perform pull-to-refresh
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      // Assert - Error should be cleared and conversations loaded
      expect(conversationProvider.error, isNull);
      expect(conversationProvider.conversations.length, 2);
    });

    testWidgets('AlwaysScrollableScrollPhysics is applied to ListView',
        (WidgetTester tester) async {
      // Arrange
      final mockConversations = createMockConversations();
      mockChatService.mockConversations = mockConversations;

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Load conversations
      await conversationProvider.loadConversations(refresh: true);
      await tester.pumpAndSettle();

      // Assert - ListView should have AlwaysScrollableScrollPhysics
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.physics, isA<AlwaysScrollableScrollPhysics>());
    });
  });
}
