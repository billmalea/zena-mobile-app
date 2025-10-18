import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/widgets/chat/tool_result_widget.dart';

void main() {
  group('ToolResultWidget - Property Submission Integration', () {
    testWidgets('routes submitProperty tool to PropertySubmissionCard',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'submitProperty',
        result: {
          'stage': 'start',
          'submissionId': 'SUB123',
          'message': 'Upload a video of your property to get started.',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (msg) {},
            ),
          ),
        ),
      );

      // Verify PropertySubmissionCard is rendered
      expect(find.text('Upload Property Video'), findsOneWidget);
      expect(find.text('ID: SUB123'), findsOneWidget);
      expect(find.text('Step 1 of 5'), findsOneWidget);
    });

    testWidgets('routes completePropertySubmission tool to PropertySubmissionCard',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'completePropertySubmission',
        result: {
          'stage': 'final_confirm',
          'submissionId': 'SUB456',
          'message': 'Review your property listing before confirming.',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (msg) {},
            ),
          ),
        ),
      );

      // Verify PropertySubmissionCard is rendered with final stage
      expect(find.text('Final Review'), findsOneWidget);
      expect(find.text('ID: SUB456'), findsOneWidget);
      expect(find.text('Step 5 of 5'), findsOneWidget);
      expect(find.text('Confirm & List'), findsOneWidget);
    });

    testWidgets('handles all submission stages correctly',
        (WidgetTester tester) async {
      final stages = [
        ('start', 'Upload Property Video', 'Step 1 of 5'),
        ('video_uploaded', 'Analyzing Video', 'Step 2 of 5'),
        ('confirm_data', 'Review Property Data', 'Step 3 of 5'),
        ('provide_info', 'Complete Missing Information', 'Step 4 of 5'),
        ('final_confirm', 'Final Review', 'Step 5 of 5'),
      ];

      for (final (stage, expectedTitle, expectedStep) in stages) {
        final toolResult = ToolResult(
          toolName: 'submitProperty',
          result: {
            'stage': stage,
            'submissionId': 'SUB789',
            'message': 'Test message for $stage',
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ToolResultWidget(
                toolResult: toolResult,
                onSendMessage: (msg) {},
              ),
            ),
          ),
        );

        // Verify correct stage is rendered
        expect(find.text(expectedTitle), findsOneWidget);
        expect(find.text(expectedStep), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('passes onSendMessage callback correctly',
        (WidgetTester tester) async {
      bool messageSent = false;
      String? sentMessage;

      final toolResult = ToolResult(
        toolName: 'submitProperty',
        result: {
          'stage': 'start',
          'submissionId': 'SUB101',
          'message': 'Upload video',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (msg) {
                messageSent = true;
                sentMessage = msg;
              },
            ),
          ),
        ),
      );

      // Tap the upload button
      await tester.tap(find.text('Upload Video'));
      await tester.pumpAndSettle();

      // Verify callback was triggered
      expect(messageSent, true);
      expect(sentMessage, 'I want to upload a property video');
    });

    testWidgets('handles missing submissionId gracefully',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'submitProperty',
        result: {
          'stage': 'start',
          'message': 'Upload video',
          // No submissionId provided
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (msg) {},
            ),
          ),
        ),
      );

      // Should render with default ID
      expect(find.text('ID: unknown'), findsOneWidget);
      expect(find.text('Upload Property Video'), findsOneWidget);
    });

    testWidgets('handles alternative submissionId field name',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'submitProperty',
        result: {
          'stage': 'start',
          'id': 'SUB202', // Using 'id' instead of 'submissionId'
          'message': 'Upload video',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (msg) {},
            ),
          ),
        ),
      );

      // Should use 'id' field
      expect(find.text('ID: SUB202'), findsOneWidget);
    });

    testWidgets('handles missing stage gracefully',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'submitProperty',
        result: {
          'submissionId': 'SUB303',
          'message': 'Processing',
          // No stage provided
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (msg) {},
            ),
          ),
        ),
      );

      // Should default to 'start' stage
      expect(find.text('Upload Property Video'), findsOneWidget);
      expect(find.text('Step 1 of 5'), findsOneWidget);
    });

    testWidgets('renders with additional data field',
        (WidgetTester tester) async {
      final toolResult = ToolResult(
        toolName: 'submitProperty',
        result: {
          'stage': 'confirm_data',
          'submissionId': 'SUB404',
          'message': 'Review the data',
          'data': {
            'title': 'Modern Apartment',
            'price': 50000,
            'bedrooms': 2,
          },
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: (msg) {},
            ),
          ),
        ),
      );

      // Should render correctly with data
      expect(find.text('Review Property Data'), findsOneWidget);
      expect(find.text('ID: SUB404'), findsOneWidget);
    });
  });
}
