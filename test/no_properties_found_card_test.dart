import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/no_properties_found_card.dart';

void main() {
  group('NoPropertiesFoundCard', () {
    testWidgets('displays no properties found message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NoPropertiesFoundCard(
              searchCriteria: {},
            ),
          ),
        ),
      );

      expect(find.text('No Properties Found'), findsOneWidget);
      expect(
        find.text(
            'We couldn\'t find any properties matching your search criteria.'),
        findsOneWidget,
      );
    });

    testWidgets('displays search criteria when provided',
        (WidgetTester tester) async {
      final searchCriteria = {
        'location': 'Westlands',
        'minRent': 30000,
        'maxRent': 50000,
        'bedrooms': 2,
        'bathrooms': 2,
        'propertyType': 'Apartment',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoPropertiesFoundCard(
              searchCriteria: searchCriteria,
            ),
          ),
        ),
      );

      expect(find.text('Your search criteria:'), findsOneWidget);
      expect(find.text('Location: Westlands'), findsOneWidget);
      expect(find.text('Budget: KES 30,000 - 50,000'), findsOneWidget);
      expect(find.text('2 Bedrooms'), findsOneWidget);
      expect(find.text('2 Bathrooms'), findsOneWidget);
      expect(find.text('Apartment'), findsOneWidget);
    });

    testWidgets('displays suggestions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NoPropertiesFoundCard(
              searchCriteria: {},
            ),
          ),
        ),
      );

      expect(find.text('Suggestions'), findsOneWidget);
      expect(find.text('Try expanding your budget range'), findsOneWidget);
      expect(find.text('Consider nearby neighborhoods'), findsOneWidget);
      expect(find.text('Adjust the number of bedrooms'), findsOneWidget);
      expect(find.text('Remove some amenity filters'), findsOneWidget);
    });

    testWidgets('displays action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NoPropertiesFoundCard(
              searchCriteria: {},
            ),
          ),
        ),
      );

      expect(find.text('Adjust Search'), findsOneWidget);
      expect(find.text('Start Hunting'), findsOneWidget);
    });

    testWidgets('calls onSendMessage when Adjust Search is tapped',
        (WidgetTester tester) async {
      String? sentMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoPropertiesFoundCard(
              searchCriteria: {},
              onSendMessage: (message) {
                sentMessage = message;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Adjust Search'));
      await tester.pump();

      expect(sentMessage, 'I want to adjust my search criteria');
    });

    testWidgets('calls onSendMessage when Start Hunting is tapped',
        (WidgetTester tester) async {
      String? sentMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoPropertiesFoundCard(
              searchCriteria: {},
              onSendMessage: (message) {
                sentMessage = message;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Start Hunting'));
      await tester.pump();

      expect(sentMessage, 'I want to start property hunting');
    });

    testWidgets('handles empty search criteria gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NoPropertiesFoundCard(
              searchCriteria: {},
            ),
          ),
        ),
      );

      // When search criteria is empty, the "Your search criteria:" section is not shown
      expect(find.text('Your search criteria:'), findsNothing);
      // But the main message and suggestions should still be visible
      expect(find.text('No Properties Found'), findsOneWidget);
      expect(find.text('Suggestions'), findsOneWidget);
    });

    testWidgets('displays amenities in search criteria',
        (WidgetTester tester) async {
      final searchCriteria = {
        'amenities': ['WiFi', 'Parking', 'Security'],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoPropertiesFoundCard(
              searchCriteria: searchCriteria,
            ),
          ),
        ),
      );

      expect(find.text('Amenities: WiFi, Parking, Security'), findsOneWidget);
    });

    testWidgets('formats rent numbers with thousand separators',
        (WidgetTester tester) async {
      final searchCriteria = {
        'minRent': 100000,
        'maxRent': 200000,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoPropertiesFoundCard(
              searchCriteria: searchCriteria,
            ),
          ),
        ),
      );

      expect(find.text('Budget: KES 100,000 - 200,000'), findsOneWidget);
    });
  });
}
