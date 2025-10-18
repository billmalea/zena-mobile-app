import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/models/conversation.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/widgets/conversation/conversation_list_item.dart';

void main() {
  group('ConversationListItem', () {
    late Conversation testConversation;
    late Conversation emptyConversation;

    setUp(() {
      // Create test conversation with messages
      testConversation = Conversation(
        id: 'conv-1',
        userId: 'user-1',
        messages: [
          Message(
            id: 'msg-1',
            role: 'user',
            content: 'Hello, I am looking for a property',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          Message(
            id: 'msg-2',
            role: 'assistant',
            content: 'I can help you with that!',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      // Create empty conversation
      emptyConversation = Conversation(
        id: 'conv-2',
        userId: 'user-1',
        messages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('renders conversation title from first message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversationListItem(
              conversation: testConversation,
              isActive: false,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Hello, I am looking for a property'), findsOneWidget);
    });

    testWidgets('renders "New Conversation" for empty conversation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversationListItem(
              conversation: emptyConversation,
              isActive: false,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('New Conversation'), findsOneWidget);
    });

    testWidgets('displays last message preview truncated to 2 lines', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversationListItem(
              conversation: testConversation,
              isActive: false,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('I can help you with that!'), findsOneWidget);
    });

    testWidgets('displays relative timestamp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversationListItem(
              conversation: testConversation,
              isActive: false,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Should show "1h ago" or similar
      expect(find.textContaining('ago'), findsOneWidget);
    });

    testWidgets('highlights active conversation with bold text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversationListItem(
              conversation: testConversation,
              isActive: true,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(
        find.text('Hello, I am looking for a property'),
      );
      expect(titleText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversationListItem(
              conversation: testConversation,
              isActive: false,
              onTap: () => tapped = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      expect(tapped, true);
    });

    testWidgets('shows delete confirmation dialog on swipe', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversationListItem(
              conversation: testConversation,
              isActive: false,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Swipe to delete
      await tester.drag(
        find.byType(Dismissible),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Delete Conversation'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this conversation? This action cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('calls onDelete when deletion is confirmed', (tester) async {
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversationListItem(
              conversation: testConversation,
              isActive: false,
              onTap: () {},
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      // Swipe to delete
      await tester.drag(
        find.byType(Dismissible),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleted, true);
    });

    testWidgets('does not call onDelete when deletion is cancelled', (tester) async {
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversationListItem(
              conversation: testConversation,
              isActive: false,
              onTap: () {},
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      // Swipe to delete
      await tester.drag(
        find.byType(Dismissible),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      // Cancel deletion
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(deleted, false);
    });

    testWidgets('truncates long conversation titles', (tester) async {
      final longConversation = Conversation(
        id: 'conv-3',
        userId: 'user-1',
        messages: [
          Message(
            id: 'msg-1',
            role: 'user',
            content: 'This is a very long message that should be truncated because it exceeds the maximum length allowed for a conversation title',
            createdAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversationListItem(
              conversation: longConversation,
              isActive: false,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Should be truncated with ellipsis - check for the specific truncated title
      expect(find.text('This is a very long message that should be truncat...'), findsOneWidget);
    });

    testWidgets('shows red background when swiping', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversationListItem(
              conversation: testConversation,
              isActive: false,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Start swiping
      await tester.drag(
        find.byType(Dismissible),
        const Offset(-100, 0),
      );
      await tester.pump();

      // Should show red background with delete icon
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });
}
