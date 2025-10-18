import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/suggested_queries.dart';

void main() {
  group('SuggestedQueries Widget', () {
    testWidgets('displays default suggestions', (WidgetTester tester) async {
      String? selectedQuery;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestedQueries(
              onQuerySelected: (query) {
                selectedQuery = query;
              },
            ),
          ),
        ),
      );

      // Verify "Try asking:" header is displayed
      expect(find.text('Try asking:'), findsOneWidget);

      // Verify all 6 default suggestions are displayed
      expect(
        find.text('Find me a 2-bedroom apartment in Westlands under 50k'),
        findsOneWidget,
      );
      expect(find.text('I want to list my property'), findsOneWidget);
      expect(find.text('Show me bedsitters near Ngong Road'), findsOneWidget);
      expect(
        find.text("What's the difference between a bedsitter and studio?"),
        findsOneWidget,
      );
      expect(find.text('Help me calculate what I can afford'), findsOneWidget);
      expect(find.text('Tell me about Kilimani neighborhood'), findsOneWidget);

      // Verify arrow icons are displayed
      expect(find.byIcon(Icons.arrow_forward), findsNWidgets(6));
    });

    testWidgets('calls onQuerySelected when chip is tapped',
        (WidgetTester tester) async {
      String? selectedQuery;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestedQueries(
              onQuerySelected: (query) {
                selectedQuery = query;
              },
            ),
          ),
        ),
      );

      // Tap on the first suggestion
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

    testWidgets('displays custom suggestions when provided',
        (WidgetTester tester) async {
      final customSuggestions = [
        'Custom query 1',
        'Custom query 2',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestedQueries(
              onQuerySelected: (_) {},
              suggestions: customSuggestions,
            ),
          ),
        ),
      );

      // Verify custom suggestions are displayed
      expect(find.text('Custom query 1'), findsOneWidget);
      expect(find.text('Custom query 2'), findsOneWidget);

      // Verify only 2 arrow icons (matching custom suggestions count)
      expect(find.byIcon(Icons.arrow_forward), findsNWidgets(2));
    });

    testWidgets('chips have proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestedQueries(
              onQuerySelected: (_) {},
            ),
          ),
        ),
      );

      // Find the first InkWell
      final inkWell = tester.widget<InkWell>(
        find.byType(InkWell).first,
      );

      // Verify InkWell has rounded border radius
      expect(inkWell.borderRadius, BorderRadius.circular(12));

      // Find the first Container inside InkWell
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(InkWell).first,
          matching: find.byType(Container),
        ).first,
      );

      // Verify Container has border and rounded corners
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.border, isNotNull);
    });
  });
}
