import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/widgets/chat/tool_result_widget.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/phone_confirmation_card.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/phone_input_card.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/contact_info_card.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/payment_error_card.dart';

void main() {
  group('ToolResultWidget - Contact Info Flow', () {
    testWidgets('routes to PhoneConfirmationCard when needsPhoneConfirmation is true',
        (WidgetTester tester) async {
      // Arrange
      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'needsPhoneConfirmation': true,
          'userPhoneFromProfile': '+254712345678',
          'message': 'Confirm your phone number',
          'property': {
            'title': 'Test Property',
            'commission_amount': 500,
          },
        },
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (message) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(PhoneConfirmationCard), findsOneWidget);
      expect(find.text('+254712345678'), findsOneWidget);
      expect(find.text('Yes, use this number'), findsOneWidget);
    });

    testWidgets('routes to PhoneInputCard when needsPhoneNumber is true',
        (WidgetTester tester) async {
      // Arrange
      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'needsPhoneNumber': true,
          'message': 'Please provide your phone number',
          'property': {
            'title': 'Test Property',
            'commission_amount': 500,
          },
        },
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (message) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(PhoneInputCard), findsOneWidget);
      expect(find.text('Enter Phone Number'), findsOneWidget);
    });

    testWidgets('routes to ContactInfoCard when success is true and contactInfo exists',
        (WidgetTester tester) async {
      // Arrange
      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'success': true,
          'contactInfo': {
            'name': 'John Doe',
            'phone': '+254712345678',
            'propertyTitle': 'Test Property',
          },
          'message': 'Payment successful!',
          'paymentInfo': {
            'amount': 500,
            'receiptNumber': 'REC123',
          },
        },
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (message) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ContactInfoCard), findsOneWidget);
      expect(find.text('Payment Successful!'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('routes to PaymentErrorCard when success is false and error exists',
        (WidgetTester tester) async {
      // Arrange
      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'success': false,
          'error': 'Payment was cancelled',
          'errorType': 'PAYMENT_CANCELLED',
          'property': {
            'title': 'Test Property',
            'commission_amount': 500,
          },
        },
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (message) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(PaymentErrorCard), findsOneWidget);
      expect(find.text('Payment Cancelled'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('sends correct message when phone confirmation is confirmed',
        (WidgetTester tester) async {
      // Arrange
      String? sentMessage;
      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'needsPhoneConfirmation': true,
          'userPhoneFromProfile': '+254712345678',
          'message': 'Confirm your phone number',
          'property': {
            'title': 'Test Property',
            'commission_amount': 500,
          },
        },
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (message) {
                sentMessage = message;
              },
            ),
          ),
        ),
      );

      // Tap confirm button
      await tester.tap(find.text('Yes, use this number'));
      await tester.pump();

      // Assert
      expect(sentMessage, contains('+254712345678'));
      expect(sentMessage, contains('Yes'));
    });

    testWidgets('sends correct message when phone confirmation is declined',
        (WidgetTester tester) async {
      // Arrange
      String? sentMessage;
      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'needsPhoneConfirmation': true,
          'userPhoneFromProfile': '+254712345678',
          'message': 'Confirm your phone number',
          'property': {
            'title': 'Test Property',
            'commission_amount': 500,
          },
        },
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (message) {
                sentMessage = message;
              },
            ),
          ),
        ),
      );

      // Tap decline button
      await tester.tap(find.text('No, use different number'));
      await tester.pump();

      // Assert
      expect(sentMessage, contains('different phone number'));
    });

    testWidgets('sends correct message when phone number is submitted',
        (WidgetTester tester) async {
      // Arrange
      String? sentMessage;
      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'needsPhoneNumber': true,
          'message': 'Please provide your phone number',
          'property': {
            'title': 'Test Property',
            'commission_amount': 500,
          },
        },
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (message) {
                sentMessage = message;
              },
            ),
          ),
        ),
      );

      // Enter phone number
      await tester.enterText(find.byType(TextField), '0712345678');
      await tester.pump();

      // Tap submit button
      await tester.tap(find.text('Submit Phone Number'));
      await tester.pump();

      // Assert
      expect(sentMessage, contains('My phone number is'));
      expect(sentMessage, contains('+254712345678'));
    });

    testWidgets('sends correct message when payment retry is tapped',
        (WidgetTester tester) async {
      // Arrange
      String? sentMessage;
      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'success': false,
          'error': 'Payment failed',
          'errorType': 'PAYMENT_FAILED',
          'property': {
            'title': 'Test Property',
            'commission_amount': 500,
          },
        },
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (message) {
                sentMessage = message;
              },
            ),
          ),
        ),
      );

      // Tap retry button
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      // Assert
      expect(sentMessage, 'Try again');
    });
  });
}
