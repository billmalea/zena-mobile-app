import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/models/submission_state.dart';
import 'package:zena_mobile/widgets/chat/workflow/workflow_navigation.dart';

void main() {
  group('WorkflowNavigation Widget Tests', () {
    testWidgets('displays status badge with correct stage name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkflowNavigation(
              currentStage: SubmissionStage.confirmData,
            ),
          ),
        ),
      );

      expect(find.text('Confirm Data'), findsOneWidget);
    });

    testWidgets('displays back button when stage allows back navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowNavigation(
              currentStage: SubmissionStage.confirmData,
              onBack: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('does not display back button on start stage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowNavigation(
              currentStage: SubmissionStage.start,
              onBack: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('displays cancel button when onCancel is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowNavigation(
              currentStage: SubmissionStage.confirmData,
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('does not display cancel button when onCancel is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkflowNavigation(
              currentStage: SubmissionStage.confirmData,
            ),
          ),
        ),
      );

      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('calls onBack callback when back button is tapped',
        (WidgetTester tester) async {
      bool backCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowNavigation(
              currentStage: SubmissionStage.confirmData,
              onBack: () {
                backCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(backCalled, isTrue);
    });

    testWidgets('calls onCancel callback when cancel button is tapped',
        (WidgetTester tester) async {
      bool cancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowNavigation(
              currentStage: SubmissionStage.confirmData,
              onCancel: () {
                cancelCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(cancelCalled, isTrue);
    });

    testWidgets('displays custom help text when provided',
        (WidgetTester tester) async {
      const customHelpText = 'This is custom help text';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkflowNavigation(
              currentStage: SubmissionStage.confirmData,
              helpText: customHelpText,
            ),
          ),
        ),
      );

      expect(find.text(customHelpText), findsOneWidget);
    });

    testWidgets('displays default help text when custom text not provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkflowNavigation(
              currentStage: SubmissionStage.start,
            ),
          ),
        ),
      );

      expect(
        find.textContaining('Upload a video of your property'),
        findsOneWidget,
      );
    });

    testWidgets('displays info icon with help text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkflowNavigation(
              currentStage: SubmissionStage.confirmData,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    group('Stage-specific tests', () {
      testWidgets('start stage displays correct icon and name',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.start,
              ),
            ),
          ),
        );

        expect(find.text('Getting Started'), findsOneWidget);
        expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      });

      testWidgets('videoUploaded stage displays correct icon and name',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.videoUploaded,
              ),
            ),
          ),
        );

        expect(find.text('Video Uploaded'), findsOneWidget);
        expect(find.byIcon(Icons.video_library), findsOneWidget);
      });

      testWidgets('confirmData stage displays correct icon and name',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.confirmData,
              ),
            ),
          ),
        );

        expect(find.text('Confirm Data'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('provideInfo stage displays correct icon and name',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.provideInfo,
              ),
            ),
          ),
        );

        expect(find.text('Provide Info'), findsOneWidget);
        expect(find.byIcon(Icons.edit_note), findsOneWidget);
      });

      testWidgets('finalConfirm stage displays correct icon and name',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.finalConfirm,
              ),
            ),
          ),
        );

        expect(find.text('Final Review'), findsOneWidget);
        expect(find.byIcon(Icons.task_alt), findsOneWidget);
      });
    });

    group('Back button visibility tests', () {
      testWidgets('back button not shown on start stage even with callback',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.start,
                onBack: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_back), findsNothing);
      });

      testWidgets('back button shown on videoUploaded stage with callback',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.videoUploaded,
                onBack: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('back button shown on confirmData stage with callback',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.confirmData,
                onBack: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('back button shown on provideInfo stage with callback',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.provideInfo,
                onBack: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('back button shown on finalConfirm stage with callback',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.finalConfirm,
                onBack: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });

    group('Help text tests', () {
      testWidgets('start stage shows correct default help text',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.start,
              ),
            ),
          ),
        );

        expect(
          find.textContaining('Upload a video of your property'),
          findsOneWidget,
        );
      });

      testWidgets('videoUploaded stage shows correct default help text',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.videoUploaded,
              ),
            ),
          ),
        );

        expect(
          find.textContaining('Your video is being analyzed'),
          findsOneWidget,
        );
      });

      testWidgets('confirmData stage shows correct default help text',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.confirmData,
              ),
            ),
          ),
        );

        expect(
          find.textContaining('Review the extracted information'),
          findsOneWidget,
        );
      });

      testWidgets('provideInfo stage shows correct default help text',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.provideInfo,
              ),
            ),
          ),
        );

        expect(
          find.textContaining('Please provide the missing information'),
          findsOneWidget,
        );
      });

      testWidgets('finalConfirm stage shows correct default help text',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: WorkflowNavigation(
                currentStage: SubmissionStage.finalConfirm,
              ),
            ),
          ),
        );

        expect(
          find.textContaining('Review all details before submitting'),
          findsOneWidget,
        );
      });
    });

    testWidgets('widget has proper styling and layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkflowNavigation(
              currentStage: SubmissionStage.confirmData,
              onBack: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Check that all key elements are present
      expect(find.byType(WorkflowNavigation), findsOneWidget);
      expect(find.text('Confirm Data'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
