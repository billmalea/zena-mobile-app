import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/property_hunting_card.dart';

void main() {
  group('PropertyHuntingCard', () {
    testWidgets('renders with active status', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyHuntingCard(
              requestId: 'REQ-12345',
              status: 'active',
              searchCriteria: {
                'location': 'Westlands, Nairobi',
                'minRent': 30000,
                'maxRent': 50000,
                'bedrooms': 2,
                'propertyType': 'Apartment',
              },
              onCheckStatus: (message) {},
            ),
          ),
        ),
      );

      expect(find.text('Property Hunting Request'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('REQ-12345'), findsOneWidget);
      expect(find.text('Westlands, Nairobi'), findsOneWidget);
      expect(find.text('Check Status'), findsOneWidget);
    });

    testWidgets('renders with completed status', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyHuntingCard(
              requestId: 'REQ-67890',
              status: 'completed',
              searchCriteria: {
                'location': 'Kilimani',
                'maxRent': 40000,
              },
            ),
          ),
        ),
      );

      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('Kilimani'), findsOneWidget);
    });

    testWidgets('displays rent range correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyHuntingCard(
              requestId: 'REQ-111',
              status: 'searching',
              searchCriteria: {
                'location': 'Any location',
                'minRent': 20000,
                'maxRent': 35000,
              },
            ),
          ),
        ),
      );

      expect(find.textContaining('KES 20000 - 35000'), findsOneWidget);
    });

    testWidgets('check status button triggers callback', (WidgetTester tester) async {
      String? receivedMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyHuntingCard(
              requestId: 'REQ-999',
              status: 'active',
              searchCriteria: {'location': 'Nairobi'},
              onCheckStatus: (message) {
                receivedMessage = message;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Check Status'));
      await tester.pump();

      expect(receivedMessage, contains('REQ-999'));
    });
  });
}
