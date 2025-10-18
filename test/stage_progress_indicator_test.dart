import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/models/submission_state.dart';
import 'package:zena_mobile/widgets/chat/workflow/stage_progress_indicator.dart';

void main() {
  group('StageProgressIndicator', () {
    testWidgets('displays correct stage number for start stage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageProgressIndicator(
              currentStage: SubmissionStage.start,
            ),
          ),
        ),
      );

      // Should show "Stage 1/5"
      expect(find.text('Stage 1/5'), findsOneWidget);
      expect(find.text('Submission Progress'), findsOneWidget);
    });

    testWidgets('displays correct stage number for videoUploaded stage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageProgressIndicator(
              currentStage: SubmissionStage.videoUploaded,
            ),
          ),
        ),
      );

      // Should show "Stage 2/5"
      expect(find.text('Stage 2/5'), findsOneWidget);
    });

    testWidgets('displays correct stage number for confirmData stage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageProgressIndicator(
              currentStage: SubmissionStage.confirmData,
            ),
          ),
        ),
      );

      // Should show "Stage 3/5"
      expect(find.text('Stage 3/5'), findsOneWidget);
    });

    testWidgets('displays correct stage number for provideInfo stage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageProgressIndicator(
              currentStage: SubmissionStage.provideInfo,
            ),
          ),
        ),
      );

      // Should show "Stage 4/5"
      expect(find.text('Stage 4/5'), findsOneWidget);
    });

    testWidgets('displays correct stage number for finalConfirm stage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageProgressIndicator(
              currentStage: SubmissionStage.finalConfirm,
            ),
          ),
        ),
      );

      // Should show "Stage 5/5"
      expect(find.text('Stage 5/5'), findsOneWidget);
    });

    testWidgets('displays all stage names', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageProgressIndicator(
              currentStage: SubmissionStage.confirmData,
            ),
          ),
        ),
      );

      // All stage names should be visible
      expect(find.text('Start Submission'), findsOneWidget);
      expect(find.text('Video Uploaded'), findsOneWidget);
      expect(find.text('Confirm Data'), findsOneWidget);
      expect(find.text('Provide Info'), findsOneWidget);
      expect(find.text('Final Confirmation'), findsOneWidget);
    });

    testWidgets('shows checkmarks for completed stages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageProgressIndicator(
              currentStage: SubmissionStage.confirmData,
            ),
          ),
        ),
      );

      // Should have checkmarks for completed stages (start and videoUploaded)
      // The check icon appears twice (for stages 1 and 2)
      expect(find.byIcon(Icons.check), findsNWidgets(2));
    });

    testWidgets('highlights current stage', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageProgressIndicator(
              currentStage: SubmissionStage.provideInfo,
            ),
          ),
        ),
      );

      // Should show "Current" badge for the current stage
      expect(find.text('Current'), findsOneWidget);
    });

    testWidgets('shows progress bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageProgressIndicator(
              currentStage: SubmissionStage.confirmData,
            ),
          ),
        ),
      );

      // Should have a LinearProgressIndicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Verify progress value (stage 3 of 5 = 0.6)
      final progressIndicator =
          tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(progressIndicator.value, 0.6);
    });

    testWidgets('progress bar shows correct value for each stage',
        (WidgetTester tester) async {
      // Test each stage
      final stages = [
        (SubmissionStage.start, 0.2),
        (SubmissionStage.videoUploaded, 0.4),
        (SubmissionStage.confirmData, 0.6),
        (SubmissionStage.provideInfo, 0.8),
        (SubmissionStage.finalConfirm, 1.0),
      ];

      for (final (stage, expectedProgress) in stages) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StageProgressIndicator(
                currentStage: stage,
              ),
            ),
          ),
        );

        final progressIndicator = tester
            .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
        expect(
          progressIndicator.value,
          expectedProgress,
          reason: 'Stage $stage should have progress $expectedProgress',
        );
      }
    });

    testWidgets('shows stage numbers for incomplete stages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageProgressIndicator(
              currentStage: SubmissionStage.start,
            ),
          ),
        ),
      );

      // Should show numbers for stages that aren't completed
      expect(find.text('1'), findsOneWidget); // Current stage
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders correctly in a Card', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageProgressIndicator(
              currentStage: SubmissionStage.videoUploaded,
            ),
          ),
        ),
      );

      // Should be wrapped in a Card
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('supports custom total stages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageProgressIndicator(
              currentStage: SubmissionStage.confirmData,
              totalStages: 10,
            ),
          ),
        ),
      );

      // Should show custom total
      expect(find.text('Stage 3/10'), findsOneWidget);
    });
  });
}
