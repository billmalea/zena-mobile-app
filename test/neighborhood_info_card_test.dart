import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/neighborhood_info_card.dart';

void main() {
  group('NeighborhoodInfoCard', () {
    testWidgets('renders basic neighborhood info', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeighborhoodInfoCard(
              name: 'Westlands',
              description: 'A vibrant commercial and residential area in Nairobi.',
              keyFeatures: [
                'Close to shopping malls',
                'Good public transport',
                'Safe neighborhood',
              ],
            ),
          ),
        ),
      );

      expect(find.text('Westlands'), findsOneWidget);
      expect(find.text('Neighborhood Info'), findsOneWidget);
      expect(find.textContaining('vibrant commercial'), findsOneWidget);
      expect(find.text('Close to shopping malls'), findsOneWidget);
      expect(find.text('Good public transport'), findsOneWidget);
      expect(find.text('Safe neighborhood'), findsOneWidget);
    });

    testWidgets('renders with safety rating', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeighborhoodInfoCard(
              name: 'Kilimani',
              description: 'Upscale residential area.',
              keyFeatures: ['Quiet streets'],
              safetyRating: 4.5,
            ),
          ),
        ),
      );

      expect(find.text('Safety Rating: '), findsOneWidget);
      expect(find.text('4.5/5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('renders with average rent prices', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeighborhoodInfoCard(
              name: 'Karen',
              description: 'Leafy suburb.',
              keyFeatures: ['Spacious properties'],
              averageRent: {
                'Studio': 25000.0,
                'Apartment': 45000.0,
                'House': 80000.0,
              },
            ),
          ),
        ),
      );

      expect(find.text('Average Rent Prices'), findsOneWidget);
      expect(find.text('Studio'), findsOneWidget);
      expect(find.text('Apartment'), findsOneWidget);
      expect(find.text('House'), findsOneWidget);
      expect(find.textContaining('KES 25000/mo'), findsOneWidget);
      expect(find.textContaining('KES 45000/mo'), findsOneWidget);
      expect(find.textContaining('KES 80000/mo'), findsOneWidget);
    });

    testWidgets('renders complete card with all features', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeighborhoodInfoCard(
              name: 'Lavington',
              description: 'Prestigious residential area with excellent amenities.',
              keyFeatures: [
                'International schools nearby',
                'Shopping centers',
                'Parks and recreation',
              ],
              safetyRating: 4.8,
              averageRent: {
                'Apartment': 60000.0,
                'House': 120000.0,
              },
            ),
          ),
        ),
      );

      expect(find.text('Lavington'), findsOneWidget);
      expect(find.text('4.8/5'), findsOneWidget);
      expect(find.text('International schools nearby'), findsOneWidget);
      expect(find.text('Average Rent Prices'), findsOneWidget);
    });
  });
}
