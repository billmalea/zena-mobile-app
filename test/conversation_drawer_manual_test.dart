import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zena_mobile/models/conversation.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/providers/conversation_provider.dart';
import 'package:zena_mobile/services/chat_service.dart';
import 'package:zena_mobile/widgets/conversation/conversation_drawer.dart';

// Mock ChatService that doesn't require DotEnv initialization
class MockChatService implements ChatService {
  List<Conversation> mockConversations = [];
  bool shouldThrowError = false;

  @override
  Future<List<Conversation>> getConversations() async {
    if (shouldThrowError) {
      throw Exception('Failed to load conversations');
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
}

void main() {
  late MockChatService mockChatService;
  late ConversationProvider conversationProvider;

  setUp(() {
    mockChatService = MockChatService();
    conversationProvider = ConversationProvider(mockChatService);
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

  Conversation createMockConversation(String id, String content) {
    return Conversation(
      id: id,
      userId: 'user-1',
      messages: [
        Message(
          id: 'msg-$id',
          role: 'user',
          content: content,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  group('ConversationDrawer Basic Tests', () {
    testWidgets('should display header elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Verify header elements
      expect(find.text('Conversations'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show empty state', (WidgetTester tester) async {
      mockChatService.mockConversations = [];

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Verify empty state
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.text('No conversations yet'), findsOneWidget);
    });

    testWidgets('should display conversations', (WidgetTester tester) async {
      mockChatService.mockConversations = [
        createMockConversation('conv-1', 'Hello, I need help finding a property'),
        createMockConversation('conv-2', 'What is the price range?'),
      ];

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Verify conversations are displayed (check for ListTile widgets)
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('should call onNewConversation callback',
        (WidgetTester tester) async {
      bool called = false;

      await tester.pumpWidget(
        createTestWidget(
          onNewConversation: () {
            called = true;
          },
        ),
      );
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Tap new conversation button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('should show error state', (WidgetTester tester) async {
      mockChatService.shouldThrowError = true;

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Wait for error
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify error state
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
