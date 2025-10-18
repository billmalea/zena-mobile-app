import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/contact_info_card.dart';

void main() {
  group('ContactInfoCard', () {
    testWidgets('displays success message with checkmark icon',
        (WidgetTester tester) async {
      // Arrange
      final contactInfo = {
        'name': 'John Doe',
        'phone': '+254712345678',
        'propertyTitle': '2BR Apartment in Westlands',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactInfoCard(
              contactInfo: contactInfo,
              message: 'Payment successful!',
              alreadyPaid: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Payment Successful!'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('displays property title and details',
        (WidgetTester tester) async {
      // Arrange
      final contactInfo = {
        'name': 'Jane Smith',
        'phone': '+254723456789',
        'propertyTitle': '3BR House in Karen',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactInfoCard(
              contactInfo: contactInfo,
              message: 'Here is the contact info',
              alreadyPaid: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('3BR House in Karen'), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('displays agent/owner name and phone number',
        (WidgetTester tester) async {
      // Arrange
      final contactInfo = {
        'name': 'Agent Mike',
        'phone': '+254734567890',
        'propertyTitle': 'Studio in CBD',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactInfoCard(
              contactInfo: contactInfo,
              message: 'Contact details',
              alreadyPaid: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Agent Mike'), findsOneWidget);
      expect(find.text('+254734567890'), findsOneWidget);
      expect(find.text('Contact Information'), findsOneWidget);
    });

    testWidgets('displays Call and WhatsApp buttons',
        (WidgetTester tester) async {
      // Arrange
      final contactInfo = {
        'name': 'Owner Sarah',
        'phone': '+254745678901',
        'propertyTitle': 'Bedsitter in Ngong Road',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactInfoCard(
              contactInfo: contactInfo,
              message: 'Contact info',
              alreadyPaid: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsWidgets);
      expect(find.byIcon(Icons.chat), findsOneWidget);
    });

    testWidgets('displays payment receipt information when provided',
        (WidgetTester tester) async {
      // Arrange
      final contactInfo = {
        'name': 'Property Owner',
        'phone': '+254756789012',
        'propertyTitle': '1BR Apartment',
      };
      final paymentInfo = {
        'amount': 500,
        'receiptNumber': 'REC123456',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactInfoCard(
              contactInfo: contactInfo,
              paymentInfo: paymentInfo,
              message: 'Payment successful',
              alreadyPaid: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Payment Receipt'), findsOneWidget);
      expect(find.text('Amount Paid:'), findsOneWidget);
      expect(find.text('KES 500'), findsOneWidget);
      expect(find.text('Receipt:'), findsOneWidget);
      expect(find.text('REC123456'), findsOneWidget);
    });

    testWidgets('displays video link button when available',
        (WidgetTester tester) async {
      // Arrange
      final contactInfo = {
        'name': 'Agent Tom',
        'phone': '+254767890123',
        'propertyTitle': '2BR Apartment',
        'videoLink': 'https://example.com/video',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactInfoCard(
              contactInfo: contactInfo,
              message: 'Contact info',
              alreadyPaid: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Watch Property Video'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    });

    testWidgets('displays email when provided', (WidgetTester tester) async {
      // Arrange
      final contactInfo = {
        'name': 'Agent Lisa',
        'phone': '+254778901234',
        'email': 'lisa@example.com',
        'propertyTitle': '3BR Villa',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactInfoCard(
              contactInfo: contactInfo,
              message: 'Contact details',
              alreadyPaid: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('lisa@example.com'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('shows "Contact Info Retrieved" when already paid',
        (WidgetTester tester) async {
      // Arrange
      final contactInfo = {
        'name': 'Owner Bob',
        'phone': '+254789012345',
        'propertyTitle': 'Studio Apartment',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactInfoCard(
              contactInfo: contactInfo,
              message: 'Retrieved from history',
              alreadyPaid: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Contact Info Retrieved'), findsOneWidget);
      expect(find.text('Payment Receipt'), findsNothing);
    });

    testWidgets('handles missing optional fields gracefully',
        (WidgetTester tester) async {
      // Arrange
      final contactInfo = {
        'phone': '+254790123456',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactInfoCard(
              contactInfo: contactInfo,
              message: 'Minimal contact info',
              alreadyPaid: false,
            ),
          ),
        ),
      );

      // Assert - Should use default values
      expect(find.text('Property Owner'), findsOneWidget);
      expect(find.text('Property'), findsOneWidget);
      expect(find.text('+254790123456'), findsOneWidget);
    });

    testWidgets('handles empty phone number gracefully',
        (WidgetTester tester) async {
      // Arrange
      final contactInfo = {
        'name': 'Agent Without Phone',
        'propertyTitle': 'Test Property',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactInfoCard(
              contactInfo: contactInfo,
              message: 'Contact info',
              alreadyPaid: false,
            ),
          ),
        ),
      );

      // Assert - Should not show phone buttons
      expect(find.text('Call'), findsNothing);
      expect(find.text('WhatsApp'), findsNothing);
    });
  });
}
