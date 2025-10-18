import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/models/message.dart';

void main() {
  group('Message Model - Metadata Tests', () {
    test('should create message with metadata', () {
      final metadata = {
        'submissionId': 'sub_123',
        'workflowStage': 'confirmData',
      };

      final message = Message(
        id: 'msg_1',
        role: 'user',
        content: 'Test message',
        createdAt: DateTime(2025, 10, 18),
        metadata: metadata,
      );

      expect(message.metadata, equals(metadata));
      expect(message.submissionId, equals('sub_123'));
      expect(message.workflowStage, equals('confirmData'));
      expect(message.isPartOfWorkflow, isTrue);
    });

    test('should create message without metadata', () {
      final message = Message(
        id: 'msg_1',
        role: 'user',
        content: 'Test message',
        createdAt: DateTime(2025, 10, 18),
      );

      expect(message.metadata, isNull);
      expect(message.submissionId, isNull);
      expect(message.workflowStage, isNull);
      expect(message.isPartOfWorkflow, isFalse);
    });

    test('should serialize message with metadata to JSON', () {
      final metadata = {
        'submissionId': 'sub_123',
        'workflowStage': 'confirmData',
      };

      final message = Message(
        id: 'msg_1',
        role: 'user',
        content: 'Test message',
        createdAt: DateTime(2025, 10, 18, 10, 30),
        metadata: metadata,
      );

      final json = message.toJson();

      expect(json['id'], equals('msg_1'));
      expect(json['role'], equals('user'));
      expect(json['content'], equals('Test message'));
      expect(json['createdAt'], equals('2025-10-18T10:30:00.000'));
      expect(json['metadata'], equals(metadata));
      expect(json['metadata']['submissionId'], equals('sub_123'));
      expect(json['metadata']['workflowStage'], equals('confirmData'));
    });

    test('should serialize message without metadata to JSON', () {
      final message = Message(
        id: 'msg_1',
        role: 'user',
        content: 'Test message',
        createdAt: DateTime(2025, 10, 18, 10, 30),
      );

      final json = message.toJson();

      expect(json['id'], equals('msg_1'));
      expect(json['role'], equals('user'));
      expect(json['content'], equals('Test message'));
      expect(json['createdAt'], equals('2025-10-18T10:30:00.000'));
      expect(json['metadata'], isNull);
    });

    test('should deserialize message with metadata from JSON', () {
      final json = {
        'id': 'msg_1',
        'role': 'user',
        'content': 'Test message',
        'createdAt': '2025-10-18T10:30:00.000',
        'metadata': {
          'submissionId': 'sub_123',
          'workflowStage': 'confirmData',
        },
      };

      final message = Message.fromJson(json);

      expect(message.id, equals('msg_1'));
      expect(message.role, equals('user'));
      expect(message.content, equals('Test message'));
      expect(message.createdAt, equals(DateTime(2025, 10, 18, 10, 30)));
      expect(message.metadata, isNotNull);
      expect(message.submissionId, equals('sub_123'));
      expect(message.workflowStage, equals('confirmData'));
      expect(message.isPartOfWorkflow, isTrue);
    });

    test('should deserialize message without metadata from JSON', () {
      final json = {
        'id': 'msg_1',
        'role': 'user',
        'content': 'Test message',
        'createdAt': '2025-10-18T10:30:00.000',
      };

      final message = Message.fromJson(json);

      expect(message.id, equals('msg_1'));
      expect(message.role, equals('user'));
      expect(message.content, equals('Test message'));
      expect(message.createdAt, equals(DateTime(2025, 10, 18, 10, 30)));
      expect(message.metadata, isNull);
      expect(message.submissionId, isNull);
      expect(message.workflowStage, isNull);
      expect(message.isPartOfWorkflow, isFalse);
    });

    test('should round-trip serialize and deserialize with metadata', () {
      final originalMetadata = {
        'submissionId': 'sub_456',
        'workflowStage': 'provideInfo',
        'customField': 'customValue',
      };

      final originalMessage = Message(
        id: 'msg_2',
        role: 'assistant',
        content: 'AI response',
        createdAt: DateTime(2025, 10, 18, 11, 45),
        metadata: originalMetadata,
      );

      final json = originalMessage.toJson();
      final deserializedMessage = Message.fromJson(json);

      expect(deserializedMessage.id, equals(originalMessage.id));
      expect(deserializedMessage.role, equals(originalMessage.role));
      expect(deserializedMessage.content, equals(originalMessage.content));
      expect(deserializedMessage.createdAt, equals(originalMessage.createdAt));
      expect(deserializedMessage.metadata, equals(originalMetadata));
      expect(deserializedMessage.submissionId, equals('sub_456'));
      expect(deserializedMessage.workflowStage, equals('provideInfo'));
      expect(deserializedMessage.isPartOfWorkflow, isTrue);
    });

    test('should copy message with updated metadata', () {
      final originalMessage = Message(
        id: 'msg_1',
        role: 'user',
        content: 'Test message',
        createdAt: DateTime(2025, 10, 18),
        metadata: {'submissionId': 'sub_123'},
      );

      final updatedMetadata = {
        'submissionId': 'sub_123',
        'workflowStage': 'finalConfirm',
      };

      final copiedMessage = originalMessage.copyWith(
        metadata: updatedMetadata,
      );

      expect(copiedMessage.id, equals(originalMessage.id));
      expect(copiedMessage.role, equals(originalMessage.role));
      expect(copiedMessage.content, equals(originalMessage.content));
      expect(copiedMessage.metadata, equals(updatedMetadata));
      expect(copiedMessage.submissionId, equals('sub_123'));
      expect(copiedMessage.workflowStage, equals('finalConfirm'));
    });

    test('should handle metadata with various data types', () {
      final metadata = {
        'submissionId': 'sub_789',
        'workflowStage': 'start',
        'stepNumber': 1,
        'isComplete': false,
        'tags': ['property', 'submission'],
        'nestedData': {
          'key1': 'value1',
          'key2': 123,
        },
      };

      final message = Message(
        id: 'msg_3',
        role: 'user',
        content: 'Complex metadata test',
        createdAt: DateTime(2025, 10, 18),
        metadata: metadata,
      );

      final json = message.toJson();
      final deserializedMessage = Message.fromJson(json);

      expect(deserializedMessage.metadata, equals(metadata));
      expect(deserializedMessage.metadata!['stepNumber'], equals(1));
      expect(deserializedMessage.metadata!['isComplete'], equals(false));
      expect(deserializedMessage.metadata!['tags'], equals(['property', 'submission']));
      expect(deserializedMessage.metadata!['nestedData']['key1'], equals('value1'));
    });
  });
}
