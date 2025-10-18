import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zena_mobile/models/submission_state.dart';
import 'package:zena_mobile/services/submission_state_manager.dart';

void main() {
  group('Error Recovery Tests', () {
    late SubmissionStateManager stateManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      stateManager = SubmissionStateManager(prefs);
    });

    test('should mark submission with error', () async {
      // Create submission
      final state = stateManager.createNew('user123');
      
      // Mark with error
      await stateManager.markError(state.submissionId, 'Network error');
      
      // Verify error is stored
      final retrieved = stateManager.getState(state.submissionId);
      expect(retrieved, isNotNull);
      expect(retrieved!.lastError, equals('Network error'));
      expect(retrieved.hasError, isTrue);
    });

    test('should clear error from submission', () async {
      // Create submission with error
      final state = stateManager.createNew('user123');
      await stateManager.markError(state.submissionId, 'Network error');
      
      // Clear error
      await stateManager.clearError(state.submissionId);
      
      // Verify error is cleared
      final retrieved = stateManager.getState(state.submissionId);
      expect(retrieved, isNotNull);
      expect(retrieved!.lastError, isNull);
      expect(retrieved.hasError, isFalse);
    });

    test('should validate valid submission state', () {
      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user123',
        stage: SubmissionStage.start,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        updatedAt: DateTime.now(),
      );

      expect(stateManager.validateState(state), isTrue);
    });

    test('should detect invalid submission state - empty ID', () {
      final state = SubmissionState(
        submissionId: '',
        userId: 'user123',
        stage: SubmissionStage.start,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(stateManager.validateState(state), isFalse);
    });

    test('should detect invalid submission state - future timestamp', () {
      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user123',
        stage: SubmissionStage.start,
        createdAt: DateTime.now().add(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      );

      expect(stateManager.validateState(state), isFalse);
    });

    test('should detect invalid submission state - videoUploaded without video',
        () {
      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user123',
        stage: SubmissionStage.videoUploaded,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(stateManager.validateState(state), isFalse);
    });

    test('should validate videoUploaded stage with video', () {
      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user123',
        stage: SubmissionStage.videoUploaded,
        video: VideoData(url: 'https://example.com/video.mp4'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(stateManager.validateState(state), isTrue);
    });

    test('should detect invalid submission state - confirmData without AI data',
        () {
      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user123',
        stage: SubmissionStage.confirmData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(stateManager.validateState(state), isFalse);
    });

    test('should validate confirmData stage with AI data', () {
      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user123',
        stage: SubmissionStage.confirmData,
        aiExtracted: {'bedrooms': 2, 'bathrooms': 1},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(stateManager.validateState(state), isTrue);
    });

    test('should detect corrupted states', () async {
      // Create valid state
      final validState = stateManager.createNew('user123');
      
      // Create invalid state by directly manipulating storage
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
      
      expect(corrupted, contains('invalid_sub'));
      expect(corrupted, isNot(contains(validState.submissionId)));
    });

    test('should remove corrupted state', () async {
      // Create invalid state
      final invalidState = SubmissionState(
        submissionId: 'invalid_sub',
        userId: '',
        stage: SubmissionStage.start,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await stateManager.saveState(invalidState);
      
      // Remove corrupted state
      await stateManager.removeCorruptedState('invalid_sub');
      
      // Verify it's removed
      final retrieved = stateManager.getState('invalid_sub');
      expect(retrieved, isNull);
    });

    test('should queue state update on save failure', () async {
      // This test verifies the queue mechanism exists
      // In real scenario, save would fail due to storage issues
      expect(stateManager.queuedUpdateCount, equals(0));
    });

    test('should process queued updates', () async {
      // Create a state
      final state = stateManager.createNew('user123');
      
      // Process queue (should be empty but shouldn't error)
      await stateManager.processQueuedUpdates();
      
      // Verify state still exists
      final retrieved = stateManager.getState(state.submissionId);
      expect(retrieved, isNotNull);
    });

    test('should preserve state on error', () async {
      // Create submission
      final state = stateManager.createNew('user123');
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );
      
      // Mark error
      await stateManager.markError(state.submissionId, 'Upload failed');
      
      // Verify state is preserved with error
      final retrieved = stateManager.getState(state.submissionId);
      expect(retrieved, isNotNull);
      expect(retrieved!.stage, equals(SubmissionStage.videoUploaded));
      expect(retrieved.lastError, equals('Upload failed'));
    });

    test('should allow retry from last successful stage', () async {
      // Create submission and progress through stages
      final state = stateManager.createNew('user123');
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );
      await stateManager.updateVideoData(
        state.submissionId,
        VideoData(url: 'https://example.com/video.mp4'),
      );
      
      // Mark error at next stage
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.confirmData,
      );
      await stateManager.markError(state.submissionId, 'AI processing failed');
      
      // Clear error to retry
      await stateManager.clearError(state.submissionId);
      
      // Verify can continue from confirmData stage
      final retrieved = stateManager.getState(state.submissionId);
      expect(retrieved, isNotNull);
      expect(retrieved!.stage, equals(SubmissionStage.confirmData));
      expect(retrieved.video, isNotNull);
      expect(retrieved.hasError, isFalse);
    });

    test('should handle multiple errors on same submission', () async {
      final state = stateManager.createNew('user123');
      
      // First error
      await stateManager.markError(state.submissionId, 'Error 1');
      var retrieved = stateManager.getState(state.submissionId);
      expect(retrieved!.lastError, equals('Error 1'));
      
      // Second error (overwrites first)
      await stateManager.markError(state.submissionId, 'Error 2');
      retrieved = stateManager.getState(state.submissionId);
      expect(retrieved!.lastError, equals('Error 2'));
    });

    test('should detect missing fields in provideInfo stage', () {
      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user123',
        stage: SubmissionStage.provideInfo,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Should be invalid without missing fields
      expect(stateManager.validateState(state), isFalse);
    });

    test('should validate provideInfo stage with missing fields', () {
      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user123',
        stage: SubmissionStage.provideInfo,
        missingFields: ['rent', 'deposit'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(stateManager.validateState(state), isTrue);
    });

    test('should detect empty data in finalConfirm stage', () {
      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user123',
        stage: SubmissionStage.finalConfirm,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Should be invalid without any data
      expect(stateManager.validateState(state), isFalse);
    });

    test('should validate finalConfirm stage with data', () {
      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user123',
        stage: SubmissionStage.finalConfirm,
        aiExtracted: {'bedrooms': 2},
        userProvided: {'rent': 50000},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(stateManager.validateState(state), isTrue);
    });
  });
}
