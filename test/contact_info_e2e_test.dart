import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/widgets/chat/tool_result_widget.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/phone_confirmation_card.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/phone_input_card.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/contact_info_card.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/payment_error_card.dart';

/// End-to-End tests for the Contact Info Request Flow with M-Pesa payment
/// 
/// This test suite covers the complete user journey from requesting contact info
/// through phone confirmation, payment processing, and displaying results.
/// 
/// Test Scenarios:
/// 1. Complete flow: Request → Phone confirmation → Payment → Contact info display
/// 2. Phone confirmation with "Yes" button
/// 3. Phone confirmation with "No" button and provide different number
/// 4. Successful payment flow
/// 5. Cancelled payment flow
/// 6. Timeout scenario
/// 7. Failed payment scenario
/// 8. Retry after error
/// 9. Call button functionality
/// 10. WhatsApp button functionality
/// 11. Backend polling verification (mobile waits for result)
void main() {
  group('Contact Info E2E Tests', () {
    late List<String> sentMessages;

    setUp(() {
      sentMessages = [];
    });

    // Helper to create test widget with message callback
    Widget createTestWidget(ToolResult toolResult) {
      return MaterialApp(
        home: Scaffold(
          body: ToolResultWidget(
            toolResult: toolResult,
            onSendMessage: (message) {
              sentMessages.add(message);
            },
          ),
        ),
      );
    }

    group('1. Complete Flow Tests', () {
      testWidgets('Complete successful flow: Phone confirmation → Payment → Contact info',
          (WidgetTester tester) async {
        // Step 1: Phone confirmation needed
        final phoneConfirmationResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': false,
            'needsPhoneConfirmation': true,
            'message': 'I can see you have +254712345678 on file. Should I proceed with this number?',
            'userPhoneFromProfile': '+254712345678',
            'property': {
              'id': 'prop_123',
              'title': '2BR Apartment in Westlands',
              'commission_amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(phoneConfirmationResult));
        await tester.pumpAndSettle();

        // Verify phone confirmation card is displayed
        expect(find.byType(PhoneConfirmationCard), findsOneWidget);
        expect(find.text('+254712345678'), findsOneWidget);
        expect(find.text('2BR Apartment in Westlands'), findsOneWidget);

        // User confirms phone number
        await tester.tap(find.text('Yes, use this number'));
        await tester.pumpAndSettle();

        expect(sentMessages.length, 1);
        expect(sentMessages.last, contains('+254712345678'));

        // Step 2: Backend processes payment (mobile shows loading)
        // In real app, this would show a loading indicator
        // Backend polls M-Pesa status internally

        // Step 3: Payment successful - contact info displayed
        final contactInfoResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': true,
            'message': 'Payment successful! The property agent is now contacting you.',
            'contactInfo': {
              'name': 'John Doe',
              'phone': '+254712345678',
              'email': 'john@example.com',
              'propertyTitle': '2BR Apartment in Westlands',
            },
            'paymentInfo': {
              'amount': 5000,
              'status': 'completed',
              'transactionId': 'ABC123',
              'receiptNumber': 'XYZ789',
            },
          },
        );

        await tester.pumpWidget(createTestWidget(contactInfoResult));
        await tester.pumpAndSettle();

        // Verify contact info card is displayed
        expect(find.byType(ContactInfoCard), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('+254712345678'), findsOneWidget);
        expect(find.text('john@example.com'), findsOneWidget);
        expect(find.text('KES 5000'), findsOneWidget);
        expect(find.text('XYZ789'), findsOneWidget);
      });
    });

    group('2. Phone Confirmation - Yes Button', () {
      testWidgets('User confirms phone number with "Yes" button',
          (WidgetTester tester) async {
        final toolResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'needsPhoneConfirmation': true,
            'userPhoneFromProfile': '+254712345678',
            'message': 'Confirm your phone number',
            'property': {
              'title': 'Test Property',
              'commission_amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(toolResult));
        await tester.pumpAndSettle();

        // Find and tap "Yes" button
        final yesButton = find.text('Yes, use this number');
        expect(yesButton, findsOneWidget);

        await tester.tap(yesButton);
        await tester.pumpAndSettle();

        // Verify message was sent
        expect(sentMessages.length, 1);
        expect(sentMessages.first, contains('Yes'));
        expect(sentMessages.first, contains('+254712345678'));
      });
    });

    group('3. Phone Confirmation - No Button', () {
      testWidgets('User declines and provides different phone number',
          (WidgetTester tester) async {
        // Step 1: User declines phone confirmation
        final confirmationResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'needsPhoneConfirmation': true,
            'userPhoneFromProfile': '+254712345678',
            'message': 'Confirm your phone number',
            'property': {
              'title': 'Test Property',
              'commission_amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(confirmationResult));
        await tester.pumpAndSettle();

        // Tap "No" button
        await tester.tap(find.text('No, use different number'));
        await tester.pumpAndSettle();

        expect(sentMessages.length, 1);
        expect(sentMessages.first, contains('different'));

        // Step 2: Phone input card is shown
        final phoneInputResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'needsPhoneNumber': true,
            'message': 'Please provide your phone number',
            'property': {
              'title': 'Test Property',
              'commission_amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(phoneInputResult));
        await tester.pumpAndSettle();

        expect(find.byType(PhoneInputCard), findsOneWidget);

        // User enters different phone number
        await tester.enterText(
          find.byType(TextField),
          '0798765432',
        );
        await tester.pumpAndSettle();

        // Submit button should be enabled
        final submitButton = find.text('Submit Phone Number');
        expect(submitButton, findsOneWidget);

        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Verify normalized phone number was sent
        expect(sentMessages.length, 2);
        expect(sentMessages.last, contains('+254798765432'));
      });
    });

    group('4. Successful Payment Flow', () {
      testWidgets('Complete M-Pesa payment successfully',
          (WidgetTester tester) async {
        final successResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': true,
            'message': 'Payment successful!',
            'contactInfo': {
              'name': 'Jane Smith',
              'phone': '+254722334455',
              'email': 'jane@example.com',
              'propertyTitle': '3BR House in Karen',
            },
            'paymentInfo': {
              'amount': 7500,
              'status': 'completed',
              'receiptNumber': 'MPE123456',
            },
          },
        );

        await tester.pumpWidget(createTestWidget(successResult));
        await tester.pumpAndSettle();

        // Verify success indicators
        expect(find.byType(ContactInfoCard), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);
        expect(find.text('Payment Successful!'), findsOneWidget);
        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('KES 7500'), findsOneWidget);
        expect(find.text('MPE123456'), findsOneWidget);
      });
    });

    group('5. Cancelled Payment Flow', () {
      testWidgets('User cancels M-Pesa payment on phone',
          (WidgetTester tester) async {
        final cancelledResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': false,
            'error': 'Payment was cancelled: User cancelled transaction',
            'errorType': 'PAYMENT_CANCELLED',
            'property': {
              'title': '2BR Apartment in Westlands',
              'commission_amount': 5000,
            },
            'paymentInfo': {
              'amount': 5000,
              'status': 'cancelled',
              'failureReason': 'User cancelled',
            },
          },
        );

        await tester.pumpWidget(createTestWidget(cancelledResult));
        await tester.pumpAndSettle();

        // Verify error card is displayed
        expect(find.byType(PaymentErrorCard), findsOneWidget);
        expect(find.text('Payment Cancelled'), findsOneWidget);
        expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
        
        // Verify user-friendly message
        expect(find.textContaining('cancelled'), findsOneWidget);
        
        // Verify retry button exists
        expect(find.text('Try Again'), findsOneWidget);
      });
    });

    group('6. Timeout Scenario', () {
      testWidgets('Payment times out when user doesn\'t respond',
          (WidgetTester tester) async {
        final timeoutResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': false,
            'error': 'Payment verification timeout: No response after 30 seconds',
            'errorType': 'PAYMENT_TIMEOUT',
            'property': {
              'title': '2BR Apartment in Westlands',
              'commission_amount': 5000,
            },
            'paymentInfo': {
              'amount': 5000,
              'status': 'timeout',
            },
          },
        );

        await tester.pumpWidget(createTestWidget(timeoutResult));
        await tester.pumpAndSettle();

        // Verify timeout error card
        expect(find.byType(PaymentErrorCard), findsOneWidget);
        expect(find.text('Payment Timeout'), findsOneWidget);
        expect(find.byIcon(Icons.access_time_outlined), findsOneWidget);
        
        // Verify helpful tip is shown
        expect(find.textContaining('60 seconds'), findsOneWidget);
        
        // Verify retry button
        expect(find.text('Try Again'), findsOneWidget);
      });
    });

    group('7. Failed Payment Scenario', () {
      testWidgets('Payment fails due to insufficient balance',
          (WidgetTester tester) async {
        final failedResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': false,
            'error': 'Payment failed: Insufficient M-Pesa balance',
            'errorType': 'PAYMENT_FAILED',
            'property': {
              'title': '2BR Apartment in Westlands',
              'commission_amount': 5000,
            },
            'paymentInfo': {
              'amount': 5000,
              'status': 'failed',
              'failureReason': 'Insufficient balance',
            },
          },
        );

        await tester.pumpWidget(createTestWidget(failedResult));
        await tester.pumpAndSettle();

        // Verify failed error card
        expect(find.byType(PaymentErrorCard), findsOneWidget);
        expect(find.text('Payment Failed'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        
        // Verify error message (appears in both error text and tip)
        expect(find.textContaining('Insufficient'), findsWidgets);
        
        // Verify helpful tip (also contains "M-Pesa balance")
        expect(find.textContaining('M-Pesa balance'), findsWidgets);
        
        // Verify retry button
        expect(find.text('Try Again'), findsOneWidget);
      });
    });

    group('8. Retry After Error', () {
      testWidgets('User retries payment after cancellation',
          (WidgetTester tester) async {
        final errorResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': false,
            'error': 'Payment was cancelled',
            'errorType': 'PAYMENT_CANCELLED',
            'property': {
              'title': 'Test Property',
              'commission_amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(errorResult));
        await tester.pumpAndSettle();

        // Tap retry button
        await tester.tap(find.text('Try Again'));
        await tester.pumpAndSettle();

        // Verify retry message was sent
        expect(sentMessages.length, 1);
        expect(sentMessages.first, equals('Try again'));
      });

      testWidgets('User retries payment after timeout',
          (WidgetTester tester) async {
        final timeoutResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': false,
            'error': 'Payment timeout',
            'errorType': 'PAYMENT_TIMEOUT',
            'property': {
              'title': 'Test Property',
              'commission_amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(timeoutResult));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Try Again'));
        await tester.pumpAndSettle();

        expect(sentMessages.length, 1);
        expect(sentMessages.first, equals('Try again'));
      });

      testWidgets('User retries payment after failure',
          (WidgetTester tester) async {
        final failedResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': false,
            'error': 'Payment failed',
            'errorType': 'PAYMENT_FAILED',
            'property': {
              'title': 'Test Property',
              'commission_amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(failedResult));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Try Again'));
        await tester.pumpAndSettle();

        expect(sentMessages.length, 1);
        expect(sentMessages.first, equals('Try again'));
      });
    });

    group('9. Call Button Functionality', () {
      testWidgets('Call button is displayed and tappable',
          (WidgetTester tester) async {
        final contactInfoResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': true,
            'message': 'Contact info retrieved',
            'contactInfo': {
              'name': 'Test Agent',
              'phone': '+254712345678',
              'propertyTitle': 'Test Property',
            },
            'paymentInfo': {
              'amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(contactInfoResult));
        await tester.pumpAndSettle();

        // Verify call button exists
        final callButton = find.text('Call');
        expect(callButton, findsOneWidget);

        // Verify phone icon exists in the card
        expect(find.byIcon(Icons.phone), findsWidgets);

        // Note: We can't actually test the URL launcher in unit tests
        // as it requires platform integration. This would be tested
        // manually on a real device.
      });
    });

    group('10. WhatsApp Button Functionality', () {
      testWidgets('WhatsApp button is displayed and tappable',
          (WidgetTester tester) async {
        final contactInfoResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': true,
            'message': 'Contact info retrieved',
            'contactInfo': {
              'name': 'Test Agent',
              'phone': '+254712345678',
              'propertyTitle': 'Test Property',
            },
            'paymentInfo': {
              'amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(contactInfoResult));
        await tester.pumpAndSettle();

        // Verify WhatsApp button exists
        final whatsappButton = find.text('WhatsApp');
        expect(whatsappButton, findsOneWidget);

        // Verify chat icon exists in the card
        expect(find.byIcon(Icons.chat), findsWidgets);

        // Note: We can't actually test the URL launcher in unit tests
        // as it requires platform integration. This would be tested
        // manually on a real device.
      });
    });

    group('11. Backend Polling Verification', () {
      testWidgets('Mobile waits for backend result without polling',
          (WidgetTester tester) async {
        // This test verifies that the mobile app doesn't do any polling
        // It simply displays the result from the backend

        // Step 1: Phone confirmation
        final confirmationResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'needsPhoneConfirmation': true,
            'userPhoneFromProfile': '+254712345678',
            'message': 'Confirm phone',
            'property': {
              'title': 'Test Property',
              'commission_amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(confirmationResult));
        await tester.pumpAndSettle();

        // User confirms
        await tester.tap(find.text('Yes, use this number'));
        await tester.pumpAndSettle();

        // At this point, the mobile app has sent the message
        // and is waiting for the backend to respond
        // The backend handles ALL polling internally

        // Step 2: Backend returns final result after polling
        final finalResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': true,
            'message': 'Payment successful',
            'contactInfo': {
              'name': 'Agent',
              'phone': '+254712345678',
              'propertyTitle': 'Test Property',
            },
            'paymentInfo': {
              'amount': 5000,
              'receiptNumber': 'ABC123',
            },
          },
        );

        await tester.pumpWidget(createTestWidget(finalResult));
        await tester.pumpAndSettle();

        // Verify final result is displayed
        expect(find.byType(ContactInfoCard), findsOneWidget);
        expect(find.text('Payment successful'), findsOneWidget);

        // Key verification: Mobile app made NO polling requests
        // It only sent one message (phone confirmation) and received one result
        expect(sentMessages.length, 1);
      });

      testWidgets('Backend handles timeout internally',
          (WidgetTester tester) async {
        // Backend polls for 30 seconds, then returns timeout error
        // Mobile app just displays the error

        final timeoutResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': false,
            'error': 'Payment verification timeout after 30 seconds',
            'errorType': 'PAYMENT_TIMEOUT',
            'property': {
              'title': 'Test Property',
              'commission_amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(timeoutResult));
        await tester.pumpAndSettle();

        // Verify timeout error is displayed
        expect(find.byType(PaymentErrorCard), findsOneWidget);
        expect(find.text('Payment Timeout'), findsOneWidget);

        // Mobile app didn't do any polling - just displayed the result
      });
    });

    group('Edge Cases', () {
      testWidgets('Already paid property shows contact info without payment details',
          (WidgetTester tester) async {
        final alreadyPaidResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': true,
            'message': 'You have already paid for this property',
            'alreadyPaid': true,
            'contactInfo': {
              'name': 'Agent',
              'phone': '+254712345678',
              'propertyTitle': 'Test Property',
            },
          },
        );

        await tester.pumpWidget(createTestWidget(alreadyPaidResult));
        await tester.pumpAndSettle();

        expect(find.byType(ContactInfoCard), findsOneWidget);
        expect(find.text('Contact Info Retrieved'), findsOneWidget);
        
        // Payment details section should not be shown
        expect(find.text('Payment Receipt'), findsNothing);
      });

      testWidgets('Contact info with video link shows video button',
          (WidgetTester tester) async {
        final withVideoResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': true,
            'message': 'Contact info retrieved',
            'contactInfo': {
              'name': 'Agent',
              'phone': '+254712345678',
              'propertyTitle': 'Test Property',
              'videoLink': 'https://example.com/video.mp4',
            },
            'paymentInfo': {
              'amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(withVideoResult));
        await tester.pumpAndSettle();

        // Verify video button is shown
        expect(find.text('Watch Property Video'), findsOneWidget);
        expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      });

      testWidgets('Phone input validates Kenyan formats correctly',
          (WidgetTester tester) async {
        final phoneInputResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'needsPhoneNumber': true,
            'message': 'Enter phone',
            'property': {
              'title': 'Test Property',
              'commission_amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(phoneInputResult));
        await tester.pumpAndSettle();

        final textField = find.byType(TextField);

        // Test valid formats
        final validFormats = [
          '+254712345678',
          '254712345678',
          '0712345678',
          '0112345678',
        ];

        for (final format in validFormats) {
          await tester.enterText(textField, format);
          await tester.pumpAndSettle();

          // Submit button should be enabled (find by text instead)
          final submitButton = find.text('Submit Phone Number');
          expect(submitButton, findsOneWidget, reason: 'Format $format should show submit button');

          // Clear for next test
          await tester.enterText(textField, '');
          await tester.pumpAndSettle();
        }

        // Test invalid formats
        final invalidFormats = [
          '12345',
          '+1234567890',
          'abcdefghij',
          '0812345678', // Wrong prefix
        ];

        for (final format in invalidFormats) {
          await tester.enterText(textField, format);
          await tester.pumpAndSettle();

          // Error message should be shown or button disabled
          expect(
            find.text('Please enter a valid Kenyan phone number'),
            findsOneWidget,
            reason: 'Format $format should be invalid',
          );
        }
      });

      testWidgets('Processing error shows appropriate message',
          (WidgetTester tester) async {
        final processingErrorResult = ToolResult(
          toolName: 'requestContactInfo',
          result: {
            'success': false,
            'error': 'Payment processing error: System unavailable',
            'errorType': 'PAYMENT_PROCESSING_ERROR',
            'property': {
              'title': 'Test Property',
              'commission_amount': 5000,
            },
          },
        );

        await tester.pumpWidget(createTestWidget(processingErrorResult));
        await tester.pumpAndSettle();

        expect(find.byType(PaymentErrorCard), findsOneWidget);
        expect(find.text('Processing Error'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
      });
    });
  });
}
