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

  group('ConversationDrawer Widget Tests', () {
    testWidgets('should display header with title and new conversation button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Verify header elements
      expect(find.text('Conversations'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byTooltip('New Conversation'), findsOneWidget);
    });

    testWidgets('should display search widget', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Verify search field is present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search conversations...'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading',
        (WidgetTester tester) async {
      conversationProvider.loadConversations(refresh: true);

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pump();

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when error occurs',
        (WidgetTester tester) async {
      mockChatService.shouldThrowError = true;

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Wait for error to appear
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(
          find.textContaining('Failed to load conversations'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should show empty state when no conversations',
        (WidgetTester tester) async {
      mockChatService.mockConversations = [];

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Verify empty state is shown
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.text('No conversations yet'), findsOneWidget);
      expect(
          find.text('Start a new conversation to get started'), findsOneWidget);
    });

    testWidgets('should display conversation list when conversations exist',
        (WidgetTester tester) async {
      mockChatService.mockConversations = [
        createMockConversation('conv-1', 'First conversation'),
        createMockConversation('conv-2', 'Second conversation'),
        createMockConversation('conv-3', 'Third conversation'),
      ];

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Verify conversations are displayed
      expect(find.text('First conversation'), findsOneWidget);
      expect(find.text('Second conversation'), findsOneWidget);
      expect(find.text('Third conversation'), findsOneWidget);
    });

    testWidgets('should handle conversation selection callback',
        (WidgetTester tester) async {
      String? selectedConversationId;

      mockChatService.mockConversations = [
        createMockConversation('conv-1', 'First conversation'),
        createMockConversation('conv-2', 'Second conversation'),
      ];

      await tester.pumpWidget(
        createTestWidget(
          onConversationSelected: (id) {
            selectedConversationId = id;
          },
        ),
      );
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Tap on first conversation
      await tester.tap(find.text('First conversation'));
      await tester.pumpAndSettle();

      // Verify callback was called with correct ID
      expect(selectedConversationId, equals('conv-1'));
    });

    testWidgets('should handle new conversation callback',
        (WidgetTester tester) async {
      bool newConversationCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          onNewConversation: () {
            newConversationCalled = true;
          },
        ),
      );
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Tap on new conversation button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(newConversationCalled, isTrue);
    });

    testWidgets('should highlight active conversation',
        (WidgetTester tester) async {
      mockChatService.mockConversations = [
        createMockConversation('conv-1', 'First conversation'),
        createMockConversation('conv-2', 'Second conversation'),
      ];

      await tester.pumpWidget(
        createTestWidget(activeConversationId: 'conv-1'),
      );
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Find the ListTile for the active conversation
      final listTile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('First conversation'),
          matching: find.byType(ListTile),
        ),
      );

      // Verify it's marked as selected
      expect(listTile.selected, isTrue);
    });

    testWidgets('should retry loading on error retry button tap',
        (WidgetTester tester) async {
      mockChatService.shouldThrowError = true;

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Wait for error to appear
      await tester.pump();
      await tester.pumpAndSettle();

      // Now allow success
      mockChatService.shouldThrowError = false;
      mockChatService.mockConversations = [
        createMockConversation('conv-1', 'First conversation'),
      ];

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Verify conversations are now displayed
      expect(find.text('First conversation'), findsOneWidget);
    });

    testWidgets('should load conversations on drawer open',
        (WidgetTester tester) async {
      mockChatService.mockConversations = [
        createMockConversation('conv-1', 'First conversation'),
      ];

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Verify conversations were loaded
      expect(conversationProvider.conversations.length, equals(1));
      expect(find.text('First conversation'), findsOneWidget);
    });
  });
}
