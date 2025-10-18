import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/final_review_card.dart';

void main() {
  group('FinalReviewCard', () {
    late Map<String, dynamic> samplePropertyData;
    late bool confirmCalled;
    late bool editCalled;

    setUp(() {
      confirmCalled = false;
      editCalled = false;

      samplePropertyData = {
        'title': '2BR Modern Apartment in Westlands',
        'description':
            'Beautiful 2-bedroom apartment with modern amenities, located in the heart of Westlands. Perfect for professionals and small families.',
        'propertyType': 'Apartment',
        'bedrooms': 2,
        'bathrooms': 2,
        'rentAmount': 50000,
        'commissionAmount': 5000,
        'location': 'Westlands, Nairobi',
        'address': '123 Westlands Road',
        'neighborhood': 'Westlands',
        'amenities': ['WiFi', 'Parking', 'Security', 'Gym'],
        'features': ['Balcony', 'Modern Kitchen', 'Spacious Living Room'],
        'squareFootage': 1200,
        'furnished': true,
        'petsAllowed': false,
        'parkingSpaces': 1,
      };
    });

    Widget createTestWidget(Map<String, dynamic> propertyData) {
      return MaterialApp(
        home: Scaffold(
          body: FinalReviewCard(
            propertyData: propertyData,
            onConfirm: () {
              confirmCalled = true;
            },
            onEdit: () {
              editCalled = true;
            },
          ),
        ),
      );
    }

    testWidgets('displays complete property summary', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Verify title is displayed
      expect(find.text('2BR Modern Apartment in Westlands'), findsOneWidget);

      // Verify description is displayed
      expect(
        find.textContaining('Beautiful 2-bedroom apartment'),
        findsOneWidget,
      );

      // Verify basic information
      expect(find.text('Apartment'), findsOneWidget);
      expect(find.text('2'), findsWidgets); // bedrooms and bathrooms

      // Verify financial information
      expect(find.textContaining('KSh 50,000'), findsOneWidget);
      expect(find.textContaining('KSh 5,000'), findsOneWidget);

      // Verify location
      expect(find.text('Westlands, Nairobi'), findsOneWidget);
      expect(find.text('123 Westlands Road'), findsOneWidget);
    });

    testWidgets('displays amenities as chips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Verify amenities are displayed
      expect(find.text('WiFi'), findsOneWidget);
      expect(find.text('Parking'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Gym'), findsOneWidget);
    });

    testWidgets('displays features as chips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Verify features are displayed
      expect(find.text('Balcony'), findsOneWidget);
      expect(find.text('Modern Kitchen'), findsOneWidget);
      expect(find.text('Spacious Living Room'), findsOneWidget);
    });

    testWidgets('displays terms and conditions checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Verify checkbox is present and unchecked
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);
      expect(tester.widget<Checkbox>(checkbox).value, false);

      // Verify terms text is displayed
      expect(
        find.textContaining('I confirm that all information provided is accurate'),
        findsOneWidget,
      );
    });

    testWidgets('confirm button is disabled when terms not accepted',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Scroll to the bottom to find the button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Find the confirm button by text
      expect(find.text('Confirm and List'), findsOneWidget);
      
      // Try to tap it - should not trigger callback since it's disabled
      await tester.tap(find.text('Confirm and List'));
      await tester.pumpAndSettle();
      
      // Verify callback was NOT called
      expect(confirmCalled, false);
    });

    testWidgets('confirm button is enabled when terms accepted',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Scroll to the bottom to find the checkbox
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Tap the checkbox to accept terms
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Find the confirm button by text
      expect(find.text('Confirm and List'), findsOneWidget);
      
      // Tap it - should trigger callback since it's enabled
      await tester.tap(find.text('Confirm and List'));
      await tester.pumpAndSettle();
      
      // Verify callback was called
      expect(confirmCalled, true);
    });

    testWidgets('calls onConfirm when confirm button tapped with terms accepted',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Scroll to the bottom
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Accept terms
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Tap confirm button by finding the text
      await tester.tap(find.text('Confirm and List'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(confirmCalled, true);
    });

    testWidgets('calls onEdit when edit button tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Scroll to the bottom to find the button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Tap edit button by finding the text
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(editCalled, true);
    });

    testWidgets('displays helper text when terms not accepted',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Scroll to the bottom to find the helper text
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Verify helper text is displayed
      expect(
        find.text('Please accept the terms and conditions to proceed'),
        findsOneWidget,
      );
    });

    testWidgets('hides helper text when terms accepted', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Scroll to the bottom
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Accept terms
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Verify helper text is not displayed
      expect(
        find.text('Please accept the terms and conditions to proceed'),
        findsNothing,
      );
    });

    testWidgets('handles missing optional fields gracefully',
        (WidgetTester tester) async {
      final minimalData = {
        'title': 'Simple Property',
        'description': 'A simple property listing',
        'propertyType': 'House',
        'bedrooms': 1,
        'bathrooms': 1,
        'rentAmount': 20000,
        'location': 'Nairobi',
      };

      await tester.pumpWidget(createTestWidget(minimalData));

      // Verify required fields are displayed
      expect(find.text('Simple Property'), findsOneWidget);
      expect(find.text('A simple property listing'), findsOneWidget);
      expect(find.text('House'), findsOneWidget);

      // Verify card renders without errors
      expect(find.byType(FinalReviewCard), findsOneWidget);
    });

    testWidgets('displays furnished status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Verify furnished is displayed as Yes
      expect(find.text('Yes'), findsWidgets);

      // Test with unfurnished property
      final unfurnishedData = Map<String, dynamic>.from(samplePropertyData);
      unfurnishedData['furnished'] = false;

      await tester.pumpWidget(createTestWidget(unfurnishedData));
      await tester.pumpAndSettle();

      // Verify furnished is displayed as No
      expect(find.text('No'), findsWidgets);
    });

    testWidgets('displays pets allowed status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Verify pets allowed is displayed as No
      expect(find.text('No'), findsWidgets);

      // Test with pets allowed property
      final petsAllowedData = Map<String, dynamic>.from(samplePropertyData);
      petsAllowedData['petsAllowed'] = true;

      await tester.pumpWidget(createTestWidget(petsAllowedData));
      await tester.pumpAndSettle();

      // Verify pets allowed is displayed as Yes
      expect(find.text('Yes'), findsWidgets);
    });

    testWidgets('formats currency correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Verify currency formatting with commas
      expect(find.textContaining('KSh 50,000'), findsOneWidget);
      expect(find.textContaining('KSh 5,000'), findsOneWidget);
    });

    testWidgets('displays section headers with icons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Verify section headers are present
      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Financial Information'), findsOneWidget);
      // Location appears both as section header and field label, so expect at least one
      expect(find.text('Location'), findsAtLeastNWidgets(1));
      expect(find.text('Amenities'), findsOneWidget);
      expect(find.text('Features'), findsOneWidget);
    });

    testWidgets('displays parking spaces when available', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Verify parking spaces is displayed
      expect(find.text('Parking Spaces'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('hides parking spaces when zero', (WidgetTester tester) async {
      final noParkingData = Map<String, dynamic>.from(samplePropertyData);
      noParkingData['parkingSpaces'] = 0;

      await tester.pumpWidget(createTestWidget(noParkingData));

      // Verify parking spaces is not displayed
      expect(find.text('Parking Spaces'), findsNothing);
    });

    testWidgets('displays square footage when available', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Verify square footage is displayed
      expect(find.text('Square Footage'), findsOneWidget);
      expect(find.textContaining('1200 sq ft'), findsOneWidget);
    });

    testWidgets('handles empty amenities list', (WidgetTester tester) async {
      final noAmenitiesData = Map<String, dynamic>.from(samplePropertyData);
      noAmenitiesData['amenities'] = [];

      await tester.pumpWidget(createTestWidget(noAmenitiesData));

      // Verify amenities section is not displayed
      expect(find.text('Amenities'), findsNothing);
    });

    testWidgets('handles empty features list', (WidgetTester tester) async {
      final noFeaturesData = Map<String, dynamic>.from(samplePropertyData);
      noFeaturesData['features'] = [];

      await tester.pumpWidget(createTestWidget(noFeaturesData));

      // Verify features section is not displayed
      expect(find.text('Features'), findsNothing);
    });

    testWidgets('displays neighborhood when different from location',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Verify neighborhood is displayed
      expect(find.text('Neighborhood'), findsOneWidget);
      expect(find.text('Westlands'), findsWidgets);
    });

    testWidgets('checkbox toggles state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Scroll to the bottom to find the checkbox
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Initial state - unchecked
      Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, false);

      // Tap to check
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, true);

      // Tap to uncheck
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('displays final review header with icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(samplePropertyData));

      // Verify header is displayed
      expect(find.text('Final Review'), findsOneWidget);
      expect(find.text('Review before listing'), findsOneWidget);

      // Verify icon is present
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('handles snake_case property keys', (WidgetTester tester) async {
      final snakeCaseData = {
        'title': 'Test Property',
        'description': 'Test description',
        'property_type': 'Apartment',
        'bedrooms': 2,
        'bathrooms': 1,
        'rent_amount': 30000,
        'commission_amount': 3000,
        'location': 'Test Location',
        'square_footage': 800,
        'pets_allowed': true,
        'parking_spaces': 2,
      };

      await tester.pumpWidget(createTestWidget(snakeCaseData));

      // Verify data is displayed correctly
      expect(find.text('Test Property'), findsOneWidget);
      expect(find.text('Apartment'), findsOneWidget);
      expect(find.textContaining('KSh 30,000'), findsOneWidget);
      expect(find.textContaining('800 sq ft'), findsOneWidget);
    });
  });
}
