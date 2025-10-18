import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/widgets/chat/tool_result_widget.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/property_hunting_card.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/commission_card.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/neighborhood_info_card.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/affordability_card.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/auth_prompt_card.dart';

void main() {
  group('ToolResultWidget Routing Tests', () {
    testWidgets('Routes property hunting tool to PropertyHuntingCard',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'adminPropertyHunting',
        result: {
          'requestId': 'test-123',
          'status': 'active',
          'searchCriteria': {
            'location': 'Westlands',
            'minRent': 30000,
            'maxRent': 50000,
          },
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ToolResultWidget(
                toolResult: toolResult,
                onSendMessage: (msg) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PropertyHuntingCard), findsOneWidget);
      expect(find.text('Property Hunting Request'), findsOneWidget);
    });

    testWidgets('Routes commission tool to CommissionCard',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'getCommissionStatus',
        result: {
          'amount': 5000.0,
          'propertyReference': 'Test Property',
          'dateEarned': DateTime.now().toIso8601String(),
          'status': 'paid',
          'totalEarnings': 15000.0,
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ToolResultWidget(
                toolResult: toolResult,
                onSendMessage: (msg) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CommissionCard), findsOneWidget);
      expect(find.text('Commission Earned'), findsOneWidget);
    });

    testWidgets('Routes neighborhood info tool to NeighborhoodInfoCard',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'getNeighborhoodInfo',
        result: {
          'name': 'Westlands',
          'description': 'A vibrant neighborhood',
          'keyFeatures': ['Shopping malls', 'Restaurants', 'Good transport'],
          'safetyRating': 4.5,
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ToolResultWidget(
                toolResult: toolResult,
                onSendMessage: (msg) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(NeighborhoodInfoCard), findsOneWidget);
      expect(find.text('Westlands'), findsOneWidget);
    });

    testWidgets('Routes affordability tool to AffordabilityCard',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'calculateAffordability',
        result: {
          'monthlyIncome': 100000.0,
          'recommendedRange': {
            'min': 25000.0,
            'max': 30000.0,
          },
          'affordabilityPercentage': 30.0,
          'budgetBreakdown': {
            'Rent': 30000.0,
            'Food': 20000.0,
            'Transport': 10000.0,
          },
          'tips': ['Save at least 20% of your income'],
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ToolResultWidget(
                toolResult: toolResult,
                onSendMessage: (msg) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AffordabilityCard), findsOneWidget);
      expect(find.text('Rent Affordability'), findsOneWidget);
    });

    testWidgets('Routes auth prompt tool to AuthPromptCard',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'requiresAuth',
        result: {
          'message': 'Please sign in to access this feature',
          'allowGuest': false,
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ToolResultWidget(
                toolResult: toolResult,
                onSendMessage: (msg) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AuthPromptCard), findsOneWidget);
      expect(find.text('Authentication Required'), findsOneWidget);
    });

    testWidgets('Routes unknown tool to fallback card',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'unknownTool',
        result: {
          'data': 'some data',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ToolResultWidget(
                toolResult: toolResult,
                onSendMessage: (msg) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Unknown Tool Result'), findsOneWidget);
      expect(find.text('Tool: unknownTool'), findsOneWidget);
    });

    testWidgets('Handles empty tool result gracefully',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'emptyTool',
        result: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ToolResultWidget(
                toolResult: toolResult,
                onSendMessage: (msg) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Empty Result'), findsOneWidget);
    });

    testWidgets('Passes onSendMessage callback correctly',
        (WidgetTester tester) async {
      String? sentMessage;
      final toolResult = ToolResult(
        toolName: 'requiresAuth',
        result: {
          'message': 'Test message',
          'allowGuest': false,
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ToolResultWidget(
                toolResult: toolResult,
                onSendMessage: (msg) {
                  sentMessage = msg;
                },
              ),
            ),
          ),
        ),
      );

      // Find and tap the sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(sentMessage, equals('Sign in'));
    });

    testWidgets('Routes propertyHuntingStatus to PropertyHuntingCard',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'propertyHuntingStatus',
        result: {
          'id': 'status-456',
          'status': 'completed',
          'criteria': {
            'location': 'Kilimani',
          },
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ToolResultWidget(
                toolResult: toolResult,
                onSendMessage: (msg) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PropertyHuntingCard), findsOneWidget);
    });

    testWidgets('Routes confirmRentalSuccess to CommissionCard',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'confirmRentalSuccess',
        result: {
          'commission': 3000.0,
          'property': 'Apartment in Westlands',
          'date': DateTime.now().toIso8601String(),
          'status': 'pending',
          'total': 3000.0,
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ToolResultWidget(
                toolResult: toolResult,
                onSendMessage: (msg) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CommissionCard), findsOneWidget);
    });
  });
}
