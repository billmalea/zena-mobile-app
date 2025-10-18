import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zena_mobile/models/submission_state.dart';
import 'package:zena_mobile/services/submission_state_manager.dart';

void main() {
  group('State Persistence on App Restart', () {
    late SubmissionStateManager stateManager;

    setUp(() async {
      // Initialize SharedPreferences with empty data
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      stateManager = SubmissionStateManager(prefs);
    });

    tearDown(() async {
      // Clean up
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('should persist and load active submission states after app restart',
        () async {
      // Create a submission state
      final state = stateManager.createNew('user_123');
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );

      // Simulate app restart by creating new SubmissionStateManager with same storage
      final prefs = await SharedPreferences.getInstance();
      final newStateManager = SubmissionStateManager(prefs);

      // Load active submissions (simulating what ChatProvider does on init)
      final activeStates = newStateManager.getAllActiveStates();

      // Verify submission was persisted and can be restored
      expect(activeStates.length, equals(1));
      expect(activeStates.first.submissionId, equals(state.submissionId));
      expect(activeStates.first.stage, equals(SubmissionStage.videoUploaded));
      expect(activeStates.first.userId, equals('user_123'));
    });

    test('should restore most recent submission if multiple exist', () async {
      // Create multiple submissions
      final state1 = stateManager.createNew('user_123');
      await Future.delayed(const Duration(milliseconds: 10));
      final state2 = stateManager.createNew('user_123');
      await Future.delayed(const Duration(milliseconds: 10));
      final state3 = stateManager.createNew('user_123');

      // Update state3 to make it most recent
      await stateManager.updateStage(
        state3.submissionId,
        SubmissionStage.confirmData,
      );

      // Simulate app restart
      final prefs = await SharedPreferences.getInstance();
      final newStateManager = SubmissionStateManager(prefs);

      // Load active submissions (sorted by most recent first)
      final activeStates = newStateManager.getAllActiveStates();

      // Verify most recent submission is first
      expect(activeStates.length, equals(3));
      expect(activeStates.first.submissionId, equals(state3.submissionId));
      expect(activeStates.first.stage, equals(SubmissionStage.confirmData));
    });

    test('should return empty list if no submissions exist', () async {
      // Simulate app restart with no existing submissions
      final prefs = await SharedPreferences.getInstance();
      final newStateManager = SubmissionStateManager(prefs);

      // Load active submissions
      final activeStates = newStateManager.getAllActiveStates();

      // Verify no submissions were found
      expect(activeStates, isEmpty);
    });

    test('should restore submission with all data intact', () async {
      // Create submission with complete data
      final state = stateManager.createNew('user_123');

      // Add video data
      final videoData = VideoData(
        url: 'https://example.com/video.mp4',
        publicUrl: 'https://example.com/public/video.mp4',
        analysisResults: {'bedrooms': 2, 'bathrooms': 2},
        duration: 120,
        quality: '1080p',
      );
      await stateManager.updateVideoData(state.submissionId, videoData);

      // Add AI extracted data
      await stateManager.updateAIExtracted(state.submissionId, {
        'title': 'Test Property',
        'bedrooms': 2,
        'bathrooms': 2,
      });

      // Add user provided data
      await stateManager.updateUserProvided(state.submissionId, {
        'rent': 50000,
        'deposit': 100000,
      });

      // Add missing fields
      await stateManager.updateMissingFields(
        state.submissionId,
        ['amenities', 'availableFrom'],
      );

      // Update stage
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.provideInfo,
      );

      // Simulate app restart
      final prefs = await SharedPreferences.getInstance();
      final newStateManager = SubmissionStateManager(prefs);

      // Load and verify all data was restored
      final restoredState = newStateManager.getState(state.submissionId)!;
      expect(restoredState.submissionId, equals(state.submissionId));
      expect(restoredState.stage, equals(SubmissionStage.provideInfo));
      expect(restoredState.video?.url, equals(videoData.url));
      expect(restoredState.video?.publicUrl, equals(videoData.publicUrl));
      expect(restoredState.video?.duration, equals(videoData.duration));
      expect(restoredState.aiExtracted?['title'], equals('Test Property'));
      expect(restoredState.userProvided?['rent'], equals(50000));
      expect(restoredState.missingFields, contains('amenities'));
      expect(restoredState.missingFields, contains('availableFrom'));
    });

    test('should preserve state in storage after cancellation', () async {
      // Create a submission state
      final state = stateManager.createNew('user_123');
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );

      // Verify state exists
      expect(stateManager.getState(state.submissionId), isNotNull);

      // Simulate app restart
      final prefs = await SharedPreferences.getInstance();
      final newStateManager = SubmissionStateManager(prefs);

      // Verify state still exists in storage (for potential recovery)
      final storedState = newStateManager.getState(state.submissionId);
      expect(storedState, isNotNull);
      expect(storedState?.stage, equals(SubmissionStage.videoUploaded));
    });

    test('should remove state from storage after completion', () async {
      // Create a submission state
      final state = stateManager.createNew('user_123');

      // Verify state exists
      expect(stateManager.getState(state.submissionId), isNotNull);

      // Complete submission (clear state)
      await stateManager.clearState(state.submissionId);

      // Simulate app restart
      final prefs = await SharedPreferences.getInstance();
      final newStateManager = SubmissionStateManager(prefs);

      // Verify state is removed from storage
      final storedState = newStateManager.getState(state.submissionId);
      expect(storedState, isNull);
    });

    test('should handle corrupted state data gracefully', () async {
      // Manually insert corrupted data into SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('submission_states', 'invalid json data');

      // Try to load states with corrupted data
      final newStateManager = SubmissionStateManager(prefs);
      final activeStates = newStateManager.getAllActiveStates();

      // Should return empty list instead of crashing
      expect(activeStates, isEmpty);
    });

    test('should restore submission after multiple app restarts', () async {
      // Create submission
      final state = stateManager.createNew('user_123');
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );

      final prefs = await SharedPreferences.getInstance();

      // First restart
      var stateManager1 = SubmissionStateManager(prefs);
      var states1 = stateManager1.getAllActiveStates();
      expect(states1.first.submissionId, equals(state.submissionId));

      // Second restart
      var stateManager2 = SubmissionStateManager(prefs);
      var states2 = stateManager2.getAllActiveStates();
      expect(states2.first.submissionId, equals(state.submissionId));

      // Third restart
      var stateManager3 = SubmissionStateManager(prefs);
      var states3 = stateManager3.getAllActiveStates();
      expect(states3.first.submissionId, equals(state.submissionId));
    });

    test('should persist state updates across restarts', () async {
      // Create submission and update through stages
      final state = stateManager.createNew('user_123');

      // Stage 1
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );

      // Restart and verify
      var prefs = await SharedPreferences.getInstance();
      var newManager = SubmissionStateManager(prefs);
      var restoredState = newManager.getState(state.submissionId);
      expect(restoredState?.stage, equals(SubmissionStage.videoUploaded));

      // Stage 2
      await newManager.updateStage(
        state.submissionId,
        SubmissionStage.confirmData,
      );

      // Restart and verify again
      var newManager2 = SubmissionStateManager(prefs);
      var restoredState2 = newManager2.getState(state.submissionId);
      expect(restoredState2?.stage, equals(SubmissionStage.confirmData));
    });
  });
}
