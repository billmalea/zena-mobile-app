import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/affordability_card.dart';

void main() {
  group('AffordabilityCard', () {
    testWidgets('renders basic affordability info', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffordabilityCard(
              monthlyIncome: 100000.0,
              recommendedRange: {
                'min': 25000.0,
                'max': 30000.0,
              },
              affordabilityPercentage: 30.0,
              budgetBreakdown: {},
              tips: [],
            ),
          ),
        ),
      );

      expect(find.text('Rent Affordability'), findsOneWidget);
      expect(find.text('KES 100000'), findsOneWidget);
      expect(find.text('KES 25000'), findsOneWidget);
      expect(find.text('KES 30000'), findsOneWidget);
      expect(find.textContaining('30% of income'), findsOneWidget);
    });

    testWidgets('displays excellent affordability status', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffordabilityCard(
              monthlyIncome: 150000.0,
              recommendedRange: {
                'min': 30000.0,
                'max': 45000.0,
              },
              affordabilityPercentage: 25.0,
              budgetBreakdown: {},
              tips: [],
            ),
          ),
        ),
      );

      expect(find.textContaining('Excellent'), findsOneWidget);
    });

    testWidgets('displays budget breakdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AffordabilityCard(
                monthlyIncome: 100000.0,
                recommendedRange: {
                  'min': 25000.0,
                  'max': 30000.0,
                },
                affordabilityPercentage: 30.0,
                budgetBreakdown: {
                  'Rent': 30000.0,
                  'Food': 20000.0,
                  'Transport': 15000.0,
                  'Savings': 20000.0,
                },
                tips: [],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Budget Breakdown'), findsOneWidget);
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Savings'), findsOneWidget);
      expect(find.textContaining('30000'), findsWidgets);
      expect(find.textContaining('20000'), findsWidgets);
    });

    testWidgets('displays financial tips', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffordabilityCard(
              monthlyIncome: 80000.0,
              recommendedRange: {
                'min': 20000.0,
                'max': 24000.0,
              },
              affordabilityPercentage: 30.0,
              budgetBreakdown: {},
              tips: [
                'Keep rent below 30% of income',
                'Build an emergency fund',
                'Consider shared accommodation',
              ],
            ),
          ),
        ),
      );

      expect(find.text('Financial Tips'), findsOneWidget);
      expect(find.text('Keep rent below 30% of income'), findsOneWidget);
      expect(find.text('Build an emergency fund'), findsOneWidget);
      expect(find.text('Consider shared accommodation'), findsOneWidget);
    });

    testWidgets('shows high risk status for high percentage', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffordabilityCard(
              monthlyIncome: 50000.0,
              recommendedRange: {
                'min': 15000.0,
                'max': 20000.0,
              },
              affordabilityPercentage: 45.0,
              budgetBreakdown: {},
              tips: [],
            ),
          ),
        ),
      );

      expect(find.textContaining('High Risk'), findsOneWidget);
    });
  });
}
