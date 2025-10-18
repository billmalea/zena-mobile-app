import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/widgets/chat/tool_result_widget.dart';

void main() {
  group('ToolResultWidget - Payment Error Integration', () {
    testWidgets('routes payment_error stage to PaymentErrorCard', (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'stage': 'payment_error',
          'error': 'Payment was cancelled',
          'errorType': 'PAYMENT_CANCELLED',
          'property': {
            'title': 'Test Property',
            'commission': 500,
          },
        },
      );

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

      // Verify PaymentErrorCard is rendered
      expect(find.text('Payment Cancelled'), findsOneWidget);
      expect(find.text('Test Property'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('handles payment timeout error', (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'stage': 'payment_error',
          'error': 'Request timed out',
          'errorType': 'PAYMENT_TIMEOUT',
          'property': {
            'title': '2BR Apartment',
            'commission': 1000,
          },
          'paymentInfo': {
            'phoneNumber': '+254712345678',
          },
        },
      );

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

      // Verify timeout error is displayed
      expect(find.text('Payment Timeout'), findsOneWidget);
      expect(find.text('+254712345678'), findsOneWidget);
      expect(find.byIcon(Icons.access_time_outlined), findsOneWidget);
    });

    testWidgets('handles payment failed error with transaction info', (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'stage': 'payment_error',
          'error': 'Insufficient funds',
          'errorType': 'PAYMENT_FAILED',
          'property': {
            'title': 'Studio Apartment',
            'commission': 750,
          },
          'paymentInfo': {
            'phoneNumber': '+254700000000',
            'transactionId': 'TXN987654',
            'amount': 750,
          },
        },
      );

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

      // Verify failed error with transaction details
      expect(find.text('Payment Failed'), findsOneWidget);
      expect(find.text('TXN987654'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('retry button triggers onSendMessage callback', (WidgetTester tester) async {
      String? sentMessage;

      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'stage': 'payment_error',
          'error': 'Payment failed',
          'errorType': 'PAYMENT_FAILED',
          'property': {
            'title': 'Test Property',
            'commission': 500,
          },
        },
      );

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

      // Tap the Try Again button
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      // Verify callback was triggered
      expect(sentMessage, 'Try again');
    });

    testWidgets('handles processing error type', (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'stage': 'payment_error',
          'error': 'System error occurred',
          'errorType': 'PAYMENT_PROCESSING_ERROR',
          'property': {
            'title': 'Luxury Villa',
            'commission': 2000,
          },
        },
      );

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

      // Verify processing error is displayed
      expect(find.text('Processing Error'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('handles error without errorType', (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'requestContactInfo',
        result: {
          'stage': 'payment_error',
          'error': 'Unknown error occurred',
          'property': {
            'title': 'Test Property',
            'commission': 500,
          },
        },
      );

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

      // Verify default error handling
      expect(find.text('Payment Error'), findsOneWidget);
      expect(find.text('Unknown error occurred'), findsOneWidget);
    });
  });
}
