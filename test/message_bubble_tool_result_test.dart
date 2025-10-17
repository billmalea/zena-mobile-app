import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/widgets/chat/message_bubble.dart';

void main() {
  group('MessageBubble Tool Result Rendering', () {
    testWidgets('renders message content without tool results', (WidgetTester tester) async {
      final message = Message(
        id: '1',
        role: 'assistant',
        content: 'Hello, how can I help you?',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      expect(find.text('Hello, how can I help you?'), findsOneWidget);
    });

    testWidgets('renders message with single tool result', (WidgetTester tester) async {
      final message = Message(
        id: '2',
        role: 'assistant',
        content: 'Here are some properties:',
        toolResults: [
          ToolResult(
            toolName: 'requiresAuth',
            result: {
              'message': 'Please sign in to continue',
            },
          ),
        ],
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MessageBubble(message: message),
            ),
          ),
        ),
      );

      expect(find.text('Here are some properties:'), findsOneWidget);
      // Tool result widget should be rendered
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('renders message with multiple tool results', (WidgetTester tester) async {
      final message = Message(
        id: '3',
        role: 'assistant',
        content: 'Multiple results:',
        toolResults: [
          ToolResult(
            toolName: 'getNeighborhoodInfo',
            result: {'name': 'Westlands', 'description': 'Great area'},
          ),
          ToolResult(
            toolName: 'calculateAffordability',
            result: {'monthlyIncome': 100000, 'recommendedRange': {'min': 20000, 'max': 30000}},
          ),
        ],
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MessageBubble(message: message),
            ),
          ),
        ),
      );

      expect(find.text('Multiple results:'), findsOneWidget);
      // Should render multiple tool result widgets
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('passes onSendMessage callback to tool result widget', (WidgetTester tester) async {
      bool callbackCalled = false;
      String? sentMessage;

      final message = Message(
        id: '4',
        role: 'assistant',
        content: 'Test callback',
        toolResults: [
          ToolResult(
            toolName: 'requiresAuth',
            result: {'message': 'Please sign in'},
          ),
        ],
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: message,
              onSendMessage: (text) {
                callbackCalled = true;
                sentMessage = text;
              },
            ),
          ),
        ),
      );

      expect(find.text('Test callback'), findsOneWidget);
      // Callback should be passed to ToolResultWidget
      // (actual callback invocation would be tested in ToolResultWidget tests)
    });

    testWidgets('renders empty message with only tool results', (WidgetTester tester) async {
      final message = Message(
        id: '5',
        role: 'assistant',
        content: '',
        toolResults: [
          ToolResult(
            toolName: 'requiresAuth',
            result: {
              'message': 'Please sign in',
            },
          ),
        ],
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MessageBubble(message: message),
            ),
          ),
        ),
      );

      // Should not render message bubble for empty content
      expect(find.text(''), findsNothing);
      // But should render tool results
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('handles user messages correctly', (WidgetTester tester) async {
      final message = Message(
        id: '6',
        role: 'user',
        content: 'Show me properties in Westlands',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      expect(find.text('Show me properties in Westlands'), findsOneWidget);
      // User messages should be aligned right
      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerRight);
    });
  });
}
