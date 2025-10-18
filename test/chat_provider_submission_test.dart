import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zena_mobile/models/submission_state.dart';
import 'package:zena_mobile/models/message.dart';
import 'package:zena_mobile/services/submission_state_manager.dart';

void main() {
  group('ChatProvider Submission Tracking - SubmissionStateManager', () {
    late SubmissionStateManager stateManager;

    setUp(() async {
      // Initialize SharedPreferences with mock
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      stateManager = SubmissionStateManager(prefs);
    });

    test('should start new submission', () {
      final state = stateManager.createNew('test_user_123');
      expect(state.submissionId, isNotEmpty);
      expect(state.userId, equals('test_user_123'));
      expect(state.stage, equals(SubmissionStage.start));
    });

    test('should update submission stage', () async {
      final state = stateManager.createNew('test_user_123');
      
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );
      
      final updatedState = stateManager.getState(state.submissionId);
      expect(updatedState?.stage, equals(SubmissionStage.videoUploaded));
    });

    test('should update submission video data', () async {
      final state = stateManager.createNew('test_user_123');
      
      final videoData = VideoData(
        url: 'https://example.com/video.mp4',
        publicUrl: 'https://example.com/public/video.mp4',
        duration: 120,
        quality: '1080p',
      );
      
      await stateManager.updateVideoData(state.submissionId, videoData);
      
      final updatedState = stateManager.getState(state.submissionId);
      expect(updatedState?.video, isNotNull);
      expect(updatedState?.video?.url, equals('https://example.com/video.mp4'));
      expect(updatedState?.video?.duration, equals(120));
    });

    test('should update AI extracted data', () async {
      final state = stateManager.createNew('test_user_123');
      
      final aiData = {
        'bedrooms': 2,
        'bathrooms': 2,
        'propertyType': 'apartment',
      };
      
      await stateManager.updateAIExtracted(state.submissionId, aiData);
      
      final updatedState = stateManager.getState(state.submissionId);
      expect(updatedState?.aiExtracted, isNotNull);
      expect(updatedState?.aiExtracted?['bedrooms'], equals(2));
      expect(updatedState?.aiExtracted?['propertyType'], equals('apartment'));
    });

    test('should update user provided data', () async {
      final state = stateManager.createNew('test_user_123');
      
      final userData = {
        'rent': 50000,
        'deposit': 100000,
      };
      
      await stateManager.updateUserProvided(state.submissionId, userData);
      
      final updatedState = stateManager.getState(state.submissionId);
      expect(updatedState?.userProvided, isNotNull);
      expect(updatedState?.userProvided?['rent'], equals(50000));
      expect(updatedState?.userProvided?['deposit'], equals(100000));
    });

    test('should merge user provided data', () async {
      final state = stateManager.createNew('test_user_123');
      
      // First update
      await stateManager.updateUserProvided(state.submissionId, {
        'rent': 50000,
      });
      
      // Second update - should merge
      await stateManager.updateUserProvided(state.submissionId, {
        'deposit': 100000,
      });
      
      final updatedState = stateManager.getState(state.submissionId);
      expect(updatedState?.userProvided?['rent'], equals(50000));
      expect(updatedState?.userProvided?['deposit'], equals(100000));
    });

    test('should update missing fields', () async {
      final state = stateManager.createNew('test_user_123');
      
      final missingFields = ['amenities', 'availableFrom'];
      
      await stateManager.updateMissingFields(state.submissionId, missingFields);
      
      final updatedState = stateManager.getState(state.submissionId);
      expect(updatedState?.missingFields, isNotNull);
      expect(updatedState?.missingFields?.length, equals(2));
      expect(updatedState?.missingFields, contains('amenities'));
      expect(updatedState?.missingFields, contains('availableFrom'));
    });

    test('should clear submission state', () async {
      final state = stateManager.createNew('test_user_123');
      
      // Verify state exists
      expect(stateManager.getState(state.submissionId), isNotNull);
      
      // Clear state
      await stateManager.clearState(state.submissionId);
      
      // Verify state is cleared
      expect(stateManager.getState(state.submissionId), isNull);
    });

    test('should get all active states', () async {
      final state1 = stateManager.createNew('user_1');
      await Future.delayed(const Duration(milliseconds: 10));
      final state2 = stateManager.createNew('user_2');
      
      final activeStates = stateManager.getAllActiveStates();
      
      expect(activeStates.length, equals(2));
      // Should be sorted by most recent first
      expect(activeStates[0].submissionId, equals(state2.submissionId));
      expect(activeStates[1].submissionId, equals(state1.submissionId));
    });

    test('should track complete submission lifecycle', () async {
      final state = stateManager.createNew('test_user_123');
      
      // Stage 1: Start
      expect(state.stage, equals(SubmissionStage.start));
      
      // Stage 2: Video uploaded
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.videoUploaded,
      );
      final videoData = VideoData(url: 'https://example.com/video.mp4');
      await stateManager.updateVideoData(state.submissionId, videoData);
      
      var currentState = stateManager.getState(state.submissionId);
      expect(currentState?.stage, equals(SubmissionStage.videoUploaded));
      expect(currentState?.video, isNotNull);
      
      // Stage 3: Confirm data
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.confirmData,
      );
      await stateManager.updateAIExtracted(state.submissionId, {
        'bedrooms': 2,
        'bathrooms': 2,
      });
      
      currentState = stateManager.getState(state.submissionId);
      expect(currentState?.stage, equals(SubmissionStage.confirmData));
      expect(currentState?.aiExtracted, isNotNull);
      
      // Stage 4: Provide info
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.provideInfo,
      );
      await stateManager.updateUserProvided(state.submissionId, {
        'rent': 50000,
      });
      await stateManager.updateMissingFields(
        state.submissionId,
        ['amenities'],
      );
      
      currentState = stateManager.getState(state.submissionId);
      expect(currentState?.stage, equals(SubmissionStage.provideInfo));
      expect(currentState?.userProvided, isNotNull);
      expect(currentState?.missingFields, isNotNull);
      
      // Stage 5: Final confirm
      await stateManager.updateStage(
        state.submissionId,
        SubmissionStage.finalConfirm,
      );
      
      currentState = stateManager.getState(state.submissionId);
      expect(currentState?.stage, equals(SubmissionStage.finalConfirm));
      expect(currentState?.isComplete, isTrue);
      
      // Complete and clear
      await stateManager.clearState(state.submissionId);
      expect(stateManager.getState(state.submissionId), isNull);
    });

    test('should calculate progress correctly', () {
      final state1 = SubmissionState(
        submissionId: 'test_1',
        userId: 'user_1',
        stage: SubmissionStage.start,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(state1.progress, equals(0.2)); // 1/5

      final state2 = state1.copyWith(stage: SubmissionStage.videoUploaded);
      expect(state2.progress, equals(0.4)); // 2/5

      final state3 = state1.copyWith(stage: SubmissionStage.confirmData);
      expect(state3.progress, equals(0.6)); // 3/5

      final state4 = state1.copyWith(stage: SubmissionStage.provideInfo);
      expect(state4.progress, equals(0.8)); // 4/5

      final state5 = state1.copyWith(stage: SubmissionStage.finalConfirm);
      expect(state5.progress, equals(1.0)); // 5/5
    });

    test('should merge all data correctly', () {
      final state = SubmissionState(
        submissionId: 'test_1',
        userId: 'user_1',
        stage: SubmissionStage.provideInfo,
        aiExtracted: {
          'bedrooms': 2,
          'bathrooms': 2,
        },
        userProvided: {
          'rent': 50000,
          'deposit': 100000,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final allData = state.allData;
      expect(allData['bedrooms'], equals(2));
      expect(allData['bathrooms'], equals(2));
      expect(allData['rent'], equals(50000));
      expect(allData['deposit'], equals(100000));
    });
  });

  group('ChatProvider Message Submission Context', () {
    test('should include submission context in message metadata when in workflow', () {
      // Create a message with submission context
      final metadata = <String, dynamic>{
        'submissionId': 'sub_123456',
        'workflowStage': 'SubmissionStage.confirmData',
      };

      final message = Message(
        id: 'msg_1',
        role: 'user',
        content: 'Here is my property data',
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      // Verify metadata is included
      expect(message.metadata, isNotNull);
      expect(message.submissionId, equals('sub_123456'));
      expect(message.workflowStage, equals('SubmissionStage.confirmData'));
      expect(message.isPartOfWorkflow, isTrue);
    });

    test('should not include submission context when not in workflow', () {
      final message = Message(
        id: 'msg_1',
        role: 'user',
        content: 'Regular message',
        createdAt: DateTime.now(),
      );

      // Verify no metadata
      expect(message.metadata, isNull);
      expect(message.submissionId, isNull);
      expect(message.workflowStage, isNull);
      expect(message.isPartOfWorkflow, isFalse);
    });

    test('should serialize and deserialize message with submission context', () {
      final metadata = <String, dynamic>{
        'submissionId': 'sub_123456',
        'workflowStage': 'SubmissionStage.videoUploaded',
      };

      final originalMessage = Message(
        id: 'msg_1',
        role: 'user',
        content: 'Video uploaded',
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      // Serialize to JSON
      final json = originalMessage.toJson();

      // Deserialize from JSON
      final deserializedMessage = Message.fromJson(json);

      // Verify metadata is preserved
      expect(deserializedMessage.submissionId, equals('sub_123456'));
      expect(deserializedMessage.workflowStage, equals('SubmissionStage.videoUploaded'));
      expect(deserializedMessage.isPartOfWorkflow, isTrue);
    });

    test('should handle multiple messages with different submission contexts', () {
      final message1 = Message(
        id: 'msg_1',
        role: 'user',
        content: 'First submission',
        createdAt: DateTime.now(),
        metadata: {
          'submissionId': 'sub_111',
          'workflowStage': 'SubmissionStage.start',
        },
      );

      final message2 = Message(
        id: 'msg_2',
        role: 'user',
        content: 'Second submission',
        createdAt: DateTime.now(),
        metadata: {
          'submissionId': 'sub_222',
          'workflowStage': 'SubmissionStage.confirmData',
        },
      );

      final message3 = Message(
        id: 'msg_3',
        role: 'user',
        content: 'Regular message',
        createdAt: DateTime.now(),
      );

      // Verify each message has correct context
      expect(message1.submissionId, equals('sub_111'));
      expect(message1.workflowStage, equals('SubmissionStage.start'));
      expect(message1.isPartOfWorkflow, isTrue);

      expect(message2.submissionId, equals('sub_222'));
      expect(message2.workflowStage, equals('SubmissionStage.confirmData'));
      expect(message2.isPartOfWorkflow, isTrue);

      expect(message3.submissionId, isNull);
      expect(message3.isPartOfWorkflow, isFalse);
    });

    test('should update message metadata with copyWith', () {
      final originalMessage = Message(
        id: 'msg_1',
        role: 'user',
        content: 'Original message',
        createdAt: DateTime.now(),
      );

      // Add submission context
      final updatedMessage = originalMessage.copyWith(
        metadata: {
          'submissionId': 'sub_123',
          'workflowStage': 'SubmissionStage.provideInfo',
        },
      );

      // Verify original message unchanged
      expect(originalMessage.metadata, isNull);
      expect(originalMessage.isPartOfWorkflow, isFalse);

      // Verify updated message has context
      expect(updatedMessage.submissionId, equals('sub_123'));
      expect(updatedMessage.workflowStage, equals('SubmissionStage.provideInfo'));
      expect(updatedMessage.isPartOfWorkflow, isTrue);
    });

    test('should handle metadata with additional custom fields', () {
      final metadata = <String, dynamic>{
        'submissionId': 'sub_123',
        'workflowStage': 'SubmissionStage.finalConfirm',
        'customField': 'customValue',
        'timestamp': 1697500000,
      };

      final message = Message(
        id: 'msg_1',
        role: 'user',
        content: 'Message with custom metadata',
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      // Verify submission context
      expect(message.submissionId, equals('sub_123'));
      expect(message.workflowStage, equals('SubmissionStage.finalConfirm'));
      expect(message.isPartOfWorkflow, isTrue);

      // Verify custom fields preserved
      expect(message.metadata?['customField'], equals('customValue'));
      expect(message.metadata?['timestamp'], equals(1697500000));
    });
  });
}
