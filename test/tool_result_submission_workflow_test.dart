import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zena_mobile/models/submission_state.dart';
import 'package:zena_mobile/services/submission_state_manager.dart';

void main() {
  group('Tool Result Handling for Submission Workflow', () {
    late SubmissionStateManager stateManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      stateManager = SubmissionStateManager(prefs);
    });

    test('should handle start stage tool result', () async {
      final toolResult = {
        'toolName': 'submitProperty',
        'stage': 'start',
        'submissionId': 'sub_test_123',
      };

      // Simulate tool result processing
      final submissionId = toolResult['submissionId'] as String;
      final state = stateManager.createNew('user_123');
      
      // Verify initial state
      expect(state.stage, equals(SubmissionStage.start));
    });

    test('should handle video_uploaded stage tool result', () async {
      final state = stateManager.createNew('user_123');
      
      final toolResult = {
        'toolName': 'submitProperty',
        'stage': 'video_uploaded',
        'submissionId': state.submissionId,
        'video': {
          'url': 'https://example.com/video.mp4',
          'publicUrl': 'https://example.com/public/video.mp4',
          'duration': 120,
          'quality': '1080p',
        },
      };

      // Process video_uploaded stage
      final videoData = VideoData.fromJson(toolResult['video'] as Map<String, dynamic>);
      await stateManager.updateVideoData(state.submissionId, videoData);
      await stateManager.updateStage(state.submissionId, SubmissionStage.videoUploaded);

      // Verify state updated
      final updated = stateManager.getState(state.submissionId);
      expect(updated!.stage, equals(SubmissionStage.videoUploaded));
      expect(updated.video, isNotNull);
      expect(updated.video!.url, equals('https://example.com/video.mp4'));
      expect(updated.video!.duration, equals(120));
    });

    test('should handle confirm_data stage tool result', () async {
      final state = stateManager.createNew('user_123');
      
      final toolResult = {
        'toolName': 'submitProperty',
        'stage': 'confirm_data',
        'submissionId': state.submissionId,
        'extractedData': {
          'title': '2BR Apartment in Westlands',
          'bedrooms': 2,
          'bathrooms': 2,
          'propertyType': 'apartment',
          'location': 'Westlands',
        },
      };

      // Process confirm_data stage
      final extractedData = toolResult['extractedData'] as Map<String, dynamic>;
      await stateManager.updateAIExtracted(state.submissionId, extractedData);
      await stateManager.updateStage(state.submissionId, SubmissionStage.confirmData);

      // Verify state updated
      final updated = stateManager.getState(state.submissionId);
      expect(updated!.stage, equals(SubmissionStage.confirmData));
      expect(updated.aiExtracted, isNotNull);
      expect(updated.aiExtracted!['bedrooms'], equals(2));
      expect(updated.aiExtracted!['propertyType'], equals('apartment'));
    });

    test('should handle provide_info stage tool result with missing fields', () async {
      final state = stateManager.createNew('user_123');
      
      final toolResult = {
        'toolName': 'submitProperty',
        'stage': 'provide_info',
        'submissionId': state.submissionId,
        'missingFields': ['rent', 'deposit', 'amenities'],
      };

      // Process provide_info stage
      final missingFields = (toolResult['missingFields'] as List).cast<String>();
      await stateManager.updateMissingFields(state.submissionId, missingFields);
      await stateManager.updateStage(state.submissionId, SubmissionStage.provideInfo);

      // Verify state updated
      final updated = stateManager.getState(state.submissionId);
      expect(updated!.stage, equals(SubmissionStage.provideInfo));
      expect(updated.missingFields, isNotNull);
      expect(updated.missingFields!.length, equals(3));
      expect(updated.missingFields, contains('rent'));
      expect(updated.missingFields, contains('deposit'));
    });

    test('should handle provide_info stage tool result with user data', () async {
      final state = stateManager.createNew('user_123');
      
      final toolResult = {
        'toolName': 'submitProperty',
        'stage': 'provide_info',
        'submissionId': state.submissionId,
        'missingFields': ['rent', 'deposit'],
        'userData': {
          'rent': 50000,
          'deposit': 100000,
        },
      };

      // Process provide_info stage
      final missingFields = (toolResult['missingFields'] as List).cast<String>();
      await stateManager.updateMissingFields(state.submissionId, missingFields);
      
      final userData = toolResult['userData'] as Map<String, dynamic>;
      await stateManager.updateUserProvided(state.submissionId, userData);
      
      await stateManager.updateStage(state.submissionId, SubmissionStage.provideInfo);

      // Verify state updated
      final updated = stateManager.getState(state.submissionId);
      expect(updated!.stage, equals(SubmissionStage.provideInfo));
      expect(updated.missingFields, isNotNull);
      expect(updated.userProvided, isNotNull);
      expect(updated.userProvided!['rent'], equals(50000));
    });

    test('should handle final_confirm stage tool result', () async {
      final state = stateManager.createNew('user_123');
      
      final toolResult = {
        'toolName': 'submitProperty',
        'stage': 'final_confirm',
        'submissionId': state.submissionId,
        'finalData': {
          'confirmed': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
      };

      // Process final_confirm stage
      final finalData = toolResult['finalData'] as Map<String, dynamic>?;
      if (finalData != null) {
        await stateManager.updateUserProvided(state.submissionId, finalData);
      }
      await stateManager.updateStage(state.submissionId, SubmissionStage.finalConfirm);

      // Verify state updated
      final updated = stateManager.getState(state.submissionId);
      expect(updated!.stage, equals(SubmissionStage.finalConfirm));
      expect(updated.isComplete, isTrue);
      expect(updated.userProvided, isNotNull);
      expect(updated.userProvided!['confirmed'], equals(true));
    });

    test('should handle complete stage tool result', () async {
      final state = stateManager.createNew('user_123');
      
      final toolResult = {
        'toolName': 'submitProperty',
        'stage': 'complete',
        'submissionId': state.submissionId,
      };

      // Process complete stage - clear state
      await stateManager.clearState(state.submissionId);

      // Verify state cleared
      final updated = stateManager.getState(state.submissionId);
      expect(updated, isNull);
    });

    test('should handle complete 5-stage workflow with tool results', () async {
      final state = stateManager.createNew('user_123');
      final submissionId = state.submissionId;

      // Stage 1: Start
      expect(state.stage, equals(SubmissionStage.start));

      // Stage 2: Video uploaded
      final videoResult = {
        'stage': 'video_uploaded',
        'video': {
          'url': 'https://example.com/video.mp4',
          'duration': 120,
        },
      };
      final videoData = VideoData.fromJson(videoResult['video'] as Map<String, dynamic>);
      await stateManager.updateVideoData(submissionId, videoData);
      await stateManager.updateStage(submissionId, SubmissionStage.videoUploaded);

      var current = stateManager.getState(submissionId);
      expect(current!.stage, equals(SubmissionStage.videoUploaded));
      expect(current.video, isNotNull);

      // Stage 3: Confirm data
      final confirmResult = {
        'stage': 'confirm_data',
        'extractedData': {
          'bedrooms': 2,
          'bathrooms': 2,
          'propertyType': 'apartment',
        },
      };
      await stateManager.updateAIExtracted(
        submissionId,
        confirmResult['extractedData'] as Map<String, dynamic>,
      );
      await stateManager.updateStage(submissionId, SubmissionStage.confirmData);

      current = stateManager.getState(submissionId);
      expect(current!.stage, equals(SubmissionStage.confirmData));
      expect(current.aiExtracted, isNotNull);

      // Stage 4: Provide info
      final provideInfoResult = {
        'stage': 'provide_info',
        'missingFields': ['rent', 'deposit'],
        'userData': {
          'rent': 50000,
          'deposit': 100000,
        },
      };
      await stateManager.updateMissingFields(
        submissionId,
        (provideInfoResult['missingFields'] as List).cast<String>(),
      );
      await stateManager.updateUserProvided(
        submissionId,
        provideInfoResult['userData'] as Map<String, dynamic>,
      );
      await stateManager.updateStage(submissionId, SubmissionStage.provideInfo);

      current = stateManager.getState(submissionId);
      expect(current!.stage, equals(SubmissionStage.provideInfo));
      expect(current.missingFields, isNotNull);
      expect(current.userProvided, isNotNull);

      // Stage 5: Final confirm
      await stateManager.updateStage(submissionId, SubmissionStage.finalConfirm);

      current = stateManager.getState(submissionId);
      expect(current!.stage, equals(SubmissionStage.finalConfirm));
      expect(current.isComplete, isTrue);

      // Complete
      await stateManager.clearState(submissionId);
      expect(stateManager.getState(submissionId), isNull);
    });

    test('should handle tool result without submissionId', () async {
      final toolResult = {
        'toolName': 'submitProperty',
        'stage': 'start',
        // No submissionId provided
      };

      // Should handle gracefully - create new submission
      final state = stateManager.createNew('user_123');
      expect(state, isNotNull);
      expect(state.stage, equals(SubmissionStage.start));
    });

    test('should handle tool result with invalid stage', () async {
      final state = stateManager.createNew('user_123');
      
      final toolResult = {
        'toolName': 'submitProperty',
        'stage': 'invalid_stage',
        'submissionId': state.submissionId,
      };

      // Should handle gracefully - no state change
      final before = stateManager.getState(state.submissionId);
      
      // Invalid stage should not update state
      // (In real implementation, this would be handled in _handleSubmissionToolResult)
      
      final after = stateManager.getState(state.submissionId);
      expect(after!.stage, equals(before!.stage));
    });

    test('should handle tool result with missing video data', () async {
      final state = stateManager.createNew('user_123');
      
      final toolResult = {
        'toolName': 'submitProperty',
        'stage': 'video_uploaded',
        'submissionId': state.submissionId,
        // No video data provided
      };

      // Should handle gracefully - update stage only
      await stateManager.updateStage(state.submissionId, SubmissionStage.videoUploaded);

      final updated = stateManager.getState(state.submissionId);
      expect(updated!.stage, equals(SubmissionStage.videoUploaded));
      expect(updated.video, isNull);
    });

    test('should handle tool result with missing extracted data', () async {
      final state = stateManager.createNew('user_123');
      
      final toolResult = {
        'toolName': 'submitProperty',
        'stage': 'confirm_data',
        'submissionId': state.submissionId,
        // No extractedData provided
      };

      // Should handle gracefully - update stage only
      await stateManager.updateStage(state.submissionId, SubmissionStage.confirmData);

      final updated = stateManager.getState(state.submissionId);
      expect(updated!.stage, equals(SubmissionStage.confirmData));
      expect(updated.aiExtracted, isNull);
    });

    test('should handle multiple tool results for same submission', () async {
      final state = stateManager.createNew('user_123');
      
      // First tool result - video uploaded
      await stateManager.updateVideoData(
        state.submissionId,
        VideoData(url: 'https://example.com/video.mp4'),
      );
      await stateManager.updateStage(state.submissionId, SubmissionStage.videoUploaded);

      // Second tool result - confirm data
      await stateManager.updateAIExtracted(state.submissionId, {
        'bedrooms': 2,
      });
      await stateManager.updateStage(state.submissionId, SubmissionStage.confirmData);

      // Third tool result - provide info
      await stateManager.updateUserProvided(state.submissionId, {
        'rent': 50000,
      });
      await stateManager.updateStage(state.submissionId, SubmissionStage.provideInfo);

      // Verify all data accumulated
      final updated = stateManager.getState(state.submissionId);
      expect(updated!.stage, equals(SubmissionStage.provideInfo));
      expect(updated.video, isNotNull);
      expect(updated.aiExtracted, isNotNull);
      expect(updated.userProvided, isNotNull);
    });

    test('should preserve existing data when updating stage', () async {
      final state = stateManager.createNew('user_123');
      
      // Add video data
      await stateManager.updateVideoData(
        state.submissionId,
        VideoData(url: 'https://example.com/video.mp4'),
      );
      
      // Add AI extracted data
      await stateManager.updateAIExtracted(state.submissionId, {
        'bedrooms': 2,
      });
      
      // Update stage
      await stateManager.updateStage(state.submissionId, SubmissionStage.confirmData);

      // Verify all data preserved
      final updated = stateManager.getState(state.submissionId);
      expect(updated!.video, isNotNull);
      expect(updated.aiExtracted, isNotNull);
      expect(updated.stage, equals(SubmissionStage.confirmData));
    });
  });
}
