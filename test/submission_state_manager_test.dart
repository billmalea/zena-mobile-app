import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zena_mobile/models/submission_state.dart';
import 'package:zena_mobile/services/submission_state_manager.dart';

void main() {
  late SubmissionStateManager manager;
  late SharedPreferences prefs;

  setUp(() async {
    // Initialize SharedPreferences with mock values
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    manager = SubmissionStateManager(prefs);
  });

  tearDown(() async {
    // Clear all data after each test
    await prefs.clear();
  });

  group('SubmissionStateManager - Create Operations', () {
    test('createNew should create new submission with unique ID', () {
      final state = manager.createNew('user_123');

      expect(state.submissionId, isNotEmpty);
      expect(state.submissionId, startsWith('sub_'));
      expect(state.userId, equals('user_123'));
      expect(state.stage, equals(SubmissionStage.start));
      expect(state.createdAt, isNotNull);
      expect(state.updatedAt, isNotNull);
    });

    test('createNew should generate unique IDs for multiple submissions', () {
      final state1 = manager.createNew('user_123');
      final state2 = manager.createNew('user_123');

      expect(state1.submissionId, isNot(equals(state2.submissionId)));
    });

    test('createNew should persist state to storage', () {
      final state = manager.createNew('user_123');
      final retrieved = manager.getState(state.submissionId);

      expect(retrieved, isNotNull);
      expect(retrieved!.submissionId, equals(state.submissionId));
      expect(retrieved.userId, equals(state.userId));
    });
  });

  group('SubmissionStateManager - Read Operations', () {
    test('getState should return null for non-existent submission', () {
      final state = manager.getState('non_existent_id');
      expect(state, isNull);
    });

    test('getState should retrieve existing submission', () {
      final created = manager.createNew('user_123');
      final retrieved = manager.getState(created.submissionId);

      expect(retrieved, isNotNull);
      expect(retrieved!.submissionId, equals(created.submissionId));
      expect(retrieved.userId, equals(created.userId));
      expect(retrieved.stage, equals(created.stage));
    });

    test('getAllActiveStates should return empty list when no submissions', () {
      final states = manager.getAllActiveStates();
      expect(states, isEmpty);
    });

    test('getAllActiveStates should return all submissions', () {
      manager.createNew('user_1');
      manager.createNew('user_2');
      manager.createNew('user_3');

      final states = manager.getAllActiveStates();
      expect(states.length, equals(3));
    });

    test('getAllActiveStates should sort by most recently updated first', () async {
      final state1 = manager.createNew('user_1');
      await Future.delayed(const Duration(milliseconds: 10));
      final state2 = manager.createNew('user_2');
      await Future.delayed(const Duration(milliseconds: 10));
      final state3 = manager.createNew('user_3');

      final states = manager.getAllActiveStates();
      expect(states[0].submissionId, equals(state3.submissionId));
      expect(states[1].submissionId, equals(state2.submissionId));
      expect(states[2].submissionId, equals(state1.submissionId));
    });
  });

  group('SubmissionStateManager - Update Operations', () {
    test('saveState should persist submission state', () async {
      final state = manager.createNew('user_123');
      final updated = state.copyWith(stage: SubmissionStage.videoUploaded);

      await manager.saveState(updated);
      final retrieved = manager.getState(state.submissionId);

      expect(retrieved!.stage, equals(SubmissionStage.videoUploaded));
    });

    test('updateStage should update submission stage', () async {
      final state = manager.createNew('user_123');

      await manager.updateStage(state.submissionId, SubmissionStage.confirmData);
      final retrieved = manager.getState(state.submissionId);

      expect(retrieved!.stage, equals(SubmissionStage.confirmData));
      expect(retrieved.updatedAt.isAfter(state.updatedAt), isTrue);
    });

    test('updateStage should do nothing for non-existent submission', () async {
      await manager.updateStage('non_existent', SubmissionStage.confirmData);
      final retrieved = manager.getState('non_existent');
      expect(retrieved, isNull);
    });

    test('updateVideoData should store video information', () async {
      final state = manager.createNew('user_123');
      final videoData = VideoData(
        url: 'https://example.com/video.mp4',
        publicUrl: 'https://example.com/public/video.mp4',
        duration: 120,
        quality: '1080p',
      );

      await manager.updateVideoData(state.submissionId, videoData);
      final retrieved = manager.getState(state.submissionId);

      expect(retrieved!.video, isNotNull);
      expect(retrieved.video!.url, equals(videoData.url));
      expect(retrieved.video!.publicUrl, equals(videoData.publicUrl));
      expect(retrieved.video!.duration, equals(120));
      expect(retrieved.video!.quality, equals('1080p'));
    });

    test('updateAIExtracted should store AI-extracted data', () async {
      final state = manager.createNew('user_123');
      final aiData = {
        'bedrooms': 2,
        'bathrooms': 2,
        'propertyType': 'apartment',
      };

      await manager.updateAIExtracted(state.submissionId, aiData);
      final retrieved = manager.getState(state.submissionId);

      expect(retrieved!.aiExtracted, isNotNull);
      expect(retrieved.aiExtracted!['bedrooms'], equals(2));
      expect(retrieved.aiExtracted!['bathrooms'], equals(2));
      expect(retrieved.aiExtracted!['propertyType'], equals('apartment'));
    });

    test('updateUserProvided should store user-provided data', () async {
      final state = manager.createNew('user_123');
      final userData = {
        'rent': 50000,
        'deposit': 100000,
      };

      await manager.updateUserProvided(state.submissionId, userData);
      final retrieved = manager.getState(state.submissionId);

      expect(retrieved!.userProvided, isNotNull);
      expect(retrieved.userProvided!['rent'], equals(50000));
      expect(retrieved.userProvided!['deposit'], equals(100000));
    });

    test('updateUserProvided should merge with existing data', () async {
      final state = manager.createNew('user_123');

      await manager.updateUserProvided(state.submissionId, {'rent': 50000});
      await manager.updateUserProvided(state.submissionId, {'deposit': 100000});

      final retrieved = manager.getState(state.submissionId);

      expect(retrieved!.userProvided!['rent'], equals(50000));
      expect(retrieved.userProvided!['deposit'], equals(100000));
    });

    test('updateMissingFields should store missing field list', () async {
      final state = manager.createNew('user_123');
      final missingFields = ['amenities', 'availableFrom', 'parking'];

      await manager.updateMissingFields(state.submissionId, missingFields);
      final retrieved = manager.getState(state.submissionId);

      expect(retrieved!.missingFields, isNotNull);
      expect(retrieved.missingFields!.length, equals(3));
      expect(retrieved.missingFields, contains('amenities'));
      expect(retrieved.missingFields, contains('availableFrom'));
      expect(retrieved.missingFields, contains('parking'));
    });
  });

  group('SubmissionStateManager - Delete Operations', () {
    test('clearState should remove submission from storage', () async {
      final state = manager.createNew('user_123');

      await manager.clearState(state.submissionId);
      final retrieved = manager.getState(state.submissionId);

      expect(retrieved, isNull);
    });

    test('clearState should not affect other submissions', () async {
      final state1 = manager.createNew('user_1');
      final state2 = manager.createNew('user_2');

      await manager.clearState(state1.submissionId);

      expect(manager.getState(state1.submissionId), isNull);
      expect(manager.getState(state2.submissionId), isNotNull);
    });

    test('clearState should handle non-existent submission gracefully', () async {
      await manager.clearState('non_existent');
      // Should not throw error
    });
  });

  group('SubmissionStateManager - Complete Workflow', () {
    test('should handle complete 5-stage workflow', () async {
      // Stage 1: Start
      final state = manager.createNew('user_123');
      expect(state.stage, equals(SubmissionStage.start));

      // Stage 2: Video uploaded
      await manager.updateStage(state.submissionId, SubmissionStage.videoUploaded);
      final videoData = VideoData(
        url: 'https://example.com/video.mp4',
        duration: 120,
      );
      await manager.updateVideoData(state.submissionId, videoData);

      var retrieved = manager.getState(state.submissionId);
      expect(retrieved!.stage, equals(SubmissionStage.videoUploaded));
      expect(retrieved.video, isNotNull);

      // Stage 3: Confirm data
      await manager.updateStage(state.submissionId, SubmissionStage.confirmData);
      await manager.updateAIExtracted(state.submissionId, {
        'bedrooms': 2,
        'bathrooms': 2,
      });

      retrieved = manager.getState(state.submissionId);
      expect(retrieved!.stage, equals(SubmissionStage.confirmData));
      expect(retrieved.aiExtracted, isNotNull);

      // Stage 4: Provide info
      await manager.updateStage(state.submissionId, SubmissionStage.provideInfo);
      await manager.updateMissingFields(state.submissionId, ['rent', 'deposit']);
      await manager.updateUserProvided(state.submissionId, {
        'rent': 50000,
        'deposit': 100000,
      });

      retrieved = manager.getState(state.submissionId);
      expect(retrieved!.stage, equals(SubmissionStage.provideInfo));
      expect(retrieved.missingFields, isNotNull);
      expect(retrieved.userProvided, isNotNull);

      // Stage 5: Final confirm
      await manager.updateStage(state.submissionId, SubmissionStage.finalConfirm);

      retrieved = manager.getState(state.submissionId);
      expect(retrieved!.stage, equals(SubmissionStage.finalConfirm));
      expect(retrieved.isComplete, isTrue);

      // Complete and clear
      await manager.clearState(state.submissionId);
      expect(manager.getState(state.submissionId), isNull);
    });

    test('should handle multiple concurrent submissions', () async {
      final state1 = manager.createNew('user_1');
      final state2 = manager.createNew('user_2');

      await manager.updateStage(state1.submissionId, SubmissionStage.videoUploaded);
      await manager.updateStage(state2.submissionId, SubmissionStage.confirmData);

      final retrieved1 = manager.getState(state1.submissionId);
      final retrieved2 = manager.getState(state2.submissionId);

      expect(retrieved1!.stage, equals(SubmissionStage.videoUploaded));
      expect(retrieved2!.stage, equals(SubmissionStage.confirmData));
    });
  });

  group('SubmissionStateManager - Error Handling', () {
    test('should handle corrupted storage data gracefully', () async {
      // Manually corrupt the storage
      await prefs.setString('submission_states', 'invalid json');

      // Should not throw and return empty list
      final states = manager.getAllActiveStates();
      expect(states, isEmpty);

      // Should be able to create new submission
      final state = manager.createNew('user_123');
      expect(state, isNotNull);
    });

    test('should handle empty storage', () {
      final states = manager.getAllActiveStates();
      expect(states, isEmpty);

      final state = manager.getState('any_id');
      expect(state, isNull);
    });
  });

  group('SubmissionStateManager - Persistence', () {
    test('should persist data across manager instances', () async {
      final state = manager.createNew('user_123');
      await manager.updateStage(state.submissionId, SubmissionStage.videoUploaded);

      // Create new manager instance with same prefs
      final newManager = SubmissionStateManager(prefs);
      final retrieved = newManager.getState(state.submissionId);

      expect(retrieved, isNotNull);
      expect(retrieved!.submissionId, equals(state.submissionId));
      expect(retrieved.stage, equals(SubmissionStage.videoUploaded));
    });
  });
}
