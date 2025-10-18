import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/commission_card.dart';

void main() {
  group('CommissionCard', () {
    testWidgets('renders with paid status', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommissionCard(
              amount: 500.0,
              propertyReference: '2BR Apartment in Westlands',
              dateEarned: DateTime.now().subtract(const Duration(days: 2)),
              status: 'paid',
              totalEarnings: 2500.0,
            ),
          ),
        ),
      );

      expect(find.text('Commission Earned'), findsOneWidget);
      expect(find.text('PAID'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      expect(find.text('2BR Apartment in Westlands'), findsOneWidget);
      expect(find.textContaining('KES 2500'), findsOneWidget);
    });

    testWidgets('renders with pending status and shows message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommissionCard(
              amount: 750.0,
              propertyReference: 'Studio in Kilimani',
              dateEarned: DateTime.now(),
              status: 'pending',
              totalEarnings: 1500.0,
            ),
          ),
        ),
      );

      expect(find.text('PENDING'), findsOneWidget);
      expect(find.textContaining('3-5 business days'), findsOneWidget);
    });

    testWidgets('displays date correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommissionCard(
              amount: 600.0,
              propertyReference: 'Property ABC',
              dateEarned: DateTime.now(),
              status: 'paid',
              totalEarnings: 3000.0,
            ),
          ),
        ),
      );

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('displays total earnings', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommissionCard(
              amount: 500.0,
              propertyReference: 'Test Property',
              dateEarned: DateTime.now(),
              status: 'paid',
              totalEarnings: 5000.0,
            ),
          ),
        ),
      );

      expect(find.text('Total Earnings'), findsOneWidget);
      expect(find.text('KES 5000'), findsOneWidget);
    });
  });
}
