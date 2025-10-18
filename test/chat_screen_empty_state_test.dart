import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/enhanced_empty_state.dart';
import 'package:zena_mobile/widgets/chat/suggested_queries.dart';

void main() {
  group('ChatScreen Enhanced Empty State Integration', () {
    testWidgets('EnhancedEmptyState displays all required elements',
        (WidgetTester tester) async {
      // Test that the EnhancedEmptyState widget displays correctly
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedEmptyState(
              onQuerySelected: (_) {},
            ),
          ),
        ),
      );

      // Verify all key elements are present
      expect(find.byType(EnhancedEmptyState), findsOneWidget);
      expect(find.byIcon(Icons.home_work), findsOneWidget);
      expect(find.text('Hi! 👋'), findsOneWidget);
      expect(find.text('I\'m your AI rental assistant'), findsOneWidget);
      expect(find.text('I can help you:'), findsOneWidget);
      expect(find.text('Find properties'), findsOneWidget);
      expect(find.text('List your property'), findsOneWidget);
      expect(find.text('Calculate affordability'), findsOneWidget);
      expect(find.text('Get neighborhood info'), findsOneWidget);
      expect(find.byType(SuggestedQueries), findsOneWidget);
    });

    testWidgets('EnhancedEmptyState displays user name when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedEmptyState(
              userName: 'John',
              onQuerySelected: (_) {},
            ),
          ),
        ),
      );

      // Verify user name is displayed
      expect(find.text('Hi John! 👋'), findsOneWidget);
    });

    testWidgets('EnhancedEmptyState calls onQuerySelected when query is tapped',
        (WidgetTester tester) async {
      String? selectedQuery;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedEmptyState(
              onQuerySelected: (query) {
                selectedQuery = query;
              },
            ),
          ),
        ),
      );

      // Scroll to make the query visible
      await tester.dragUntilVisible(
        find.text('Find me a 2-bedroom apartment in Westlands under 50k'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      // Tap on a suggested query
      await tester.tap(
        find.text('Find me a 2-bedroom apartment in Westlands under 50k'),
      );
      await tester.pumpAndSettle();

      // Verify callback was called with correct query
      expect(
        selectedQuery,
        'Find me a 2-bedroom apartment in Westlands under 50k',
      );
    });

    testWidgets('EnhancedEmptyState displays all suggested queries',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedEmptyState(
              onQuerySelected: (_) {},
            ),
          ),
        ),
      );

      // Scroll to make queries visible
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // Verify all default suggested queries are displayed
      expect(find.text('Try asking:'), findsOneWidget);
      expect(
        find.text('Find me a 2-bedroom apartment in Westlands under 50k'),
        findsOneWidget,
      );
      expect(find.text('I want to list my property'), findsOneWidget);
      expect(find.text('Show me bedsitters near Ngong Road'), findsOneWidget);
      expect(
        find.text('What\'s the difference between a bedsitter and studio?'),
        findsOneWidget,
      );
      expect(find.text('Help me calculate what I can afford'), findsOneWidget);
      expect(find.text('Tell me about Kilimani neighborhood'), findsOneWidget);
    });

    testWidgets('EnhancedEmptyState is scrollable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedEmptyState(
              onQuerySelected: (_) {},
            ),
          ),
        ),
      );

      // Verify the widget is scrollable
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('EnhancedEmptyState displays correctly in light theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: EnhancedEmptyState(
              onQuerySelected: (_) {},
            ),
          ),
        ),
      );

      // Verify widget renders without errors
      expect(find.byType(EnhancedEmptyState), findsOneWidget);
    });

    testWidgets('EnhancedEmptyState displays correctly in dark theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: EnhancedEmptyState(
              onQuerySelected: (_) {},
            ),
          ),
        ),
      );

      // Verify widget renders without errors
      expect(find.byType(EnhancedEmptyState), findsOneWidget);
    });
  });
}

