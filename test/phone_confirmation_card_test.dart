import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/phone_confirmation_card.dart';

void main() {
  group('PhoneConfirmationCard', () {
    testWidgets('displays phone number and property details correctly',
        (WidgetTester tester) async {
      // Sample data
      const phoneNumber = '+254712345678';
      const message =
          'Please confirm your phone number to proceed with payment.';
      final property = {
        'title': '2BR Apartment in Westlands',
        'commission': 500,
      };

      bool confirmCalled = false;
      bool declineCalled = false;

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneConfirmationCard(
              phoneNumber: phoneNumber,
              message: message,
              property: property,
              onConfirm: () => confirmCalled = true,
              onDecline: () => declineCalled = true,
            ),
          ),
        ),
      );

      // Verify phone number is displayed
      expect(find.text(phoneNumber), findsOneWidget);

      // Verify property title is displayed
      expect(find.text('2BR Apartment in Westlands'), findsOneWidget);

      // Verify commission is displayed
      expect(find.textContaining('KES 500'), findsOneWidget);

      // Verify message is displayed
      expect(find.text(message), findsOneWidget);

      // Verify buttons are present
      expect(find.text('Yes, use this number'), findsOneWidget);
      expect(find.text('No, use different number'), findsOneWidget);

      // Test confirm button
      await tester.tap(find.text('Yes, use this number'));
      await tester.pump();
      expect(confirmCalled, true);

      // Test decline button
      await tester.tap(find.text('No, use different number'));
      await tester.pump();
      expect(declineCalled, true);
    });

    testWidgets('handles missing property data gracefully',
        (WidgetTester tester) async {
      // Build with minimal data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneConfirmationCard(
              phoneNumber: '+254700000000',
              message: 'Confirm your number',
              property: {},
              onConfirm: () {},
              onDecline: () {},
            ),
          ),
        ),
      );

      // Should display default values
      expect(find.text('Property'), findsOneWidget);
      expect(find.textContaining('KES 0'), findsOneWidget);
    });

    testWidgets('displays default message when message is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneConfirmationCard(
              phoneNumber: '+254712345678',
              message: '',
              property: {'title': 'Test Property', 'commission': 100},
              onConfirm: () {},
              onDecline: () {},
            ),
          ),
        ),
      );

      // Should display default message
      expect(
        find.text(
            'We need to confirm your phone number to send the M-Pesa payment request.'),
        findsOneWidget,
      );
    });

    testWidgets('renders all UI elements correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneConfirmationCard(
              phoneNumber: '+254712345678',
              message: 'Test message',
              property: {'title': 'Test Property', 'commission': 250},
              onConfirm: () {},
              onDecline: () {},
            ),
          ),
        ),
      );

      // Verify icons are present
      expect(find.byIcon(Icons.phone_android), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.monetization_on_outlined), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

      // Verify header text
      expect(find.text('Confirm Phone Number'), findsOneWidget);
    });
  });
}
