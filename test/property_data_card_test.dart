import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/property_data_card.dart';

void main() {
  group('PropertyDataCard', () {
    final sampleData = {
      'title': '2BR Apartment',
      'description': 'Modern apartment',
      'propertyType': 'Apartment',
      'bedrooms': 2,
      'bathrooms': 2,
      'rentAmount': 50000,
      'commissionAmount': 5000,
      'location': 'Westlands',
      'amenities': ['WiFi', 'Parking'],
    };

    testWidgets('renders with complete data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyDataCard(
              propertyData: sampleData,
            ),
          ),
        ),
      );

      expect(find.text('Review Property Data'), findsOneWidget);
      expect(find.text('All required fields are complete'), findsOneWidget);
      expect(find.text('2BR Apartment'), findsOneWidget);
      expect(find.text('KSh 50,000'), findsOneWidget);
    });

    testWidgets('shows warning for incomplete data',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyDataCard(
              propertyData: const {'title': ''},
            ),
          ),
        ),
      );

      expect(find.text('Some required fields need attention'), findsOneWidget);
    });

    testWidgets('calls onEdit callback', (WidgetTester tester) async {
      bool called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyDataCard(
              propertyData: sampleData,
              onEdit: (field, value) => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      expect(called, true);
    });

    testWidgets('calls onConfirm callback', (WidgetTester tester) async {
      bool called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyDataCard(
              propertyData: sampleData,
              onConfirm: () => called = true,
            ),
          ),
        ),
      );

      // Scroll to the button
      await tester.dragUntilVisible(
        find.text('Confirm Data'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm Data'));
      expect(called, true);
    });

    testWidgets('displays section headers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyDataCard(
              propertyData: sampleData,
            ),
          ),
        ),
      );

      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Financial Information'), findsOneWidget);
      expect(find.text('Location Information'), findsOneWidget);
      expect(find.text('Property Details'), findsOneWidget);
    });

    testWidgets('handles snake_case fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyDataCard(
              propertyData: const {
                'title': 'Test',
                'description': 'Desc',
                'property_type': 'House',
                'rent_amount': 40000,
                'location': 'Nairobi',
              },
            ),
          ),
        ),
      );

      expect(find.text('House'), findsOneWidget);
      expect(find.text('KSh 40,000'), findsOneWidget);
    });
  });
}
