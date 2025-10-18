import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/payment_error_card.dart';

void main() {
  group('PaymentErrorCard', () {
    testWidgets('displays PAYMENT_CANCELLED error correctly', (WidgetTester tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentErrorCard(
              error: 'Payment was cancelled by user',
              errorType: 'PAYMENT_CANCELLED',
              property: {
                'title': 'Test Property',
                'commission': 500,
              },
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      // Verify error title
      expect(find.text('Payment Cancelled'), findsOneWidget);
      
      // Verify property title is displayed
      expect(find.text('Test Property'), findsOneWidget);
      
      // Verify commission amount is displayed
      expect(find.text('KES 500'), findsOneWidget);
      
      // Verify Try Again button exists
      expect(find.text('Try Again'), findsOneWidget);
      
      // Verify cancel icon is displayed
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);

      // Test retry button
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      expect(retryPressed, true);
    });

    testWidgets('displays PAYMENT_TIMEOUT error correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentErrorCard(
              error: 'Payment request timed out',
              errorType: 'PAYMENT_TIMEOUT',
              property: {
                'title': '2BR Apartment',
                'commission': 1000,
              },
              onRetry: () {},
            ),
          ),
        ),
      );

      // Verify error title
      expect(find.text('Payment Timeout'), findsOneWidget);
      
      // Verify timeout icon is displayed
      expect(find.byIcon(Icons.access_time_outlined), findsOneWidget);
      
      // Verify help tip is displayed
      expect(find.textContaining('complete the M-Pesa prompt within 60 seconds'), findsOneWidget);
    });

    testWidgets('displays PAYMENT_FAILED error correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentErrorCard(
              error: 'Insufficient funds',
              errorType: 'PAYMENT_FAILED',
              property: {
                'title': 'Studio Apartment',
                'commission': 750,
              },
              paymentInfo: {
                'phoneNumber': '+254712345678',
                'transactionId': 'TXN123456',
              },
              onRetry: () {},
            ),
          ),
        ),
      );

      // Verify error title
      expect(find.text('Payment Failed'), findsOneWidget);
      
      // Verify error icon is displayed
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      
      // Verify payment info is displayed
      expect(find.text('+254712345678'), findsOneWidget);
      expect(find.text('TXN123456'), findsOneWidget);
      
      // Verify help tip is displayed
      expect(find.textContaining('sufficient M-Pesa balance'), findsOneWidget);
    });

    testWidgets('displays PAYMENT_PROCESSING_ERROR correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentErrorCard(
              error: 'System error occurred',
              errorType: 'PAYMENT_PROCESSING_ERROR',
              property: {
                'title': 'Luxury Villa',
                'commission': 2000,
              },
              onRetry: () {},
            ),
          ),
        ),
      );

      // Verify error title
      expect(find.text('Processing Error'), findsOneWidget);
      
      // Verify warning icon is displayed
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('displays unknown error type with default styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentErrorCard(
              error: 'Unknown error',
              errorType: 'UNKNOWN_ERROR',
              property: {
                'title': 'Test Property',
                'commission': 500,
              },
              onRetry: () {},
            ),
          ),
        ),
      );

      // Verify default error title
      expect(find.text('Payment Error'), findsOneWidget);
      
      // Verify default error icon is displayed
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays error without errorType', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentErrorCard(
              error: 'Custom error message',
              property: {
                'title': 'Test Property',
                'commission': 500,
              },
              onRetry: () {},
            ),
          ),
        ),
      );

      // Verify custom error message is displayed
      expect(find.text('Custom error message'), findsOneWidget);
      
      // Verify default error title
      expect(find.text('Payment Error'), findsOneWidget);
    });

    testWidgets('handles missing payment info gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentErrorCard(
              error: 'Payment failed',
              errorType: 'PAYMENT_FAILED',
              property: {
                'title': 'Test Property',
                'commission': 500,
              },
              onRetry: () {},
            ),
          ),
        ),
      );

      // Should render without crashing
      expect(find.byType(PaymentErrorCard), findsOneWidget);
    });

    testWidgets('extracts commission from paymentInfo if not in property', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentErrorCard(
              error: 'Payment failed',
              errorType: 'PAYMENT_FAILED',
              property: {
                'title': 'Test Property',
              },
              paymentInfo: {
                'amount': 1500,
              },
              onRetry: () {},
            ),
          ),
        ),
      );

      // Verify commission from paymentInfo is displayed
      expect(find.text('KES 1500'), findsOneWidget);
    });
  });
}
