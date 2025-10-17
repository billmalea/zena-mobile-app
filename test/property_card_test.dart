import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/property_card.dart';

void main() {
  group('PropertyCard Enhanced Features', () {
    testWidgets('renders property card with all details', (WidgetTester tester) async {
      final propertyData = {
        'id': '1',
        'title': '2BR Apartment in Westlands',
        'description': 'Beautiful apartment with modern amenities',
        'location': 'Westlands, Nairobi',
        'rentAmount': 50000,
        'commissionAmount': 5000,
        'bedrooms': 2,
        'bathrooms': 2,
        'propertyType': 'Apartment',
        'amenities': ['WiFi', 'Parking', 'Security', 'Gym'],
        'images': [
          'https://example.com/image1.jpg',
          'https://example.com/image2.jpg',
        ],
        'videos': [],
        'available': true,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertyCard(propertyData: propertyData),
            ),
          ),
        ),
      );

      // Verify title is displayed
      expect(find.text('2BR Apartment in Westlands'), findsOneWidget);
      
      // Verify location is displayed
      expect(find.text('Westlands, Nairobi'), findsOneWidget);
      
      // Verify price is displayed with KES formatting
      expect(find.text('KSh 50,000'), findsOneWidget);
      expect(find.text('per month'), findsOneWidget);
      
      // Verify bedrooms and bathrooms are displayed
      expect(find.text('2'), findsNWidgets(2)); // 2 bedrooms and 2 bathrooms
      
      // Verify property type is displayed
      expect(find.text('Apartment'), findsOneWidget);
      
      // Verify amenities are displayed
      expect(find.text('WiFi'), findsOneWidget);
      expect(find.text('Parking'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Gym'), findsOneWidget);
      
      // Verify Request Contact button is displayed
      expect(find.text('Request Contact Info'), findsOneWidget);
    });

    testWidgets('displays availability badge correctly', (WidgetTester tester) async {
      final propertyData = {
        'id': '2',
        'title': 'Studio in Kilimani',
        'location': 'Kilimani, Nairobi',
        'rentAmount': 30000,
        'commissionAmount': 3000,
        'bedrooms': 1,
        'bathrooms': 1,
        'propertyType': 'Studio',
        'amenities': [],
        'images': ['https://example.com/image.jpg'],
        'videos': [],
        'available': true,
        'status': 'available',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertyCard(propertyData: propertyData),
            ),
          ),
        ),
      );

      // Verify availability badge is displayed
      expect(find.text('Available'), findsOneWidget);
    });

    testWidgets('handles property with no amenities', (WidgetTester tester) async {
      final propertyData = {
        'id': '3',
        'title': 'Basic Room',
        'location': 'Ngara, Nairobi',
        'rentAmount': 15000,
        'commissionAmount': 1500,
        'bedrooms': 1,
        'bathrooms': 1,
        'propertyType': 'Room',
        'amenities': [],
        'images': ['https://example.com/image.jpg'],
        'videos': [],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertyCard(propertyData: propertyData),
            ),
          ),
        ),
      );

      // Verify card renders without amenities section
      expect(find.text('Basic Room'), findsOneWidget);
      expect(find.text('KSh 15,000'), findsOneWidget);
    });

    testWidgets('calls onRequestContact callback when button is pressed', (WidgetTester tester) async {
      String? sentMessage;
      
      final propertyData = {
        'id': '4',
        'title': 'Test Property',
        'location': 'Test Location',
        'rentAmount': 40000,
        'commissionAmount': 4000,
        'bedrooms': 2,
        'bathrooms': 1,
        'propertyType': 'Apartment',
        'amenities': [],
        'images': ['https://example.com/image.jpg'],
        'videos': [],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertyCard(
                propertyData: propertyData,
                onRequestContact: (message) {
                  sentMessage = message;
                },
              ),
            ),
          ),
        ),
      );

      // Tap the Request Contact button
      await tester.tap(find.text('Request Contact Info'));
      await tester.pump();

      // Verify callback was called with correct message
      expect(sentMessage, contains('Test Property'));
      expect(sentMessage, contains('request contact info'));
    });

    testWidgets('displays multiple images with carousel indicators', (WidgetTester tester) async {
      final propertyData = {
        'id': '5',
        'title': 'Property with Multiple Images',
        'location': 'Nairobi',
        'rentAmount': 60000,
        'commissionAmount': 6000,
        'bedrooms': 3,
        'bathrooms': 2,
        'propertyType': 'House',
        'amenities': [],
        'images': [
          'https://example.com/image1.jpg',
          'https://example.com/image2.jpg',
          'https://example.com/image3.jpg',
        ],
        'videos': [],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertyCard(propertyData: propertyData),
            ),
          ),
        ),
      );

      // Verify PageView is present for carousel
      expect(find.byType(PageView), findsOneWidget);
      
      // Verify carousel indicators are present (3 dots for 3 images)
      final containers = tester.widgetList<Container>(find.byType(Container));
      final indicatorContainers = containers.where((container) {
        final decoration = container.decoration;
        if (decoration is BoxDecoration) {
          return decoration.shape == BoxShape.circle;
        }
        return false;
      });
      expect(indicatorContainers.length, 3);
    });

    testWidgets('handles property with no images', (WidgetTester tester) async {
      final propertyData = {
        'id': '6',
        'title': 'Property without Images',
        'location': 'Nairobi',
        'rentAmount': 25000,
        'commissionAmount': 2500,
        'bedrooms': 1,
        'bathrooms': 1,
        'propertyType': 'Bedsitter',
        'amenities': [],
        'images': [],
        'videos': [],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertyCard(propertyData: propertyData),
            ),
          ),
        ),
      );

      // Verify placeholder is shown
      expect(find.text('No image available'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('displays correct icons for property details', (WidgetTester tester) async {
      final propertyData = {
        'id': '7',
        'title': 'Test Icons',
        'location': 'Nairobi',
        'rentAmount': 35000,
        'commissionAmount': 3500,
        'bedrooms': 2,
        'bathrooms': 1,
        'propertyType': 'Flat',
        'amenities': [],
        'images': ['https://example.com/image.jpg'],
        'videos': [],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertyCard(propertyData: propertyData),
            ),
          ),
        ),
      );

      // Verify icons are present
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.bed_outlined), findsOneWidget);
      expect(find.byIcon(Icons.bathroom_outlined), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
    });
  });
}
