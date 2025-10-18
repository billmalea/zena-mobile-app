import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/models/submission_state.dart';

void main() {
  group('VideoData', () {
    test('should serialize to JSON correctly', () {
      final videoData = VideoData(
        url: 'https://example.com/video.mp4',
        publicUrl: 'https://example.com/public/video.mp4',
        analysisResults: {'bedrooms': 2, 'bathrooms': 1},
        duration: 120,
        quality: '1080p',
      );

      final json = videoData.toJson();

      expect(json['url'], 'https://example.com/video.mp4');
      expect(json['publicUrl'], 'https://example.com/public/video.mp4');
      expect(json['analysisResults'], {'bedrooms': 2, 'bathrooms': 1});
      expect(json['duration'], 120);
      expect(json['quality'], '1080p');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'url': 'https://example.com/video.mp4',
        'publicUrl': 'https://example.com/public/video.mp4',
        'analysisResults': {'bedrooms': 2, 'bathrooms': 1},
        'duration': 120,
        'quality': '1080p',
      };

      final videoData = VideoData.fromJson(json);

      expect(videoData.url, 'https://example.com/video.mp4');
      expect(videoData.publicUrl, 'https://example.com/public/video.mp4');
      expect(videoData.analysisResults, {'bedrooms': 2, 'bathrooms': 1});
      expect(videoData.duration, 120);
      expect(videoData.quality, '1080p');
    });

    test('should handle null optional fields', () {
      final videoData = VideoData(url: 'https://example.com/video.mp4');

      final json = videoData.toJson();
      final deserialized = VideoData.fromJson(json);

      expect(deserialized.url, 'https://example.com/video.mp4');
      expect(deserialized.publicUrl, null);
      expect(deserialized.analysisResults, null);
      expect(deserialized.duration, null);
      expect(deserialized.quality, null);
    });

    test('copyWith should update specified fields', () {
      final original = VideoData(url: 'https://example.com/video.mp4');
      final updated = original.copyWith(
        publicUrl: 'https://example.com/public/video.mp4',
        duration: 120,
      );

      expect(updated.url, 'https://example.com/video.mp4');
      expect(updated.publicUrl, 'https://example.com/public/video.mp4');
      expect(updated.duration, 120);
      expect(updated.analysisResults, null);
    });
  });

  group('SubmissionState', () {
    final testDate = DateTime(2025, 10, 18, 12, 0, 0);

    test('should serialize to JSON correctly', () {
      final videoData = VideoData(
        url: 'https://example.com/video.mp4',
        duration: 120,
      );

      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user_456',
        stage: SubmissionStage.confirmData,
        video: videoData,
        aiExtracted: {'bedrooms': 2, 'bathrooms': 1},
        userProvided: {'rent': 50000},
        missingFields: ['amenities', 'availableFrom'],
        createdAt: testDate,
        updatedAt: testDate,
      );

      final json = state.toJson();

      expect(json['submissionId'], 'sub_123');
      expect(json['userId'], 'user_456');
      expect(json['stage'], 'confirmData');
      expect(json['video'], isNotNull);
      expect(json['aiExtracted'], {'bedrooms': 2, 'bathrooms': 1});
      expect(json['userProvided'], {'rent': 50000});
      expect(json['missingFields'], ['amenities', 'availableFrom']);
      expect(json['createdAt'], testDate.toIso8601String());
      expect(json['updatedAt'], testDate.toIso8601String());
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'submissionId': 'sub_123',
        'userId': 'user_456',
        'stage': 'confirmData',
        'video': {
          'url': 'https://example.com/video.mp4',
          'duration': 120,
        },
        'aiExtracted': {'bedrooms': 2, 'bathrooms': 1},
        'userProvided': {'rent': 50000},
        'missingFields': ['amenities', 'availableFrom'],
        'createdAt': testDate.toIso8601String(),
        'updatedAt': testDate.toIso8601String(),
      };

      final state = SubmissionState.fromJson(json);

      expect(state.submissionId, 'sub_123');
      expect(state.userId, 'user_456');
      expect(state.stage, SubmissionStage.confirmData);
      expect(state.video, isNotNull);
      expect(state.video!.url, 'https://example.com/video.mp4');
      expect(state.aiExtracted, {'bedrooms': 2, 'bathrooms': 1});
      expect(state.userProvided, {'rent': 50000});
      expect(state.missingFields, ['amenities', 'availableFrom']);
      expect(state.createdAt, testDate);
      expect(state.updatedAt, testDate);
    });

    test('should handle null optional fields', () {
      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user_456',
        stage: SubmissionStage.start,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final json = state.toJson();
      final deserialized = SubmissionState.fromJson(json);

      expect(deserialized.submissionId, 'sub_123');
      expect(deserialized.userId, 'user_456');
      expect(deserialized.stage, SubmissionStage.start);
      expect(deserialized.video, null);
      expect(deserialized.aiExtracted, null);
      expect(deserialized.userProvided, null);
      expect(deserialized.missingFields, null);
    });

    test('copyWith should update specified fields', () {
      final original = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user_456',
        stage: SubmissionStage.start,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final updated = original.copyWith(
        stage: SubmissionStage.videoUploaded,
        video: VideoData(url: 'https://example.com/video.mp4'),
      );

      expect(updated.submissionId, 'sub_123');
      expect(updated.userId, 'user_456');
      expect(updated.stage, SubmissionStage.videoUploaded);
      expect(updated.video, isNotNull);
      expect(updated.video!.url, 'https://example.com/video.mp4');
    });

    test('progress should calculate correctly for each stage', () {
      final stages = [
        SubmissionStage.start,
        SubmissionStage.videoUploaded,
        SubmissionStage.confirmData,
        SubmissionStage.provideInfo,
        SubmissionStage.finalConfirm,
      ];

      for (var i = 0; i < stages.length; i++) {
        final state = SubmissionState(
          submissionId: 'sub_123',
          userId: 'user_456',
          stage: stages[i],
          createdAt: testDate,
          updatedAt: testDate,
        );

        final expectedProgress = (i + 1) / stages.length;
        expect(state.progress, expectedProgress);
      }
    });

    test('isComplete should return true only for finalConfirm stage', () {
      final stages = [
        SubmissionStage.start,
        SubmissionStage.videoUploaded,
        SubmissionStage.confirmData,
        SubmissionStage.provideInfo,
        SubmissionStage.finalConfirm,
      ];

      for (var stage in stages) {
        final state = SubmissionState(
          submissionId: 'sub_123',
          userId: 'user_456',
          stage: stage,
          createdAt: testDate,
          updatedAt: testDate,
        );

        if (stage == SubmissionStage.finalConfirm) {
          expect(state.isComplete, true);
        } else {
          expect(state.isComplete, false);
        }
      }
    });

    test('allData should merge aiExtracted and userProvided', () {
      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user_456',
        stage: SubmissionStage.provideInfo,
        aiExtracted: {'bedrooms': 2, 'bathrooms': 1, 'location': 'Westlands'},
        userProvided: {'rent': 50000, 'bedrooms': 3}, // Override bedrooms
        createdAt: testDate,
        updatedAt: testDate,
      );

      final allData = state.allData;

      expect(allData['bedrooms'], 3); // userProvided overrides aiExtracted
      expect(allData['bathrooms'], 1);
      expect(allData['location'], 'Westlands');
      expect(allData['rent'], 50000);
    });

    test('allData should handle null aiExtracted and userProvided', () {
      final state = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user_456',
        stage: SubmissionStage.start,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final allData = state.allData;

      expect(allData, isEmpty);
    });

    test('should round-trip through JSON serialization', () {
      final original = SubmissionState(
        submissionId: 'sub_123',
        userId: 'user_456',
        stage: SubmissionStage.confirmData,
        video: VideoData(
          url: 'https://example.com/video.mp4',
          publicUrl: 'https://example.com/public/video.mp4',
          analysisResults: {'bedrooms': 2},
          duration: 120,
          quality: '1080p',
        ),
        aiExtracted: {'bedrooms': 2, 'bathrooms': 1},
        userProvided: {'rent': 50000},
        missingFields: ['amenities'],
        createdAt: testDate,
        updatedAt: testDate,
      );

      final json = original.toJson();
      final deserialized = SubmissionState.fromJson(json);

      expect(deserialized.submissionId, original.submissionId);
      expect(deserialized.userId, original.userId);
      expect(deserialized.stage, original.stage);
      expect(deserialized.video!.url, original.video!.url);
      expect(deserialized.video!.publicUrl, original.video!.publicUrl);
      expect(deserialized.video!.duration, original.video!.duration);
      expect(deserialized.video!.quality, original.video!.quality);
      expect(deserialized.aiExtracted, original.aiExtracted);
      expect(deserialized.userProvided, original.userProvided);
      expect(deserialized.missingFields, original.missingFields);
      expect(deserialized.createdAt, original.createdAt);
      expect(deserialized.updatedAt, original.updatedAt);
    });
  });

  group('SubmissionStage', () {
    test('should have all expected stages', () {
      expect(SubmissionStage.values.length, 5);
      expect(SubmissionStage.values, contains(SubmissionStage.start));
      expect(SubmissionStage.values, contains(SubmissionStage.videoUploaded));
      expect(SubmissionStage.values, contains(SubmissionStage.confirmData));
      expect(SubmissionStage.values, contains(SubmissionStage.provideInfo));
      expect(SubmissionStage.values, contains(SubmissionStage.finalConfirm));
    });
  });
}
