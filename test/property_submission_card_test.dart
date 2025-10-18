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
            body: PropertySubmissionCard(
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
      );

      // Verify stage title
      expect(find.text('Upload Property Video'), findsOneWidget);

      // Verify submission ID
      expect(find.text('ID: SUB123'), findsOneWidget);

      // Verify message
      expect(
          find.text('Upload a video of your property to get started.'),
          findsOneWidget);

      // Verify progress indicator shows 1/5
      expect(find.text('Step 1 of 5'), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);

      // Verify upload button exists
      expect(find.text('Upload Video'), findsOneWidget);

      // Tap upload button
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
            body: PropertySubmissionCard(
              submissionId: 'SUB456',
              stage: 'video_uploaded',
              message: 'We are analyzing your video...',
            ),
          ),
        ),
      );

      // Verify stage title
      expect(find.text('Analyzing Video'), findsOneWidget);

      // Verify progress indicator shows 2/5
      expect(find.text('Step 2 of 5'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);

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
            body: PropertySubmissionCard(
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
      );

      // Verify stage title
      expect(find.text('Review Property Data'), findsOneWidget);

      // Verify progress indicator shows 3/5
      expect(find.text('Step 3 of 5'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Edit Data'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);

      // Verify back button exists
      expect(find.text('Back'), findsOneWidget);

      // Tap confirm button
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
            body: PropertySubmissionCard(
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
      );

      // Verify stage title
      expect(find.text('Complete Missing Information'), findsOneWidget);

      // Verify progress indicator shows 4/5
      expect(find.text('Step 4 of 5'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);

      // Verify submit button
      expect(find.text('Submit Information'), findsOneWidget);

      // Verify back button exists
      expect(find.text('Back'), findsOneWidget);

      // Tap submit button
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
            body: PropertySubmissionCard(
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
      );

      // Verify stage title
      expect(find.text('Final Review'), findsOneWidget);

      // Verify progress indicator shows 5/5
      expect(find.text('Step 5 of 5'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Confirm & List'), findsOneWidget);

      // Verify no back button at final stage
      expect(find.text('Back'), findsNothing);

      // Tap confirm button
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
            body: PropertySubmissionCard(
              submissionId: 'SUB303',
              stage: 'unknown_stage',
              message: 'Processing...',
            ),
          ),
        ),
      );

      // Should default to stage 1
      expect(find.text('Property Submission'), findsWidgets);
      expect(find.text('Step 1 of 5'), findsOneWidget);
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
              body: PropertySubmissionCard(
                submissionId: 'SUB404',
                stage: stage,
                message: 'Test message',
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
            body: PropertySubmissionCard(
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
      );

      // Tap back button
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(messageSent, true);
      expect(sentMessage, 'Go back to previous step');
    });

    testWidgets('edit button in confirm_data stage triggers correct callback',
        (WidgetTester tester) async {
      bool messageSent = false;
      String? sentMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertySubmissionCard(
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
      );

      // Tap edit button
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
            body: PropertySubmissionCard(
              submissionId: 'SUB707',
              stage: 'final_confirm',
              message: 'Final review',
              onSendMessage: (msg) {
                messageSent = true;
                sentMessage = msg;
              },
            ),
          ),
        ),
      );

      // Tap edit button
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
            body: PropertySubmissionCard(
              submissionId: 'SUB808',
              stage: 'start',
              message: 'Upload video',
            ),
          ),
        ),
      );

      // Should render without errors
      expect(find.text('Upload Property Video'), findsOneWidget);
      expect(find.text('Upload Video'), findsOneWidget);

      // Tapping button should not cause errors
      await tester.tap(find.text('Upload Video'));
      await tester.pumpAndSettle();
    });

    testWidgets('handles empty message gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertySubmissionCard(
              submissionId: 'SUB909',
              stage: 'start',
              message: '',
            ),
          ),
        ),
      );

      // Should render without the message container
      expect(find.text('Upload Property Video'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsNothing);
    });

    testWidgets('progress bar shows correct percentage',
        (WidgetTester tester) async {
      final stages = [
        ('start', 0.2),
        ('video_uploaded', 0.4),
        ('confirm_data', 0.6),
        ('provide_info', 0.8),
        ('final_confirm', 1.0),
      ];

      for (final (stage, expectedValue) in stages) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PropertySubmissionCard(
                submissionId: 'SUB1010',
                stage: stage,
                message: 'Test',
              ),
            ),
          ),
        );

        // Find the LinearProgressIndicator
        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );

        // Verify progress value
        expect(progressIndicator.value, expectedValue);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });
  });
}
