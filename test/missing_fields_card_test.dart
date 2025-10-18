import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/missing_fields_card.dart';

void main() {
  group('MissingFieldsCard', () {
    testWidgets('displays correct number of missing fields',
        (WidgetTester tester) async {
      final missingFields = ['title', 'description', 'rentAmount'];
      final fieldHints = {
        'title': 'Enter property title',
        'description': 'Enter property description',
        'rentAmount': 'Enter monthly rent amount',
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

      // Verify header shows correct count
      expect(find.text('3 fields required'), findsOneWidget);

      // Verify all field labels are displayed
      expect(find.text('TITLE'), findsOneWidget);
      expect(find.text('DESCRIPTION'), findsOneWidget);
      expect(find.text('RENT AMOUNT'), findsOneWidget);
    });

    testWidgets('displays field hints correctly', (WidgetTester tester) async {
      final missingFields = ['title'];
      final fieldHints = {
        'title': 'Enter a descriptive property title',
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

      // Verify hint text is displayed
      expect(find.text('Enter a descriptive property title'), findsOneWidget);
    });

    testWidgets('validates required fields on submit',
        (WidgetTester tester) async {
      final missingFields = ['title', 'rentAmount'];
      final fieldHints = {
        'title': 'Enter property title',
        'rentAmount': 'Enter monthly rent',
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

      // Try to submit without filling fields
      await tester.tap(find.text('Submit Information'));
      await tester.pumpAndSettle();

      // Verify validation errors are shown
      expect(find.text('This field is required'), findsWidgets);

      // Verify submit was not called
      expect(submitCalled, false);
    });

    testWidgets('validates title length', (WidgetTester tester) async {
      final missingFields = ['title'];
      final fieldHints = {'title': 'Enter property title'};

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

      // Enter a title that's too short
      await tester.enterText(
        find.byType(TextField),
        'Short',
      );

      // Unfocus the field to trigger validation
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Title must be at least 10 characters'), findsOneWidget);
    });

    testWidgets('validates numeric fields', (WidgetTester tester) async {
      final missingFields = ['rentAmount'];
      final fieldHints = {'rentAmount': 'Enter monthly rent'};

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

      // Enter invalid numeric value
      await tester.enterText(
        find.byType(TextField),
        '0',
      );

      // Unfocus the field
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Amount must be greater than 0'), findsOneWidget);
    });

    testWidgets('calls onSubmit with collected data when valid',
        (WidgetTester tester) async {
      final missingFields = ['title', 'rentAmount'];
      final fieldHints = {
        'title': 'Enter property title',
        'rentAmount': 'Enter monthly rent',
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

      // Fill in valid data
      final titleField = find.byType(TextField).first;
      final rentField = find.byType(TextField).last;

      await tester.enterText(titleField, 'Beautiful 2BR Apartment');
      await tester.enterText(rentField, '50000');
      await tester.pumpAndSettle();

      // Submit the form
      await tester.tap(find.text('Submit Information'));
      await tester.pumpAndSettle();

      // Verify onSubmit was called with correct data
      expect(submittedData, isNotNull);
      expect(submittedData!['title'], 'Beautiful 2BR Apartment');
      expect(submittedData!['rentAmount'], 50000);
    });

    testWidgets('formats field names correctly', (WidgetTester tester) async {
      final missingFields = [
        'propertyType',
        'rent_amount',
        'neighborhood',
      ];
      final fieldHints = {
        'propertyType': 'Enter type',
        'rent_amount': 'Enter rent',
        'neighborhood': 'Enter neighborhood',
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

      // Verify formatted field names
      expect(find.text('PROPERTY TYPE'), findsOneWidget);
      expect(find.text('RENT AMOUNT'), findsOneWidget);
      expect(find.text('NEIGHBORHOOD'), findsOneWidget);
    });

    testWidgets('shows error icon for invalid fields',
        (WidgetTester tester) async {
      final missingFields = ['title'];
      final fieldHints = {'title': 'Enter property title'};

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

      // Unfocus to trigger validation
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify error icon is shown
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('uses multiline input for description field',
        (WidgetTester tester) async {
      final missingFields = ['description'];
      final fieldHints = {'description': 'Enter property description'};

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

      // Find the TextField widget
      final textField = tester.widget<TextField>(find.byType(TextField));

      // Verify it allows multiple lines
      expect(textField.maxLines, 4);
      expect(textField.keyboardType, TextInputType.multiline);
    });

    testWidgets('validates description length', (WidgetTester tester) async {
      final missingFields = ['description'];
      final fieldHints = {'description': 'Enter property description'};

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

      // Enter a description that's too short
      await tester.enterText(
        find.byType(TextField),
        'Too short',
      );

      // Unfocus the field
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify error message
      expect(
        find.text('Description must be at least 20 characters'),
        findsOneWidget,
      );
    });
  });
}
