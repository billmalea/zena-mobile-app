import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/phone_input_card.dart';

void main() {
  group('PhoneInputCard', () {
    late String? submittedPhone;

    setUp(() {
      submittedPhone = null;
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: PhoneInputCard(
            message: 'Test message',
            property: {
              'title': 'Test Property',
              'commission': 500,
            },
            onSubmit: (phone) {
              submittedPhone = phone;
            },
          ),
        ),
      );
    }

    testWidgets('renders correctly with all elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify header
      expect(find.text('Enter Phone Number'), findsOneWidget);

      // Verify property context
      expect(find.text('Test Property'), findsOneWidget);
      expect(find.text('KES 500'), findsOneWidget);

      // Verify phone input field
      expect(find.byType(TextField), findsOneWidget);

      // Verify submit button
      expect(find.text('Submit Phone Number'), findsOneWidget);

      // Verify format hints
      expect(
          find.textContaining('Accepted formats:'), findsOneWidget);
    });

    testWidgets('validates +254 format correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid +254 format
      await tester.enterText(find.byType(TextField), '+254712345678');
      await tester.pump();

      // Verify no error message
      expect(find.text('Please enter a valid Kenyan phone number'),
          findsNothing);
    });

    testWidgets('validates 254 format without + correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid 254 format
      await tester.enterText(find.byType(TextField), '254712345678');
      await tester.pump();

      // Verify no error message
      expect(find.text('Please enter a valid Kenyan phone number'),
          findsNothing);
    });

    testWidgets('validates 07 format correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid 07 format
      await tester.enterText(find.byType(TextField), '0712345678');
      await tester.pump();

      // Verify no error message
      expect(find.text('Please enter a valid Kenyan phone number'),
          findsNothing);
    });

    testWidgets('validates 01 format correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid 01 format
      await tester.enterText(find.byType(TextField), '0112345678');
      await tester.pump();

      // Verify no error message
      expect(find.text('Please enter a valid Kenyan phone number'),
          findsNothing);
    });

    testWidgets('shows error for invalid phone number',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter invalid phone number
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();

      // Verify error message is shown
      expect(find.text('Please enter a valid Kenyan phone number'),
          findsOneWidget);
    });

    testWidgets('normalizes +254 format correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid +254 format
      await tester.enterText(find.byType(TextField), '+254712345678');
      await tester.pump();

      // Find and tap submit button
      final button = find.text('Submit Phone Number');
      await tester.tap(button);
      await tester.pump();

      // Verify normalized phone
      expect(submittedPhone, '+254712345678');
    });

    testWidgets('normalizes 254 format to +254',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter 254 format without +
      await tester.enterText(find.byType(TextField), '254712345678');
      await tester.pump();

      // Find and tap submit button
      final button = find.text('Submit Phone Number');
      await tester.tap(button);
      await tester.pump();

      // Verify normalized phone
      expect(submittedPhone, '+254712345678');
    });

    testWidgets('normalizes 07 format to +254',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter 07 format
      await tester.enterText(find.byType(TextField), '0712345678');
      await tester.pump();

      // Find and tap submit button
      final button = find.text('Submit Phone Number');
      await tester.tap(button);
      await tester.pump();

      // Verify normalized phone
      expect(submittedPhone, '+254712345678');
    });

    testWidgets('normalizes 01 format to +254',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter 01 format
      await tester.enterText(find.byType(TextField), '0112345678');
      await tester.pump();

      // Find and tap submit button
      final button = find.text('Submit Phone Number');
      await tester.tap(button);
      await tester.pump();

      // Verify normalized phone
      expect(submittedPhone, '+254112345678');
    });

    testWidgets('handles phone with spaces and dashes',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter phone with spaces and dashes
      await tester.enterText(
          find.byType(TextField), '+254 712-345-678');
      await tester.pump();

      // Verify no error message
      expect(find.text('Please enter a valid Kenyan phone number'),
          findsNothing);

      // Find and tap submit button
      final button = find.text('Submit Phone Number');
      await tester.tap(button);
      await tester.pump();

      // Verify normalized phone (spaces and dashes removed)
      expect(submittedPhone, '+254712345678');
    });

    testWidgets('clear button clears input and resets validation',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid phone
      await tester.enterText(find.byType(TextField), '0712345678');
      await tester.pump();

      // Verify no error
      expect(find.text('Please enter a valid Kenyan phone number'),
          findsNothing);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Verify input is cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('displays custom message when provided',
        (WidgetTester tester) async {
      const customMessage = 'Custom test message for phone input';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputCard(
              message: customMessage,
              property: {
                'title': 'Test Property',
                'commission': 500,
              },
              onSubmit: (phone) {},
            ),
          ),
        ),
      );

      expect(find.text(customMessage), findsOneWidget);
    });
  });
}
