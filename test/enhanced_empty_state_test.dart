import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/enhanced_empty_state.dart';

void main() {
  group('EnhancedEmptyState Widget Tests', () {
    testWidgets('displays app logo/icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedEmptyState(
              onQuerySelected: (_) {},
            ),
          ),
        ),
      );

      // Verify logo icon is displayed
      expect(find.byIcon(Icons.home_work), findsOneWidget);
    });

    testWidgets('displays welcome message without user name',
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

      // Verify welcome message without name
      expect(find.text('Hi! 👋'), findsOneWidget);
    });

    testWidgets('displays welcome message with user name',
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

      // Verify welcome message with name
      expect(find.text('Hi John! 👋'), findsOneWidget);
    });

    testWidgets('displays AI rental assistant subtitle',
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

      // Verify subtitle
      expect(find.text('I\'m your AI rental assistant'), findsOneWidget);
    });

    testWidgets('displays all key features', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedEmptyState(
              onQuerySelected: (_) {},
            ),
          ),
        ),
      );

      // Verify features header
      expect(find.text('I can help you:'), findsOneWidget);

      // Verify all key features
      expect(find.text('Find properties'), findsOneWidget);
      expect(find.text('List your property'), findsOneWidget);
      expect(find.text('Calculate affordability'), findsOneWidget);
      expect(find.text('Get neighborhood info'), findsOneWidget);

      // Verify feature icons
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.add_home), findsOneWidget);
      expect(find.byIcon(Icons.calculate), findsOneWidget);
      expect(find.byIcon(Icons.location_city), findsOneWidget);
    });

    testWidgets('integrates SuggestedQueries widget',
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

      // Verify suggested queries section is present
      expect(find.text('Try asking:'), findsOneWidget);

      // Verify at least one suggested query is displayed
      expect(
        find.text('Find me a 2-bedroom apartment in Westlands under 50k'),
        findsOneWidget,
      );
    });

    testWidgets('calls onQuerySelected when query is tapped',
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

    testWidgets('has proper spacing and hierarchy',
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

      // Verify proper padding
      final scrollView =
          tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      expect(scrollView.padding, const EdgeInsets.all(24));
    });

    testWidgets('displays correctly in light theme',
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

    testWidgets('displays correctly in dark theme',
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
