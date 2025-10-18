import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zena_mobile/models/submission_state.dart';
import 'package:zena_mobile/services/submission_state_manager.dart';
import 'package:zena_mobile/providers/chat_provider.dart';

/// Integration test for complete 5-stage property submission workflow
/// Tests all stages, state persistence, error recovery, and concurrent submissions
void main() {
  // Load environment variables and initialize Supabase before running tests
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env.local');

    // Initialize SharedPreferences mock before Supabase
    SharedPreferences.setMockInitialValues({});

    // Initialize Supabase with test credentials
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  });

  group('Complete 5-Stage Workflow Integration Tests', () {
    late SharedPreferences prefs;
    late SubmissionStateManager stateManager;
    late ChatProvider chatProvider;

    setUp(() async {
      // Initialize SharedPreferences with mock
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      stateManager = SubmissionStateManager(prefs);
      chatProvider = ChatProvider(stateManager);
    });

    tearDown(() async {
      // Clean up
      await prefs.clear();
    });

    test('Stage 1: Start submission and show video upload instructions',
        () async {
      // Start submission directly with state manager (no auth required)
      final state = stateManager.createNew('test_user_123');

      // Verify submission was created
      expect(state.submissionId, isNotEmpty);
      expect(state.userId, equals('test_user_123'));

      // Verify initial stage
      expect(state.stage, equals(SubmissionStage.start));
      expect(state.video, isNull);
      expect(state.aiExtracted, isNull);
      expect(state.userProvided, isNull);
      expect(state.missingFields, isNull);

      // Verify progress calculation
      expect(state.progress, equals(0.2)); // 1/5 stages
      expect(state.isComplete, isFalse);
    });

    test('Stage 2: Upload video and store video data', () async {
      // Start submission
      final state = stateManager.createNew('test_user_123');
      final submissionId = state.submissionId;

      // Create video data
      final videoData = VideoData(
        url: 'https://storage.example.com/video123.mp4',
        publicUrl: 'https://cdn.example.com/video123.mp4',
        analysisResults: {
          'bedrooms': 2,
          'bathrooms': 2,
          'propertyType': 'apartment',
        },
        duration: 120,
        quality: '1080p',
      );

      // Update video data
      await stateManager.updateVideoData(submissionId, videoData);
      await stateManager.updateStage(
          submissionId, SubmissionStage.videoUploaded);

      // Verify video data was stored
      final updatedState = stateManager.getState(submissionId)!;
      expect(updatedState.stage, equals(SubmissionStage.videoUploaded));
      expect(updatedState.video, isNotNull);
      expect(updatedState.video!.url, equals(videoData.url));
      expect(updatedState.video!.publicUrl, equals(videoData.publicUrl));
      expect(updatedState.video!.duration, equals(120));
      expect(updatedState.video!.quality, equals('1080p'));
      expect(updatedState.video!.analysisResults, isNotNull);
      expect(updatedState.video!.analysisResults!['bedrooms'], equals(2));

      // Verify progress
      expect(updatedState.progress, equals(0.4)); // 2/5 stages
    });

    test('Stage 3: Display extracted data and confirm/correct', () async {
      // Start submission and upload video
      final state = stateManager.createNew('test_user_123');
      final submissionId = state.submissionId;

      final videoData = VideoData(
        url: 'https://storage.example.com/video123.mp4',
        analysisResults: {'bedrooms': 2},
      );
      await stateManager.updateVideoData(submissionId, videoData);
      await stateManager.updateStage(
          submissionId, SubmissionStage.videoUploaded);

      // AI extracts data
      final extractedData = {
        'title': '2BR Apartment in Westlands',
        'bedrooms': 2,
        'bathrooms': 2,
        'propertyType': 'apartment',
        'location': 'Westlands',
        'rent': 45000,
      };

      await stateManager.updateAIExtracted(submissionId, extractedData);
      await stateManager.updateStage(submissionId, SubmissionStage.confirmData);

      // Verify extracted data was stored
      final confirmedState = stateManager.getState(submissionId)!;
      expect(confirmedState.stage, equals(SubmissionStage.confirmData));
      expect(confirmedState.aiExtracted, isNotNull);
      expect(confirmedState.aiExtracted!['title'],
          equals('2BR Apartment in Westlands'));
      expect(confirmedState.aiExtracted!['bedrooms'], equals(2));
      expect(confirmedState.aiExtracted!['rent'], equals(45000));

      // User corrects data
      final userCorrections = {
        'rent': 50000, // Corrected rent
        'bathrooms': 1, // Corrected bathrooms
      };

      await stateManager.updateUserProvided(submissionId, userCorrections);

      // Verify user corrections were merged
      final updatedState = stateManager.getState(submissionId)!;
      expect(updatedState.userProvided, isNotNull);
      expect(updatedState.userProvided!['rent'], equals(50000));
      expect(updatedState.userProvided!['bathrooms'], equals(1));

      // Verify allData merges both
      expect(updatedState.allData['rent'], equals(50000)); // User override
      expect(updatedState.allData['bathrooms'], equals(1)); // User override
      expect(updatedState.allData['bedrooms'], equals(2)); // AI data
      expect(updatedState.allData['location'], equals('Westlands')); // AI data

      // Verify progress
      expect(updatedState.progress, equals(0.6)); // 3/5 stages
    });

    test('Stage 4: Provide missing information', () async {
      // Start submission and progress to confirmData stage
      final state = stateManager.createNew('test_user_123');
      final submissionId = state.submissionId;

      await stateManager.updateStage(submissionId, SubmissionStage.confirmData);

      // AI identifies missing fields
      final missingFields = ['amenities', 'availableFrom', 'deposit'];
      await stateManager.updateMissingFields(submissionId, missingFields);
      await stateManager.updateStage(submissionId, SubmissionStage.provideInfo);

      // Verify missing fields were stored
      var provideInfoState = stateManager.getState(submissionId)!;
      expect(provideInfoState.stage, equals(SubmissionStage.provideInfo));
      expect(provideInfoState.missingFields, isNotNull);
      expect(provideInfoState.missingFields!.length, equals(3));
      expect(provideInfoState.missingFields, contains('amenities'));
      expect(provideInfoState.missingFields, contains('availableFrom'));
      expect(provideInfoState.missingFields, contains('deposit'));

      // User provides missing information
      final providedData = {
        'amenities': ['parking', 'gym', 'pool'],
        'availableFrom': '2025-11-01',
        'deposit': 100000,
      };

      await stateManager.updateUserProvided(submissionId, providedData);

      // Verify provided data was stored
      provideInfoState = stateManager.getState(submissionId)!;
      expect(provideInfoState.userProvided, isNotNull);
      expect(provideInfoState.userProvided!['amenities'],
          equals(['parking', 'gym', 'pool']));
      expect(provideInfoState.userProvided!['availableFrom'],
          equals('2025-11-01'));
      expect(provideInfoState.userProvided!['deposit'], equals(100000));

      // Verify progress
      expect(provideInfoState.progress, equals(0.8)); // 4/5 stages
    });

    test('Stage 5: Final review and confirmation', () async {
      // Start submission and progress through all stages
      final state = stateManager.createNew('test_user_123');
      final submissionId = state.submissionId;

      // Add complete data
      await stateManager.updateAIExtracted(submissionId, {
        'title': '2BR Apartment',
        'bedrooms': 2,
        'bathrooms': 2,
      });

      await stateManager.updateUserProvided(submissionId, {
        'rent': 50000,
        'deposit': 100000,
        'amenities': ['parking'],
      });

      // Move to final confirm stage
      await stateManager.updateStage(
          submissionId, SubmissionStage.finalConfirm);

      // Verify final stage
      var finalState = stateManager.getState(submissionId)!;
      expect(finalState.stage, equals(SubmissionStage.finalConfirm));
      expect(finalState.isComplete, isTrue);
      expect(finalState.progress, equals(1.0)); // 5/5 stages

      // Verify all data is present
      expect(finalState.allData['title'], equals('2BR Apartment'));
      expect(finalState.allData['bedrooms'], equals(2));
      expect(finalState.allData['rent'], equals(50000));
      expect(finalState.allData['deposit'], equals(100000));

      // Complete submission
      await stateManager.clearState(submissionId);

      // Verify submission was cleared
      expect(stateManager.getState(submissionId), isNull);
    });

    test('State persists between stages', () async {
      // Start submission
      final state = stateManager.createNew('test_user_123');
      final submissionId = state.submissionId;

      // Stage 1: Start
      expect(stateManager.getState(submissionId)!.stage,
          equals(SubmissionStage.start));

      // Stage 2: Video uploaded
      await stateManager.updateVideoData(
          submissionId, VideoData(url: 'test.mp4'));
      await stateManager.updateStage(
          submissionId, SubmissionStage.videoUploaded);
      expect(stateManager.getState(submissionId)!.stage,
          equals(SubmissionStage.videoUploaded));
      expect(stateManager.getState(submissionId)!.video, isNotNull);

      // Stage 3: Confirm data
      await stateManager.updateAIExtracted(submissionId, {'bedrooms': 2});
      await stateManager.updateStage(submissionId, SubmissionStage.confirmData);
      expect(stateManager.getState(submissionId)!.stage,
          equals(SubmissionStage.confirmData));
      expect(stateManager.getState(submissionId)!.video,
          isNotNull); // Still persisted
      expect(stateManager.getState(submissionId)!.aiExtracted, isNotNull);

      // Stage 4: Provide info
      await stateManager.updateUserProvided(submissionId, {'rent': 50000});
      await stateManager.updateStage(submissionId, SubmissionStage.provideInfo);
      expect(stateManager.getState(submissionId)!.stage,
          equals(SubmissionStage.provideInfo));
      expect(stateManager.getState(submissionId)!.video,
          isNotNull); // Still persisted
      expect(stateManager.getState(submissionId)!.aiExtracted,
          isNotNull); // Still persisted
      expect(stateManager.getState(submissionId)!.userProvided, isNotNull);

      // Stage 5: Final confirm
      await stateManager.updateStage(
          submissionId, SubmissionStage.finalConfirm);
      final finalState = stateManager.getState(submissionId)!;
      expect(finalState.stage, equals(SubmissionStage.finalConfirm));
      expect(finalState.video, isNotNull); // All data persisted
      expect(finalState.aiExtracted, isNotNull);
      expect(finalState.userProvided, isNotNull);
    });

    test('State persists after app restart', () async {
      // Create submission and add data
      final state = stateManager.createNew('test_user_123');
      final submissionId = state.submissionId;

      await stateManager.updateVideoData(
          submissionId, VideoData(url: 'test.mp4'));
      await stateManager
          .updateAIExtracted(submissionId, {'bedrooms': 2, 'rent': 45000});
      await stateManager.updateUserProvided(submissionId, {'rent': 50000});
      await stateManager.updateStage(submissionId, SubmissionStage.confirmData);

      // Simulate app restart by creating new state manager instance
      final newStateManager = SubmissionStateManager(prefs);

      // Verify submission was restored
      final restoredState = newStateManager.getState(submissionId);
      expect(restoredState, isNotNull);
      expect(restoredState!.stage, equals(SubmissionStage.confirmData));
      expect(restoredState.video, isNotNull);
      expect(restoredState.video!.url, equals('test.mp4'));
      expect(restoredState.aiExtracted!['bedrooms'], equals(2));
      expect(restoredState.userProvided!['rent'], equals(50000));
      expect(restoredState.allData['rent'], equals(50000)); // User override
    });

    test('Multiple concurrent submissions', () async {
      // Create first submission
      final state1 = stateManager.createNew('user1');
      final submission1Id = state1.submissionId;
      await stateManager
          .updateAIExtracted(submission1Id, {'title': 'Property 1'});
      await stateManager.updateStage(
          submission1Id, SubmissionStage.confirmData);

      // Create second submission (simulating different user or session)
      final state2 = stateManager.createNew('user2');
      final submission2Id = state2.submissionId;
      await stateManager
          .updateAIExtracted(submission2Id, {'title': 'Property 2'});
      await stateManager.updateStage(
          submission2Id, SubmissionStage.provideInfo);

      // Create third submission
      final state3 = stateManager.createNew('user3');
      final submission3Id = state3.submissionId;
      await stateManager.updateVideoData(
          submission3Id, VideoData(url: 'video3.mp4'));
      await stateManager.updateStage(
          submission3Id, SubmissionStage.videoUploaded);

      // Verify all submissions exist independently
      final allStates = stateManager.getAllActiveStates();
      expect(allStates.length, equals(3));

      // Verify each submission has correct data
      final sub1 = stateManager.getState(submission1Id)!;
      expect(sub1.stage, equals(SubmissionStage.confirmData));
      expect(sub1.aiExtracted!['title'], equals('Property 1'));

      final sub2 = stateManager.getState(submission2Id)!;
      expect(sub2.stage, equals(SubmissionStage.provideInfo));
      expect(sub2.aiExtracted!['title'], equals('Property 2'));

      final sub3 = stateManager.getState(submission3Id)!;
      expect(sub3.stage, equals(SubmissionStage.videoUploaded));
      expect(sub3.video!.url, equals('video3.mp4'));

      // Verify submissions are sorted by most recent
      expect(allStates[0].submissionId, equals(submission3Id)); // Most recent
      expect(allStates[2].submissionId, equals(submission1Id)); // Oldest
    });

    test('Canceling submission', () async {
      // Start submission and add data
      final state = stateManager.createNew('test_user_123');
      final submissionId = state.submissionId;

      await stateManager.updateVideoData(
          submissionId, VideoData(url: 'test.mp4'));
      await stateManager.updateAIExtracted(submissionId, {'bedrooms': 2});
      await stateManager.updateStage(submissionId, SubmissionStage.confirmData);

      // Verify submission exists
      expect(stateManager.getState(submissionId), isNotNull);

      // Verify state is preserved in storage
      expect(stateManager.getState(submissionId), isNotNull);
      expect(stateManager.getState(submissionId)!.stage,
          equals(SubmissionStage.confirmData));

      // Delete submission permanently
      await stateManager.clearState(submissionId);
      expect(stateManager.getState(submissionId), isNull);
    });

    test('Error recovery - preserve state on error', () async {
      // Start submission and add data
      final state = stateManager.createNew('test_user_123');
      final submissionId = state.submissionId;

      await stateManager.updateVideoData(
          submissionId, VideoData(url: 'test.mp4'));
      await stateManager.updateAIExtracted(submissionId, {'bedrooms': 2});
      await stateManager.updateStage(submissionId, SubmissionStage.confirmData);

      // Simulate error
      await stateManager.markError(submissionId, 'Network timeout');

      // Verify state is preserved
      final errorState = stateManager.getState(submissionId)!;
      expect(errorState.stage, equals(SubmissionStage.confirmData));
      expect(errorState.video, isNotNull);
      expect(errorState.aiExtracted, isNotNull);
      expect(errorState.hasError, isTrue);
      expect(errorState.lastError, equals('Network timeout'));

      // Verify can retry from last successful stage
      await stateManager.clearError(submissionId);

      final retriedState = stateManager.getState(submissionId)!;
      expect(retriedState.hasError, isFalse);
      expect(retriedState.lastError, isNull);
      expect(retriedState.stage, equals(SubmissionStage.confirmData));
    });

    test('Error recovery - detect and handle state corruption', () async {
      // Create submission
      final state = stateManager.createNew('test_user_123');
      final submissionId = state.submissionId;

      // Manually corrupt the state by creating invalid data
      final corruptedState = SubmissionState(
        submissionId: submissionId,
        userId: 'user1',
        stage: SubmissionStage.videoUploaded,
        video: null, // Invalid: videoUploaded stage requires video
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await stateManager.saveState(corruptedState);

      // Detect corruption
      final corrupted = stateManager.detectCorruptedStates();
      expect(corrupted, contains(submissionId));

      // Verify validation fails
      expect(stateManager.validateState(corruptedState), isFalse);

      // Remove corrupted state
      await stateManager.removeCorruptedState(submissionId);
      expect(stateManager.getState(submissionId),
          isNull); // Corrupted state removed
    });

    test('Error recovery - queue updates when network fails', () async {
      // Start submission
      final state = stateManager.createNew('test_user_123');
      final submissionId = state.submissionId;

      // Simulate network failure by directly testing queue mechanism
      expect(stateManager.hasQueuedUpdates, isFalse);
      expect(stateManager.queuedUpdateCount, equals(0));

      // Note: In real scenario, network failure would trigger queuing
      // For this test, we verify the queue processing works
      await stateManager.updateVideoData(
          submissionId, VideoData(url: 'test.mp4'));

      // Process any queued updates
      await stateManager.processQueuedUpdates();

      // Verify state was saved
      final savedState = stateManager.getState(submissionId)!;
      expect(savedState.video, isNotNull);
      expect(savedState.video!.url, equals('test.mp4'));
    });

    test('Complete end-to-end workflow', () async {
      // Stage 1: Start
      final state = stateManager.createNew('test_user_123');
      final submissionId = state.submissionId;
      expect(stateManager.getState(submissionId)!.stage,
          equals(SubmissionStage.start));

      // Stage 2: Upload video
      final videoData = VideoData(
        url: 'https://storage.example.com/property-video.mp4',
        publicUrl: 'https://cdn.example.com/property-video.mp4',
        analysisResults: {'detected': 'apartment'},
        duration: 180,
        quality: '1080p',
      );
      await stateManager.updateVideoData(submissionId, videoData);
      await stateManager.updateStage(
          submissionId, SubmissionStage.videoUploaded);

      // Stage 3: AI extracts and user confirms/corrects
      await stateManager.updateAIExtracted(submissionId, {
        'title': '2BR Apartment in Westlands',
        'bedrooms': 2,
        'bathrooms': 2,
        'propertyType': 'apartment',
        'location': 'Westlands',
        'rent': 45000,
      });
      await stateManager.updateStage(submissionId, SubmissionStage.confirmData);

      await stateManager.updateUserProvided(submissionId, {
        'rent': 50000, // User correction
      });

      // Stage 4: Provide missing info
      await stateManager
          .updateMissingFields(submissionId, ['amenities', 'deposit']);
      await stateManager.updateStage(submissionId, SubmissionStage.provideInfo);

      await stateManager.updateUserProvided(submissionId, {
        'amenities': ['parking', 'gym'],
        'deposit': 100000,
      });

      // Stage 5: Final confirmation
      await stateManager.updateStage(
          submissionId, SubmissionStage.finalConfirm);

      // Verify complete state
      final finalState = stateManager.getState(submissionId)!;
      expect(finalState.isComplete, isTrue);
      expect(finalState.progress, equals(1.0));
      expect(finalState.allData['title'], equals('2BR Apartment in Westlands'));
      expect(finalState.allData['bedrooms'], equals(2));
      expect(finalState.allData['rent'], equals(50000)); // User override
      expect(finalState.allData['amenities'], equals(['parking', 'gym']));
      expect(finalState.allData['deposit'], equals(100000));

      // Complete submission
      await stateManager.clearState(submissionId);
      expect(stateManager.getState(submissionId), isNull);
    });
  });
}
