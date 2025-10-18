import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zena_mobile/models/submission_state.dart';
import 'package:zena_mobile/services/submission_state_manager.dart';

void main() {
  group('Error Recovery Integration Tests', () {
    late SubmissionStateManager stateManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      stateManager = SubmissionStateManager(prefs);
    });

    test('should preserve submission state when error occurs', () async {
      // Create submission
      final state = stateManager.createNew('user123');

      // Progress to video uploaded stage
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );
      await stateManager.updateVideoData(
        state.submissionId,
        VideoData(url: 'https://example.com/video.mp4'),
      );

      // Simulate error
      await stateManager.markError(state.submissionId, 'Network timeout');

      // Verify state is preserved
      final retrieved = stateManager.getState(state.submissionId);
      expect(retrieved, isNotNull);
      expect(retrieved!.stage, equals(SubmissionStage.videoUploaded));
      expect(retrieved.video, isNotNull);
      expect(retrieved.hasError, isTrue);
      expect(retrieved.lastError, equals('Network timeout'));
    });

    test('should allow retry from last successful stage', () async {
      // Create submission with error
      final state = stateManager.createNew('user123');
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );
      await stateManager.updateVideoData(
        state.submissionId,
        VideoData(url: 'https://example.com/video.mp4'),
      );
      await stateManager.markError(state.submissionId, 'Processing failed');

      // Clear error (simulating retry)
      await stateManager.clearError(state.submissionId);

      // Verify error is cleared and state is preserved
      final retrieved = stateManager.getState(state.submissionId);
      expect(retrieved, isNotNull);
      expect(retrieved!.hasError, isFalse);
      expect(retrieved.stage, equals(SubmissionStage.videoUploaded));
      expect(retrieved.video, isNotNull);
    });

    test('should detect and handle corrupted submission', () async {
      // Create invalid submission
      final invalidState = SubmissionState(
        submissionId: 'invalid_sub',
        userId: '',
        stage: SubmissionStage.start,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await stateManager.saveState(invalidState);

      // Check for corrupted submissions
      final corrupted = stateManager.detectCorruptedStates();
      expect(corrupted, contains('invalid_sub'));

      // Remove corrupted submission
      await stateManager.removeCorruptedState('invalid_sub');

      // Verify corrupted state is removed
      final retrieved = stateManager.getState('invalid_sub');
      expect(retrieved, isNull);
    });

    test('should process queued updates after network recovery', () async {
      // Create submission
      final state = stateManager.createNew('user123');

      // Process queued updates (should not error even if queue is empty)
      await stateManager.processQueuedUpdates();

      // Verify submission still exists
      final retrieved = stateManager.getState(state.submissionId);
      expect(retrieved, isNotNull);
    });

    test('should handle multiple errors on same submission', () async {
      // Create submission
      final state = stateManager.createNew('user123');

      // First error
      await stateManager.markError(state.submissionId, 'Error 1');
      var retrieved = stateManager.getState(state.submissionId);
      expect(retrieved!.lastError, equals('Error 1'));

      // Second error
      await stateManager.markError(state.submissionId, 'Error 2');
      retrieved = stateManager.getState(state.submissionId);
      expect(retrieved!.lastError, equals('Error 2'));
    });

    test('should preserve state for recovery after cancellation', () async {
      // Create submission
      final state = stateManager.createNew('user123');

      // Progress submission
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );

      // State is preserved in storage (cancellation just clears current reference)
      final retrieved = stateManager.getState(state.submissionId);
      expect(retrieved, isNotNull);
      expect(retrieved!.stage, equals(SubmissionStage.videoUploaded));
    });

    test('should delete submission permanently', () async {
      // Create submission
      final state = stateManager.createNew('user123');

      // Delete submission
      await stateManager.clearState(state.submissionId);

      // Verify submission is removed from storage
      final retrieved = stateManager.getState(state.submissionId);
      expect(retrieved, isNull);
    });

    test('should restore submission on app restart', () async {
      // Create submission
      final state = stateManager.createNew('user123');
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );

      // Simulate app restart by creating new state manager
      final prefs = await SharedPreferences.getInstance();
      final newStateManager = SubmissionStateManager(prefs);

      // Verify submission is restored
      final activeStates = newStateManager.getAllActiveStates();
      expect(activeStates.length, equals(1));
      expect(activeStates.first.submissionId, equals(state.submissionId));
    });

    test('should restore submission with error on app restart', () async {
      // Create submission with error
      final state = stateManager.createNew('user123');
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );
      await stateManager.markError(state.submissionId, 'Upload failed');

      // Simulate app restart
      final prefs = await SharedPreferences.getInstance();
      final newStateManager = SubmissionStateManager(prefs);

      // Verify submission with error is restored
      final activeStates = newStateManager.getAllActiveStates();
      expect(activeStates.length, equals(1));
      expect(activeStates.first.hasError, isTrue);
    });

    test('should validate state before retry', () async {
      // Create invalid submission
      final invalidState = SubmissionState(
        submissionId: 'invalid_sub',
        userId: '',
        stage: SubmissionStage.start,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await stateManager.saveState(invalidState);

      // Validate state
      expect(stateManager.validateState(invalidState), isFalse);
    });

    test('should handle non-existent submission', () async {
      // Try to get non-existent submission
      final state = stateManager.getState('non_existent');
      expect(state, isNull);
    });

    test('should clear error after successful retry', () async {
      // Create submission with error
      final state = stateManager.createNew('user123');
      await stateManager.markError(state.submissionId, 'Network error');

      // Clear error (simulating successful retry)
      await stateManager.clearError(state.submissionId);

      // Verify error is cleared
      final retrieved = stateManager.getState(state.submissionId);
      expect(retrieved, isNotNull);
      expect(retrieved!.hasError, isFalse);
    });

    test('should detect corrupted states on initialization', () async {
      // Create invalid submission
      final invalidState = SubmissionState(
        submissionId: 'invalid_sub',
        userId: '',
        stage: SubmissionStage.start,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await stateManager.saveState(invalidState);

      // Detect corrupted states
      final corrupted = stateManager.detectCorruptedStates();

      // Verify corrupted submission is detected
      expect(corrupted, contains('invalid_sub'));
    });

    test('should handle complete workflow with error and recovery', () async {
      // Create submission
      final state = stateManager.createNew('user123');

      // Stage 1: Video uploaded
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );
      await stateManager.updateVideoData(
        state.submissionId,
        VideoData(url: 'https://example.com/video.mp4'),
      );

      // Stage 2: Error during data confirmation
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.confirmData,
      );
      await stateManager.markError(state.submissionId, 'AI processing failed');

      // Verify error state
      var retrieved = stateManager.getState(state.submissionId);
      expect(retrieved!.hasError, isTrue);
      expect(retrieved.stage, equals(SubmissionStage.confirmData));

      // Clear error (simulating retry)
      await stateManager.clearError(state.submissionId);

      // Verify error cleared and can continue
      retrieved = stateManager.getState(state.submissionId);
      expect(retrieved!.hasError, isFalse);
      expect(retrieved.stage, equals(SubmissionStage.confirmData));

      // Continue workflow
      await stateManager.updateAIExtracted(state.submissionId, {'bedrooms': 2});
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.provideInfo,
      );

      // Complete submission
      await stateManager.clearState(state.submissionId);

      // Verify submission is cleared
      retrieved = stateManager.getState(state.submissionId);
      expect(retrieved, isNull);
    });
  });
}
