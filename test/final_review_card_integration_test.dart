import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/final_review_card.dart';

void main() {
  group('FinalReviewCard Integration Tests', () {
    testWidgets('complete review flow - accept terms and confirm',
        (WidgetTester tester) async {
      bool confirmed = false;
      bool edited = false;

      final propertyData = {
        'title': 'Luxury 3BR Penthouse in Kilimani',
        'description':
            'Stunning 3-bedroom penthouse with panoramic city views, modern finishes, and premium amenities. Located in the heart of Kilimani.',
        'propertyType': 'Penthouse',
        'bedrooms': 3,
        'bathrooms': 3,
        'rentAmount': 120000,
        'commissionAmount': 12000,
        'location': 'Kilimani, Nairobi',
        'address': '456 Kilimani Road, Nairobi',
        'neighborhood': 'Kilimani',
        'amenities': [
          'WiFi',
          'Parking',
          '24/7 Security',
          'Gym',
          'Swimming Pool',
          'Backup Generator'
        ],
        'features': [
          'Balcony',
          'Modern Kitchen',
          'Master En-suite',
          'Walk-in Closet',
          'City Views'
        ],
        'squareFootage': 2000,
        'furnished': true,
        'petsAllowed': true,
        'parkingSpaces': 2,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinalReviewCard(
              propertyData: propertyData,
              onConfirm: () {
                confirmed = true;
              },
              onEdit: () {
                edited = true;
              },
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Final Review'), findsOneWidget);
      expect(find.text('Luxury 3BR Penthouse in Kilimani'), findsOneWidget);

      // Scroll to view all content
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify property details are displayed
      expect(find.text('Penthouse'), findsOneWidget);
      expect(find.text('3'), findsWidgets); // bedrooms and bathrooms
      expect(find.textContaining('KSh 120,000'), findsOneWidget);

      // Scroll to amenities
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify amenities
      expect(find.text('WiFi'), findsOneWidget);
      expect(find.text('Gym'), findsOneWidget);
      expect(find.text('Swimming Pool'), findsOneWidget);

      // Scroll to bottom
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      // Verify terms checkbox is present and unchecked
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);
      expect(tester.widget<Checkbox>(checkbox).value, false);

      // Verify confirm button exists but is disabled
      expect(find.text('Confirm and List'), findsOneWidget);
      expect(confirmed, false);

      // Try to confirm without accepting terms - should not work
      await tester.tap(find.text('Confirm and List'));
      await tester.pumpAndSettle();
      expect(confirmed, false);

      // Accept terms
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Verify checkbox is now checked
      expect(tester.widget<Checkbox>(checkbox).value, true);

      // Now confirm should work
      await tester.tap(find.text('Confirm and List'));
      await tester.pumpAndSettle();
      expect(confirmed, true);
    });

    testWidgets('complete review flow - edit property',
        (WidgetTester tester) async {
      bool confirmed = false;
      bool edited = false;

      final propertyData = {
        'title': 'Simple Studio Apartment',
        'description': 'Cozy studio apartment perfect for singles.',
        'propertyType': 'Studio',
        'bedrooms': 0,
        'bathrooms': 1,
        'rentAmount': 25000,
        'location': 'Ngong Road, Nairobi',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinalReviewCard(
              propertyData: propertyData,
              onConfirm: () {
                confirmed = true;
              },
              onEdit: () {
                edited = true;
              },
            ),
          ),
        ),
      );

      // Scroll to bottom
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Tap edit button
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Verify edit callback was called
      expect(edited, true);
      expect(confirmed, false);
    });

    testWidgets('displays all property information comprehensively',
        (WidgetTester tester) async {
      final completePropertyData = {
        'title': 'Complete Property Listing',
        'description': 'A property with all fields filled',
        'propertyType': 'Villa',
        'bedrooms': 5,
        'bathrooms': 4,
        'rentAmount': 250000,
        'commissionAmount': 25000,
        'location': 'Karen, Nairobi',
        'address': '789 Karen Road',
        'neighborhood': 'Karen',
        'amenities': ['WiFi', 'Parking', 'Security', 'Garden', 'Pool'],
        'features': ['Fireplace', 'Study Room', 'Guest House'],
        'squareFootage': 5000,
        'furnished': true,
        'petsAllowed': true,
        'parkingSpaces': 4,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinalReviewCard(
              propertyData: completePropertyData,
              onConfirm: () {},
              onEdit: () {},
            ),
          ),
        ),
      );

      // Verify title and description
      expect(find.text('Complete Property Listing'), findsOneWidget);
      expect(find.text('A property with all fields filled'), findsOneWidget);

      // Scroll and verify basic information
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Villa'), findsOneWidget);
      expect(find.text('5'), findsWidgets);
      expect(find.text('4'), findsWidgets);

      // Scroll and verify financial information
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.textContaining('KSh 250,000'), findsOneWidget);
      expect(find.textContaining('KSh 25,000'), findsOneWidget);

      // Scroll and verify location
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Karen, Nairobi'), findsWidgets);
      expect(find.text('789 Karen Road'), findsOneWidget);

      // Scroll and verify amenities
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Garden'), findsOneWidget);
      expect(find.text('Pool'), findsOneWidget);

      // Scroll and verify features
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Fireplace'), findsOneWidget);
      expect(find.text('Study Room'), findsOneWidget);
    });

    testWidgets('handles minimal property data gracefully',
        (WidgetTester tester) async {
      final minimalData = {
        'title': 'Basic Property',
        'description': 'Minimal information',
        'propertyType': 'Apartment',
        'bedrooms': 1,
        'bathrooms': 1,
        'rentAmount': 15000,
        'location': 'Nairobi',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinalReviewCard(
              propertyData: minimalData,
              onConfirm: () {},
              onEdit: () {},
            ),
          ),
        ),
      );

      // Verify required fields are displayed
      expect(find.text('Basic Property'), findsOneWidget);
      expect(find.text('Minimal information'), findsOneWidget);
      expect(find.text('Apartment'), findsOneWidget);
      expect(find.textContaining('KSh 15,000'), findsOneWidget);

      // Verify card renders without errors
      expect(find.byType(FinalReviewCard), findsOneWidget);

      // Scroll to bottom and verify buttons are present
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Confirm and List'), findsOneWidget);
    });

    testWidgets('checkbox state persists through scrolling',
        (WidgetTester tester) async {
      final propertyData = {
        'title': 'Test Property',
        'description': 'Test description',
        'propertyType': 'House',
        'bedrooms': 2,
        'bathrooms': 2,
        'rentAmount': 40000,
        'location': 'Nairobi',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinalReviewCard(
              propertyData: propertyData,
              onConfirm: () {},
              onEdit: () {},
            ),
          ),
        ),
      );

      // Scroll to bottom
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Check the checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, true);

      // Scroll up
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 1000));
      await tester.pumpAndSettle();

      // Scroll back down
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      // Verify checkbox is still checked
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, true);
    });

    testWidgets('displays correct boolean values for furnished and pets',
        (WidgetTester tester) async {
      final propertyData = {
        'title': 'Test Property',
        'description': 'Test',
        'propertyType': 'Apartment',
        'bedrooms': 2,
        'bathrooms': 1,
        'rentAmount': 30000,
        'location': 'Nairobi',
        'furnished': true,
        'petsAllowed': false,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinalReviewCard(
              propertyData: propertyData,
              onConfirm: () {},
              onEdit: () {},
            ),
          ),
        ),
      );

      // Scroll to find the boolean fields
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify furnished is Yes and pets allowed is No
      expect(find.text('Furnished'), findsOneWidget);
      expect(find.text('Pets Allowed'), findsOneWidget);
      expect(find.text('Yes'), findsWidgets);
      expect(find.text('No'), findsWidgets);
    });
  });
}
