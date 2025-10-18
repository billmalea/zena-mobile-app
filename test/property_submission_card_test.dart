import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/property_submission_card.dart';

void main() {
  group('PropertySubmissionCard', () {
    testWidgets('renders start stage correctly', (WidgetTester tester) async {
      bool messageSent = false;
      String? sentMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySubmissionCard(
                submissionId: 'SUB123',
                stage: 'start',
                message: 'Upload a video of your property to get started.',
                onSendMessage: (msg) {
                  messageSent = true;
                  sentMessage = msg;
                },
              ),
            ),
          ),
        ),
      );

      // Verify stage title
      expect(find.text('Upload Property Video'), findsOneWidget);

      // Verify submission ID
      expect(find.text('ID: SUB123'), findsOneWidget);

      // Verify message in WorkflowNavigation
      expect(
          find.text('Upload a video of your property to get started.'),
          findsOneWidget);

      // Verify StageProgressIndicator shows Stage 1/5
      expect(find.text('Stage 1/5'), findsOneWidget);
      expect(find.text('Submission Progress'), findsOneWidget);

      // Verify upload button exists
      expect(find.text('Upload Video'), findsOneWidget);

      // Scroll to and tap upload button
      await tester.ensureVisible(find.text('Upload Video'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upload Video'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(messageSent, true);
      expect(sentMessage, 'I want to upload a property video');
    });

    testWidgets('renders video_uploaded stage with loading indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySubmissionCard(
                submissionId: 'SUB456',
                stage: 'video_uploaded',
                message: 'We are analyzing your video...',
              ),
            ),
          ),
        ),
      );

      // Verify stage title
      expect(find.text('Analyzing Video'), findsOneWidget);

      // Verify StageProgressIndicator shows Stage 2/5
      expect(find.text('Stage 2/5'), findsOneWidget);

      // Verify message in WorkflowNavigation
      expect(find.text('We are analyzing your video...'), findsOneWidget);

      // Verify loading indicator
      expect(find.text('Analyzing your video...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders confirm_data stage with action buttons',
        (WidgetTester tester) async {
      bool messageSent = false;
      String? sentMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySubmissionCard(
                submissionId: 'SUB789',
                stage: 'confirm_data',
                message: 'Please review the extracted property data.',
                onSendMessage: (msg) {
                  messageSent = true;
                  sentMessage = msg;
                },
              ),
            ),
          ),
        ),
      );

      // Verify stage title
      expect(find.text('Review Property Data'), findsOneWidget);

      // Verify StageProgressIndicator shows Stage 3/5
      expect(find.text('Stage 3/5'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Edit Data'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);

      // Verify back button exists in WorkflowNavigation
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Scroll to and tap confirm button
      await tester.ensureVisible(find.text('Confirm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(messageSent, true);
      expect(sentMessage, 'The data looks correct, proceed');
    });

    testWidgets('renders provide_info stage correctly',
        (WidgetTester tester) async {
      bool messageSent = false;
      String? sentMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySubmissionCard(
                submissionId: 'SUB101',
                stage: 'provide_info',
                message: 'Please provide the missing information.',
                onSendMessage: (msg) {
                  messageSent = true;
                  sentMessage = msg;
                },
              ),
            ),
          ),
        ),
      );

      // Verify stage title
      expect(find.text('Complete Missing Information'), findsOneWidget);

      // Verify StageProgressIndicator shows Stage 4/5
      expect(find.text('Stage 4/5'), findsOneWidget);

      // Verify submit button
      expect(find.text('Submit Information'), findsOneWidget);

      // Verify back button exists in WorkflowNavigation
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Scroll to and tap submit button
      await tester.ensureVisible(find.text('Submit Information'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit Information'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(messageSent, true);
      expect(sentMessage, 'I have provided the missing information');
    });

    testWidgets('renders final_confirm stage correctly',
        (WidgetTester tester) async {
      bool messageSent = false;
      String? sentMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySubmissionCard(
                submissionId: 'SUB202',
                stage: 'final_confirm',
                message: 'Review your property listing before confirming.',
                onSendMessage: (msg) {
                  messageSent = true;
                  sentMessage = msg;
                },
              ),
            ),
          ),
        ),
      );

      // Verify stage title (appears in multiple places)
      expect(find.text('Final Review'), findsWidgets);

      // Verify StageProgressIndicator shows Stage 5/5
      expect(find.text('Stage 5/5'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Confirm & List'), findsOneWidget);

      // Verify back button does NOT exist at final stage
      expect(find.byIcon(Icons.arrow_back), findsNothing);

      // Scroll to and tap confirm button
      await tester.ensureVisible(find.text('Confirm & List'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm & List'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(messageSent, true);
      expect(sentMessage, 'Confirm and list my property');
    });

    testWidgets('handles unknown stage gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySubmissionCard(
                submissionId: 'SUB303',
                stage: 'unknown_stage',
                message: 'Processing...',
              ),
            ),
          ),
        ),
      );

      // Should default to stage 1
      expect(find.text('Property Submission'), findsWidgets);
      expect(find.text('Stage 1/5'), findsOneWidget);
      expect(find.text('ID: SUB303'), findsOneWidget);
    });

    testWidgets('displays correct icons for each stage',
        (WidgetTester tester) async {
      final stages = [
        ('start', Icons.videocam_outlined),
        ('video_uploaded', Icons.analytics_outlined),
        ('confirm_data', Icons.fact_check_outlined),
        ('provide_info', Icons.edit_note_outlined),
        ('final_confirm', Icons.check_circle_outline),
      ];

      for (final (stage, expectedIcon) in stages) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PropertySubmissionCard(
                  submissionId: 'SUB404',
                  stage: stage,
                  message: 'Test message',
                ),
              ),
            ),
          ),
        );

        // Verify icon is present
        expect(find.byIcon(expectedIcon), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('back button triggers correct callback',
        (WidgetTester tester) async {
      bool messageSent = false;
      String? sentMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySubmissionCard(
                submissionId: 'SUB505',
                stage: 'confirm_data',
                message: 'Review data',
                onSendMessage: (msg) {
                  messageSent = true;
                  sentMessage = msg;
                },
              ),
            ),
          ),
        ),
      );

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(messageSent, true);
      expect(sentMessage, 'Go back to previous step');
    });

    testWidgets('cancel button triggers correct callback',
        (WidgetTester tester) async {
      bool messageSent = false;
      String? sentMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySubmissionCard(
                submissionId: 'SUB606',
                stage: 'confirm_data',
                message: 'Review data',
                onSendMessage: (msg) {
                  messageSent = true;
                  sentMessage = msg;
                },
              ),
            ),
          ),
        ),
      );

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(messageSent, true);
      expect(sentMessage, 'Cancel submission');
    });

    testWidgets('edit button in confirm_data stage triggers correct callback',
        (WidgetTester tester) async {
      bool messageSent = false;
      String? sentMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySubmissionCard(
                submissionId: 'SUB707',
                stage: 'confirm_data',
                message: 'Review data',
                onSendMessage: (msg) {
                  messageSent = true;
                  sentMessage = msg;
                },
              ),
            ),
          ),
        ),
      );

      // Scroll to and tap edit button
      await tester.ensureVisible(find.text('Edit Data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit Data'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(messageSent, true);
      expect(sentMessage, 'I need to edit the property data');
    });

    testWidgets('edit button in final_confirm stage triggers correct callback',
        (WidgetTester tester) async {
      bool messageSent = false;
      String? sentMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySubmissionCard(
                submissionId: 'SUB808',
                stage: 'final_confirm',
                message: 'Final review',
                onSendMessage: (msg) {
                  messageSent = true;
                  sentMessage = msg;
                },
              ),
            ),
          ),
        ),
      );

      // Scroll to and tap edit button
      await tester.ensureVisible(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(messageSent, true);
      expect(sentMessage, 'I want to make changes');
    });

    testWidgets('renders without onSendMessage callback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySubmissionCard(
                submissionId: 'SUB909',
                stage: 'start',
                message: 'Upload video',
              ),
            ),
          ),
        ),
      );

      // Should render without errors
      expect(find.text('Upload Property Video'), findsOneWidget);
      expect(find.text('Upload Video'), findsOneWidget);

      // Scroll to and tap button (should not cause errors)
      await tester.ensureVisible(find.text('Upload Video'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upload Video'));
      await tester.pumpAndSettle();
    });

    testWidgets('handles empty message gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySubmissionCard(
                submissionId: 'SUB1010',
                stage: 'start',
                message: '',
              ),
            ),
          ),
        ),
      );

      // Should render without the message in WorkflowNavigation
      expect(find.text('Upload Property Video'), findsOneWidget);
      // Default help text should be shown instead
      expect(
          find.text(
              'Upload a video of your property to get started. Make sure to show all rooms and features.'),
          findsOneWidget);
    });

    testWidgets('StageProgressIndicator shows correct stage',
        (WidgetTester tester) async {
      final stages = [
        ('start', 'Stage 1/5'),
        ('video_uploaded', 'Stage 2/5'),
        ('confirm_data', 'Stage 3/5'),
        ('provide_info', 'Stage 4/5'),
        ('final_confirm', 'Stage 5/5'),
      ];

      for (final (stage, expectedText) in stages) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PropertySubmissionCard(
                  submissionId: 'SUB1111',
                  stage: stage,
                  message: 'Test',
                ),
              ),
            ),
          ),
        );

        // Verify stage text
        expect(find.text(expectedText), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('WorkflowNavigation shows correct status badge',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySubmissionCard(
                submissionId: 'SUB1212',
                stage: 'confirm_data',
                message: 'Test',
              ),
            ),
          ),
        ),
      );

      // Verify status badge text appears (may appear multiple times in different components)
      expect(find.text('Confirm Data'), findsWidgets);
    });
  });
}
