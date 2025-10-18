import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/missing_fields_card.dart';

/// Integration tests for MissingFieldsCard covering various scenarios
void main() {
  group('MissingFieldsCard Integration Tests', () {
    testWidgets('Scenario 1: Basic property submission with title and rent',
        (WidgetTester tester) async {
      final missingFields = ['title', 'rentAmount'];
      final fieldHints = {
        'title': 'Enter a descriptive title for your property',
        'rentAmount': 'Enter the monthly rent amount in KES',
      };
      Map<String, dynamic>? submittedData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MissingFieldsCard(
              missingFields: missingFields,
              fieldHints: fieldHints,
              onSubmit: (data) {
                submittedData = data;
              },
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Complete Missing Information'), findsOneWidget);
      expect(find.text('2 fields required'), findsOneWidget);

      // Fill in the fields
      await tester.enterText(
        find.byType(TextField).first,
        'Spacious 3BR Apartment in Westlands',
      );
      await tester.enterText(
        find.byType(TextField).last,
        '75000',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Submit Information'));
      await tester.pumpAndSettle();

      // Verify submission
      expect(submittedData, isNotNull);
      expect(submittedData!['title'], 'Spacious 3BR Apartment in Westlands');
      expect(submittedData!['rentAmount'], 75000);
    });

    testWidgets('Scenario 2: Complete property details with all field types',
        (WidgetTester tester) async {
      final missingFields = [
        'title',
        'description',
        'propertyType',
        'bedrooms',
        'bathrooms',
        'location',
      ];
      final fieldHints = {
        'title': 'Property title',
        'description': 'Detailed description',
        'propertyType': 'Type of property',
        'bedrooms': 'Number of bedrooms',
        'bathrooms': 'Number of bathrooms',
        'location': 'Property location',
      };
      Map<String, dynamic>? submittedData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MissingFieldsCard(
                missingFields: missingFields,
                fieldHints: fieldHints,
                onSubmit: (data) {
                  submittedData = data;
                },
              ),
            ),
          ),
        ),
      );

      // Verify all fields are displayed
      expect(find.text('6 fields required'), findsOneWidget);
      expect(find.text('TITLE'), findsOneWidget);
      expect(find.text('DESCRIPTION'), findsOneWidget);
      expect(find.text('PROPERTY TYPE'), findsOneWidget);
      expect(find.text('BEDROOMS'), findsOneWidget);
      expect(find.text('BATHROOMS'), findsOneWidget);
      expect(find.text('LOCATION'), findsOneWidget);

      // Fill in all fields
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Modern Family Home');
      await tester.enterText(
        textFields.at(1),
        'Beautiful modern home with spacious rooms and great amenities',
      );
      await tester.enterText(textFields.at(2), 'House');
      await tester.enterText(textFields.at(3), '4');
      await tester.enterText(textFields.at(4), '3');
      await tester.enterText(textFields.at(5), 'Karen, Nairobi');
      await tester.pumpAndSettle();

      // Scroll to submit button
      await tester.ensureVisible(find.text('Submit Information'));
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Submit Information'));
      await tester.pumpAndSettle();

      // Verify all data was collected
      expect(submittedData, isNotNull);
      expect(submittedData!['title'], 'Modern Family Home');
      expect(
        submittedData!['description'],
        'Beautiful modern home with spacious rooms and great amenities',
      );
      expect(submittedData!['propertyType'], 'House');
      expect(submittedData!['bedrooms'], 4);
      expect(submittedData!['bathrooms'], 3);
      expect(submittedData!['location'], 'Karen, Nairobi');
    });

    testWidgets('Scenario 3: Validation prevents submission with errors',
        (WidgetTester tester) async {
      final missingFields = ['title', 'description', 'rentAmount'];
      final fieldHints = {
        'title': 'Property title',
        'description': 'Property description',
        'rentAmount': 'Monthly rent',
      };
      bool submitCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MissingFieldsCard(
              missingFields: missingFields,
              fieldHints: fieldHints,
              onSubmit: (_) {
                submitCalled = true;
              },
            ),
          ),
        ),
      );

      // Fill with invalid data
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Short'); // Too short
      await tester.enterText(textFields.at(1), 'Also short'); // Too short
      await tester.enterText(textFields.at(2), '0'); // Invalid amount
      await tester.pumpAndSettle();

      // Try to submit
      await tester.tap(find.text('Submit Information'));
      await tester.pumpAndSettle();

      // Verify errors are shown
      expect(find.text('Title must be at least 10 characters'), findsOneWidget);
      expect(
        find.text('Description must be at least 20 characters'),
        findsOneWidget,
      );
      expect(find.text('Amount must be greater than 0'), findsOneWidget);

      // Verify submit was not called
      expect(submitCalled, false);
    });

    testWidgets('Scenario 4: Real-time validation on field blur',
        (WidgetTester tester) async {
      final missingFields = ['title'];
      final fieldHints = {'title': 'Property title'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MissingFieldsCard(
              missingFields: missingFields,
              fieldHints: fieldHints,
              onSubmit: (_) {},
            ),
          ),
        ),
      );

      // Enter invalid data
      await tester.enterText(find.byType(TextField), 'Short');

      // Unfocus the field
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify error appears
      expect(find.text('Title must be at least 10 characters'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Fix the error
      await tester.enterText(
        find.byType(TextField),
        'Valid Property Title',
      );
      await tester.pumpAndSettle();

      // Verify error disappears
      expect(find.text('Title must be at least 10 characters'), findsNothing);
    });

    testWidgets('Scenario 5: Snake case and camelCase field names',
        (WidgetTester tester) async {
      final missingFields = [
        'rentAmount',
        'rent_amount',
        'propertyType',
        'property_type',
      ];
      final fieldHints = {
        'rentAmount': 'Rent amount',
        'rent_amount': 'Rent amount alt',
        'propertyType': 'Property type',
        'property_type': 'Property type alt',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MissingFieldsCard(
              missingFields: missingFields,
              fieldHints: fieldHints,
              onSubmit: (_) {},
            ),
          ),
        ),
      );

      // Verify all field names are formatted correctly
      expect(find.text('RENT AMOUNT'), findsNWidgets(2));
      expect(find.text('PROPERTY TYPE'), findsNWidgets(2));
    });

    testWidgets('Scenario 6: Numeric field validation edge cases',
        (WidgetTester tester) async {
      final missingFields = ['bedrooms', 'bathrooms', 'rentAmount'];
      final fieldHints = {
        'bedrooms': 'Number of bedrooms',
        'bathrooms': 'Number of bathrooms',
        'rentAmount': 'Monthly rent',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MissingFieldsCard(
              missingFields: missingFields,
              fieldHints: fieldHints,
              onSubmit: (_) {},
            ),
          ),
        ),
      );

      final textFields = find.byType(TextField);

      // Note: FilteringTextInputFormatter.digitsOnly prevents negative numbers
      // So we test with 0 instead
      await tester.enterText(textFields.at(0), '0');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      // 0 is valid for bedrooms, so no error expected

      // Test excessive bathrooms
      await tester.enterText(textFields.at(1), '100');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Value seems too high'), findsOneWidget);

      // Test excessive rent
      await tester.enterText(textFields.at(2), '2000000000');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Amount seems too high'), findsOneWidget);
    });

    testWidgets('Scenario 7: Single field required',
        (WidgetTester tester) async {
      final missingFields = ['location'];
      final fieldHints = {'location': 'Enter property location'};
      Map<String, dynamic>? submittedData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MissingFieldsCard(
              missingFields: missingFields,
              fieldHints: fieldHints,
              onSubmit: (data) {
                submittedData = data;
              },
            ),
          ),
        ),
      );

      // Verify singular form
      expect(find.text('1 field required'), findsOneWidget);

      // Fill and submit
      await tester.enterText(find.byType(TextField), 'Kilimani, Nairobi');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit Information'));
      await tester.pumpAndSettle();

      expect(submittedData, isNotNull);
      expect(submittedData!['location'], 'Kilimani, Nairobi');
    });
  });
}
